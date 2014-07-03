function [X,A] = nanmoving_average2(X,Fr,Fc,INT)
%NANMOVING_AVERAGE2   Smooths a matrix through the moving average method.
%
%   Syntax:
%     [Y,Nsum] = nanmoving_average2(X,Fr,Fc,INT);
%
%   Input:
%     X   - Matrix of finite elements.
%     Fr  - Window semi-length in the rows. A positive scalar (default 0).
%     Fc  - Window semi-length in the columns. A positive scalar (default
%           Fr). 
%     INT - If INT=0: do not interpolates NaN's (default); elseif INT=1 do
%           interpolates.
%
%   Output:
%     Y    - Smoothed X elements.
%     Nsum - Number of not NaN's elements that fixed on the moving window.
%            Provided to get a sum instead of a mean: Y.*Nsum.
%
%   Description:
%     Quickly smooths the matrix X by averaging each element along with
%     the surrounding elements that fit in the little matrix
%     (2Fr+1)x(2Fc+1) centered at the element (boxcar filter), but ignoring
%     NaN's. The elements at the ends are also averaged but the ones on the
%     corners are left intact. If Fr or Fc is zero or empty the smoothing
%     is made through the columns or rows only, respectively. With the
%     windows size defined in this way, the filter has zero phase. 
%
%   Example:
%      [X,Y] = meshgrid(-2:.2:2,3:-.2:-2);
%      Zi = 5*X.*exp(-X.^2-Y.^2); 
%      Zr = Zi + rand(size(Zi));
%      Zr([8 46 398 400]) = NaN;
%      Zs = nanmoving_average2(Zr,2,3);
%       subplot(131), surf(X,Y,Zi) 
%       view(2), shading interp, xlabel('Z')
%       subplot(132), surf(X,Y,Zr)
%       view(2), shading interp, xlabel('Z + noise + NaN''s')
%       subplot(133), surf(X,Y,Zs)
%       view(2), shading interp, xlabel('Z smoothed')
%
%
%   See also FILTER2, RECTWIN, NANMEAN and MOVING_AVERAGE,
%   NANMOVING_AVERAGE, MOVING_AVERAGE2 by Carlos Vargas

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

% January 2008, fixed bug on the Fr,Fc data.

%% Error checking: 
if ~nargin
  error('Nanmoving_average2:Inputs','There are no inputs.')
elseif nargin<2 || isempty(Fr)
 Fr = 0;
end
if ndims(X) ~= 2
 error('Nanmoving_average2:Inputs','Entry must be a matrix.')
end
if nargin<3 || isempty(Fc)
 Fc = Fr;
end
if nargin<4 || isempty(INT)
 INT = 0;
end
if ~INT
 inan = isnan(X);
end

%% MAIN
% Sums by each column with NaN interpolation:
[X,A] = nanmoving_average(X,Fr,1,1); X = X.*A;
% Sums by each sumed row:
[X,B] = nanmoving_average(X,Fc,2,1); X = X.*B;
% Sumed elements:
[A,C] =    moving_average(A,Fc,2);   A = A.*C;
% All NaNs
X(A==0) = NaN;
% Mean:
X = X./A;
% Interpolation?:
if ~INT
 X(inan) = NaN;
end

% Carlos Adrián Vargas Aguilera. nubeobscura@hotmail.com