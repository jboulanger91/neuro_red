
%%%%%%%%%%%%%%%%%%%%%%
%%   KEY FUNCTION   %%
%%%%%%%%%%%%%%%%%%%%%%
%v0.1 2021/03/16
%%Plots one variable upon the tectum avg image

function plotcorrelationmap(subsample,AllHox,HoxTemp,numCellTotal,valsToPlot,cell_per,alpha,MinAngle,MaxAngle,colorbarplot)

%twoColCMap=load('F:\.shortcut-targets-by-id\1hAipi84k--6-WdgJp-H6kvKO_IsueAHX\toShareWithJonBoulanger\scripts\colormaps\ColorMapDarkBlueGreenYellow.mat');
%twoColCMap=load('/Volumes/GoogleDrive/.shortcut-targets-by-id/1hAipi84k--6-WdgJp-H6kvKO_IsueAHX/toShareWithJonBoulanger/scripts/colormaps/ColorMapDarkBlueGreenYellow.mat');

cmap=turbo; 

%Make the GnRH cell of interest patched magenta
verts=[cell_per{HoxTemp}(:,1),cell_per{HoxTemp}(:,2)];
faces=1:1:length(verts);
patch('Faces',faces,'Vertices',verts,'FaceColor',[1 0 1],'EdgeColor',[1 0 1]);
freezeColors;

%Define the number of colors
cMapInterp=zeros(size(valsToPlot,2),3);
for colorIndex=1:3
    cMapTemp2=interp1(1:length(cmap),cmap(:,colorIndex)',linspace(1,length(cmap),size(valsToPlot,2)));
    cMapInterp(:,colorIndex)=cMapTemp2;
end

%Normalize the values of the variable of interest
[valsToPlotNorm,~]=normalizerMinMax(valsToPlot,alpha,MinAngle,MaxAngle);

%%Plot patches
for indCell=1:numCellTotal %Define the number of colors
    verts=[cell_per{indCell}(:,1), cell_per{indCell}(:,2)];
    faces=1:1:length(verts);
    if ~isnan(valsToPlotNorm(indCell))
        indColor=round(valsToPlotNorm(indCell)*(numCellTotal-1)+1);
        patch('Faces',faces,'Vertices',verts,'FaceColor',cMapInterp(indColor,:),'EdgeColor',cMapInterp(indColor,:));
    end
end
freezeColors;

if subsample==1
    %Make every GnRH cell circled magenta
    for indCell=1:length(AllHox)
        verts=[cell_per{AllHox(indCell)}(:,1),cell_per{AllHox(indCell)}(:,2)];
        faces=1:1:length(verts);
        patch('Faces',faces,'Vertices',verts,'FaceColor','none','EdgeColor',[1 0 1]);
    end
end

%%Make colorbar
if colorbarplot==1
    hc=colorbar; caxis([0 1]);
    ticks=get(hc,'YTick'); ticksLim=get(hc,'YLim'); colormap(cmap);
    
    %Labels values/positions
    labels=linspace(MinAngle,MaxAngle,5);
    poslabels=linspace(0,1,5);
    set(hc,'YTick',poslabels,'YTickLabel',labels);
    freezeColors;
end

end

