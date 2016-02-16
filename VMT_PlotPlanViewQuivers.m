function [PVdata,fig_planview_handle,log_text] = VMT_PlotPlanViewQuivers(z,A,V,Map,drng,ascale,QuiverSpacing,pvsmwin,pshore,plot_english,varargin)
% This function plots a plan view of the measurement region with a vector
% field of depth averaged velocity for each processed mean cross section.
%
% ASC version is for plotting ASCII loaded data. 9/2/09 (also has new
% pvsmwin input for the filter window)
%
% Added DOQQ plotting capabilities (PRJ, 6-23-10)
% Added english units option
% Added vector data output option in GUI
%
% User Notes:
%
% 1. Supply z, A, V, and Map for plotting a single mean cross section
% 2. Leave z, A, V, and Map blank (i.e. [],[],[],[]) to load multiple,
%   (preprocessed and saved) cross sections. In this case, user must supply
%   a cell array of filenames, and a path
% 3. Leave drng blank (i.e. []) for full depth means or specify
%   the a 2 component vector of depths in meters (drng = [ dupper dlower])
%   of the depth range to average and plot
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-10-08 
% Last modified: F.L. Engel, USGS, 2/20/2013


warning off
% disp('Plotting Plan View with Depth-Averaged Velocity Vectors...')

%% User Input

%QuiverSpacing   = 15;  %Plots a quiver every X emsembles
%ascale          = 1.5; %Set to 1 for autoscaling and other values for increased or decreased arrow lengths
if exist('plot_english')==0
    plot_english  = 0;
    disp('No units specified, plotting in metric units by default')
end

%% Plot Quivers on Area Map

if isnan(drng)
    drng = [];
end

windowSize      = pvsmwin; %Size of window for running average in smoothing of mean vel vectors (set in GUI)

% See if PLOT 1 exists already, if so clear the figure
fig_planview_handle = findobj(0,'name','Plan View Map');

if ~isempty(fig_planview_handle) &&  ishandle(fig_planview_handle)
    figure(fig_planview_handle); clf
else
    fig_planview_handle = figure('name','Plan View Map'); clf
    %set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
end

% Turn off the menu bar, and keep only specified tools
disableMenuBar(fig_planview_handle)

% Parse optional arguements
minrng       = [];
maxrng       = [];
usecolormap  = [];
cptfullfile  = [];
PVdata.outfile = {};
if ~isempty(varargin)
    if iscell(varargin{1})
        mapmult = true;
        zf = length(varargin{1});
    else
        mapmult = false;
        zf = 1;
    end
    zPathName = varargin{2};
    zFileName = varargin{1};
    plotref   = varargin{3}; % 'hab' or 'dfs'
    
    
    % Parse VMT_GraphicsControl arguements
    if size(varargin,2) > 3 % min and max specified at least
        minrng       = varargin{4};
        maxrng       = varargin{5};
        usecolormap  = varargin{6};
        cptfullfile  = varargin{7};
    end
else
    mapmult = false;
    zf = 1;
end

if mapmult
    hwait = waitbar(0,'Plotting multiple input files, please be patient...');
end
for n=1:zf
    if mapmult
        eval(['load (' sprintf( '\''' ) fullfile(zPathName,zFileName{n}) sprintf( '\''' ) ')']);
        waitbar(n/(zf+1),hwait)
    end
    
    if ~isempty(drng) % This will always have a value if run from VMT GUI
        switch plotref
            case 'dfs'
                indx = V.mcsDepth < drng(1) | V.mcsDepth > drng(2);               
            case 'hab'
                HABdiff = bsxfun(@minus,V.mcsBed,V.mcsDepth);
                indx = HABdiff < drng(1) | HABdiff > drng(2);
                
        end
        %Set all data outside depth range to nan
        V.mcsX(indx) = nan;
        V.mcsY(indx) = nan;
        V.mcsEast(indx) = nan;
        V.mcsNorth(indx) = nan;
        V.mcsTime(indx) = nan;
        
        % Check that there is data. If user requests a narrow depth range,
        % there is a chance the results returns no data. If that's the
        % case, throw a warning and return.
        if all(isnan(V.mcsEast(:))) && all(isnan(V.mcsNorth(:)))
            if ~mapmult
                warndlg('User defined depth range returns no data. Try a different range.','Warning: Depth range error')
                return
            end
        end
%         if n == 1
%             if plot_english
%                 disp(['Plotting Depth Range ' num2str(drng(1)*3.281) 'ft to ' num2str(drng(2)*3.281) 'ft'])
%             else 
%                 disp(['Plotting Depth Range ' num2str(drng(1)) 'm to ' num2str(drng(2)) 'm'])
%             end
%         end
        
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
   end
    

    %Smooth using a running mean defined by WindowSize (averages
    %'2*windowsize+1' ensembles together (centered on node (boxcar filter))
    if windowSize == 0
        V.mcsX1sm     = V.mcsX1;
        V.mcsY1sm     = V.mcsY1;
        V.mcsEast1sm  = V.mcsEast1;
        V.mcsNorth1sm = V.mcsNorth1;
        V.mcsTime1sm  = V.mcsTime;
    else
%         V.mcsX1sm     = filter(ones(1,windowSize)/windowSize,1,V.mcsX1);
%         V.mcsY1sm     = filter(ones(1,windowSize)/windowSize,1,V.mcsY1);
%         V.mcsEast1sm  = filter(ones(1,windowSize)/windowSize,1,V.mcsEast1);
%         V.mcsNorth1sm = filter(ones(1,windowSize)/windowSize,1,V.mcsNorth1);
        
        V.mcsEast1sm  = nanmoving_average(V.mcsEast1,windowSize);  %added 1-7-10, prj
        V.mcsNorth1sm = nanmoving_average(V.mcsNorth1,windowSize);
        V.mcsTime1sm  = nanmoving_average(V.mcsTime,windowSize);
        V.mcsX1sm     = V.mcsX1;
        V.mcsY1sm     = V.mcsY1;
    end
    
    for zi = 1 : z
        Mag(:,:,zi) = A(zi).Comp.mcsMag(:,:);
        %Mag(:,:,zi) = A(zi).Clean.vMag(:,:);
    end
    numavg = nansum(~isnan(Mag),3);
    numavg(numavg==0) = NaN;
    enscnt = nanmean(numavg,1);
    [I,J] = ind2sub(size(enscnt),find(enscnt>=1));  %Changed to 1 from 2 (PRJ, 12-12-08)

    et = windowSize+J(1):QuiverSpacing:J(end);  
    
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
        toquiv(1:493,1:4)=NaN;
        lenp = 0;
    end
    
    len = length(V.mcsX1sm(1,et));

    toquiv(lenp+1:len+lenp,1)=V.mcsX1sm(1,et);
    toquiv(lenp+1:len+lenp,2)=V.mcsY1sm(1,et);
    toquiv(lenp+1:len+lenp,3)=nanmean(V.mcsEast1sm(:,et),1);
    toquiv(lenp+1:len+lenp,4)=nanmean(V.mcsNorth1sm(:,et),1);
    toquiv(lenp+1:len+lenp,5)=nanmean(V.mcsTime1sm(:,et),1);
    toquiv(lenp+1:len+lenp,6)=hypot(V.xLeftBank-V.mcsX1sm(1,et),V.yLeftBank-V.mcsY1sm(1,et));
    lenp = length(V.mcsX1sm(1,et))+lenp;

    % quiverc2wcmap(V.mcsX1sm(1,et),V.mcsY1sm(1,et),nanmean(V.mcsEast1sm(:,et),1),nanmean(V.mcsNorth1sm(:,et),1),0);
    %quiverc(V.mcsX1sm(1,et),V.mcsY1sm(1,et),nanmean(V.mcsEast1sm(:,et),1),nanmean(V.mcsNorth1sm(:,et),1),0)
    %     quiver(V.mcsX1sm(1,et),V.mcsY1sm(1,et),nanmean(V.mcsEast1sm(:,et),1),nanmean(V.mcsNorth1sm(:,et),1),0)
    
    if mapmult
        % Save the filename for each plotted vector. This is used in other
        % functions, like in the Excel output.
        PVdata.outfile = vertcat(PVdata.outfile,repmat(zFileName(n),len,1));
        clear A V z Mag numavg enscnt I J latlon idx namecut
    else
        PVdata.outfile = repmat({zFileName},len,1);
    end
end
vr = sqrt(toquiv(:,3).^2+toquiv(:,4).^2);

% Save only the good data  %Added 3-28-12 PRJ
gdindx = find(~isnan(vr));
toquiv = toquiv(gdindx,:);
PVdata.outfile = PVdata.outfile(gdindx);

% Take care of waitbar if used
if exist('hwait','var') && ishandle(hwait)
    waitbar(1,hwait)
    delete(hwait)
end

figure(fig_planview_handle); hold on
% if pdoqq
%     VMT_OverlayDOQQ
% end
% if pshore
%     if ~isempty(Map) 
%         VMT_PlotShoreline(Map)
%     end
% end
%quiverc2wcmap(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),0,vr,1);
if plot_english
    %quiverc(toquiv(:,1),toquiv(:,2),toquiv(:,3)*0.03281,toquiv(:,4)*0.03281,ascale);  %*0.03281 to go from cm/s to ft/s
    quiverc(toquiv(:,1),toquiv(:,2),toquiv(:,3)*0.03281,toquiv(:,4)*0.03281,ascale,...
        minrng,...
        maxrng,...
        usecolormap,...
        cptfullfile);
    colorbar%('FontSize',16,'XColor','w','YColor','w');
    if sum(~isnan(vr)) == 0
        errordlg('No Data in Specified Depth Range','Plotting Error');
    end
    log_text = {sprintf('   DAV range: %6.3f to %6.3f ft/s', nanmin(vr)*0.03281,nanmax(vr)*0.03281)};
    %caxis([nanmin(vr*0.03281) nanmax(vr*0.03281)])  %resets the color bar axis from 0 to 64 to span the velocity mag range
    % Reset the color bar axis from 0 to 64 to span the velocity mag range
    if ~isempty(minrng)
        caxis([minrng maxrng])  
    else
        caxis([nanmin(vr*0.03281) nanmax(vr*0.03281)])
    end
    if ~isempty(drng)
        switch plotref
            case 'dfs'
                title(...
                    {'Depth-Averaged Velocities (ft/s)'; ...
                    ['Averaged over depths ' ...
                    num2str(drng(1)*3.281,2) 'ft to ' num2str(drng(2)*3.281,2) 'ft' ...
                    ' below surface']});
            case 'hab'
                title(...
                    {'Depth-Averaged Velocities (ft/s)'; ...
                    ['Averaged over depths ' ...
                    num2str(drng(1)*3.281,2) 'ft to ' num2str(drng(2)*3.281,2) 'ft' ...
                    ' above bed']});
        end
    else
        title('Depth-Averaged Velocities (ft/s)')%,'Color','w');
    end
else  %plot in metric units
    %quiverc(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),ascale);
    quiverc(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),ascale,...
        minrng,...
        maxrng,...
        usecolormap,...
        cptfullfile);
    colorbar%('FontSize',16,'XColor','w','YColor','w');
    if sum(~isnan(vr)) == 0
        errordlg('No Data in Specified Depth Range','Plotting Error');
    end
    log_text = {sprintf('   DAV range: %6.3f to %6.3f cm/s', nanmin(vr),nanmax(vr))};
    
    % Reset the color bar axis from 0 to 64 to span the velocity mag range
    if ~isempty(minrng)
        caxis([minrng maxrng])  
    else
        caxis([nanmin(vr) nanmax(vr)])
    end
    
    if ~isempty(drng)
        switch plotref
            case 'dfs'
                title(...
                    {'Depth-Averaged Velocities (cm/s)'; ...
                    ['Averaged over depths ' ...
                    num2str(drng(1),2) 'm to ' num2str(drng(2),2) 'm' ...
                    ' below surface']});
            case 'hab'
                title(...
                    {'Depth-Averaged Velocities (cm/s)'; ...
                    ['Averaged over depths ' ...
                    num2str(drng(1),2) 'm to ' num2str(drng(2),2) 'm' ...
                    ' above bed']});
        end
    else
        title('Depth-Averaged Velocities (cm/s)')%,'Color','w');
    end
end

xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
figure(fig_planview_handle); box on
%set(gcf,'Color',[0 0 0]) %[0.2 0.2 0.2]
%set(gca,'Color',[0.8,0.733,0.533]) %[0.3 0.3 0.3]
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
set(gca,'TickDir','out')

% Format the ticks for UTM and allow zooming and panning
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM
hdlzm = zoom;
set(hdlzm,'ActionPostCallback',@mypostcallback_zoom);
set(hdlzm,'Enable','on');
hdlpn = pan;
set(hdlpn,'ActionPostCallback',@mypostcallback_pan);
set(hdlpn,'Enable','on');

% Display the figure
% Hide the figure until the end (this makes the rendering look better)
%set(fig_planview_handle,'visible','on')

%% Save the planview data as output and to an *.anv file with spacing and smoothing (for iRiC) 
outmat = zeros(size(toquiv,1),6);
outmat(:,1:2) = toquiv(:,1:2);       % In metric units
outmat(:,4:5) = toquiv(:,3:4)./100;  % Converts cm/s to m/s
outmat(:,6)   = toquiv(:,5);         % Serial time
outmat(:,7)   = toquiv(:,6);         % Dist from left bank

%Screen to ID missing data
goodrows = [];
for i = 1:size(outmat,1)
    rowsum = sum(isnan(outmat(i,:)));
    if rowsum == 0
        goodrows = [goodrows; i];
    end
end

PVdata.outmat = outmat(goodrows,:)';

function mypostcallback_zoom(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when zooming) 

function mypostcallback_pan(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when panning) 


