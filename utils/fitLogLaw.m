function [ustar,zo,ks,cod,upred,zpred,delta] = fitLogLaw(u,z,h)

% This function fits a log law of the form u/u* = 1/kappa*ln(z/zo) to the given data
% and returns u*, zo, and the sum of the squared residuals ssr.   

% P.R. Jackson, 10-8-10

%Example:

% clear all
% z = 5:50; u = 0.046/0.41*log(z/0.008);
% u = u + (2*rand(size(u))-1).*0.05.*u;
% [ustar,zo,ks,ssr,upred,zpred,delta] = fitLogLaw(u,z);
% figure(1); clf; plot(u,z); hold on
% plot(upred,zpred,'r-'); hold on
% plot(upred+delta',zpred,'r:',upred-delta',zpred,'r:'); hold on

if (nargin < 3)
    h = max(z);
end

zpred = linspace(0,h,100);

%kappa = 0.41; % Von Karman constant

coefinit   = [1 1]; %initial guess at coefficients  
logfcn     = inline('coef(1)./0.41.*log(z./coef(2))', 'coef', 'z'); 
[coef,r,J,sig,mse] = nlinfit(z,u,logfcn,coefinit); %nonlinear fit 
[upred,delta] = nlpredci(logfcn,zpred,coef,r,'covar',sig);
ustar = coef(1); 
zo    = coef(2);

ks = 30*zo; %Nikuradse equivanelt sand roughness (for input in m)

ssr = sum(r.^2);

sstot = sum((u - mean(u)).^2);

cod = 1 - ssr./sstot;

