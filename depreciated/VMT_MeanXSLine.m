function [m,b] = VMT_MeanXSLine(z,A)
% Fits multiple transects at a single location with a single line. Inputs
% are number of files (z) and data matrix (Z)(see ReadFiles.m). Outputs are
% the intercept (b) and slope (b) of the best fit line.
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-9-08 



%% Determine the best fit mean cross-section line from multiple transects
% initialize vectors for concatenation

x = [];
y = [];

for zi = 1 : z
       
    % concatenate long and lat into a single column vector for regression
    x=cat(1,x,A(zi).Comp.xUTM);
    y=cat(1,y,A(zi).Comp.yUTM);
    
    plot(A(zi).Comp.xUTM,A(zi).Comp.yUTM,'r')
    plot(A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,'b')
        
end

% find the equation of the best fit line 
whichstats = {'tstat','yhat'};
stats = regstats(y,x,'linear', whichstats);

% mean cross-section line slope and intercept
V.m = stats.tstat.beta(2);
V.b = stats.tstat.beta(1);

clear x y stats whichstats zi