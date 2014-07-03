function A = VMT_unitQcont(A,V,z)
% VMT_UNITQCONT applies unit discharge continuity correction MCS velocities
% This routine computes the correction, then applies it to the North and
% East velocity components of each ensemble and bin for the ADCP data. This
% routine runs BEFORE the data are gridded to the mean cross section, so
% if used, the correction applies to all subsequent computations (e.g., ZSD
% and Rozovskii decomposition).
% 
% DISCUSSION 
% In theory, the change in elevation in the streamwise direction
% should be zero (since we are creating a plane in the lateral direction).
% However, in practice, this may not be the case. Hopefully, the user has
% chosen an appropriate cross section location where the bed is not varying
% dramatically in the streamwise direction, but even still, some error may
% exist. One way to approach this potential error is to account for any
% changes in the mass flux between the sample location where data were
% collected (i.e., the actual ensemble) and the position on the mean cross
% section. This function corrects the mean cross section velocities,
% assuming that mass flux is constant in the streamwise direction.
% 
% Definition Sketch
% ==============================================
%                    ..     ^
%       Shiptrack  .        |
%            +     .        |
%            |      .       |
%            +-----> .      |
%                    .      |
%                    .      |
%                   .       |
%                  .        |
%                 .         | u2h2
%           u1h1 +----------+
%               .           |
%               .           |
%                .          |<-------+
%                 .         |        |
%                  .        |        |
%                    .      |        +
%                     .     |       MCS
%                      .    |
%                        .  v 
% 
% Under the assumption that mass flux (i.e., unit discharge) is constant in
% the streamwise direction:
%       qs1 = u1h1 = qs2 = u2h2 
% is independent of s, the streamwise direction
% 
% Therefore, we can correct u2 by
%               h1
%       u2 = u1----
%               h2  
% 
% For a further discussion, see:
%       Hoitink, A. J. F., F. A. Buschmann, and B. Vermeulen. 2009.
%           Continuous measurements of discharge from a horizontal acoustic
%           Doppler current profiler in a tidal river. WRR 45, W11406,
%           doi:10.1029/2009WR007791.
% 
% There are several reasons to be cautious in choosing to apply this
% correction: 
% 1.It makes the assumption that mass flux is constant in the
%   streamwise direction. This is probably true for well selected
%   cross-sections. But it could break down in cases where flow is strongly
%   convergent or divergent, or if the deviation of the shiptrack is too
%   great. 
% 2.Streamwise flow in situations of changing depths will accel./decell.
%   according to the Bernoulli principle- and this is the reason for the
%   correction. However, because of the beam spread, it is likely that
%   in these situations where streamwise depth is varying, the the depth
%   will be incorrectly estimated, and will lead to high or low biased
%   velocities (depending on whether depth is deepening/shoaling).
% 3.Essentially, this amounts to correction of the data by estimating the
%   depth at the mean cross section. If the coverage of the shiptracks are
%   sparse for a certain region of the mean cross section, the quality of
%   the depth estimation will be significantly affected, leading to a bias
%   in the correction. A situation where shiptracks may not perfectly
%   represent the bed is near the bank, with flow seperation. Here, ship
%   tracks often drift off the best fit line computed by VMT, since the
%   majority of the data are better clustered there. In this case, the
%   correction will become biased by the estimation of the depth at that
%   location.
% 
% Frank L. Engel, USGS
% 
% SEE ALSO: interp1, nanmean, smooth

% disp('Applying streamwise unit discharge correction...')
% Create matrix of all depths, with their stations
h2_interp = [];
for zi = 1:z
    A(zi).Comp.h1 = nanmean(A(zi).Nav.depth,2)';
    h2_interp = [h2_interp; A(zi).Comp.dl A(zi).Comp.h1'];
end

% Sort it by station
[~,idx] = sort(h2_interp(:,1));
h2_interp = h2_interp(idx,:);

% Remove duplicate stations (to avoid issues during interp1)
uniqs = find(diff(h2_interp(:,1)) ~= 0);
h2_interp = h2_interp([1 (uniqs+1)'],:);

% Remove nans in depths to aviod issues during smoothing
h2_interp = h2_interp(~isnan(h2_interp(:,2)),:);

% Smooth the bed, to get a representation of the MCS bed Estimate a
% smoothing span which will approximate that created by averaging the bed
% at each grid node.
span = 5*ceil(A(1).hgns/(V.meddens+V.stddens));
%h2_interp(:,3) = smooth(h2_interp(:,2),span);
%Replaced smooth as it did not handle edges well (PRJ, 10-19-12)
[h2_interp(:,3),~] = nanmoving_average(h2_interp(:,2),span/2);

if 0 %Plot to check
    figure(8); clf
    plot(h2_interp(:,1),h2_interp(:,2),'r.'); hold on
    plot(h2_interp(:,1),h2_interp(:,3),'k-');
    set(gca,'Ydir','reverse')
end

% Do the computations
PD = [];  %Percent diff 
for zi = 1:z
    % Ensure that the stationing is in the right direction, and then write
    % h1 to the A.Comp struct
    h1_sort = [A(zi).Comp.dl nanmean(A(zi).Nav.depth,2)]; 
    [~,h1_idx] = sort(h1_sort(:,1));
    h1_sort = h1_sort(h1_idx,:);
    A(zi).Comp.h1 = h1_sort(:,2)';
    
    % Interpolate the bed at the MCS for each ensemble in the current
    % transect
    A(zi).Comp.h2 = interp1(...
        h2_interp(:,1),...
        h2_interp(:,3),...
        A(zi).Comp.itDist(1,:));
    
    % To compute the correction, we have to get the intrinsic coordinates
    % of the velocity vectors (neglecting vertical component). Technically,
    % we are not correcting for streamwise changes, assuming that
    % streamwise is taken exactly perpendicular to the MCS
    A(zi).Comp.psi = V.phi-A(zi).Clean.vDir;
    A(zi).Comp.u1 = cosd(A(zi).Comp.psi).*A(zi).Clean.vMag;
    A(zi).Comp.v1 = sind(A(zi).Comp.psi).*A(zi).Clean.vMag;
    A(zi).Comp.hratio = repmat(A(zi).Comp.h1./A(zi).Comp.h2,size(A(zi).Comp.itDist,1),1);
    
    % Now we can compute the corrected velocities
    A(zi).Comp.u2 = A(zi).Comp.u1.*A(zi).Comp.hratio;
    
    % Save the percent differnce for statisical analysis
    PD = [PD; (A(zi).Comp.hratio(1,:)' - 1)*100];
    %A(zi).Comp.w1 = A(zi).Wat.vVert;
    
    if 0 % Plot to check
        figure(9); clf
        plot(A(zi).Comp.itDist(1,:),A(zi).Comp.h1,'r.-'); hold on
        plot(A(zi).Comp.itDist(1,:),A(zi).Comp.h2,'k.-');
        set(gca,'Ydir','reverse')
        pause
    end
    
end

% Report the percent difference stats & plot profiles (for testing)
if 0
    PDmed = nanmedian(PD);
    PDmax = nanmax(PD);
    PDmin = nanmin(PD);
    scrnwrt = {['Median Percent Difference (%) = ' num2str(PDmed)];...
               ['Max Percent Difference (%) = ' num2str(PDmax)];...
               ['Min Percent Difference (%) = ' num2str(PDmin)]};   
    figure(10); clf
    for zi = 1:z
        plot(A(zi).Comp.itDist(1,:),(A(zi).Comp.hratio(1,:) - 1)*100,'k-')
        hold on;
        xlabel('Distance from Left Bank, in meters')
        ylabel('Percent Difference in Velocity')
    end
    grid on
    ylim([min([min(PD) -50]) max([max(PD) 50])])
    text(0.1*mean(A(1).Comp.itDist(1,:)),25,scrnwrt)
    set(gca,'YMinorGrid','on')
end

% Rotate the new corrected u,v back into the East,North frame of reference.
% Note that to recover the components, we need to rotate to -V.theta
% degrees.

% Rotation matrix
R = [cos(-geo2arideg(V.theta)*pi/180) sin(-geo2arideg(V.theta)*pi/180);...
    -sin(-geo2arideg(V.theta)*pi/180) cos(-geo2arideg(V.theta)*pi/180)]';

% Overwrite the original East,North components from the original ASC inputs
for zi = 1:z
    % The vectors to be rotated
    N = [A(zi).Comp.u2(:) A(zi).Comp.v1(:)];
    % Do the rotation
    T = N*R;
    
%     if V.phi >= 0 && V.phi <= 180 
%         East = -reshape(T(:,2),size(A(zi).Clean.vEast));
%     elseif V.phi > 180 && V.phi < 360
%         East = reshape(T(:,2),size(A(zi).Clean.vEast));
%     end
    
    if V.phi >90 && V.phi < 270 
        North = -reshape(T(:,1),size(A(zi).Clean.vNorth));
        East  = reshape(T(:,2),size(A(zi).Clean.vEast));
    elseif V.phi >= 270 || V.phi <= 90
        North = reshape(T(:,1),size(A(zi).Clean.vNorth));
        East = -reshape(T(:,2),size(A(zi).Clean.vEast));
    end
    % Write the result back to the A struct
    A(zi).Clean.vEast = East;
    A(zi).Clean.vNorth = North;
    clear N T East North 
end