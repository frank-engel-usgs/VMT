function [geoAng] = ari2geodeg(ariAng)
%ARI2GEODEG converts arithmetic angles to geographic angles.
% ariAng is a scalar, vector, or matrix of angles in degrees,
% such as those produced with atan() or atan2().
% geoAng is an output of size(ariAng) with angles converted to
% geographic headings (North = 0, with angles positive
% clockwise)
%
% EXAMPLE USAGE
%   ariAng = 150
%   [geoAng] = mcsADCP.ari2geodeg(ariAng)
%   geoAng =
% 
%   300
%
% Frank L. Engel, USGS
%
% SEE ALSO: mcsADCP, geo2arideg


ariAng(ariAng<0) = ariAng(ariAng<0) + 360;
ariAng = ariAng + 270;
ariAng(ariAng>360) = ariAng(ariAng>360)-360;
geoAng = 360-ariAng;
end % function ari2geodeg