function [dm,zm,Vme,Vmn,Vmv,Vmag,nmedpts,maxd] = ComputeNormalizedProfile(d,binDepth,Ve,Vn,Vv)

%This function computes the normalized velocity profile from basic velocity
%components.  This method ensures that profiles with variable depths are
%averaged according to height above the bed rather than depth from surface.

% d: 1 x n vector of bed depths
% binDepth: m x n matrix of bin depths as defined by the ADCP
% Ve: m x n matrix of East Velocity obervations
% Vn: m x n matrix of North Velocity observations

%P.R. Jackson, USGS, 3-21-12

%Determine the bin size
binSpacing = diff(binDepth(:,1));
binSize = binSpacing(1);

%Use the max depth and binsize to set the number of points in the profile
%(this maintains the resolution of the original data)

maxd = nanmax(d);
npts = ceil(maxd/binSize);
zcellBounds = linspace(0,1,npts+1);  %Boundary points for each averaging cell
zcn = (zcellBounds(2:end)+zcellBounds(1:end-1))/2;  %midpoint of each averaging cell

% Compute the normalized sample height above the bed
% Normalize by depth

dmat = repmat(d,size(binDepth,1),1);
zn = (dmat-binDepth)./dmat;

% Aggregate the data and plot the normalized profiles
Ve_all = [];
Vn_all = [];
Vv_all = [];
zn_all = [];
for i = 1:length(d)
    Ve_all = [Ve_all; Ve(:,i)];
    Vn_all = [Vn_all; Vn(:,i)];
    Vv_all = [Vv_all; Vv(:,i)];
    zn_all = [zn_all; zn(:,i)];
end


% Compute the median profiles
Vme = nan*ones(npts,1);
Vmn = nan*ones(npts,1);
Vmv = nan*ones(npts,1);
nmedpts = nan*ones(npts,1);
for i = 1:npts
    indx = find(zn_all >= zcellBounds(i) & zn_all < zcellBounds(i+1) & ~isnan(Ve_all) & ~isnan(Vn_all));
    Vme(i) = nanmedian(Ve_all(indx));
    Vmn(i) = nanmedian(Vn_all(indx));
    Vmv(i) = nanmedian(Vv_all(indx));
    nmedpts(i) = length(indx);
end

% Plot the median profiles

figure(11); clf
subplot(1,3,1)
plot(Ve_all,zn_all,'k.'); hold on
plot(Vme,zcn,'ro-')
ylim([0 1])
ylabel('Normalized Height above bed')
xlabel('East Velocity')
grid on
subplot(1,3,2)
plot(Vn_all,zn_all,'k.'); hold on
plot(Vmn,zcn,'ro-')
ylim([0 1])
%ylabel('Normalized Height above bed')
xlabel('North Velocity')
grid on
subplot(1,3,3)
plot(Vv_all,zn_all,'k.'); hold on
plot(Vmv,zcn,'ro-')
ylim([0 1])
%ylabel('Normalized Height above bed')
xlabel('Vertical Velocity')
grid on

%Compute the Velocity Magnitude
Vmag = sqrt(Vme.^2 + Vmn.^2);

%Convert back to height above bottom and depth
zm = zcn*maxd;  %unnormalized height above bed
dm = maxd - zm;  %Depth from surface

% Remove points with few contributing observations
if 1
    scrnpct = 0.2;  %screening percent 
    medobs = nanmedian(nmedpts);  %median number of observations
    indx = find(nmedpts < scrnpct*medobs);  %finds points in the profile with fewer than 20% of the median number of observations contributing to the median
    Vme(indx) = nan;
    Vmn(indx) = nan;
    Vmv(indx) = nan;
    Vmag(indx) = nan;
end








