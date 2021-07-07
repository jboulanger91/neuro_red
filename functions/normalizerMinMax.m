
%Version 22092014. Works: Yes

%This incredibly complicated function computes the normalised values for a
%given array x. The intermediary result xTemp is the x array where the min
%is substracted and a non lineraity component might have been added. 

function [y,xTemp]=normalizerMinMax(x,alpha,min,max)
    xTemp=(x-min).^(1/alpha);
    y=(xTemp-nanmin(xTemp(:)))./(max-min);
end

