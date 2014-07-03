function [znm,vm] = VMT_ComputeNormProf(zn,v,n)
% Computes the normaized median profile from multiemsemble data.
%
% Inputs:
%
% zn: matrix of normized, bed origin bin locations (#bins x #ens)
% v:  matrix of observed velocity magniitude (#bins x #ens)
% n:  number of cells to use in the profile binning
%
% P.R. Jackson, USGS, 8-31-12

% Reshape the matrices to create vectors
zn_vec = reshape(zn,size(zn,1)*size(zn,2),1);
v_vec  = reshape(v,size(v,1)*size(v,2),1);

% Bin the data and compute median values
cell_breaks = 0:1/n:1;  %Limits of each cell
dum = diff(cell_breaks);
znm = cumsum([(cell_breaks(2)/2) dum(2:end)]);

vm  = nan*ones(1,n);  %preallocate
obs = nan*ones(1,n);  %preallocate
for i = 1:n
    indx = find(zn_vec >= cell_breaks(i) & zn_vec < cell_breaks(i+1));
    vm(i) = nanmedian(v_vec(indx));
    obs(i) = length(indx);
end

% Find any cells that have < 20% of the median number of data points all
% other bins
indx = find(obs < 0.2*nanmedian(obs));

% Plot the data

if 0  %for debugging
    figure(1); clf
    plot(v_vec,zn_vec,'k.'); hold on
    plot(vm,znm,'bs-'); hold on
    plot(vm(indx),znm(indx),'ro')
    xlabel('velocity')
    ylabel('normalized height above bottom')
    xlim([0 max(v_vec)])
    ylim([0 1])
end

%Remove lean cells
vm(indx) = nan;



    


