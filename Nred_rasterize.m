
%%%%%%%%%%%%%%%%%%%%%%
%%    KEY SCRIPT    %%
%%%%%%%%%%%%%%%%%%%%%%
%v0.2 03/18/2021
%Videos registration
%Makes raster with the Hox5 project paramters
%Export example traces of Hox5 and control cells

%%%%%%  CHOOSE INPUT FILE
clear all
[filename,pathname] = uigetfile({'*_ALL_CELLS.mat';'*_ALL_CELLS.MAT'},'Open file with fluorescence time series', 'MultiSelect', 'off');
filenameALL_CELLS=fullfile(pathname,filename);

cut=strfind(filenameALL_CELLS,'_ALL_CELLS.mat');
filenameARTIFACTS=[filenameALL_CELLS(1:cut-1) '_ARTIFACTS.mat'];
load(filenameARTIFACTS);

%%
%%%%%%  PARAMETERS
plotFlag=0;
prompt = {'Frequency of imaging (frames per second, Hz)','Fluorescence decay time constant of reporter (\tau , seconds)'};
dlg_title = 'Imaging parameters';
num_lines = 1;
def = {'4','3.5'};

%Reference for tau decay
%https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4710481/
%? H2B?GCaMP6s =3.5±0.7s(std)

opts.Interpreter='tex';% x=1:size(raster,1);
answer = inputdlg(prompt,dlg_title,num_lines,def,opts);
params.fps= str2num(answer{1});
params.tauDecay=str2num(answer{2});

plotFlag=0;
prompt = {'Minimal number of pixels per ROI','Minimal ROI fluorescence relative to baseline level (%)','Maximal sudden decrease in ROI baseline fluorescence (z-score of baseline fluorescence variations)'};
dlg_title = 'Parameters for control of data sanity';
num_lines = 1;
def = {'5','25','-4'};

answer = inputdlg(prompt,dlg_title,num_lines,def);
params.cutOffPixels= str2num(answer{1});
params.cutOffIntensity= str2num(answer{2});
params.cutOffDev= str2num(answer{3});

%%
data=load(filenameALL_CELLS);
imageAvg=data.avg;
cut=strfind(filenameALL_CELLS,'_ALL_CELLS.mat');
outputFile=[filenameALL_CELLS(1:cut-1) '_RASTER.mat'];

ansMethod = questdlg('Subtract the fluorescence from surrounding neuropile?', 'Neuropile fluorescence contamination correction', 'Yes','No','Yes');
params.neuropileSubtraction=ansMethod;
if strcmp(params.neuropileSubtraction,'Yes')
    prompt = {'Set the coefficient \alpha (0 to 1) for neuropile subtraction (Fcorrected = F - \alpha * Fneuropile)'};
    dlg_title = 'Set neuropile correction';
    num_lines = 1;
    def = {'0.4'};
    opts.Interpreter='tex';
    answer = inputdlg(prompt,dlg_title,num_lines,def,opts);
    params.alpha= str2num(answer{1});
    
end

ansMethod = questdlg('Choose method to estimate baseline fluorescence', 'Baseline fluorescence (F0) calculation', 'Average fluorescence on time window','Smooth slow dynamics','Average fluorescence on time window');
params.fluoBaselineCalculation.Method=ansMethod;

if strcmp(params.fluoBaselineCalculation.Method,'Average fluorescence on time window')
    prompt = {'Select t0 (in seconds)','Select t1 (in seconds)'};
    dlg_title = 'Select time window (from t0 to t1) for calculation of F0 ';
    num_lines = 1;
    def = {'0','5'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    params.fluoBaselineCalculation.t0= str2num(answer{1});
    params.fluoBaselineCalculation.t1= str2num(answer{2});
    
end

%%
disp('Step 1: Sanity test for ROIs and calculation relative fluorescence variation.')
[fluoTraces,F0,smoothBaseline,deletedCells,ROIRed]=SanityTest(filenameALL_CELLS,params,data.ROIRed);
deltaFoF=(fluoTraces-F0)./F0;

%%
disp('Step 2: Calculation of noise level in baseline fluorescence ROIs.')
[deltaFoF, mu, sigma, params]=EstimateBaselineNoise(filenameALL_CELLS, deltaFoF, params);
deltaFoF(logical(movements),:)=NaN;

ansMethod = questdlg('Choose method for detection on significant trasients', 'Select method', 'Static threshold', 'Dynamic threshold', 'Import data','Static threshold');
params.methodSignificatTransients=ansMethod;

%%
disp('Step 3: Detection of significant fluorescence transients.')
if strcmp(ansMethod,'Static threshold')
    prompt = {'Minimal \DeltaF/F0 * 1/\sigma of significant ROI fluorescence transient'};
    dlg_title = 'Parameters for inference signinficant fluorescence transients';
    num_lines = 1;
    def = {'3'};
    opts.Interpreter='tex';
    answer = inputdlg(prompt,dlg_title,num_lines,def,opts);
    params.deltaFoFCutOff= str2num(answer{1});
    
    disp('Step 3.1: Producing raster plot.')
    raster=double(bsxfun(@gt,deltaFoF,params.deltaFoFCutOff*sigma+mu));
    
    disp('Step 3.2: Saving and quitting.')
    save(outputFile,'raster', 'params','deltaFoF', 'deletedCells','movements', 'mu', 'sigma','imageAvg', 'F0');
    
elseif strcmp(ansMethod,'Dynamic threshold')
    
    prompt = {'Minimal cofindence that ROI fluorescence transient is not noise (%)'};
    dlg_title = 'Parameter for inference signinficant fluorescence transients';
    num_lines = 1;
    
    def = {'95'};
    opts.Interpreter='tex';
    answer = inputdlg(prompt,dlg_title,num_lines,def,opts);
    
    params.confCutOff= str2num(answer{1});
    
    disp('Step 3.1: Estimating noise model.')
    [densityData, densityNoise, xev, yev] = NoiseModel(filenameALL_CELLS, deltaFoF, sigma, movements, plotFlag);
    [mapOfOdds] = SignificantOdds(deltaFoF, sigma, movements, densityData, densityNoise, xev, params, plotFlag);
    
    disp('Step 3.2: Producing raster plot.')
    [raster, mapOfOddsJoint]=Rasterize(deltaFoF, sigma, movements, mapOfOdds, xev, yev, params);
    
    disp('Step 3.1: Saving and quitting.')
    save(outputFile,'raster', 'params','deltaFoF', 'deletedCells','movements', 'mu', 'sigma', 'mapOfOdds', 'mapOfOddsJoint', 'xev', 'yev', 'densityData', 'densityNoise','imageAvg', 'F0','ROIRed');
    
elseif strcmp(ansMethod,'Import data')
    [filename,pathname] = uigetfile({'*.mat';'*.MAT'},'Open file with data to import', 'MultiSelect', 'off');
    dataImport=load(fullfile(pathname,filename));
    raster=dataImport.significantTransients;
    
    disp('Step 3.1: Saving and quitting.')
    save(outputFile,'raster', 'params','deltaFoF', 'deletedCells','movements', 'mu', 'sigma','imageAvg', 'F0');
end

%Export the cell's traces including the ROIRed cells of interest 
ansPlot = questdlg('Plot examples of significant fluorescent traces?', 'Plot results', 'Yes','No','Yes');

if strcmp(ansPlot,'Yes')
    ansContinue='Yes';
    alreadyPlot=[];
    [a,b]=sort(nansum(raster),'descend');
    t=linspace(0,(size(raster,1)-1)/params.fps,size(raster,1));
    z=zeros(size(t));
    while strcmp(ansContinue,'Yes')
        
        prompt = {'Number of traces per plot','\DeltaF/F0 plot scale'};
        dlg_title = 'Plot parameters';
        num_lines = 1;
        
        def = {'20','3'};
        opts.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,opts);
        
        totalPlot= str2num(answer{1});
        scalePlot= str2num(answer{2});
        numPlotCells=1:totalPlot;
        
        %Add the identified Hox5 cells to the plot
        bROIred=[b(numPlotCells) ROIRed]
        
        y=bsxfun(@plus,deltaFoF(:,bROIred),scalePlot*[1:size(deltaFoF(:,bROIred),2)]);
        col = raster(:,[b(numPlotCells) data.ROIRed]);
        figure; hold on
        for i=1:size(col,2)
            surface([t(1:end-1);t(1:end-1)],[i;i],[y(1:end-1,i)';y(1:end-1,i)'],[col(1:end-1,i)';col(1:end-1,i)'],'facecol','no','edgecol','interp','linew',1);
        end
        posBar=t(end)*1.05;
        plot3([posBar;posBar],[1;1],[1;1+scalePlot],'k','linewidth',5);
        colormap([0 0 0; 1 0 0])
        xlim([t(1) t(end)*1.07]); xlabel('Time (s)')
        set(gca,'View', [0 40],'ycolor','w','zcolor','w','TickLength',[.01; .01])
        h=text(posBar+5,1,1,[num2str(scalePlot) ' \DeltaF/F0']);
        set(h, 'rotation', 90)
        
        %Add Hox5 mention to the left label in the plot
        for cells_idx=1:length(numPlotCells)+length(ROIRed)
           if cells_idx<=length(numPlotCells)
            str_plot{cells_idx}=num2str(bROIred(cells_idx)); 
           else
               str_plot{cells_idx}=['hox5_' num2str(bROIred(cells_idx))]
           end 
        end    
        for i=1:size(col,2)
            %Hox5/control label
            l=text(t(1)-25,i,scalePlot*i,str_plot{i}); set(l, 'Interpreter', 'none')
        end
        %Export the traces
        export_path=[filenameALL_CELLS(1:cut-1) '_Traces.pdf']
        export_fig(export_path, '-pdf', '-painters','-nofontswap');
        
        ansContinue = questdlg('Continue with more traces?', 'Plot results', 'Yes','No','Yes');
        b(1:totalPlot)=[];  
    end
end

%v0.2 03/18/2021
%Sanity test was modified to re-index cells when some are deleted. 
%ROIRed indexes are also re-indexed in case of del.

