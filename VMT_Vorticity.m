function [V] = VMT_Vorticity(V)
% Not currently implemented
%
% Computes normalized STREAMWISE vorticity for the averaged cross-section
% based 3 different measures of secondary flow (Transverse (v), Secondary
% (zsd), Secondary (Roz)). This function uses the smoothed values of each
% component, and thus is called with each REPLOT.
% 
% Vorticity (\omega) is normalized by the channel top width &
% average streamwise velocity:
%       \omega = \tilde{\omega} frac{B}{U} 
% 
% FROM WIKIPEDIA: In fluid dynamics, the vorticity is a vector that
% describes the local spinning motion of a fluid near some point, as would
% be seen by an observer located at that point and traveling along with the
% fluid. Conceptually, the vorticity could be determined by marking the
% particles of the fluid in a small neighborhood of the point in question,
% and watching their relative displacements as they move along the flow.
% The vorticity vector would be twice the mean angular velocity vector of
% those particles relative to their center of mass, oriented according to
% the right-hand rule. This quantity must not be confused with the angular
% velocity of the particles relative to some other point. More precisely,
% the vorticity of a flow is a vector field (\omega), equal to the CURL
% (rotational) of its velocity field (v,w).
% 
% Written by Frank L. Engel, USGS
% Last modified: F.L. Engel, USGS, 12/21/2012

% Begin code

B = V.dl;
U = nanmean(V.u(:));

[V.vorticity_vw,~]= curl(...
    V.mcsDist,...
    V.mcsDepth,...
    V.vSmooth,...
    V.wSmooth);
V.vorticity_vw = -V.vorticity_vw.*B./U; % reverse sign to keep RH coordinates

[V.vorticity_zsd,~]= curl(...
    V.mcsDist,...
    V.mcsDepth,...
    V.vsSmooth,...
    V.wSmooth);
V.vorticity_zsd = -V.vorticity_zsd.*B./U;

[V.vorticity_roz,~]= curl(...
    V.mcsDist,...
    V.mcsDepth,...
    V.Roz.usSmooth,...
    V.wSmooth);
V.vorticity_roz = -V.vorticity_roz.*B./U;

% Vertical vorticity -- not saved in V struct, experiemental only
[vorticity_uv,~]= curl(...
    V.mcsDist,...
    V.mcsDepth,...
    V.uSmooth,...
    V.vSmooth);
vorticity_uv = -vorticity_uv.*B./U; % reverse sign to keep RH coordinates