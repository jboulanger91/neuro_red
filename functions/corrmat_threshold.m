

%v0.1/03/15/2021
% This programs computes the correlation matrix and determined the
% threshold for significant correlation at a given confidence range. 

function [corr_mat,threshold]=corrmat_threshold(raster,percentile)

    %1. Compute Correlations
    corr_mat=corr(raster); 
    
    %2. Places NaN on the diagonal to remove auto-correlation
    corr_mat(logical(eye(size(corr_mat))))=NaN;
    
    %3. Determine a threshold for significant correlations
    shuffledRasterSpont=shake(raster,1);
    corrMatshuffledRasterSpont=corr(shuffledRasterSpont);
    corrMatshuffledRasterSpont(logical(eye(size(corrMatshuffledRasterSpont))))=NaN;
    threshold=prctile(reshape(corrMatshuffledRasterSpont,1,size(corrMatshuffledRasterSpont,1)^2),percentile);
    
end 
