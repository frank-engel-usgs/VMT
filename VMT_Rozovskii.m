function [V,log_text] = VMT_Rozovskii(V,A)
% Computes the frame of reference transpositon as described in Kenworthy
% and Rhoads (1998) ESPL using a Rozovskii type analysis.
%
% Notes:
%     -I extrapolate the velocity at the near surface bin to the water
%      surface for the depth averaging (ie, BC at u(z=0) = u(z=bin1))
%     -There are cases where the bin corresponding with the bed actually
%      contains flow data (i.e., not NaN or zero). For cases where the
%      blanking distance DOES exists, I have imposed a BC of U=0 at the bed,
%     -In cases where data goes all of the way to the bed, I have divided
%      the last bin's velocity by 2, essentially imposing a U=0 at the
%      boundary by extrapolating to the bottom of the bin.
%
% Written by:
% Frank L. Engel, USGS (fengel@usgs.gov)
% Last edited: F.L. Engel, USGS, 2/20/2013

%disp('Performing Rozovskii analysis...')
log_text = {'      Performing Rozovskii analysis...'};

% Calculate dy and dz for each meaurement point
dy=mean(diff(V.mcsDist(1,:)));%m
dz=mean(diff(V.mcsDepth(:,1)));%m

% Pull the velocity data, and convert NaNs to zeros (needed for proper
% depth integration to the boundary)
u = V.u; v = V.v;
idx = isnan(u) | isnan(v);
u(idx) = 0; v(idx) = 0;

% Pull depth data
d = V.mcsDepth;

% Pull the bed data
b = V.mcsBed;

% Work on each vertical (not necesarily the same as ensemble) seperately
for i = 1:size(u,2)
    % Finds closest cell to bed
    [~, array_position(i)]...
        = min(abs(d(:,i) - b(i)));
    for j = 1:array_position(i)
        if j == 1 % Near water surface
            % Compute first bin by exprapolating velocity to the water
            % surface. WSE = 0. Imposes BC u(z=0) = u(z=bin1)
            du_i(j,i) = u(j,i)*(d(j+1,i)-d(j,i))...
                + u(j,i)*(d(j,i)-dz/2-0);
            dv_i(j,i) = v(j,i)*(d(j+1,i)-d(j,i))...
                + v(j,i)*(d(j,i)-dz/2-0);
        elseif j < array_position(i) % Inbetween
            du_i(j,i) = u(j,i)*(d(j+1,i)-d(j-1,i))/2;
            dv_i(j,i) = v(j,i)*(d(j+1,i)-d(j-1,i))/2;
        elseif j == array_position(i) % Near bed
            indx = find(u(:,i) ~= 0);  %Revision PRJ 9-1-09
            if isempty(indx)
                du_i(:,i) = NaN;
                dv_i(:,i) = NaN;
            else
                l = indx(end);
                k = j - l;
                % Computes du from last good bin to the bed by linear
                % interpolation. IMPOSES BC: u=0 at the bed
                % Paints everything below last bin as NaN
                du_i(j-k+2:size(u,2),i) = NaN;
                dv_i(j-k+2:size(u,2),i) = NaN;
            end
        end
    end
    
    % Depth averaged quantities
    U(i) = nansum(du_i(:,i))/d(array_position(i),i);
    V1(i) = nansum(dv_i(:,i))/d(array_position(i),i);
    U_mag(i) = sqrt(U(i)^2+V1(i)^2); % resultant vector
    
    % Angle of resultant vector from a perpendicular line along the
    % transect
    phi(i) = atan(V1(i)/U(i));
    phi_deg(i) = phi(i).*180/pi;
    
    % Compute Rozovskii variables at each bin
    for j = 1:array_position(i)
        uu(j,i) = sqrt(u(j,i)^2+v(j,i)^2);
		if (u(j,i) < 0) && (v(j,i) < 0)
			theta(j,i) = atan(v(j,i)/u(j,i)) - pi();
		elseif (u(j,i) < 0) && (v(j,i) > 0)
			theta(j,i) = atan(v(j,i)/u(j,i)) + pi();
		else
			theta(j,i) = atan(v(j,i)/u(j,i));
		end
        theta_deg(j,i) = theta(j,i).*180/pi;
        up(j,i) = uu(j,i)*cos(theta(j,i)-phi(i));
        us(j,i) = uu(j,i)*sin(theta(j,i)-phi(i));
        upy(j,i) = up(j,i)*sin(phi(i));
        upx(j,i) = up(j,i)*cos(phi(i));
        usy(j,i) = us(j,i)*cos(phi(i));
        usx(j,i) = us(j,i)*sin(phi(i));
        depths(j,i) = d(j,i);
        
        % Compute d_us to check for zero secondary discharge constraint
        if j == 1 % Near water surface
            dus_i(j,i) = us(j,i)*(d(j+1,i)-d(j,i))...
                + us(j,i)*(d(j,i)-dz/2-0);
        elseif j < array_position(i) % Inbetween
            dus_i(j,i) = us(j,i)*(d(j+1,i)-d(j-1,i))/2;
        end
        % Sum dus_i - this should be near zero for each ensemble
        q_us(i) = nansum(dus_i(:,i));
    end
    
    % Resize variables to be the same as input grids
    uu(j+1:size(u,1),i) = NaN;
    theta(j+1:size(u,1),i) = NaN;
    theta_deg(j+1:size(u,1),i) = NaN;
    up(j+1:size(u,1),i) = NaN;
    us(j+1:size(u,1),i) = NaN;
    upy(j+1:size(u,1),i) = NaN;
    usy(j+1:size(u,1),i) = NaN;
    upx(j+1:size(u,1),i) = NaN;
    usx(j+1:size(u,1),i) = NaN;
    depths(j+1:size(u,1),i) = NaN;
    dus_i(j+1:size(u,1),i) = NaN;
end

% Display error message if rozovskii computation of q_us doesn't sum to
% zero
if q_us > 1e-4
    %disp('Warning: Rozovskii secondary velocities not satisfying continuity!')
    log_text = vertcat(log_text,...
        '      Warning: Rozovskii secondary velocities',... 
        '      not satisfying continuity!');
else
    %disp('Computation successfull: Rozovskii secondary velocities satisfy continuity')
    log_text = vertcat(log_text,...
        '      Computation successfull: Rozovskii',...
        '      secondary velocities',...
        '      satisfy continuity.');
end

% Rotate local velocity vectors into global coordinate system by
% determining the angle of the transect using endpoint locations. The
% function "vrotation" is a standard rotation matrix
XStheta = atan((V.mcsY(1,end)-V.mcsY(1,1))/(V.mcsX(1,end)-V.mcsX(1,1)));
XSalpha = XStheta - pi/2;
[ux, uy, uz] = vrotation(V.u,V.v,V.w,XSalpha);


% Write outputs to Roz substructure
V.Roz.U = U;
V.Roz.V = V1;
V.Roz.U_mag  = U_mag;
V.Roz.phi = phi;
V.Roz.phi_deg = phi_deg;
V.Roz.u = V.u;
V.Roz.v = V.v;
V.Roz.u_mag = u;
V.Roz.depth = depths;
V.Roz.theta = theta;
V.Roz.theta_deg = theta_deg;
V.Roz.up = up;
V.Roz.us = us;
V.Roz.upy = upy;
V.Roz.usy = usy;
V.Roz.upx = upx;
V.Roz.usx = usx;
V.Roz.ux = ux;
V.Roz.uy = uy;
V.Roz.uz = uz;
V.Roz.alpha = XSalpha;

%disp('Rozovskii analysis complete. Added .Roz structure to V data structure.')
log_text = vertcat(log_text, '      Rozovskii analysis complete.');
% directory = pwd;
% fileloc = [directory '\' filename '.mat'];
% disp(fileloc)
