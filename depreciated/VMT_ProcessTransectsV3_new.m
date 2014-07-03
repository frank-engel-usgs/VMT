function [A,V] = VMT_ProcessTransectsV3_new(z,A,setends)
% Not used by current version
%This routine acts as a driver program to process multiple transects at a
%single cross-section for velocity mapping.

%V2 adds the cpability to set the endpoints of the mean cross section

%V3 adds the Rozovskii computations for secondary flow. 8/31/09

%Among other things, it:

% Determines the best fit mean cross-section line from multiple transects
% Map ensembles to mean c-s line
% Determine uniform mean c-s grid for vector interpolating
% Determine location of mapped ensemble points for interpolating
% Interpolate individual transects onto uniform mean c-s grid
% Average mapped mean cross-sections from individual transects together 
% Rotate velocities into u, v, and w components


%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08 

disp('Processing Data...')
% warning off
%% Map ensembles to mean cross-section

[A,V] = VMT_MapEns2MeanXSV2(z,A,setends);

%% Grid the measured data along the mean cross-section
%[A,V] = VMT_GridData2MeanXS(z,A,V);
[A,V] = VMT_GridData2MeanXS(z,A,V);

%% Computes the mean data for the mean cross-section 
%[A,V] = VMT_CompMeanXS(z,A,V);
[A,V] = VMT_CompMeanXS_old(z,A,V);

%% Decompose the velocities into u, v, and w components
[A,V] = VMT_CompMeanXS_UVW(z,A,V);

%% Decompose the velocities into primary and secondary components
[A,V] = VMT_CompMeanXS_PriSec(z,A,V);

%% Perform the Rozovskii computations
V = VMT_RozovskiiV2(V,A);

%%
%figure(4); clf
%plot3(V.mcsX,V.mcsY,V.mcsDepth(1))
disp('Processing Completed')

%% Notes:

%1. I removed scripts at the end of the original code that computes
%standard deviations (12-9-08)

% else
%     
% disp('Processing Data...')
% %% Map ensembles to mean cross-section
% hf = VMT_CreatePlotDisplay('shiptracks');
% 
% [A,V] = VMT_MapEns2MeanXSV2_PDF(hf,z,A,setends);
% 
% %% Grid the measured data along the mean cross-section
% %[A,V] = VMT_GridData2MeanXS(z,A,V);
% [A,V] = VMT_GridData2MeanXS_PDF(hf,z,A,V);
% 
% return
% %% Computes the mean data for the mean cross-section 
% %[A,V] = VMT_CompMeanXS(z,A,V);
% [A,V] = VMT_CompMeanXS_old(z,A,V);
% 
% %% Decompose the velocities into u, v, and w components
% [A,V] = VMT_CompMeanXS_UVW(z,A,V);
% 
% %% Decompose the velocities into primary and secondary components
% [A,V] = VMT_CompMeanXS_PriSec(z,A,V);
% 
% %% Perform the Rozovskii computations
% V = VMT_RozovskiiV2(V,A);
% 
% %%
% %figure(4); clf
% %plot3(V.mcsX,V.mcsY,V.mcsDepth(1))
% disp('Processing Completed')
% 
% %% Notes:
% 
% %1. I removed scripts at the end of the original code that computes
% %standard deviations (12-9-08)
% 
% end

%==========================================================================
function [A,V] = VMT_MapEns2MeanXSV2(z,A,setends)

%This routine fits multiple transects at a single location with a single
%line and maps individual ensembles to this line. Inputs are number of files (z) and data matrix (Z)(see ReadFiles.m).
%Output is the updated data matrix with new mapped variables. 

%V2 adds the capability to set the endpoints of the mean cross section

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08 

%% Determine the best fit mean cross-section line from multiple transects
% initialize vectors for concatenation

x = [];
y = [];
% figure(1); clf
% set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
mfd = zeros(1,z);
for zi = 1 : z
    
    % concatenate coords into a single column vector for regression
    x = cat(1,x,A(zi).Comp.xUTM);
    y = cat(1,y,A(zi).Comp.yUTM);

%     figure(1); hold on
%     %plot(A(zi).Comp.xUTM,A(zi).Comp.yUTM,'r'); hold on
%     plot(A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,'b'); hold on
    
    %Find the mean flow direction for each transect
    mfd(zi) = nanmean(nanmean(A(zi).Clean.vDir,1)); 
end
V.mfd = nanmean(mfd); % Mean flow direction for all the transects

if setends  %Gets a user text file with fixed cross section end points 
    
    defaultpath = 'C:\';
    defaultpath = pwd;
    endspath = [];
    if exist('\VMT\LastDir.mat') == 2
        load('VMT\LastDir.mat');
        if exist(endspath) == 7
            [file,endspath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Endpoint Text File',endspath);       
        else
            [file,endspath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Endpoint Text File',defaultpath);
        end
    else
        [file,endspath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Endpoint Text File',defaultpath);
    end
    
    if ischar(file)
        infile = [endspath file];
        %[file,path] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Endpoint Text File');
        %infile = [path file];
        disp('Loading Endpoint File...' );
        disp(infile);
        data = dlmread(infile);
        x = data(:,1);
        y = data(:,2);
        figure(1); hold on
        plot(x,y,'go','MarkerSize',10); hold on
    end
end 

% find the equation of the best fit line 
xrng = max(x) - min(x);
yrng = max(y) - min(y);

if xrng >= yrng %Fit based on coordinate with larger range of values (original fitting has issues with N-S lines because of repeated X values), PRJ 12-12-08
    [P,~] = polyfit(x,y,1);
%     figure(1); hold on; 
%     plot(x,polyval(P,x),'g-')
    V.m = P(1);
    V.b = P(2);
else
    [P,~] = polyfit(y,x,1);
%     figure(1); hold on; 
%     plot(polyval(P,y),y,'g-')
    V.m = 1/P(1);           %Reformat slope and intercept in terms of y= fn(x) rather than x = fn(y)
    V.b = -P(2)/P(1);
end

%Former method commented out
% whichstats = {'tstat','yhat'};
% stats = regstats(y,x,'linear', whichstats);
% 
% % mean cross-section line slope and intercept
% V.m = stats.tstat.beta(2);
% V.b = stats.tstat.beta(1);

clear x y stats whichstats zi

%% Map ensembles to mean c-s line
% Determine the point (mapped ensemble point) where the equation of the 
% mean cross-section line intercepts a line perpendicular to the mean
% cross-section line passing through an ensemble from an individual
% transect (see notes for equation derivation)

for zi = 1:z
    A(zi).Comp.xm = ((A(zi).Comp.xUTM-V.m.*V.b+V.m.*A(zi).Comp.yUTM)...
        ./(V.m.^2+1));
    A(zi).Comp.ym = ((V.b+V.m.*A(zi).Comp.xUTM+V.m.^2.*A(zi).Comp.yUTM)...
        ./(V.m.^2+1));
end

%Plot data to check
xensall = [];
yensall = [];
for zi = 1:z
%   plot(A(zi).Comp.xm,A(zi).Comp.ym,'b.')
  xensall = [xensall; A(zi).Comp.xm];
  yensall = [yensall; A(zi).Comp.ym];
end
% % plot(A(3).Comp.xm,A(3).Comp.ym,'xg')
% % plot(A(4).Comp.xm,A(4).Comp.ym,'oy')
% xlabel('UTM Easting (m)')
% ylabel('UTM Northing (m)')
% box on
% grid on
% %Plot a legend in Figure 1
% %figure(1); hold on
% %legend('Shoreline','GPS(corr)','GPS(raw)','Best Fit','Trans 1
% %(mapped)','Other Trans (mapped)')

%Compute the median distance between mapped points
Dmat = [xensall yensall];
if xrng > yrng
    Dmat = sortrows(Dmat,1);
else
    Dmat = sortrows(Dmat,2);
end
dxall = diff(Dmat(:,1));
dyall = diff(Dmat(:,2));
densall = sqrt(dxall.^2 + dyall.^2);
V.meddens = median(densall);
V.stddens = std(densall);
disp(['Median Spacing Between Mapped Ensembles = ' num2str(V.meddens) ' m'])
disp(['Standard Deviation of Spacing Between Mapped Ensembles = ' num2str(V.stddens) ' m'])
disp(['Recommended Grid Node Spacing > ' num2str(V.meddens + V.stddens) ' m'])

%Display in message box for compiled version
msg_string = {['Median Spacing Between Mapped Ensembles = ' num2str(V.meddens) ' m'],...
    ['Standard Deviation of Spacing Between Mapped Ensembles = ' num2str(V.stddens) ' m'],...
    ['Recommended Grid Node Spacing > ' num2str(V.meddens + V.stddens) ' m']};
msgbox(msg_string,'VMT Grid Node Spacing','help','replace');

%%Save the shorepath
if setends
    if exist('LastDir.mat','dir')
        save('LastDir.mat','endspath','-append')
    else
        save('LastDir.mat','endspath')
    end
end

%==========================================================================
function [A,V] = VMT_GridData2MeanXS(z,A,V)

%This routine generates a uniformly spaced grid for the mean cross section and 
%maps (interpolates) individual transects to this grid.   

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08

%% User Input

xgdspc = A(1).hgns; %Horizontal Grid node spacing in meters  (vertical grid spacing is set by bins)
% if 0
%     xgdspc = V.meddens + V.stddens;  %Auto method should include 67% of the values
%     disp(['X Grid Node Auto Spacing = ' num2str(xgdspc) ' m'])
% end

%% Determine uniform mean c-s grid for vector interpolating
% Determine the end points of the mean cross-section line
% Initialize variable with mid range value
V.xe = mean(A(1).Comp.xm);
V.ys = mean(A(1).Comp.ym);
V.xw = mean(A(1).Comp.xm);
V.yn = mean(A(1).Comp.ym);

for zi = 1:z
    V.xe = max(max(A(zi).Comp.xm),V.xe);
    V.ys = min(min(A(zi).Comp.ym),V.ys);
    V.xw = min(min(A(zi).Comp.xm),V.xw);
    V.yn = max(max(A(zi).Comp.ym),V.yn);
end

% Determine the distance between the mean cross-section endpoints
V.dx = V.xe-V.xw;
V.dy = V.yn-V.ys;

V.dl = sqrt(V.dx^2+V.dy^2);

% Determine mean cross-section velocity vector grid
V.mcsDist = linspace(0,V.dl,floor(V.dl/xgdspc));                                  %%linspace(0,V.dl,V.dl); Changed to make it user selectable (PRJ, 12-12-08)
V.mcsDepth = A(1).Wat.binDepth(:,1);
[V.mcsDist V.mcsDepth] = meshgrid(V.mcsDist,V.mcsDepth);

% Determine the angle the mean cross-section makes with the 
% x-axis (longitude)
% Plot mean cross-section line
if V.m >= 0
    V.theta = atand(V.dy./V.dx);
    
%     figure(1); hold on
%     plot([V.xe V.xw],[V.yn V.ys],'ks'); hold on
    
    V.mcsX = V.xe - V.mcsDist(1,:).*cosd(V.theta);            % 
    V.mcsY = V.yn - V.mcsDist(1,:).*sind(V.theta); 
    
%     if V.mfd >= 270 | V.mfd < 90 %Flow to the north  %This code was an attempt to auto detect left bank--did'nt work so removed.  
%         V.mcsX = V.xw+V.mcsDist(1,:).*cosd(V.theta);            % 
%         V.mcsY = V.ys+V.mcsDist(1,:).*sind(V.theta);
%         
%     elseif V.mfd >= 90 & V.mfd < 270 %Flow to the south
%         V.mcsX = V.xe-V.mcsDist(1,:).*cosd(V.theta);            % 
%         V.mcsY = V.yn-V.mcsDist(1,:).*sind(V.theta);  
%     end%
    
%     plot(V.mcsX,V.mcsY,'k+'); hold on
%     plot(V.mcsX(1),V.mcsY(1),'y*'); hold on

elseif V.m < 0
    V.theta = -atand(V.dy./V.dx);
    %V.theta = atand(V.dy./V.dx); %Changed 9-28-10, PRJ (theta needs to be
    %negative--changed back to original)
    
%     figure(1); hold on
%     plot([V.xe V.xw],[V.ys V.yn],'ks'); hold on
    
    V.mcsX = V.xe - V.mcsDist(1,:).*cosd(V.theta);
    V.mcsY = V.ys - V.mcsDist(1,:).*sind(V.theta);
    %V.mcsY = V.ys+V.mcsDist(1,:).*sind(V.theta);  %Changed 9-28-10, PRJ
    
%     if V.mfd >= 270 | V.mfd < 90 %Flow to the north
%         V.mcsX = V.xw+V.mcsDist(1,:).*cosd(V.theta);            % 
%         V.mcsY = V.yn+V.mcsDist(1,:).*sind(V.theta);
%         
%     elseif V.mfd >= 90 & V.mfd < 270 %Flow to the south
%         V.mcsX = V.xe-V.mcsDist(1,:).*cosd(V.theta);
%         V.mcsY = V.ys-V.mcsDist(1,:).*sind(V.theta);  
%     end%
   
%     plot(V.mcsX,V.mcsY,'k+'); hold on
%     plot(V.mcsX(1),V.mcsY(1),'y*'); hold on
end

V.mcsX = meshgrid(V.mcsX,V.mcsDepth(:,1));
V.mcsY = meshgrid(V.mcsY,V.mcsDepth(:,1));
% figure(1); set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
clear zi

% Format the ticks for UTM and allow zooming and panning
% figure(1);
% ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM
% hdlzm_fig1 = zoom;
% set(hdlzm_fig1,'ActionPostCallback',@mypostcallback_zoom);
% set(hdlzm_fig1,'Enable','on');
% hdlpn_fig1 = pan;
% set(hdlpn_fig1,'ActionPostCallback',@mypostcallback_pan);
% set(hdlpn_fig1,'Enable','on');


%% Determine location of mapped ensemble points for interpolating
% For all transects

%A = VMT_DxDyfromLB(z,A,V); %Computes dx and dy 

for zi = 1:z
    % Determine if the mean cross-section line trends NW-SE or SW-NE
    % Determine the distance in radians from the left bank mean
    % cross-section point to the mapped ensemble point for an individual
    % transect
    A(zi).Comp.dx = abs(V.xe-A(zi).Comp.xm);  %This assumes the easternmost bank is the left bank--changed PRJ 1-21-09 (now uses VMT_DxDyfromLB--not working 2/1/09)

    if V.m > 0
        A(zi).Comp.dy = abs(V.yn-A(zi).Comp.ym);
    elseif V.m < 0
        A(zi).Comp.dy = abs(V.ys-A(zi).Comp.ym);
    end

    % Determine the distance in meters from the left bank mean
    % cross-section point to the mapped ensemble point for an individual
    % transect
    A(zi).Comp.dl = sqrt(A(zi).Comp.dx.^2+A(zi).Comp.dy.^2);

%     % Sort vectors by dl
%     A(zi).Comp.dlsort = sort(A(zi).Comp.dl,'ascend');
% 
%     % Map indices
%     for i = 1:A(zi).Sup.noe
%         for k = 1 : A(zi).Sup.noe
%             if A(zi).Comp.dlsort(i,1) == A(zi).Comp.dl(k,1)
%                 A(zi).Comp.vecmap(i,1) = k;
%             end
%         end
%     end
    
    % Sort vectors by dl
    [A(zi).Comp.dlsort,A(zi).Comp.vecmap] = sort(A(zi).Comp.dl,'ascend');

    % GPS position fix
    % if distances from the left bank are the same for two ensembles the
    % the position of the right most ensemble is interpolated from adjacent
    % ensembles
    % check for repeat values of distance
    sbt(:,1) = diff(A(zi).Comp.dlsort);
    chk(1,1) = 1;
    chk(2:A(zi).Sup.noe,1) = sbt(1:end,1);

    % identify repeat values
    A(zi).Comp.sd = (chk==0) > 0;

    % if repeat values exist interpolate distances from adjacent ensembles
    if sum(A(zi).Comp.sd) > 0

        % bracket repeat sections
        [I,~] = ind2sub(size(A(zi).Comp.sd),find(A(zi).Comp.sd==1));
        df = diff(I);
        nbrk = sum(df>1)+1;
        [I2,~] = ind2sub(size(df),find(df>1));

        bg(1) = I(1)-1;
        for n = 2 : nbrk
            bg(n) = I(I2(n-1)+1)-1;
        end

        for n = 1:nbrk -1
            ed(n) = I(I2(n))+1;
        end
        ed(nbrk) = I(end)+1;

        % interpolate repeat values
        A(zi).Comp.dlsortgpsfix = A(zi).Comp.dlsort;

        for i = 1 : nbrk
            for j = bg(i)+1 : ed(i)-1
                % interpolate
                if bg(i) > 0 && ed(i) < length(A(zi).Nav.lat_deg)

                    den=(ed(i)-bg(i));
                    num2=j-bg(i);
                    num1=ed(i)-j;

                    A(zi).Comp.dlsortgpsfix(j,1)=...
                        (num1/den).*A(zi).Comp.dlsort(bg(i))+...
                        (num2/den).*A(zi).Comp.dlsort(ed(i));

                end
                
                % extrapolate end
                if ed(i) > length(A(zi).Nav.lat_deg)
                   
                    numex = ed(i) - length(A(zi).Nav.lat_deg);
                    
                    A(zi).Comp.dlsortgpsfix(j,1)=numex.*...
                        (A(zi).Comp.dlsort(bg(i))-...
                        A(zi).Comp.dlsort(bg(i)-1))+...
                        A(zi).Comp.dlsort(bg(i));
                    
                end               
            end
        end
    else
        A(zi).Comp.dlsortgpsfix = A(zi).Comp.dlsort;
    end % IF sum(A(zi).Comp.sd) > 0
    
    % Determine velocity vector grid for individual transects
    [A(zi).Comp.itDist A(zi).Comp.itDepth] = ...
        meshgrid(A(zi).Comp.dlsortgpsfix,A(zi).Wat.binDepth(:,1));
    
    clear I I2 J J2 bg chk df ed i j nbrk sbt xUTM yUTM n zi...
        den num2 num1 numex
    
end

clear zi i k check

%% Interpolate individual transects onto uniform mean c-s grid
% Fill in uniform grid based on individual transects mapped onto the mean
% cross-section by interpolating between adjacent points

%ZI = interp2(X,Y,Z,XI,YI)
for zi = 1:z
    A(zi).Comp.mcsBack = ...
        interp2(A(zi).Comp.itDist, ...
                A(zi).Comp.itDepth, ...
                A(zi).Clean.bs(:,A(zi).Comp.vecmap), ...
                V.mcsDist, ...
                V.mcsDepth);
    A(zi).Comp.mcsBack(A(zi).Comp.mcsBack>=255) = NaN;
    
    %A(zi).Comp.mcsDir = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        %A(zi).Clean.vDir(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth); %This interpolation scheme has issues when interpolating in a flow due north (0,360 interpolate to 180)
    
    % For direction, must convert degrees to radians, take the sin of the
    % radians, and then interpolate.  Following interpolation, convert
    % radians back to degrees. (PRJ, 9-28-10)  ALSO BAD NEAR 180
    %A(zi).Comp.mcsDir = 180/pi*(interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        %sin(pi/180*(A(zi).Clean.vDir(:,A(zi).Comp.vecmap))), V.mcsDist, V.mcsDepth));
    
%     A(zi).Comp.mcsMag = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
%         A(zi).Clean.vMag(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
%         (Recomputed from north and east components (PRJ, 3-21-11) 
    
    
    A(zi).Comp.mcsEast = ...
        interp2(A(zi).Comp.itDist, ...
                A(zi).Comp.itDepth, ...
                A(zi).Clean.vEast(:,A(zi).Comp.vecmap), ...
                V.mcsDist, ...
                V.mcsDepth);
    A(zi).Comp.mcsNorth = ...
        interp2(A(zi).Comp.itDist, ...
                A(zi).Comp.itDepth, ...
                A(zi).Clean.vNorth(:,A(zi).Comp.vecmap), ...
                V.mcsDist, ...
                V.mcsDepth);
    A(zi).Comp.mcsVert = ...
        interp2(A(zi).Comp.itDist, ...
                A(zi).Comp.itDepth, ...
                A(zi).Clean.vVert(:,A(zi).Comp.vecmap), ...
                V.mcsDist, ...
                V.mcsDepth);
    
    %Compute magnitude
    A(zi).Comp.mcsMag = sqrt(A(zi).Comp.mcsEast.^2 + A(zi).Comp.mcsNorth.^2);
    
    %For direction, compute from the velocity components
    A(zi).Comp.mcsDir = 90 - (atan2(A(zi).Comp.mcsNorth, A(zi).Comp.mcsEast))*180/pi; %Compute the atan from the velocity componentes, convert to radians, and rotate to north axis
    qindx = find(A(zi).Comp.mcsDir < 0);
    if ~isempty(qindx)
        A(zi).Comp.mcsDir(qindx) = A(zi).Comp.mcsDir(qindx) + 360;  %Must add 360 deg to Quadrant 4 values as they are negative angles from the +y axis
    end
    
    A(zi).Comp.mcsBed = ...
        interp1(A(zi).Comp.itDist(1,:), ...
                nanmean(A(zi).Nav.depth(A(zi).Comp.vecmap,:),2), ...
                V.mcsDist(1,:));
end

clear zi

%% Embedded functions 
function mypostcallback_zoom(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when zooming) 

function mypostcallback_pan(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when panning) 

%==========================================================================
function [A,V] = VMT_CompMeanXS_old(z,A,V)
% Compute the mean cross section data from individual transects that have
% been previously mapped to a common grid. 

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08 

%% Average mapped mean cross-sections from individual transects together 
% Assign mapped uniform grid vectors to the same array for averaging
Back  = zeros([size(A(1).Comp.mcsBack) z]);
Dir   = zeros([size(A(1).Comp.mcsDir) z]);
Mag   = zeros([size(A(1).Comp.mcsMag) z]);
East  = zeros([size(A(1).Comp.mcsEast) z]);
North = zeros([size(A(1).Comp.mcsNorth) z]);
Vert  = zeros([size(A(1).Comp.mcsVert) z]);
Bed   = zeros([size(A(1).Comp.mcsBed) z]);
for zi = 1 : z
    Back(:,:,zi)  = A(zi).Comp.mcsBack;
    Dir(:,:,zi)   = A(zi).Comp.mcsDir;
    Mag(:,:,zi)   = A(zi).Comp.mcsMag;
    East(:,:,zi)  = A(zi).Comp.mcsEast;
    North(:,:,zi) = A(zi).Comp.mcsNorth;
    Vert(:,:,zi)  = A(zi).Comp.mcsVert;
    Bed(:,:,zi)   = A(zi).Comp.mcsBed;
end

% numavg = nansum(~isnan(Mag),3);
% numavg(numavg==0) = NaN;
% enscnt = nanmean(numavg,1);
% [I,J] = ind2sub(size(enscnt),find(enscnt>=1));  %Changed to >= 1 PRJ 12-10-08  (uses data even if only one measurement)

Backone = Back;
Magone  = Mag;
Vertone = Vert;
Bedone  = Bed;

Backone(~isnan(Back)) = 1;
Magone(~isnan(Mag))   = 1;
Vertone(~isnan(Vert)) = 1;
Bedone(~isnan(Bed))   = 1;

V.countBack = nansum(Backone,3);
V.countMag  = nansum(Magone,3);
V.countVert = nansum(Vertone,3);
V.countBed  = nansum(Bedone,3);

V.countBack(V.countBack==0) = NaN;
V.countMag(V.countMag==0)   = NaN;
V.countVert(V.countVert==0) = NaN;
V.countBed(V.countBed==0)   = NaN;

% Average mapped mean cross-sections from individual transects together
V.mcsBack  = nanmean(Back,3);
% V.mcsDir   = nanmean(Dir,3);  % Will not average correctly in all cases due to 0-360
%wrapping (PRJ, 9-29-10)
% V.mcsMag   = nanmean(Mag,3);  %Mag recomputed from north, east, up components(PRJ, 3-21-11)
V.mcsEast  = nanmean(East,3);
V.mcsNorth = nanmean(North,3);
V.mcsVert  = nanmean(Vert,3);

% Average Magnitude
V.mcsMag = sqrt(V.mcsEast.^2 + V.mcsNorth.^2 + V.mcsVert.^2);

% Average the flow direction
V.mcsDir = 90 - (atan2(V.mcsNorth, V.mcsEast))*180/pi; %Compute the atan from the velocity componentes, convert to radians, and rotate to north axis
qindx = find(V.mcsDir < 0);
if ~isempty(qindx)
    V.mcsDir(qindx) = V.mcsDir(qindx) + 360;  %Must add 360 deg to Quadrant 4 values as they are negative angles from the +y axis
end

V.mcsBed = nanmean(Bed,3);

% Compute the Bed Elevation in meters
disp(['Assigned Water Surface Elevation (WSE; in meters) = ' num2str(A(1).wse)])
V.mcsBedElev = A(1).wse - V.mcsBed;

%==========================================================================
function [A,V] = VMT_CompMeanXS_UVW(z,A,V)

%This routine computes the mean cross section velocity components (UVW) 
%from individual transects that have been previously mapped to a common grid and averaged. 

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08 


%% Rotate velocities into u, v, and w components
% Determine the direction of streamwise velocity (u)
V.phi = 180 - V.theta;  %Taken as perpendicular to the mean XS

% Determine the deviation of a vector from streamwise velocity
V.psi = V.phi - V.mcsDir;

% Determine streamwise (u), transverse (v), and vertical (w) velocities
V.u = cosd(V.psi).*V.mcsMag;
V.v = sind(V.psi).*V.mcsMag;
V.w = V.mcsVert;

for zi = 1:z
    A(zi).Comp.u = cosd(V.psi).*A(zi).Comp.mcsMag;
    A(zi).Comp.v = sind(V.psi).*A(zi).Comp.mcsMag;
    A(zi).Comp.w = A(zi).Comp.mcsVert;
end

%==========================================================================
function [A,V] = VMT_CompMeanXS_PriSec(z,A,V)

%This routine computes the mean cross section velocity components (Primary and secondary) 
%from individual transects that have been previously mapped to a common grid and averaged.  
%The Primary velocity is defined as the component of the flow in the direction of the discharge
%(i.e. rotated from the streamwise direction so the secrondary discharge is
%zero).

% This is referred to as the "zero net cross-stream discharge definition"
% (see Lane et al. 2000, Hydrological Processes 14, 2047-2071)

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08 

%% Rotate velocities into p and s components for the mean transect
% calculate dy and dz for each meaurement point
dy = mean(diff(V.mcsDist(1,:)));  % m
dz = mean(diff(V.mcsDepth(:,1))); % m
dydz = dy.*dz;

% calculate the bit of discharge for each imaginary cell around the
% velocity point
qyi = V.v.*dydz; % cm*m^2/s
qxi = V.u.*dydz; % cm*m^2/s
% qyi = V.v.*dy.*dz;%cm*m^2/s
% qxi = V.u.*dy.*dz;%cm*m^2/s

% sum the streamwise and transverse Q and calculate the angle of the
% cross section
V.Qy = nansum(nansum(qyi));%cm*m^2/s
V.Qx = nansum(nansum(qxi));%cm*m^2/s
% V.Qy = nansum(qyi(:)); % cm*m^2/s % PDF?
% V.Qx = nansum(qxi(:)); % cm*m^2/s

V.alphasp = atand(V.Qy./V.Qx);
V.phisp   = V.phi - V.alphasp;

% Rotate the velocities so that Qy is effectively zero
qpi =  qxi.*cosd(V.alphasp) + qyi.*sind(V.alphasp);
qsi = -qxi.*sind(V.alphasp) + qyi.*cosd(V.alphasp);
% R =  [ cosd(V.alphasp) sind(V.alphasp)   % PDF? Depends on dimensions
%       -sind(V.alphasp) cosd(V.alphasp)];

V.Qp = nansum(nansum(qpi));%cm*m^2/s
V.Qs = nansum(nansum(qsi));%cm*m^2/s
% V.Qp = nansum(qpi(:)));%cm*m^2/s % PDF?
% V.Qs = nansum(qsi(:)));%cm*m^2/s
disp(['Secondary Discharge after Rotation (ZSD definition; m^3/s) = ' num2str(V.Qs/100)])

V.vp = qpi./dydz; % cm/s
V.vs = qsi./dydz; % cm/s
% V.vp = qpi./(dy.*dz);%cm/s
% V.vs = qsi./(dy.*dz);%cm/s

%% Transform each individual transect

for zi = 1 : z
    % calculate the bit of discharge for each imaginary cell around the
    % velocity point
    A(zi).Comp.qyi = A(zi).Comp.v.*dydz; % cm*m^2/s
    A(zi).Comp.qxi = A(zi).Comp.u.*dydz; % cm*m^2/s
%     A(zi).Comp.qyi=A(zi).Comp.v.*dy.*dz;%cm*m^2/s
%     A(zi).Comp.qxi=A(zi).Comp.u.*dy.*dz;%cm*m^2/s
    
    % rotate the velocities so that Qy is effcetively zero
    A(zi).Comp.qpi =  A(zi).Comp.qxi.*cosd(V.alphasp) + A(zi).Comp.qyi.*sind(V.alphasp);
    A(zi).Comp.qsi = -A(zi).Comp.qxi.*sind(V.alphasp) + A(zi).Comp.qyi.*cosd(V.alphasp);
    
    A(zi).Comp.Qp=nansum(nansum(A(zi).Comp.qpi));%cm*m^2/s
    A(zi).Comp.Qs=nansum(nansum(A(zi).Comp.qsi));%cm*m^2/s
    % A(zi).Comp.Qp = nansum(A(zi).Comp.qpi(:)); % cm*m^2/s  % PDF?
    % A(zi).Comp.Qs = nansum(A(zi).Comp.qsi(:)); % cm*m^2/s
    
    A(zi).Comp.vp = A(zi).Comp.qpi./dydz; % cm/s
    A(zi).Comp.vs  =A(zi).Comp.qsi./dydz; % cm/s
%     A(zi).Comp.vp=A(zi).Comp.qpi./(dy.*dz);%cm/s
%     A(zi).Comp.vs=A(zi).Comp.qsi./(dy.*dz);%cm/s
end


%% Determine velocity deviations from the p direction

V.mcsDirDevp = V.phisp - V.mcsDir;

for zi = 1:z
    A(zi).Comp.mcsDirDevp = V.phisp - A(zi).Comp.mcsDir;
end

%==========================================================================
function [V] = VMT_RozovskiiV2(V,A)

% Computes the frame of reference transpositon as described in Kenworthy
% and Rhoads (1998) ESPL using a Rozovskii type analysis.

% Notes:
%     -The depth averaging currently linearly interpolates to the bed,
%      however we may want some other approach such as log law, etc.
%     -I extrapolate the velocity at the near surface bin to the water
%      surface for the depth averaging (ie, BC at u(z=0) = u(z=bin1))
%     -There are cases where the bin corresponding with the bed actually
%      contains flow data (i.e., not NaN or zero). For cases where the
%      blanking distance DOES exists, I have imposed a BC of U=0 at the bed,
%     -In cases where data goes all of the way to the bed, I have divided
%      the last bin's velocity by 2, essentially imposing a U=0 at the
%      boundary by extrapolating to the bottom of the bin.
%     -This function still needs to be incorporated into the GUI.

% V2 modifies the code for integration into the VMT GUI. Adds the Rozovskii output to
% the V structure and computes the X components of the primary and secondary 
% velocities (in addition to cross stream Y components). 
% P.R. Jackson, USGS


% Written by:
% Frank L. Engel (fengel2@illinois.edu)

% Last edited: 6/10/2010 FE
% FE- I fixed an error in computing theta for data in quadrants 3 & 4. The
%     linear interpolation of velocity to the bed BC was creating errors 
%     in the computation of us, so I removed it. Also, I made a new 
%     variable which is the sum of all vs as an error check (it should 
%     always sum to zero)

disp('Performing Rozovskii analysis...')
bin_size = A(1,1).Sup.binSize_cm/100; % in meters

for i = 1:size(V.mcsMag,2)
    % Finds closest bin to beam avg. depth (ie from V.mcsBed)
    [min_difference(i), array_position(i)]...
        = min(abs(V.mcsDepth(:,i) - V.mcsBed(i)));
    %disp(['ap = ' num2str(array_position(i))])
    % Create a seperate version of the velocity data which can be modified,
    % preserving the VMT processing. Replaces all of the NaNs with u=0.
    temp_u = V.u;
    temp_v = V.v;
    n = find(isnan(V.u));
    temp_u(n) = 0;
    temp_v(n) = 0;
    
    % Compute Depth-averaged velocities and angles (using a difference
    % scheme)
    for j = 1:array_position(i)
        if j == 1 % Near water surface
            % Compute first bin by exprapolating velocity to the water
            % surface. WSE = 0. Imposes BC u(z=0) = u(z=bin1)
            du_i(j,i) = temp_u(j,i)*(V.mcsDepth(j+1,i)-V.mcsDepth(j,i))...
                      + temp_u(j,i)*(V.mcsDepth(j,i)-bin_size/2-0);
            dv_i(j,i) = temp_v(j,i)*(V.mcsDepth(j+1,i)-V.mcsDepth(j,i))...
                      + temp_v(j,i)*(V.mcsDepth(j,i)-bin_size/2-0);
        elseif j < array_position(i) % Inbetween
            du_i(j,i) = temp_u(j,i)*(V.mcsDepth(j+1,i)-V.mcsDepth(j-1,i))/2;
            dv_i(j,i) = temp_v(j,i)*(V.mcsDepth(j+1,i)-V.mcsDepth(j-1,i))/2;
            
            % Got rid of the linear interpolation to the bed- it was
            % messing up the Rozovskii secondary velocities (FE 6/10/2010)
        elseif j == array_position(i) % Near bed
            %             k=0;
            %             % Search bins above the bed for the first bin containing flow
            %             % data.
            %
            % %             while temp_u(j-k,i) == 0
            % %                 if temp_u(j-k,i) == 0; k = k + 1; else end % find next good bin
            % %             end
            %
            indx = find(temp_u(:,i) ~= 0);  %Revision PRJ 9-1-09
            if isempty(indx)
                du_i(:,i) = NaN;
                dv_i(:,i) = NaN;
            else
                l = indx(end);
                k = j - l;
                % Computes du from last good bin to the bed by linear
                % interpolation. IMPOSES BC: u=0 at the bed
%                 du_i(j-k+1,i) = (temp_u(j-k,i)-temp_u(j,i))/k...
%                     *(V.mcsDepth(j,i)-V.mcsDepth(j-k,i))/k;
%                 dv_i(j-k+1,i) = (temp_v(j-k,i)-temp_v(j,i))/k...
%                     *(V.mcsDepth(j,i)-V.mcsDepth(j-k,i))/k;
                
                % Paints everything below last bin as NaN
                du_i(j-k+2:size(V.u,2),i) = NaN;
                dv_i(j-k+2:size(V.u,2),i) = NaN;
            end
        end
    end
    
    % Depth averaged quantities
    U(i) = nansum(du_i(:,i))/V.mcsDepth(array_position(i),i);
    V1(i) = nansum(dv_i(:,i))/V.mcsDepth(array_position(i),i);
    U_mag(i) = sqrt(U(i)^2+V1(i)^2); % resultant vector
    
    % Angle of resultant vector from a perpendicular line along the
    % transect
    phi(i) = atan(V1(i)/U(i));
    phi_deg(i) = rad2deg(phi(i));
    
    % Compute Rozovskii variables at each bin
    for j = 1:array_position(i)
        u(j,i) = sqrt(V.u(j,i)^2+V.v(j,i)^2);
		if (V.u(j,i) < 0) && (V.v(j,i) < 0)
			theta(j,i) = atan(V.v(j,i)/V.u(j,i)) - pi();
		elseif (V.u(j,i) < 0) && (V.v(j,i) > 0)
			theta(j,i) = atan(V.v(j,i)/V.u(j,i)) + pi();
		else
			theta(j,i) = atan(V.v(j,i)/V.u(j,i));
		end
        theta_deg(j,i) = rad2deg(theta(j,i));
        up(j,i) = u(j,i)*cos(theta(j,i)-phi(i));
        us(j,i) = u(j,i)*sin(theta(j,i)-phi(i));
        upy(j,i) = up(j,i)*sin(phi(i));
        upx(j,i) = up(j,i)*cos(phi(i));
        usy(j,i) = us(j,i)*cos(phi(i));
        usx(j,i) = us(j,i)*sin(phi(i));
        depths(j,i) = V.mcsDepth(j,i);
        
        % Compute d_us to check for zero secondary discharge constraint
        if j == 1 % Near water surface
            dus_i(j,i) = us(j,i)*(V.mcsDepth(j+1,i)-V.mcsDepth(j,i))...
                + us(j,i)*(V.mcsDepth(j,i)-bin_size/2-0);
        elseif j < array_position(i) % Inbetween
            dus_i(j,i) = us(j,i)*(V.mcsDepth(j+1,i)-V.mcsDepth(j-1,i))/2;
        end
        % Sum dus_i - this should be near zero for each ensemble
        q_us(i) = nansum(dus_i(:,i));
    end
    
    % Resize variables to be the same as V structure array
    indices = j+1:size(V.mcsMag,1);
    u(indices,i)         = NaN;
    theta(indices,i)     = NaN;
    theta_deg(indices,i) = NaN;
    up(indices,i)        = NaN;
    us(indices,i)        = NaN;
    upy(indices,i)       = NaN;
    usy(indices,i)       = NaN;
    upx(indices,i)       = NaN;
    usx(indices,i)       = NaN;
    depths(indices,i)    = NaN;
    dus_i(indices,i)     = NaN;
%     u(j+1:size(V.mcsMag,1),i) = NaN;
%     theta(j+1:size(V.mcsMag,1),i) = NaN;
%     theta_deg(j+1:size(V.mcsMag,1),i) = NaN;
%     up(j+1:size(V.mcsMag,1),i) = NaN;
%     us(j+1:size(V.mcsMag,1),i) = NaN;
%     upy(j+1:size(V.mcsMag,1),i) = NaN;
%     usy(j+1:size(V.mcsMag,1),i) = NaN;
%     upx(j+1:size(V.mcsMag,1),i) = NaN;
%     usx(j+1:size(V.mcsMag,1),i) = NaN;
%     depths(j+1:size(V.mcsMag,1),i) = NaN;
%     dus_i(j+1:size(V.mcsMag,1),i) = NaN;
end

% Display error message if rozovskii computation of q_us doesn't sum to
% zero
if q_us > 1e-4
    disp('Warning: Rozovskii secondary velocities not satisfying continuity!')
else
    disp('Computation successfull: Rozovskii secondary velocities satisfy continuity')
end

% Rotate local velocity vectors into global coordinate system by
% determining the angle of the transect using endpoint locations. The
% function "vrotation" is a standard rotation matrix
XStheta = atan((V.mcsY(1,end)-V.mcsY(1,1))/(V.mcsX(1,end)-V.mcsX(1,1)));
XSalpha = XStheta - pi/2;
[ux, uy, uz] = vrotation(V.u,V.v,V.w,XSalpha);

% Put results into the V structure

V.Roz.U         = U;
V.Roz.V         = V1;
V.Roz.U_mag     = U_mag;
V.Roz.phi       = phi;
V.Roz.phi_deg   = phi_deg;
V.Roz.u         = V.u;
V.Roz.v         = V.v;
V.Roz.u_mag     = u;
V.Roz.depth     = depths;
V.Roz.theta     = theta;
V.Roz.theta_deg = theta_deg;
V.Roz.up        = up;
V.Roz.us        = us;
V.Roz.upy       = upy;
V.Roz.usy       = usy;
V.Roz.upx       = upx;
V.Roz.usx       = usx;
V.Roz.ux        = ux;
V.Roz.uy        = uy;
V.Roz.uz        = uz;
V.Roz.alpha     = XSalpha;

% Rozovskii = struct('Ux', {Ux}, 'Uy', {Uy}, 'U', {U}, 'phi', {phi},...
%     'phi_deg', {phi_deg},'ux', {V.u}, 'uy', {V.v}, 'u', {u}, 'depth', {depths},...
%     'theta', {theta}, 'theta_deg', {theta_deg}, 'up', {up}, 'us', {us},...
%     'upy', {upy}, 'usy', {usy});

% Name of output file needs to be modified to take handle args from GUI
% Save variable into the VMTProcFile folder
% outfolder = ['VMTProcFiles\'];
% outfile=['Rozovskii'];
% filename = [outfolder outfile];
% save(filename, 'Rozovskii');

disp('Rozovskii analysis complete. Added .Roz structure to V data structure.')
% directory = pwd;
% fileloc = [directory '\' filename '.mat'];
% disp(fileloc)

