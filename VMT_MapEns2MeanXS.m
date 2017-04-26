function [A,V,log_text] = VMT_MapEns2MeanXSV2(z,A,setends,start_bank)
% Fits multiple transects at a single location with a single
% line and maps individual ensembles to this line. Inputs are number of
% files (z) and data matrix (Z)(see ReadFiles.m). Output is the updated
% data matrix with new mapped variables.
%
% If supplied, the function has the capability to set the endpoints of the
% mean cross section
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-9-08 
% Last modified: F.L. Engel, USGS, 2/20/2013



%% Determine the best fit mean cross-section line from multiple transects
% initialize vectors for concatenation

x = [];
y = [];
% figure(1); clf
% set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
for zi = 1 : z
    
    % concatenate coords into a single column vector for regression
    x=cat(1,x,A(zi).Comp.xUTM);
    y=cat(1,y,A(zi).Comp.yUTM);

%     figure(1); hold on
%     plot(A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,'b'); hold on
    
    % Plot the various reject and/or adjusted GPS location data for
    % reference
    %plot(A(zi).Comp.xUTM,A(zi).Comp.yUTM,'r'); hold on
%     plot(...
%         ...A(zi).Comp.xUTMraw(A(zi).Comp.gps_reject_locations),...
%         ...A(zi).Comp.yUTMraw(A(zi).Comp.gps_reject_locations),'g.',...
%         ...A(zi).Comp.xUTMraw(A(zi).Comp.gps_repeat_locations),...
%         ...A(zi).Comp.yUTMraw(A(zi).Comp.gps_repeat_locations),'y.',...
%         A(zi).Comp.xUTMraw(A(zi).Comp.gps_fly_aways),...
%         A(zi).Comp.yUTMraw(A(zi).Comp.gps_fly_aways),'r.')
    
    %Find the mean east and north velocity for eact transect (for mean flow
    %direction)
    mVe(zi) = nanmean(nanmean(A(zi).Clean.vEast,1));
    mVn(zi) = nanmean(nanmean(A(zi).Clean.vNorth,1));
              
end

% Gets a user text file with fixed cross section end points
if setends
    [x,y] = loadUserSetEndpoints(); % subfunction
%     figure(1); hold on
%     plot(x,y,'go','MarkerSize',10); hold on
    
    % Save the shorepath
    % if exist('LastDir.mat') == 2
        % save('LastDir.mat','endspath','-append')
    % else
        % save('LastDir.mat','endspath')
    % end
end

% Compute the mean flow direction for all the transects in geographic angle
mfdVe = mean(mVe);  %Mean east velocity for all the transects
mfdVn = mean(mVn);  %Mean north velocity for all the transects
V.mfd = ari2geodeg((atan2(mfdVn, mfdVe))*180/pi);  % Mean flow direction in geographic angle

% find the equation of the best fit line
xw = min(x); xe = max(x);
ys = min(y); yn = max(y);
xrng = xe - xw;
yrng = yn - ys;

if xrng >= yrng %Fit based on coordinate with larger range of values (original fitting has issues with N-S lines because of repeated X values), PRJ 12-12-08
    [P,S] = polyfit(x,y,1);
%     figure(1); hold on; 
%     plot(x,polyval(P,x),'g-')
    V.m = P(1);
    V.b = P(2);
    dx = xe-xw;
    dy = polyval(P,xe)-polyval(P,xw);
else
    [P,S] = polyfit(y,x,1);
%     figure(1); hold on; 
%     plot(polyval(P,y),y,'g-')
    V.m = 1/P(1);           %Reformat slope and intercept in terms of y= fn(x) rather than x = fn(y)
    V.b = -P(2)/P(1);
    dx = polyval(P,yn)-polyval(P,ys);
    dy = yn-ys;
%     if V.m >= 0
%         dy = yn-ys;
%     elseif V.m < 0
%         dy = ys-yn;
%     end
end

% Determine the distance between the mean cross-section
% endpoints
dl = sqrt(dx^2+dy^2);

% Compute the angle of the MCS in geographic angle
if V.m >= 0
    V.theta = ari2geodeg(atand(V.m)); 
elseif V.m < 0
    V.theta = ari2geodeg(atand(V.m));
end

% Determine the direction of the streamwise coordinate, which
% is taken as perpendicular to the mean cross section. Theta is
% expressed in geographical (N = 0 deg, clockwise positive)
% coordinates. This method uses a vector based approach which
% is insensitive to orientation of the cross section.

% First compute the normal unit vector to the mean
% cross section
N = [-dy dx]./sqrt(dx^2+dy^2);

% Compute the mean flow direction in the cross section. To do
% this, we also have to convert from geographic angle to
% arimetic angle
arimfddeg = geo2arideg(V.mfd);
[xmfd,ymfd] = pol2cart(arimfddeg*pi/180,1);
M = [xmfd ymfd];

% Now compute the angle between the normal and mean flow
% direction unit vectors
vdif = acos(dot(N,M)/(norm(N)*norm(M)))*180/pi;

% If the angle is greater than 90 degs, the normal vector needs
% to be reversed before resolving the u,v coordinates
if vdif >= 90
    N = -N;
%     N = [dy -dx]./sqrt(dx^2+dy^2);
end

% Plot N and M to check (scale of the vectors is 10% of the
% total length of the cross section)
midy = ys+abs(yrng)/2;
midx = xw+xrng/2;
% figure(1); hold on;
% quiver(...
%     midx,midy,N(1)*dl*0.1,...
%     N(2)*dl*0.1,1,'k')
% quiver(...
%     midx,midy,M(1)*dl*0.1,...
%     M(2)*dl*0.1,1,'r')

% Geographic angle of the normal vector to the cross section
V.phi = ari2geodeg(cart2pol(N(1),N(2))*180/pi);
V.N   = N;
V.M   = M;

clear x y stats whichstats zi

%% Map ensembles to mean c-s line
% Determine the point (mapped ensemble point) where the equation of the 
% mean cross-section line intercepts a line perpendicular to the mean
% cross-section line passing through an ensemble from an individual
% transect (see notes for equation derivation)

for zi = 1 : z
    
    A(zi).Comp.xm = ((A(zi).Comp.xUTM-V.m.*V.b+V.m.*A(zi).Comp.yUTM)...
        ./(V.m.^2+1));
    A(zi).Comp.ym = ((V.b+V.m.*A(zi).Comp.xUTM+V.m.^2.*A(zi).Comp.yUTM)...
        ./(V.m.^2+1));

    %A(zi).Comp.h1 = nanmean(A(zi).Nav.depth,2)';
end


%Plot data to check
xensall = [];
yensall = [];
for zi = 1 : z
%   plot(A(zi).Comp.xm,A(zi).Comp.ym,'b.')
  xensall    = [xensall; A(zi).Comp.xm];
  yensall    = [yensall; A(zi).Comp.ym];
end
% plot(A(3).Comp.xm,A(3).Comp.ym,'xg')
% plot(A(4).Comp.xm,A(4).Comp.ym,'oy')
% xlabel('UTM Easting (m)')
% ylabel('UTM Northing (m)')
% box on
% grid on
%Plot a legend in Figure 1
%figure(1); hold on
%legend('Shoreline','GPS(corr)','GPS(raw)','Best Fit','Trans 1
%(mapped)','Other Trans (mapped)')

%Compute the median distance between mapped points
Dmat = [xensall yensall];
if xrng > yrng
    Dmat = sortrows(Dmat,1);
else
    Dmat = sortrows(Dmat,2);
end
dxall      = diff(Dmat(:,1));
dyall      = diff(Dmat(:,2));
densall    = sqrt(dxall.^2 + dyall.^2);
V.meddens  = median(densall);
V.stddens  = std(densall);
% disp(['Median Spacing Between Mapped Ensembles = ' num2str(V.meddens) ' m'])
% disp(['Standard Deviation of Spacing Between Mapped Ensembles = ' num2str(V.stddens) ' m'])
% disp(['Recommended Grid Node Spacing > ' num2str(V.meddens + V.stddens) ' m'])

%Display in message box for compiled version
msg_string = {['Median Spacing Between Mapped Ensembles = ' num2str(V.meddens) ' m'],...
    ['Standard Deviation of Spacing Between Mapped Ensembles = ' num2str(V.stddens) ' m'],...
    ['Recommended Grid Node Spacing > ' num2str(V.meddens + V.stddens) ' m']};
% msgbox(msg_string,'VMT Grid Node Spacing','help','replace');
log_text = {...
    ['      Median Spacing Between Mapped Ensembles = ' num2str(V.meddens) ' m'];...
    ['      Standard Deviation of Spacing Between Mapped Ensembles = ' num2str(V.stddens) ' m'];...
    ['      Recommended Grid Node Spacing > ' num2str(V.meddens + V.stddens) ' m']};
    

%% Determine location of mapped ensemble points for interpolating
% For all transects

% Determine the end points of the mean cross-section line
% Initialize variable with mid range value
V.xe = mean(A(1).Comp.xm);
V.ys = mean(A(1).Comp.ym);
V.xw = mean(A(1).Comp.xm);
V.yn = mean(A(1).Comp.ym);

for zi = 1 : z
    
    V.xe = max(max(A(zi).Comp.xm),V.xe);
    V.ys = min(min(A(zi).Comp.ym),V.ys);
    V.xw = min(min(A(zi).Comp.xm),V.xw);
    V.yn = max(max(A(zi).Comp.ym),V.yn);
    
end

% Determine the distance between the mean cross-section endpoints
V.dx = V.xe-V.xw;
V.dy = V.yn-V.ys;
V.dl = sqrt(V.dx.^2+V.dy.^2);

% Check if the user wants to manually set the start bank or use the flow
% direction. 
% If Auto: Use the correctly oriented normal vector, or rather V.phi, to
% set the start bank so we are always starting on the left bank looking
% downstream (PRJ, 10-17-12)
V = setStation(V,start_bank); % Subfunction

% Occasionally, the GPS location of an esemble will be the same between two
% or more ensembles. Find those ensembles, and interpolate a new GPS
% position based on adjacent good GPS positions.
A = interpBadGPS(A,V,z); % Subfunction


% clear zi i k check




%%%%%%%%%%%%%%%%
% SUBFUNCTIONS %
%%%%%%%%%%%%%%%%
function [x,y] = loadUserSetEndpoints()
% Check to see if there is a Pref point to endpoint file
setendpoints = getpref('VMT','setendpoints');

[endsfile,endspath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},...
    'Select Endpoint Text File',fullfile(setendpoints.path,setendpoints.file));
data = dlmread(fullfile(endspath,endsfile));
x = data(:,1);
y = data(:,2);

setendpoints.path = endspath;
setendpoints.file = endsfile;
setpref('VMT','setendpoints',setendpoints)

function A = interpBadGPS(A,V,z)
for zi = 1 : z
    
    % Compute the change in X and Y from the start point to each observation
    A(zi).Comp.dx = abs(V.xLeftBank - A(zi).Comp.xm);  %Revised (PRJ, 10-17-12)
    A(zi).Comp.dy = abs(V.yLeftBank - A(zi).Comp.ym);
    
    % Determine the distance in meters from the left bank mean
    % cross-section point to the mapped ensemble point for an individual
    % transect
    A(zi).Comp.dl = sqrt(A(zi).Comp.dx.^2+A(zi).Comp.dy.^2);
    
    % Sort vectors by dl
    [A(zi).Comp.dlsort,A(zi).Comp.vecmap] = sort(A(zi).Comp.dl,'ascend');
    
    % Map indices  %FIXME  This computation is VERY slow.  Suggest revising
    % for speed
    % FLE 12/10: This is fixed. The loop was to build a vecor map. This is
    % an included output of sort.
    %     for i = 1 : A(zi).Sup.noe
    %         for k = 1 : A(zi).Sup.noe
    %
    %             if A(zi).Comp.dlsort(i,1) == A(zi).Comp.dl(k,1)
    %                 A(zi).Comp.vecmap(i,1) = k;
    %
    %             end
    %         end
    %     end
    
    % GPS position fix
    % if distances from the left bank are the same for two ensembles the
    % the position of the right most ensemble is interpolated from adjacent
    % ensembles
    % check for repeat values of distance
    chk(:,1)=[1; diff(A(zi).Comp.dlsort)];
    
    % identify repeat values
    A(zi).Comp.sd = (chk==0) > 0;
    
    % if repeat values exist interpolate distances from adjacent ensembles
    if any(A(zi).Comp.sd)
        
        % bracket repeat sections
        [I,J] = ind2sub(size(A(zi).Comp.sd),find(A(zi).Comp.sd==1));
        df=diff(I);
        numberBreaks=sum(df>1)+1;
        [I2,J2] = ind2sub(size(df),find(df>1));
        
        idxBeginBracket(1)=(I(1)-1);
        
        for n = 2 : numberBreaks
            idxBeginBracket(n)=(I(I2(n-1)+1)-1);
        end
        
        for n = 1 : numberBreaks -1
            idxEndBracket(n)=(I(I2(n))+1);
        end
        
        idxEndBracket(numberBreaks)=I(end)+1;
        
        % interpolate repeat values
        A(zi).Comp.dlsortgpsfix = A(zi).Comp.dlsort;
        
        for i = 1 : numberBreaks
            for j = idxBeginBracket(i)+1 : idxEndBracket(i)-1
                % interpolate
                if idxBeginBracket(i) > 0 && idxEndBracket(i) <= length(A(zi).Nav.lat_deg)
                    
                    den=(idxEndBracket(i)-idxBeginBracket(i));
                    num2=j-idxBeginBracket(i);
                    num1=idxEndBracket(i)-j;
                    
                    A(zi).Comp.dlsortgpsfix(j,1)=...
                        (num1/den).*A(zi).Comp.dlsort(idxBeginBracket(i))+...
                        (num2/den).*A(zi).Comp.dlsort(idxEndBracket(i));
                    
                end
                
                % extrapolate end
                if idxEndBracket(i) > length(A(zi).Nav.lat_deg)
                    
                    numex=idxEndBracket(i)-length(A(zi).Nav.lat_deg);
                    
                    A(zi).Comp.dlsortgpsfix(j,1)=numex.*...
                        (A(zi).Comp.dlsort(idxBeginBracket(i))-...
                        A(zi).Comp.dlsort(idxBeginBracket(i)-1))+...
                        A(zi).Comp.dlsort(idxBeginBracket(i));
                end
            end
        end
        
    % No duplicate GPS points    
    else 
        A(zi).Comp.dlsortgpsfix = A(zi).Comp.dlsort;
    end
    
    % Determine velocity vector grid for individual transects
    % Previous method used meshgrid. Now, tfile reads the binDepths
    % dynamically (for case of RiverRay), thus it's faster to use repmat
    % for itDist, and just assign itDepth. [FLE, 3/25/2014]
%     [A(zi).Comp.itDist, ~] = ...
%         meshgrid(A(zi).Comp.dlsortgpsfix,A(zi).Wat.binDepth(:,1));
    A(zi).Comp.itDist  = repmat(A(zi).Comp.dlsortgpsfix',size(A(zi).Wat.binDepth,1),1);
    A(zi).Comp.itDepth = A(zi).Wat.binDepth(:,A(zi).Comp.vecmap);
    %A(zi).Comp.itDepth = A(zi).Wat.binDepth;
    
    clear I I2 J J2 bg chk df ed i j nbrk xUTM yUTM n zi...
        den num2 num1 numex
    
end

function V = setStation(V,start_bank)
V.startBank = start_bank;
switch start_bank
    case 'auto'
        V = leftStation(V);
    case 'left_bank'
        V = leftStation(V);
    case 'right_bank'
        V = rightStation(V);
end

function V = leftStation(V)
if V.phi > 0 && V.phi < 90 %PHI quadrant 1
    V.xLeftBank     = V.xw;
    V.yLeftBank     = V.yn;
    V.xRightBank    = V.xe;
    V.yRightBank    = V.ys;
elseif V.phi > 90 && V.phi < 180 %PHI quadrant 2
    V.xLeftBank     = V.xe;
    V.yLeftBank     = V.yn;
    V.xRightBank    = V.xw;
    V.yRightBank    = V.ys;
elseif V.phi > 180 && V.phi < 270 %PHI quadrant 3
    V.xLeftBank     = V.xe;
    V.yLeftBank     = V.ys;
    V.xRightBank    = V.xw;
    V.yRightBank    = V.yn;
elseif V.phi > 270 && V.phi < 360 %PHI quadrant 4
    V.xLeftBank     = V.xw;
    V.yLeftBank     = V.ys;
    V.xRightBank    = V.xe;
    V.yRightBank    = V.yn;
elseif V.phi == 0 %Set special cases
    V.xLeftBank     = V.xw;
    V.yLeftBank     = V.yn; %Does not matter if use N or S point (same)
    V.xRightBank    = V.xe;
    V.yRightBank    = V.ys;
elseif V.phi == 90
    V.xLeftBank     = V.xe; %Does not matter if use E or W point (same)
    V.yLeftBank     = V.yn;
    V.xRightBank    = V.xw;
    V.yRightBank    = V.ys;
elseif V.phi == 180
    V.xLeftBank     = V.xe;
    V.yLeftBank     = V.yn; %Does not matter if use N or S point (same)
    V.xRightBank    = V.xw;
    V.yRightBank    = V.ys;
elseif V.phi == 270
    V.xLeftBank     = V.xe; %Does not matter if use E or W point (same)
    V.yLeftBank     = V.ys;
    V.xRightBank    = V.xw;
    V.yRightBank    = V.yn;
end

function V = rightStation(V)
if V.phi > 0 && V.phi < 90 %PHI quadrant 1
    V.xLeftBank     = V.xe;
    V.yLeftBank     = V.ys;
    V.xRightBank    = V.xw;
    V.yRightBank    = V.yn;
elseif V.phi > 90 && V.phi < 180 %PHI quadrant 2
    V.xLeftBank     = V.xw;
    V.yLeftBank     = V.ys;
    V.xRightBank    = V.xe;
    V.yRightBank    = V.yn;
elseif V.phi > 180 && V.phi < 270 %PHI quadrant 3
    V.xLeftBank     = V.xw;
    V.yLeftBank     = V.yn;
    V.xRightBank    = V.xe;
    V.yRightBank    = V.ys;
elseif V.phi > 270 && V.phi < 360 %PHI quadrant 4
    V.xLeftBank     = V.xe;
    V.yLeftBank     = V.yn;
    V.xRightBank    = V.xw;
    V.yRightBank    = V.ys;
elseif V.phi == 0 %Set special cases
    V.xLeftBank     = V.xe;
    V.yLeftBank     = V.ys; %Does not matter if use N or S point (same)
    V.xRightBank    = V.xw;
    V.yRightBank    = V.yn;
elseif V.phi == 90
    V.xLeftBank     = V.xw; %Does not matter if use E or W point (same)
    V.yLeftBank     = V.ys;
    V.xRightBank    = V.xe;
    V.yRightBank    = V.yn;
elseif V.phi == 180
    V.xLeftBank     = V.xw;
    V.yLeftBank     = V.ys; %Does not matter if use N or S point (same)
    V.xRightBank    = V.xe;
    V.yRightBank    = V.yn;
elseif V.phi == 270
    V.xLeftBank     = V.xw; %Does not matter if use E or W point (same)
    V.yLeftBank     = V.yn;
    V.xRightBank    = V.xe;
    V.yRightBank    = V.ys;
end