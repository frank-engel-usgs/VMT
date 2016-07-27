function [V] = VMT_SmoothVar(V,hwin,vwin)
% This routine smooths all processed variables in V struct. By default is
% uses smooth2a (FEX), but can also use nanmoving_average2 (FEX).
% 
% Updated 9-30-10 to include the smooth2a routine with user selection.
% Updated 12-21-2012 to smooth all variables. This is necessary to separate
% plotting from computations. FLE
%
% P.R. Jackson, USGS, 8/31/09
% Last modified: F.L. Engel, USGS, 12/21/2012

%disp(['Smoothing Data '])
warning off
%% Smooth
use_smooth2a = 1; %Set to 1 to use smooth2a.m for smoothing else set to 0 to use nanmoving_average2.m
% Set default to smooth2a 8-7-12 to overcome issues
% with corner values not getting averaged in
% nanmoving_average2 (really affected backscatter)
if V.probeType == 'RG'
    var ={...
        'streamwise';...
        'transverse';...
        'mag';...
        'primary_zsd';...
        'secondary_zsd';...
        'primary_roz';...
        'secondary_roz';...
        'primary_roz_x';...
        'primary_roz_y';...
        'secondary_roz_x';...
        'secondary_roz_y';...
        'backscatter';...
        'flowangle';...
        };
elseif V.probeType == 'M9'
    var ={...
        'streamwise';...
        'transverse';...
        'mag';...
        'primary_zsd';...
        'secondary_zsd';...
        'primary_roz';...
        'secondary_roz';...
        'primary_roz_x';...
        'primary_roz_y';...
        'secondary_roz_x';...
        'secondary_roz_y';...
        ...'backscatter';...
        'flowangle';...
        };
elseif V.probeType == 'S5'
    var ={...
        'streamwise';...
        'transverse';...
        'mag';...
        'primary_zsd';...
        'secondary_zsd';...
        'primary_roz';...
        'secondary_roz';...
        'primary_roz_x';...
        'primary_roz_y';...
        'secondary_roz_x';...
        'secondary_roz_y';...
        ...'backscatter';...
        'flowangle';...
        };
elseif V.probeType == 'RR'
    var ={...
        'streamwise';...
        'transverse';...
        'mag';...
        'primary_zsd';...
        'secondary_zsd';...
        'primary_roz';...
        'secondary_roz';...
        'primary_roz_x';...
        'primary_roz_y';...
        'secondary_roz_x';...
        'secondary_roz_y';...
        'backscatter';...
        'flowangle';...
        };
end
% Fr  - Window semi-length in the rows.
Fr = vwin; %
% Fc  - Window semi-length in the columns.
Fc = hwin; %

if Fr == 0 & Fc ~= 0
    errordlg('Both Vertical Smoothing Window and Horizontal Smoothing Window must be set to zero to turn off smoothing. Smoothing cannot be turned off in one direction only.' );
elseif Fr ~= 0 & Fc == 0
    errordlg('Both Vertical Smoothing Window and Horizontal Smoothing Window must be set to zero to turn off smoothing. Smoothing cannot be turned off in one direction only.');
end

for i = 1:numel(var)
    switch var{i}
        case{'streamwise'}  %Smooths the streamwise velocity
            if Fr == 0 & Fc == 0
                V.uSmooth = V.u;
            else
                if use_smooth2a
                    [V.uSmooth] = smooth2a(V.u,Fr,Fc);
                else
                    [V.uSmooth] = nanmoving_average2(V.u,Fr,Fc);
                end
            end
            
        case{'transverse'} %Smooths the transverse velocity
            if Fr == 0 & Fc == 0
                V.vSmooth = V.v;
            else
                if use_smooth2a
                    [V.vSmooth] = smooth2a(V.v,Fr,Fc);
                else
                    [V.vSmooth] = nanmoving_average2(V.v,Fr,Fc);
                end
            end
        case{'mag'} %Smooths the velocity magnitude
            if Fr == 0 & Fc == 0
                V.mcsMagSmooth = V.mcsMag;
            else
                if use_smooth2a
                    %[V.mcsMagSmooth] = smooth2a(V.mcsMag,Fr,Fc);  %Changed to
                    %use the components to smooths and then recompute. (PRJ,
                    %3-21-11)
                    V.mcsEastSmooth  = smooth2a(V.mcsEast,Fr,Fc);
                    V.mcsNorthSmooth = smooth2a(V.mcsNorth,Fr,Fc);
                else
                    %[V.mcsMagSmooth] = nanmoving_average2(V.mcsMag,Fr,Fc);
                    V.mcsEastSmooth  = nanmoving_average2(V.mcsEast,Fr,Fc);
                    V.mcsNorthSmooth = nanmoving_average2(V.mcsNorth,Fr,Fc);
                end
                [V.mcsMagSmooth] = sqrt(V.mcsEastSmooth .^2 + V.mcsNorthSmooth.^2);
            end
        case{'primary_zsd'}  %Smooths the primary velocity with zero secondary discharge definition
            if Fr == 0 & Fc == 0
                V.vpSmooth = V.vp;
            else
                if use_smooth2a
                    [V.vpSmooth] = smooth2a(V.vp,Fr,Fc);
                else
                    [V.vpSmooth] = nanmoving_average2(V.vp,Fr,Fc);
                end
            end
        case{'secondary_zsd'} %Smooths the secondary velocity with zero secondary discharge definition
            if Fr == 0 & Fc == 0
                V.vsSmooth = V.vs;
            else
                if use_smooth2a
                    [V.vsSmooth] = smooth2a(V.vs,Fr,Fc);
                else
                    [V.vsSmooth] = nanmoving_average2(V.vs,Fr,Fc);
                end
            end
        case{'primary_roz'}  %Smooths the primary velocity with Rozovskii definition
            if Fr == 0 & Fc == 0
                V.Roz.upSmooth = V.Roz.up;
            else
                if use_smooth2a
                    [V.Roz.upSmooth] = smooth2a(V.Roz.up,Fr,Fc);
                else
                    [V.Roz.upSmooth] = nanmoving_average2(V.Roz.up,Fr,Fc);
                end
            end
        case{'secondary_roz'} %Smooths the secondary velocity with Rozovskii definition
            if Fr == 0 & Fc == 0
                V.Roz.usSmooth = V.Roz.us;
            else
                if use_smooth2a
                    [V.Roz.usSmooth] = smooth2a(V.Roz.us,Fr,Fc);
                else
                    [V.Roz.usSmooth] = nanmoving_average2(V.Roz.us,Fr,Fc);
                end
            end
        case{'primary_roz_x'}  %Smooths the primary velocity with Rozovskii definition (downstream component)
            if Fr == 0 & Fc == 0
                V.Roz.upxSmooth = V.Roz.upx;
            else
                if use_smooth2a
                    [V.Roz.upxSmooth] = smooth2a(V.Roz.upx,Fr,Fc);
                else
                    [V.Roz.upxSmooth] = nanmoving_average2(V.Roz.upx,Fr,Fc);
                end
            end
        case{'primary_roz_y'}  %Smooths the primary velocity with Rozovskii definition (cross-stream component)
            if Fr == 0 & Fc == 0
                V.Roz.upySmooth = V.Roz.upy;
            else
                if use_smooth2a
                    [V.Roz.upySmooth] = smooth2a(V.Roz.upy,Fr,Fc);
                else
                    [V.Roz.upySmooth] = nanmoving_average2(V.Roz.upy,Fr,Fc);
                end
            end
        case{'secondary_roz_x'} %Smooths the secondary velocity with Rozovskii definition (downstream component)
            if Fr == 0 & Fc == 0
                V.Roz.usxSmooth = V.Roz.usx;
            else
                if use_smooth2a
                    [V.Roz.usxSmooth] = smooth2a(V.Roz.usx,Fr,Fc);
                else
                    [V.Roz.usxSmooth] = nanmoving_average2(V.Roz.usx,Fr,Fc);
                end
            end
        case{'secondary_roz_y'} %Smooths the secondary velocity with Rozovskii definition (cross-stream component)
            if Fr == 0 & Fc == 0
                V.Roz.usySmooth = V.Roz.usy;
            else
                if use_smooth2a
                    [V.Roz.usySmooth] = smooth2a(V.Roz.usy,Fr,Fc);
                else
                    [V.Roz.usySmooth] = nanmoving_average2(V.Roz.usy,Fr,Fc);
                end
            end
        case{'backscatter'} %Smooths the backscatter
            if Fr == 0 & Fc == 0
                V.mcsBackSmooth = V.mcsBack;
            else
                if use_smooth2a
                    [V.mcsBackSmooth] = smooth2a(V.mcsBack,Fr,Fc);
                else
                    [V.mcsBackSmooth] = nanmoving_average2(V.mcsBack,Fr,Fc);
                end
                
            end
        case{'flowangle'} %Smooths the flow direction
            if Fr == 0 & Fc == 0
                V.mcsDirSmooth = V.mcsDir;
            else
                %Must smooth velocity components and then compute flow direction
                if use_smooth2a
                    V.mcsNorthSmooth  = smooth2a(V.mcsNorth,Fr,Fc);
                    V.mcsEastSmooth   = smooth2a(V.mcsEast,Fr,Fc);
                else
                    V.mcsNorthSmooth  = nanmoving_average2(V.mcsNorth,Fr,Fc);
                    V.mcsEastSmooth   = nanmoving_average2(V.mcsEast,Fr,Fc);
                end
                V.mcsDirSmooth    = 90 - (atan2(V.mcsNorthSmooth, V.mcsEastSmooth))*180/pi; %Compute the atan from the velocity componentes, convert to radians, and rotate to north axis
                qindx = find(V.mcsDirSmooth < 0);
                if ~isempty(qindx)
                    V.mcsDirSmooth(qindx) = V.mcsDirSmooth(qindx) + 360;  %Must add 360 deg to Quadrant 4 values as they are negative angles from the +y axis
                end
            end
        case{'vorticity_vw'} %Smooths the vorticity using U,V
            if Fr == 0 & Fc == 0
                V.vorticity_vwSmooth = V.vorticity_vw;
            else
                if use_smooth2a
                    [V.vorticity_vwSmooth] = smooth2a(V.vorticity_vw,Fr,Fc);
                else
                    [V.vorticity_vwSmooth] = nanmoving_average2(V.vorticity_vw,Fr,Fc);
                end
            end
        case{'vorticity_zsd'} %Smooths the vorticity using Zero Secondary Discharge definition
            if Fr == 0 & Fc == 0
                V.vorticity_zsdSmooth = V.vorticity_zsd;
            else
                if use_smooth2a
                    [V.vorticity_zsdSmooth] = smooth2a(V.vorticity_zsd,Fr,Fc);
                else
                    [V.vorticity_zsdSmooth] = nanmoving_average2(V.vorticity_zsd,Fr,Fc);
                end
            end
        case{'vorticity_roz'} %Smooths the vorticity using Zero Secondary Discharge definition
            if Fr == 0 & Fc == 0
                V.vorticity_rozSmooth = V.vorticity_roz;
            else
                if use_smooth2a
                    [V.vorticity_rozSmooth] = smooth2a(V.vorticity_roz,Fr,Fc);
                else
                    [V.vorticity_rozSmooth] = nanmoving_average2(V.vorticity_roz,Fr,Fc);
                end
            end
    end
end

%Smooths the vertical velocity (Must always do it for inclusion into
%secondary vectors)
if Fr == 0 & Fc == 0
    V.wSmooth = V.w;
else
    if use_smooth2a
        [V.wSmooth] = smooth2a(V.w,Fr,Fc);
    else
        [V.wSmooth] = nanmoving_average2(V.w,Fr,Fc);
    end
end

% Smooth error velocity also
if Fr == 0 & Fc == 0
    V.mcsErrorSmooth = V.mcsError;
else
    if use_smooth2a
        [V.mcsErrorSmooth] = smooth2a(V.mcsError,Fr,Fc);
    else
        [V.mcsErrorSmooth] = nanmoving_average2(V.mcsError,Fr,Fc);
    end
end

%% Close
warning on
%disp('Smoothing Completed')
