function [aii,n,ssr,Xpred,zpred,delta] = fitPowerLaw(X,z,fixn,h,mid,top,bottom)

% This function fits a power law of the form X = aii*z^n to the given data
% and returns the constant coefficient aii, the exponent n, and the sum of the squared residuals ssr. The user has the 
% option to fix the value of n to 1/6 by setting 'fixn' = 1.  X is the velocity cross product, z is 
% the height above bottom (monotonically increasing), and h is the flow
% depth; mid, top and bottom are TF (1,0) values that tell the code to fit the
% middle of the profile, top of the profile, and bottom of the profile, respectively.  

% P.R. Jackson, 5-1-08

%Example:

% clear all
% z = 5:50; X = 0.4512*z.^(1/6);
% X = X + (2*rand(size(X))-1).*0.05.*X;
% [aii,n,ssr,Xpred,zpred,delta] = fitPowerLaw(X,z,0,55,1,1,1);
% figure(1); clf; plot(X,z); hold on
% plot(Xpred,zpred,'r-'); hold on
% plot(Xpred+delta,zpred,'r:',Xpred-delta,zpred,'r:'); hold on

zpred = [];

switch mid
    case 0; zpred = [];
    case 1; zpred = z;
end

switch top
    case 0; zpred = zpred;
    case 1; zpred = horzcat(zpred,linspace(z(end),h,10))';
end

switch bottom
    case 0; zpred = zpred;
    case 1; if top; zpred = horzcat(zpred',linspace(0,z(1),100))';
            else zpred = horzcat(zpred,linspace(0,z(1),100))';
            end
end
        
zpred = sort(zpred);

switch fixn
    case 0; 
        coefinit   = [1 1/6]; %initial guess at coefficients  
        pwrfcn     = inline('coef(1)*z.^coef(2)', 'coef', 'z'); 
        [coef,r,J,sig,mse] = nlinfit(z,X,pwrfcn,coefinit); %nonlinear fit 
        [Xpred,delta] = nlpredci(pwrfcn,zpred,coef,r,'covar',sig);
        aii = coef(1); 
        n   = coef(2);

    case 1; 
        coefinit   = [1]; %initial guess at coefficients 
        pwrfcn     = inline('coef(1)*z.^(1/6)', 'coef', 'z'); 
        [coef,r,J,sig,mse] = nlinfit(z,X,pwrfcn,coefinit); %nonlinear fit 
        [Xpred,delta] = nlpredci(pwrfcn,zpred,coef,r,'covar',sig);
        aii = coef(1); 
        n   = 1/6;
end

ssr = sum(r.^2);



