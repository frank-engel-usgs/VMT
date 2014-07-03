function PVdata = VMT_PlotPlanViewQuiversMAT(zPathName,zFileName,zf,drng,ascale,QuiverSpacing,pvsmwin,pshore,plot_english)
% No longer implemented in the current version
%
% Plots a plan view of the measurement region with a vector field of
% depth averaged velocity for each processed mean cross section.
%
% MAT adapts the code for use with the gui by changing the file input
% structure.  Also adds a separate window size for smoothing (pvsmwin).
%
% Added DOQQ plotting capabilities (PRJ, 6-23-10)
% Added the ability to change the plotting units to english
% Added the ability to output data with option in GUI
%
% User Notes:
%
% 1. Leave drng blank (i.e. []) for full depth means or specify
%   the a 2 component vector of depths in meters (drng = [ dupper dlower])
%   of the depth range to average and plot
%
% (adapted from code by J. Czuba)
% 
% P.R. Jackson, USGS, 12-10-08 
% Last modified: F.L. Engel, USGS, 2/20/2013


warning off
disp('Plotting Plan View with Depth-Averaged Velocity Vectors...')



%% User Input

%QuiverSpacing   = 10;  %Plots a quiver every X emsembles
%ascale          = 1.5; %Set to 1 for autoscaling and other values for increased or decreased arrow lengths
savebathy = 0;  %Saves bathymatry data
%savePVdata = 0;  %Saves plan view data to a file
if exist('plot_english')==0
    plot_english  = 0;
    disp('No units specified, plotting in metric units by default')
end

%% Plot Quivers on Area Map

% bathyx = [];
% bathyy = [];
% bathyz = [];

if isnan(drng)
    drng = [];
end

windowSize = pvsmwin; %Size of window for running average in smoothing of mean vel vectors (set in GUI)

plan_view_figure = figure(2); clf

if zf > 1
    mapmult = 1;
else
    mapmult = 0;
end
gradDAV = [];
gradDAVx = [];
gradDAVy = [];
ve = [];
vn = [];
xa = [];
ya = [];
xp = [];
yp = [];
bs = [];
vp = [];
vv = [];
vs = [];
dp = [];

% Check that zf is correct. In certain cases zf may correspond to the
% number of A files, and NOT the number of inputs.
if zf~=numel(zFileName)
    zf = numel(zFileName);
end

for n=1:zf
    try
        eval(['load ' zPathName '\' zFileName{n}]);
    catch
        errstrng = {'An unknown error occurred when reading the MAT file.'...
            'This error may have occurred if Matlab was unable to find selected files. '...
            'Ensure the filenames and path to the selected files are free of white spaces and special '...
            'characters (e.g. *?<>|) and try again.'};
        warndlg(errstrng, 'VMT Error')
    end
    %Get the grid node spacing  (assumes all trans processed with same grid
    %spacing)
    dx = V.mcsX(1,1) - V.mcsX(1,2);
    dy = V.mcsY(1,1) - V.mcsY(1,2);
    hgns = sqrt(dx.^2 + dy.^2);
    
    if ~isempty(drng)
        indx = find(V.mcsDepth(:,1) < drng(1) | V.mcsDepth(:,1) > drng(2));
        
        %Set all data outside depth range to nan
        V.mcsX(indx,:) = nan;
        V.mcsY(indx,:) = nan;
        V.mcsEast(indx,:) = nan;
        V.mcsNorth(indx,:) = nan;
        V.mcsDepth(indx,:) = nan;
        V.mcsBack(indx,:) = nan;
        V.w(indx,:) = nan;
        V.vp(indx,:) = nan;
        V.vs(indx,:) = nan;
       
        if n == 1
            if plot_english
                disp(['Plotting Depth Range ' num2str(drng(1)*3.281) 'ft to ' num2str(drng(2)*3.281) 'ft'])
            else 
                disp(['Plotting Depth Range ' num2str(drng(1)) 'm to ' num2str(drng(2)) 'm'])
            end
        end
        
        clear indx
    end
    
   %Compute mean positions
   V.mcsX1 = nanmean(V.mcsX,1);
   V.mcsY1 = nanmean(V.mcsY,1);
    
   if 0; %Compute the depth averaged velocity (straight arithmetic mean--old method)
        V.mcsEast1 = nanmean(V.mcsEast,1);
        V.mcsNorth1 = nanmean(V.mcsNorth,1);
    
   else %Compute the depth (or layer) averaged velocity (new method)
        V.mcsEast1  = VMT_LayerAveMean(V.mcsDepth,V.mcsEast);
        V.mcsNorth1 = VMT_LayerAveMean(V.mcsDepth,V.mcsNorth);
        V.mcsBack1  = VMT_LayerAveMean(V.mcsDepth,V.mcsBack);
        V.w1        = VMT_LayerAveMean(V.mcsDepth,V.w);
        V.vp1       = VMT_LayerAveMean(V.mcsDepth,V.vp);
        V.vs1       = VMT_LayerAveMean(V.mcsDepth,V.vs);
   end
    

    %Smooth using a running mean defined by WindowSize (averages
    %'2*windowsize+1' ensembles together (centered on node (boxcar filter))
    if windowSize == 0
        V.mcsX1sm     = V.mcsX1;
        V.mcsY1sm     = V.mcsY1;
        V.mcsEast1sm  = V.mcsEast1;
        V.mcsNorth1sm = V.mcsNorth1;
    else
        %V.mcsX1sm     = filter(ones(1,windowSize)/windowSize,1,V.mcsX1);
        %V.mcsY1sm     = filter(ones(1,windowSize)/windowSize,1,V.mcsY1);
        %V.mcsEast1sm  = filter(ones(1,windowSize)/windowSize,1,V.mcsEast1);
        %V.mcsNorth1sm = filter(ones(1,windowSize)/windowSize,1,V.mcsNorth1);
        
        V.mcsEast1sm  = nanmoving_average(V.mcsEast1,windowSize);  %added 1-7-10, prj
        V.mcsNorth1sm = nanmoving_average(V.mcsNorth1,windowSize);
        V.mcsX1sm     = V.mcsX1;
        V.mcsY1sm     = V.mcsY1;
       
    end
    
    
    for zi = 1:z
        Mag(:,:,zi) = A(zi).Comp.mcsMag(:,:);
    end
    numavg = nansum(~isnan(Mag),3);
    numavg(numavg==0) = NaN;
    enscnt = nanmean(numavg,1);
    [I,J] = ind2sub(size(enscnt),find(enscnt>=1));  %Changed to 1 from 2 (PRJ, 12-12-08)

    et = windowSize+J(1):QuiverSpacing:J(end);  %Does this cutoff boundary data???? PRJ 4-9-09
    
    % M(2*n-1,1)=V.mcsX(1,1);
    % M(2*n,1)=V.mcsX(1,end);
    % M(2*n-1,2)=V.mcsY(1,1);
    % M(2*n,2)=V.mcsY(1,end);
    %
    % idx=strfind(zFileName{n},'.');
    % namecut=zFileName{1,n}(2:idx(1)-1);
    %
    % pwr_kml(namecut,latlon);
    
    if n == 1
        %toquiv(1:493,1:4)=NaN;
        lenp = 0;
    end
    
    len = length(V.mcsX1sm(1,et));

    toquiv(lenp+1:len+lenp,1)=V.mcsX1sm(1,et);
    toquiv(lenp+1:len+lenp,2)=V.mcsY1sm(1,et);
    toquiv(lenp+1:len+lenp,3)=nanmean(V.mcsEast1sm(:,et),1);
    toquiv(lenp+1:len+lenp,4)=nanmean(V.mcsNorth1sm(:,et),1);

    lenp = length(V.mcsX1sm(1,et))+lenp;

    % quiverc2wcmap(V.mcsX1sm(1,et),V.mcsY1sm(1,et),nanmean(V.mcsEast1sm(:,et),1),nanmean(V.mcsNorth1sm(:,et),1),0);
    %quiverc(V.mcsX1sm(1,et),V.mcsY1sm(1,et),nanmean(V.mcsEast1sm(:,et),1),nanmean(V.mcsNorth1sm(:,et),1),0)
    %     quiver(V.mcsX1sm(1,et),V.mcsY1sm(1,et),nanmean(V.mcsEast1sm(:,et),1),nanmean(V.mcsNorth1sm(:,et),1),0)
    
    %output bathymetry data 
%     if savebathy
%         bathyx = [bathyx V.mcsX1];
%         bathyy = [bathyy V.mcsY1];
%         bathyz = [bathyz V.mcsBed];
%     end
    
    %Form vectors for contour mapping
    xa = [xa V.mcsX1(1,1:end)];  %All points, not subsampled
    ya = [ya V.mcsY1(1,1:end)];
    xp = [xp V.mcsX1(1,et)];    %Subsampled points
    yp = [yp V.mcsY1(1,et)];
    ve = [ve V.mcsEast1(:,et)];
    vn = [vn V.mcsNorth1(:,et)];
    vv = [vv V.w1(:,et)];
    if 0%sum(V.vp1(:,et),2) < 0  %Not working yet
        vp = [vp -V.vp1(:,et)];  %Flips sign if negative total Vp1
    else
        vp = [vp V.vp1(:,et)];
    end
    vs = [vs V.vs1(:,et)];
    bs = [bs V.mcsBack1(:,et)];
    dp = [dp V.mcsBed(1:end)];
    
    
    if mapmult
        clear A V z Mag numavg enscnt I J latlon idx namecut
    end
end
vr = sqrt(toquiv(:,3).^2+toquiv(:,4).^2);

% Save only the good data %Added 3-28-12 PRJ
gdindx = find(~isnan(vr));
toquiv = toquiv(gdindx,:);

figure(2); hold all
% if pdoqq
%     VMT_OverlayDOQQ
% end
if pshore
    if isstruct(Map) 
        VMT_PlotShoreline(Map)
    else
        disp('No Shoreline File Loaded')
    end   
end

%quiverc2wcmap(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),0,vr,1);
if plot_english
    figure(2); hold on
    quiverc(toquiv(:,1),toquiv(:,2),toquiv(:,3)*0.03281,toquiv(:,4)*0.03281,ascale);  %*0.03281 to go from cm/s to ft/s
    colorbar_handle = colorbar;
    if sum(~isnan(vr)) == 0
        errordlg('No Data in Specified Depth Range','Plotting Error');
    end
    disp(['DAV range (ft/s) = ' num2str(nanmin(vr)*0.03281) ' to ' num2str(nanmax(vr)*0.03281)])
    caxis([nanmin(vr*0.03281) nanmax(vr*0.03281)])  %resets the color bar axis from 0 to 64 to span the velocity mag range
    if ~isempty(drng)
        title_handle = title({'Depth-Averaged Velocities (ft/s)'; ['Averaged over depths ' num2str(drng(1)*3.281) 'ft to ' num2str(drng(2)*3.281) 'ft']},'Color','w');
    else
        title_handle = title('Depth-Averaged Velocities (ft/s)','Color','w');
    end    
    
else  %plot in metric units
    figure(2); hold on
    quiverc(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),ascale);
    colorbar_handle = colorbar('FontSize',16,'XColor','w','YColor','w');
    if sum(~isnan(vr)) == 0
        errordlg('No Data in Specified Depth Range','Plotting Error');
    end
    disp(['DAV range (cm/s) = ' num2str(nanmin(vr)) ' to ' num2str(nanmax(vr))])
    caxis([nanmin(vr) nanmax(vr)])  %resets the color bar axis from 0 to 64 to span the velocity mag range
    if ~isempty(drng)
        title_handle = title({'Depth-Averaged Velocities (cm/s)'; ['Averaged over depths ' num2str(drng(1)) 'm to ' num2str(drng(2)) 'm']},'Color','w');
    else
        title_handle = title('Depth-Averaged Velocities (cm/s)','Color','w');
    end
end
xlabel_handle = xlabel('UTM Easting (m)');
ylabel_handle = ylabel('UTM Northing (m)');

% Tag Figure Elements
% set(plan_view_vector_handle,        'Tag','PlanViewVectors')
set(colorbar_handle,                'Tag','ColorBar')
set(title_handle,                   'Tag','PlanViewPlotTitle')
set(ylabel_handle,                  'Tag','yLabelText')
set(xlabel_handle,                  'Tag','xLabelText')


% Adjust figure
figure(2); box on
set(gcf,'Color',[0 0 0]) %[0.2 0.2 0.2]
set(gca,...
    'DataAspectRatio',[1 1 1],...
    'PlotBoxAspectRatio',[1 1 1],...
    'TickDir','out')
set(get(gca,'Title'),   'FontSize',14,'Color','w') 
set(get(gca,'xlabel'),  'FontSize',14,'Color','w') 
set(get(gca,'ylabel'),  'FontSize',14,'Color','w')
set(colorbar_handle,...
    'FontSize',14,...
    'XColor','w',...
    'YColor','w');
if 0
    CC = cptcmap('printvelocity.cpt');
    colormap(CC)
end


% %if isstruct(Map)
%     set(gca,'Color',[0.8,0.733,0.533]) %[0.3 0.3 0.3]
% else
%     set(gca,'Color',[0 0 0]) %[0.3 0.3 0.3]
% end



%plot([min(xa) min(xa) max(xa) max(xa) min(xa)], [min(ya) max(ya) max(ya) min(ya) min(ya)],'m-'); hold on

%Compute the magnitude and direction for output (for GIS)
%[xo,yo,mag,dir] = VMT_VelVectMagDir(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4));
%outmat = [xo yo mag dir];
%dlmwrite([zPathName '\testoutmd.txt'],outmat,'precision',15)

% %Save bathy
% if savebathy
%     outmat = [bathyx' bathyy' bathyz'];
%     dlmwrite([zPathName '\bathyout.txt'],outmat,'precision',15);
% end

% Format the ticks for UTM and allow zooming and panning
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM
hdlzm = zoom;
set(hdlzm,'ActionPostCallback',@mypostcallback_zoom);
set(hdlzm,'Enable','on');
hdlpn = pan;
set(hdlpn,'ActionPostCallback',@mypostcallback_pan);
set(hdlpn,'Enable','on');

%% Save the planview data as output and to an *.anv file with spacing and smoothing (for iRiC) 
outmat = zeros(size(toquiv,1),5);
outmat(:,1:2) = toquiv(:,1:2);  % In metric units
outmat(:,4:5) = toquiv(:,3:4)./100;  %Converts cm/s to m/s

%Screen to ID missing data
goodrows = [];
for i = 1:length(outmat)
    rowsum = sum(isnan(outmat(i,:)));
    if rowsum == 0
        goodrows = [goodrows; i];
    end
end

PVdata.outmat = outmat(goodrows,:)';


%% PlanView contour plotting 
if 0 %Plot a filled velocity magnitude contour plot with quivers and a velocity gradient contour plot
    
    var = 'backscatter';
    
    indx = ~isnan(ve) & ~isnan(vn) & ~isnan(vv);
    xg = xp(indx); %subsampled, good points
    yg = yp(indx);
    ve = ve(indx);
    vn = vn(indx);
    vm = sqrt(ve.^2 + vn.^2);
    vv = vv(indx);
    vp = vp(indx);
    vs = vs(indx);
    bs = bs(1:end);  %Take all values regardless of valid velocity
    dp = dp(1:end);  %Take all values regardless of valid velocity
        
    %clear ve vn xp yp 
    
    figure(4); clf
    if isstruct(Map) %& (drng(1) == 0 | isempty(drng))  %Only add the shoreline if depth range starts at zero (to minimize interpolation at banks)
        VMT_PlotShoreline(Map)
        indxmap = find(Map.UTMe >= min(xa) & Map.UTMe <= max(xa)...
            & Map.UTMn >= min(ya) & Map.UTMn <= max(ya));
        xa = [xa Map.UTMe(indxmap)'];
        ya = [ya Map.UTMn(indxmap)'];
        xp = [xp Map.UTMe(indxmap)'];
        yp = [yp Map.UTMn(indxmap)'];
        yg = [yg Map.UTMn(indxmap)'];
        xg = [xg Map.UTMe(indxmap)'];
        vm = [vm zeros(size(Map.UTMe(indxmap)'))];  %Sets the flow magnitude to zero at the shoreline
        ve = [ve zeros(size(Map.UTMe(indxmap)'))];
        vn = [vn zeros(size(Map.UTMe(indxmap)'))];
        vv = [vv zeros(size(Map.UTMe(indxmap)'))];
        vp = [vp zeros(size(Map.UTMe(indxmap)'))];
        vs = [vs zeros(size(Map.UTMe(indxmap)'))];
        bs = [bs nan*ones(size(Map.UTMe(indxmap)'))];
        dp = [dp zeros(size(Map.UTMe(indxmap)'))];
      
        
    else
        disp('No Shoreline File Loaded')
    end
    clvls = 60;
    
    xgrdpts = 500;
    ygrdpts = xgrdpts;
    
    switch var
        case{'magnitude'}  %Plots the velocity magnitude (horizontal plane)
            gridvar = vm;
            [ZI,XI,YI] = gridfit(xg,yg,gridvar,xgrdpts,ygrdpts);
        case{'vertical'}  %Plots the vertical velocity
            gridvar = vv;
            [ZI,XI,YI] = gridfit(xg,yg,gridvar,xgrdpts,ygrdpts,'smoothness',2);
        case{'primary'}  %Plots the primary velocity n %%%**************************NEEDS TO BE CORRECTED FOR NEG PRIMARY
            gridvar = vp;
            [ZI,XI,YI] = gridfit(xg,yg,gridvar,xgrdpts,ygrdpts);
        case{'secondary'}  %Plots the secondary velocity (magnitude of secondary and vertical components)
            gridvar = vs;
            [ZI,XI,YI] = gridfit(xg,yg,gridvar,xgrdpts,ygrdpts);
        case{'backscatter'}  %Plots the backscatter
            gridvar = bs;
            [ZI,XI,YI] = gridfit(xp,yp,gridvar,xgrdpts,ygrdpts);
        case{'shear'}  %Plots the shear
            gridvar = vm;
            [ZI,XI,YI] = gridfit(xg,yg,gridvar,xgrdpts,ygrdpts);
            HX = [0 diff(XI)];
            HY = [0 diff(YI)];
        case{'secopri'}  %Plots the ratio of the secondary to primary velocity
            gridvar = abs(vs)./abs(vp);
            [ZI,XI,YI] = gridfit(xg,yg,gridvar,xgrdpts,ygrdpts,'smoothness',1);
        case{'depth'}  %Plots the average bed depth
            gridvar = dp;
            [ZI,XI,YI] = gridfit(xa,ya,gridvar,xgrdpts,ygrdpts,'smoothness',1);
%             xnodes = linspace(min(xa),max(xa),xgrdpts)';
%             xnodes(end) = max(xa); % make sure it hits the max
%             ynodes = linspace(min(ya),max(ya),ygrdpts)';
%             ynodes(end) = max(ya); % make sure it hits the max
%             [XI,YI] = meshgrid(xnodes,ynodes);
%             [ZI] = griddata(xa,ya,gridvar,XI,YI);

  
       
    end
    
    switch var
          case{'shear'} 
              [gradX,gradY] = gradient(ZI./100,HX,HY);  
              ZI = sqrt(gradX.^2 + gradY.^2);
              gridvar = ZI;
    end
    
    if isstruct(Map)
        OUT = ~inpolygon(XI,YI,Map.UTMe,Map.UTMn);
        ZI(OUT) = nan; %omit data outside of the river banks
    end
    
    zmin  = floor(nanmin(nanmin(ZI)));
    zmax  = ceil(nanmax(nanmax(ZI)));
    zinc  = (zmax - zmin) / clvls;
    zlevs = zmin:zinc:zmax;
    switch var
          case{'secopri'} 
              zmax = 1.0;
              zinc  = (zmax - 0) / clvls;
              zlevs = 0:zinc:zmax;
        case{'depth'}
            zmin  = 0;
            zmax  = ceil(nanmax(nanmax(gridvar)));
            zinc  = (zmax - zmin) / clvls;
            zlevs = zmin:zinc:zmax;
    end


    
    contour(XI,YI,ZI,zlevs,'Fill','on','Linestyle','none'); hold on
    colorbar('FontSize',16,'XColor','w','YColor','w');

    
    if 0 %Check plots by adding values for visual inspection
        for j = 1:length(gridvar)
            text(xg(j),yg(j),num2str(gridvar(j)),'FontSize',6); hold on
        end
    end
    
    %Blank if provided a shoreline 
    if isstruct(Map)
        VMT_BlankShoreline(xa,ya,Map);
        %VMT_PlotShoreline(Map);
    end
    quiver(xg,yg,ve,vn,'k','Filled'); hold on
    %xlabel('UTM Easting (m)')
    %ylabel('UTM Northing (m)')
    
    if ~isempty(drng)
        switch var
            case{'magnitude'}  %Plots the velocity magnitude (horizontal plane)
                title({'Depth-Averaged Horizontal Velocity Magnitude (cm/s)'; ['Averaged over depths ' num2str(drng(1)) 'm to ' num2str(drng(2)) 'm']},'Color','w')
            case{'vertical'}  %Plots the vertical velocity
                title({'Depth-Averaged Vertical Velocity (cm/s)'; ['Averaged over depths ' num2str(drng(1)) 'm to ' num2str(drng(2)) 'm']},'Color','w')
            case{'primary'}  %Plots the primary velocity
                title({'Depth-Averaged Primary Velocity (cm/s)'; ['Averaged over depths ' num2str(drng(1)) 'm to ' num2str(drng(2)) 'm']},'Color','w')
            case{'secondary'}  %Plots the secondary velocity
                title({'Depth-Averaged Secondary Velocity (cm/s)'; ['Averaged over depths ' num2str(drng(1)) 'm to ' num2str(drng(2)) 'm']},'Color','w')
            case{'backscatter'}  %Plots the backscatter
                title({'Depth-Averaged Backscatter (dB)'; ['Averaged over depths ' num2str(drng(1)) 'm to ' num2str(drng(2)) 'm']},'Color','w')
            case{'shear'}  %Plots the shear
                title({'Depth-Averaged Shear (s^{-1})'; ['Averaged over depths ' num2str(drng(1)) 'm to ' num2str(drng(2)) 'm']},'Color','w')
            case{'secopri'}  %Plots the ratio of the secondary to primary velocity
                title({'Depth-Averaged Ratio of Secondary to Primary Velocity'; ['Averaged over depths ' num2str(drng(1)) 'm to ' num2str(drng(2)) 'm']},'Color','w');
            case{'depth'}  %Plots the average bed depth (m)
                title('Average Bed Depth (m)','Color','w');
        end
    else 
        switch var
            case{'magnitude'}  %Plots the velocity magnitude (horizontal plane)
                title('Depth-Averaged Horizontal Velocity Magnitude (cm/s)','Color','w')
            case{'vertical'}  %Plots the vertical velocity
                title('Depth-Averaged Vertical Velocity (cm/s)','Color','w')
            case{'primary'}  %Plots the primary velocity
                title('Depth-Averaged Primary Velocity (cm/s)','Color','w')
            case{'secondary'}  %Plots the secondary velocity
                title('Depth-Averaged Secondary Velocity (cm/s)','Color','w')
            case{'backscatter'}  %Plots the backscatter
                title('Depth-Averaged Backscatter (dB)','Color','w')
            case{'shear'}  %Plots the shear
                title('Depth-Averaged Shear (s^{-1})','Color','w')
            case{'secopri'}  %Plots the ratio of the secondary to primary velocity
                title('Depth-Averaged Ratio of Secondary to Primary Velocity','Color','w');
            case{'depth'}  %Plots the average bed depth (m)
                title('Average Bed Depth (m)','Color','w');
        end
    end
    figure(4); box on
    set(gcf,'Color',[0 0 0]) %[0.2 0.2 0.2]
    if isstruct(Map)
        set(gca,'Color',[0.8,0.733,0.533]) %[0.3 0.3 0.3]
    else
        set(gca,'Color',[0 0 0]) %[0.3 0.3 0.3]
    end
    set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
    set(gca,'TickDir','out')
    set(gca,'XColor','w')
    set(gca,'YColor','w')
    
end

%% Embedded functions 
function mypostcallback_zoom(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when zooming) 

function mypostcallback_pan(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when panning) 

