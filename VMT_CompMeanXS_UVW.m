function [A,V] = VMT_CompMeanXS_UVW(z,A,V)
% Computes the mean cross section velocity components (U,V,W)
% from individual transects that have been previously mapped to a common
% grid and averaged.
% 
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-9-08 


%% Rotate velocities into u, v, and w components
% Determine the direction of streamwise velocity (u)
%V.phi = 180-V.theta;  %Taken as perpendicular to the mean XS

% Determine the deviation of a vector from streamwise velocity
V.psi = (V.phi-V.mcsDir);

% Determine streamwise (u), transverse (v), and vertical (w) velocities
V.u = cosd(V.psi).*V.mcsMag;
V.v = sind(V.psi).*V.mcsMag;
V.w = V.mcsVert;

for zi = 1 : z
    
    A(zi).Comp.u = cosd(V.psi).*A(zi).Comp.mcsMag;
    A(zi).Comp.v = sind(V.psi).*A(zi).Comp.mcsMag;
    A(zi).Comp.w = A(zi).Comp.mcsVert;
    
    A(zi).Comp.psi = V.phi-A(zi).Wat.vDir;
    A(zi).Comp.u1 = cosd(A(zi).Comp.psi).*A(zi).Wat.vMag;
    A(zi).Comp.v1 = sind(A(zi).Comp.psi).*A(zi).Wat.vMag;
    A(zi).Comp.w1 = A(zi).Wat.vVert;
    
end

