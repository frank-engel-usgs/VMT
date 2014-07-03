function [aii,n,cod,upred,zpred,delta] = fitPowerLawFull(u,z,fixn,h)

% This function fits a power law of the form u = aii*z^n to the given data
% and returns the constant coefficient aii, the exponent n, and the coef of determination cod. The user has the 
% option to fix the value of n to 1/6 by setting 'fixn' = 1.  u is the velocity (normalized by u*), z is 
% the height above bottom (monotonically increasing, normailzed by zo), and h is the normailzed flow
% depth (by zo).  

% P.R. Jackson, 10-10-10

%Example:

% clear all
% z = 5:50; X = 0.4512*z.^(1/6);
% X = X + (2*rand(size(X))-1).*0.05.*X;
% [aii,n,ssr,Xpred,zpred,delta] = fitPowerLaw(X,z,0,55,1,1,1);
% figure(1); clf; plot(X,z); hold on
% plot(Xpred,zpred,'r-'); hold on
% plot(Xpred+delta,zpred,'r:',Xpred-delta,zpred,'r:'); hold on

if (nargin < 4)
    h = max(z);
end

zpred = linspace(0,h,100);

switch fixn
    case 0; 
        coefinit   = [1 1/6]; %initial guess at coefficients  
        pwrfcn     = inline('coef(1)*z.^coef(2)', 'coef', 'z'); 
        [coef,r,J,sig,mse] = nlinfit(z,u,pwrfcn,coefinit); %nonlinear fit 
        [upred,delta] = nlpredci(pwrfcn,zpred,coef,r,'covar',sig);
        aii = coef(1); 
        n   = coef(2);

    case 1; 
        coefinit   = [1]; %initial guess at coefficients 
        pwrfcn     = inline('coef(1)*z.^(1/6)', 'coef', 'z'); 
        [coef,r,J,sig,mse] = nlinfit(z,u,pwrfcn,coefinit); %nonlinear fit 
        [upred,delta] = nlpredci(pwrfcn,zpred,coef,r,'covar',sig);
        aii = coef(1); 
        n   = 1/6;
end

ssr = sum(r.^2);

sstot = sum((u - mean(u)).^2);

cod = 1 - ssr./sstot;

