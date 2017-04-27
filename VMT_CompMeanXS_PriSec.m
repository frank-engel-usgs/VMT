function [A,V,log_text] = VMT_CompMeanXS_PriSec(z,A,V)
% Computes the mean cross section velocity components (Primary
% and secondary) from individual transects that have been previously mapped
% to a common grid and averaged. The Primary velocity is defined as the
% component of the flow in the direction of the discharge (i.e. rotated
% from the streamwise direction so the secrondary discharge is zero).
%
% This is referred to as the "zero net cross-stream discharge definition"
% (see Lane et al. 2000, Hydrological Processes 14, 2047-2071)
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-9-08 


%% Rotate velocities into p and s components for the mean transect
% calculate dy and dz for each meaurement point
dy=mean(diff(V.mcsDist(1,:)));%m
dz=mean(diff(V.mcsDepth(:,1)));%m

% calculate the bit of discharge for each imaginary cell around the
% velocity point
qyi=V.v.*dy.*dz;%cm*m^2/s
qxi=V.u.*dy.*dz;%cm*m^2/s

% sum the streamwise and transverse Q and calculate the angle of the
% cross section
V.Qy=nansum(nansum(qyi));%cm*m^2/s
V.Qx=nansum(nansum(qxi));%cm*m^2/s

% Deviation from streamwise direction in geographic angle
V.alphasp=atand(V.Qy./V.Qx);

% Difference in degrees between the tangent vector of the ZSD plane and the
% normal vector of the mean cross section
V.phisp = V.phi-V.alphasp;

% Check phisp is not greater than 360 degrees
if V.phisp > 360
    V.phisp = V.phisp - 360;
end

% rotate the velocities so that Qy is effectively zero
qpi=qxi.*cosd(V.alphasp)+qyi.*sind(V.alphasp);
qsi=-qxi.*sind(V.alphasp)+qyi.*cosd(V.alphasp);

V.Qp=nansum(nansum(qpi));%cm*m^2/s
V.Qs=nansum(nansum(qsi));%cm*m^2/s
%disp(['Secondary Discharge after Rotation (ZSD definition; m^3/s) = ' num2str(V.Qs/100)])
log_text = ['      Qs after rotation (ZSD; m^3/s) = ' num2str(V.Qs/100)];

V.vp=qpi./(dy.*dz);%cm/s
V.vs=qsi./(dy.*dz);%cm/s

%% Transform each individual transect

for zi = 1 : z  

% calculate the bit of discharge for each imaginary cell around the
% velocity point
A(zi).Comp.qyi=A(zi).Comp.v.*dy.*dz;%cm*m^2/s
A(zi).Comp.qxi=A(zi).Comp.u.*dy.*dz;%cm*m^2/s

% rotate the velocities so that Qy is effcetively zero
A(zi).Comp.qpi=A(zi).Comp.qxi.*cosd(V.alphasp)+A(zi).Comp.qyi.*sind(V.alphasp);
A(zi).Comp.qsi=-A(zi).Comp.qxi.*sind(V.alphasp)+A(zi).Comp.qyi.*cosd(V.alphasp);

A(zi).Comp.Qp=nansum(nansum(A(zi).Comp.qpi));%cm*m^2/s
A(zi).Comp.Qs=nansum(nansum(A(zi).Comp.qsi));%cm*m^2/s

A(zi).Comp.vp=A(zi).Comp.qpi./(dy.*dz);%cm/s
A(zi).Comp.vs=A(zi).Comp.qsi./(dy.*dz);%cm/s

end


%% Determine velocity deviations from the p direction

V.mcsDirDevp = V.phisp-V.mcsDir;

for zi = 1:z
    A(zi).Comp.mcsDirDevp = V.phisp - A(zi).Comp.mcsDir;
end