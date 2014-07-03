function angleInDegrees = rad2deg(angleInRadians)
% RAD2DEG Convert angles from radians to degrees
%
%   RAD2DEG has been replaced by RADTODEG.
%
%   angleInDegrees = RAD2DEG(angleInRadians) converts angle units from
%   radians to degrees.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.9.4.5 $  $Date: 2009/04/15 23:16:46 $

angleInDegrees = (180/pi) * angleInRadians;
