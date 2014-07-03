function [X,A] = moving_average2(X,Fr,Fc)
%MOVING_AVERAGE2   Smooths a matrix through the moving average method.
%
%   Syntax:
%     [Y,Nsum] = moving_average2(X,Fr,Fc);
%
%   Input:
%     X   - Matrix of finite elements.
%     Fr  - Window semi-length in the rows. A positive scalar (default 0).
%     Fc  - Window semi-length in the columns. A positive scalar (default
%           Fr). 
%
%   Output:
%     Y  - Smoothed X elements.
%     Nsum - Number of not NaN's elements that fixed on the moving window.
%            Provided to get a sum instead of a mean: Y.*Nsum.
%
%   Description:
%     Quickly smooths the matrix X by averaging each element along with
%     the surrounding elements that fit in the little matrix
%     (2Fr+1)x(2Fc+1) centered at the element (boxcar filter). The elements
%     at the ends are also averaged but the ones on the corners are left
%     intact. If Fr or Fc is zero or empty the smoothing is made through
%     the columns or rows only, respectively. With the windows size defined
%     in this way, the filter has zero phase. 
%
%   Example:
%      [X,Y] = meshgrid(-2:.2:2,3:-.2:-2);
%      Zi = 5*X.*exp(-X.^2-Y.^2); 
%      Zr = Zi + rand(size(Zi));
%      Zs = moving_average2(Zr,2,3);
%       subplot(131), surf(X,Y,Zi) 
%       view(2), shading interp, xlabel('Z')
%       subplot(132), surf(X,Y,Zr)
%       view(2), shading interp, xlabel('Z + noise')
%       subplot(133), surf(X,Y,Zs)
%       view(2), shading interp, xlabel('Z smoothed')
%
%
%   See also FILTER2, RECTWIN and MOVING_AVERAGE, NANMOVING_AVERAGE,
%   NANMOVING_AVERAGE2 by Carlos Vargas

% Copyright 2006-2008  Carlos Vargas, nubeobscura@hotmail.com
%	$Revision: 3.1 $  $Date: 2008/03/12 17:20:00 $

%   Written by
%   M. in S. Carlos Adrián Vargas Aguilera
%   Physical Oceanography PhD candidate
%   CICESE 
%   Mexico,  march 2008
%
%   nubeobscura@hotmail.com
%
%   Download from:
%   http://www.mathworks.com/matlabcentral/fileexchange/loadAuthor.do?objec
%   tType=author&objectId=1093874

% October 2006, fixed bug on the rows.
% January 2008, fixed bug on the Fr,Fc data.

%% Error checking: 
if ~nargin
  error('Moving_average2:Inputs','There are no inputs.')
elseif nargin<2 || isempty(Fr)
 Fr = 0;
end
if ndims(X) ~= 2
 error('Moving_average2:Inputs','Entry must be a matrix.')
end
if nargin<3 || isempty(Fc)
 Fc = Fr;
end


%% MAIN
% Smooths each column:
[X,A] = moving_average(X,Fr,1);
% Smooths each smoothed row:
X = moving_average(X,Fc,2);
% 2 outputs
if nargout==2
 [A,B] = moving_average(A,Fc,2);
 A = A.*B;
end

% Carlos Adrián Vargas Aguilera. nubeobscura@hotmail.com