function [A,V] = VMT_ProcessTransectsV3_new_display(h,z,A,V,setends)
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
warning off
%% Map ensembles to mean cross-section

VMT_MapEns2MeanXSV2(h,z,A,V,setends);

%% Grid the measured data along the mean cross-section
%[A,V] = VMT_GridData2MeanXS(z,A,V);
VMT_GridData2MeanXS(h,z,A,V);

%% Computes the mean data for the mean cross-section 
%[A,V] = VMT_CompMeanXS(z,A,V);
[A,V] = VMT_CompMeanXS_old(z,A,V);

%% Decompose the velocities into u, v, and w components
[A,V] = VMT_CompMeanXS_UVW(z,A,V);

%% Decompose the velocities into primary and secondary components
[A,V] = VMT_CompMeanXS_PriSec(z,A,V);

%% Perform the Rozovskii computations
V = VMT_RozovskiiV2(V,A);


%==========================================================================
function [A,V] = VMT_MapEns2MeanXSV2(h,z,A,V,setends)

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
figure(h)
% hf = VMT_CreatePlotDisplay('shiptracks');
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
for zi = 1:z
    
    % concatenate coords into a single column vector for regression
    x = cat(1,x,A(zi).Comp.xUTM);
    y = cat(1,y,A(zi).Comp.yUTM);

%     figure(1); hold on
    figure(h); hold on
    plot(A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,'b'); hold on
end

if setends  %Gets a user text file with fixed cross section end points 
    
    defaultpath = 'C:\';
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
        %     figure(1); hold on
        figure(h); hold on
        plot(x,y,'go','MarkerSize',10); hold on
    end
end

% find the equation of the best fit line 
xrng = max(x) - min(x);
yrng = max(y) - min(y);
if xrng >= yrng %Fit based on coordinate with larger range of values (original fitting has issues with N-S lines because of repeated X values), PRJ 12-12-08
    [P,~] = polyfit(x,y,1);
%     figure(1); hold on
    figure(h); hold on
    plot(x,polyval(P,x),'g-')
else
    [P,~] = polyfit(y,x,1);
%     figure(1); hold on
    figure(h); hold on
    plot(polyval(P,y),y,'g-')
end

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
end

%Plot data to check
% xensall = [];
% yensall = [];
for zi = 1 : z
  plot(A(zi).Comp.xm,A(zi).Comp.ym,'b.')
%   xensall = [xensall; A(zi).Comp.xm];
%   yensall = [yensall; A(zi).Comp.ym];
end
xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
box on
grid on

%==========================================================================
function [A,V] = VMT_GridData2MeanXS(h,z,A,V)

%This routine generates a uniformly spaced grid for the mean cross section and 
%maps (interpolates) individual transects to this grid.   

%(adapted from code by J. Czuba)

%P.R. Jackson, USGS, 12-9-08

%% User Input

xgdspc = A(1).hgns; %Horizontal Grid node spacing in meters  (vertical grid spacing is set by bins)

% Determine the distance between the mean cross-section endpoints

% Determine the angle the mean cross-section makes with the
% x-axis (longitude)
% Plot mean cross-section line
if V.m >= 0
    
%     figure(1); hold on
    figure(h); hold on
    plot([V.xe V.xw],[V.yn V.ys],'ks'); hold on
            
    plot(V.mcsX,V.mcsY,'k+'); hold on
    plot(V.mcsX(1),V.mcsY(1),'y*'); hold on

elseif V.m < 0
    
%     figure(1); hold on
    figure(h); hold on
    plot([V.xe V.xw],[V.ys V.yn],'ks'); hold on
       
    plot(V.mcsX,V.mcsY,'k+'); hold on
    plot(V.mcsX(1),V.mcsY(1),'y*'); hold on
    
end

% figure(1)
figure(h)
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])

% Format the ticks for UTM and allow zooming and panning
% figure(1)
figure(h)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM
hdlzm_fig1 = zoom;
set(hdlzm_fig1,'ActionPostCallback',@mypostcallback_zoom);
set(hdlzm_fig1,'Enable','on');
hdlpn_fig1 = pan;
set(hdlpn_fig1,'ActionPostCallback',@mypostcallback_pan);
set(hdlpn_fig1,'Enable','on');


%% Determine location of mapped ensemble points for interpolating
% For all transects

%A = VMT_DxDyfromLB(z,A,V); %Computes dx and dy 

%% Interpolate individual transects onto uniform mean c-s grid
% Fill in uniform grid based on individual transects mapped onto the mean
% cross-section by interpolating between adjacent points

%% Embedded functions 
function mypostcallback_zoom(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when zooming) 

function mypostcallback_pan(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when panning) 

%==========================================================================
function [A,V] = VMT_CompMeanXS_old(z,A,V)
%==========================================================================
function [A,V] = VMT_CompMeanXS_UVW(z,A,V)
%==========================================================================
function [A,V] = VMT_CompMeanXS_PriSec(z,A,V)

%==========================================================================
function [V] = VMT_RozovskiiV2(V,A)

