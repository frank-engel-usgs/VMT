function lam = VMT_LayerAveMean(x,y)
% Computes the layer averaged mean of y over the depth range.
% Assumes the data outside the depth range have been set to NaN.
%
% P.R. Jackson, USGS 1-7-09

% Preallocate
intgrl = nan*ones(1,size(y,2));
dz = nan*ones(1,size(y,2));

for i = 1:size(y,2)
    indx        = find(~isnan(y(:,i)));
    if isempty(indx)
        intgrl(i) = NaN;
        dz(i)     = NaN;
    elseif length(indx) == 1;  %Allows a single value mean: mean value = single value (nan before) %PRJ, 3-11-11
        intgrl(i) = y(indx,i);
        dz(i)     = 1;
    elseif length(indx) > 1;
        xt          = x(indx,i);
        yt          = y(indx,i);
        intgrl(i)   = trapz(xt,yt,1);
        dz(i)       = nanmax(xt) - nanmin(xt);
    end
    clear indx
end
lam = intgrl./dz;


