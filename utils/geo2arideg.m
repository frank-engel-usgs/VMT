function [ariAng] = geo2arideg(geoAng)
%GEO2ARIDEG converts geographic angles to arithmetic angles.
% geoAng is a scalar, vector, or matrix of geographic angles in
% degrees, i.e., geographic headings (North = 0, with angles
% positive clockwise) ariAng is an output of size(geoAng) with
% angles converted to angles such as those produced with atan()
% or atan2().
%
% EXAMPLE USAGE
%   geoAng = 300
%   [ariAng] = mcsADCP.geo2arideg(geoAng)
%   ariAng =
% 
%   150
%
% Frank L. Engel, USGS
%
% SEE ALSO: mcsADCP, ari2geodeg
ariAng = 360 - geoAng + 90;
ariAng(ariAng>360) = ariAng(ariAng>360) - 360;
end % function geo2arideg