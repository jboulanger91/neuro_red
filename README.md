# neuro_red

v0.1 03/15/2021
Jonathan Boulanger-Weill, PhD, Harvard University

To compare calcium responses of labeled neuronal sub-populations 

0- DEPENDENCIES 
  Install the following MATLAB toolboxes: 
  CAIMAN: https://github.com/flatironinstitute/CaImAn-MATLAB
  Calcium analysis basic functions: https://github.com/zebrain-lab/Toolbox-Romano-et-al

I- REGISTRATION
  1. First split the video in two colors using imageJ
  2. Add split videos to a /to_reg folder
  3. Run Nred_register.mat in this folder, based on CAIMAN (this prevents re-registering previously processed videos)

II- SEGMENTATION 
  1. Run Nred_segmentation.mat on the green_reg videos  
  2. Input the um to pix relationship 
  3. Use the Automatically detect ROIs
  4. Wait for Matlab to read the video, make the mask and change the Gamma value to 0.5 (the background cells should be visible). 
  5. Set the local contrast to 10 pixels, Set the border threshold to 0.2 and the cell center to 0.1, click on find ROIs, if happy click on Done.
  6. Set all max sliders to the right and min sliders to the left except the minimal area, set it to 26 to remove small ROIs, click Done.
  7. Proofread the ROIs (don't worry they can be proofread again, so as long as you save they can be fine-tuned) taking extra care to circle the cells of interest, click on Done.
  8. Right click on the cells of interest, they should change color and become red
  9. The _ALL_CELLS.mat file is now saved in the common folder for the next steps.

III- MOVEMENTS DETECTION 
  1. Run Nred_findartifacts.mat on the green_reg videos
  2. Set the zscore threshold to -2. 
  3. Examine each frame, keep the small shaking artefacts but remove the large movements. 

IV- TRANSIENTS EXTRACTION
  1. Run Nred_rasterize on the _ALL_CELLS.mat, this will load the associated _ARTIFACTS.mat file. 
  2. Make sure these parameters are used for consistency:  
	- Frequency of imaging 4hz
	- Fluo. decay time constant: 3.5s (for H2B:GCaM6f) 
	- Next window: Parameters for control of data-sanity: keep identical
	- Substract fluo. of the neuropil: No
	- Method for baseline fluo.: Smooth slow dynamics
	- Method for estimation of noise in baseline fluo: Gaussian model
	- Method for detection of significant transients: dynamic threshold 
	- Minimal confidence: 95%
	- Plot examples of fluorescent traces: yes, this will export Hox5+ and control example traces 

V- CELL TYPE CLASSIFICATION 
  1. Load each video using ImageJ and save the mean temporal average (Stack/Zprojection/Average intensity) as videoname_avg. Do this both for red and green registered videos. 
	
VI - CORRELATION ANALYSES 
  1. Run Nred_corr_analyses. 
