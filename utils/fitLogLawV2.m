function [ustar,zo,cod] = fitLogLawV2(u,z,h)

% This function fits a log law of the form u/u* = 1/kappa*ln(z/zo) to the given data
% and returns u*, zo, and the sum of the squared residuals ssr.   

% P.R. Jackson, 11-16-10

%Example:

% clear all
% z = 5:50; u = 0.046/0.41*log(z/0.008);
% u = u + (2*rand(size(u))-1).*0.05.*u;
% [ustar,zo] = fitLogLawV2(u,z);
% figure(1); clf; plot(u,z); hold on
% plot(upred,zpred,'r-'); hold on
% plot(upred+delta',zpred,'r:',upred-delta',zpred,'r:'); hold on

%figure(1); clf; plot(u,z,'ko-'); xlim([0 max(u)]); ylim([0 max(z)]);pause

if (nargin < 3)
    h = max(z);
end

zpred = linspace(0,h,100);

kappa = 0.41; % Von Karman constant

[p,S] = polyfit(log(z),u,1);

ustar = kappa*p(1);

zo = exp(-p(2)/p(1));

ssr = S.normr.^2;

sstot = sum((u - mean(u)).^2);

cod = 1 - ssr./sstot; %Coefficient of determination (r^2)











