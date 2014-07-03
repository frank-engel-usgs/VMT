function [xo,yo,mag,dir] = VMT_VelVectMagDir(xi,yi,Veast,Vnorth)
% Computes the magnitude and direction of velocity vectors given the east
% velocity and north velocity at specified points.  Positions x and y of
% the observations are passed through.
%
% P.R. Jackson, USGS, 1-15-09

%Compute the magnitude

mag = sqrt(Veast.^2 + Vnorth.^2);

%Determine the quadrant
indx1 = find(Veast >= 0 & Vnorth >= 0);
indx2 = find(Veast >= 0 & Vnorth <= 0);
indx3 = find(Veast <= 0 & Vnorth <= 0);
indx4 = find(Veast <= 0 & Vnorth >= 0);

%Compute the direction in degrees from north (+CW)
dir = zeros(size(Veast));

dir(indx1) = 90    - atand(abs(Vnorth(indx1)./Veast(indx1)));
dir(indx2) = 180   - atand(abs(Veast(indx2)./Vnorth(indx2)));
dir(indx3) = 270   - atand(abs(Vnorth(indx3)./Veast(indx3)));
dir(indx4) = 360   - atand(abs(Veast(indx4)./Vnorth(indx4)));

%Pass position through

xo = xi;
yo = yi;