function [Y,Nsum] = nanmoving_average(X,F,DIM,INT)
%NANMOVING_AVERAGE   Moving average ignoring NaN's.
%
%   Syntax:
%     [Y,Nsum] = nanmoving_average(X,F,DIM,INT);
%
%   Input:
%     X   - Vector or matrix of finite elements.
%     F   - Window semi-length. A positive scalar.
%     DIM - If DIM=1: smooths the columns (default); elseif DIM=2 the rows.
%     INT - If INT=0: do not interpolates NaN's (default); elseif INT=1 do
%           interpolates.
%
%   Output:
%     Y    - Smoothed X elements with/without interpolated NaN's.
%     Nsum - Number of not NaN's elements that fixed on the moving window.
%            Provided to get a sum instead of a mean: Y.*Nsum.
%
%   Description:
%     Quickly smooths the vector X by averaging each element along with the
%     2*F elements at its sides ignoring NaN's. The elements at the ends
%     are also averaged but the extrems are left intact. With the windows
%     size defined in this way, the filter has zero phase. If all the 2*F+1
%     elements al NaN's, a NaN is return.
%
%   Example:
%      x = 2*pi*linspace(-1,1); 
%      yn = cos(x) + 0.25 - 0.5*rand(size(x)); 
%      yn([5 30 40:43]) = NaN;
%      ys = nanmoving_average(yn,4);
%      yi = nanmoving_average(yn,4,[],1);
%      plot(x,yn,x,yi,'.',x,ys),  axis tight
%      legend('noisy','smooth','without interpolation',4)
%
%   See also FILTER, RECTWIN, NANMEAN and MOVING_AVERAGE, MOVING_AVERAGE2,
%   NANMOVING_AVERAGE2 by Carlos Vargas

% Copyright 2006-2008  Carlos Vargas, nubeobscura@hotmail.com
%	$Revision: 3.1 $  $Date: 2008/03/12 18:20:00 $

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

%   2008 Mar. Use CUMSUM as RUNMEAN by Jos van der Geest, no more
%   subfunctions.

%% Error checking
if ~nargin
  error('Nanmoving_average:Inputs','There are no inputs.')
elseif nargin<2 || isempty(F)
 F = 0;
end
if F==0
 Y = X;
 return
end
F = round(F);
ndim = ndims(X);
if (ndim ~= 2)
 error('Nanmoving_average:Inputs','Input is not a vector or matrix.')
end
[N,M] = size(X);
if nargin<3 || isempty(DIM)
 DIM = 1;
 if N == 1
  DIM = 2;
 end
end
if DIM == 2
 X = X.';
 [N,M] = size(X);
end
if 2*F+1>N
 warning('Nanmoving_average:Inputs',...
  'Window size must be less or equal as the number of elements.')
 Y = X;
 if DIM == 2
  Y = Y.';
 end
 return
end
if nargin<4 || isempty(INT)
 INT = 0;
end

%% Window width
Wwidth = 2*F + 1;

%% Smooth the edges but with the first and last element intact
F2 = Wwidth - 2;
Y1 =        X(     1:F2,:);
Y2 = flipud(X(N-F2+1:N ,:));
inan1 = isnan(Y1); 
inan2 = isnan(Y2);
Y1(inan1) = 0;
Y2(inan2) = 0;
Y1    = cumsum(Y1,1);    Y1    =    Y1(1:2:F2,:);
Y2    = cumsum(Y2,1);    Y2    =    Y2(1:2:F2,:);
inan1 = cumsum(inan1,1); inan1 = inan1(1:2:F2,:);
inan2 = cumsum(inan2,1); inan2 = inan2(1:2:F2,:);
Nsum1 = repmat((1:2:F2)',1,M);
Nsum2 = repmat((1:2:F2)',1,M);
Nsum1 = Nsum1 - inan1;
Nsum2 = Nsum2 - inan2;
Y1(Nsum1==0) = NaN;
Y2(Nsum2==0) = NaN;
Y1 = Y1./Nsum1;            
Y2 = Y2./Nsum2;

%% Recursive moving average method:
nnan = ~isnan(X);
X(~nnan) = 0;
% Cumsum trick copied from RUNMEAN by Jos van der Geest  (12 mar 2008)
Y = [zeros(F+1,M); X; zeros(F,M)];
Y = cumsum(Y,1);
Y = Y(Wwidth+1:end,:)-Y(1:end-Wwidth,:);
Nsum = [zeros(F+1,M); nnan; zeros(F,M)];
Nsum = cumsum(Nsum,1);
Nsum = Nsum(Wwidth+1:end,:)-Nsum(1:end-Wwidth,:);
Y = Y./Nsum;

%% Sets the smoothed edges:
Y(    1:F,:) =        Y1;
Y(N-F+1:N,:) = flipud(Y2);
Nsum(    1:F,:) = Nsum1;
Nsum(N-F+1:N,:) = flipud(Nsum2);

%% Do not interpolates:
if ~INT
 Y(~nnan) = NaN;
end

%% Return correct size:
if DIM == 2
 Y = Y.';
 Nsum = Nsum.';
end
 
%% % Recursive moving average code before Jos trick:
% W = zeros(N,M);
% Z = X(1:Wwidth,:);
% inan = isnan(Z);
% Z(inan) = 0;
% Z = sum(Z,1);
% W(F+1,:) = sum(inan,1);
% Y(F+1,:) = Z;
% % Recursive sum
% for n = F+2:N-F
%  Z = [Y(n-1,:); X(n+F,:); -X(n-F-1,:)];
%  inan = isnan(Z);
%  Z(isnan(Z)) = 0;
%  Y(n,:) = sum(Z,1);                           
%  W(n,:) = W(n-1,:) + inan(2,:) - inan(3,:);
% end
% W = Wwidth - Nnan;
% Y(W==0) = NaN;
% Y = Y./Wwidth;

%% Remove first and last (these values are left intact above and can be
%% highly erroneous)
if 1
    Y(1) = nan;
    Y(end) = nan;
end

