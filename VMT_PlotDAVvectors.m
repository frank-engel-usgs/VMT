function VMT_PlotDAVvectors(Easting,Northing,DAVeast,DAVnorth,ascale,QuiverSpacing,plot_metric)
% Plots a plan view vector field using the given velocity
% components.  Input DAV are assumend to be in meters per second.
% Used by ASCII2GIS tool
%
% P.R. Jackson, USGS, 5-11-11
% 
% Last modified: 05-29-2013
% Frank L. Engel, USGS (fengel@usgs.gov)

warning off
disp('Plotting Plan View with Depth-Averaged Velocity Vectors...')

%% User Input

if exist('plot_metric')==0
    plot_metric  = 1;
    disp('No units specified, plotting in metric units by default')
end

%%

% See if PLOT 1 exists already, if so clear the figure
fig_planview_handle = findobj(0,'name','Plan View Map');

if ~isempty(fig_planview_handle) &&  ishandle(fig_planview_handle)
    figure(fig_planview_handle); clf
else
    fig_planview_handle = figure('name','Plan View Map'); clf
    %set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
end

%% Plot Quivers on Map

toquiv(:,1) = Easting(1:QuiverSpacing:end);
toquiv(:,2) = Northing(1:QuiverSpacing:end);
toquiv(:,3) = DAVeast(1:QuiverSpacing:end);
toquiv(:,4) = DAVnorth(1:QuiverSpacing:end);
vr = sqrt(toquiv(:,3).^2+toquiv(:,4).^2);

figure(fig_planview_handle); hold on

%quiverc2wcmap(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),0,vr,1);
if ~plot_metric
%     figure(2); hold on
    quiverc(toquiv(:,1),toquiv(:,2),toquiv(:,3)*3.281,toquiv(:,4)*3.281,ascale);  %*3.281 to go from m/s to ft/s
    colorbar('FontSize',16,'XColor','w','YColor','w');
    if sum(~isnan(vr)) == 0
        errordlg('No Valid Data','Plotting Error');
    end
    disp(['DAV range (ft/s) = ' num2str(nanmin(vr)*3.281) ' to ' num2str(nanmax(vr)*3.281)])
    caxis([nanmin(vr*3.281) nanmax(vr*3.281)])  %resets the color bar axis from 0 to 64 to span the velocity mag range
    title('Depth-Averaged Velocities (ft/s)','Color','w');
    
else  %plot in metric units
%     figure(2); hold on
    quiverc(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),ascale);
%     quiverc(toquiv(:,1),toquiv(:,2),toquiv(:,3)*0.03281,toquiv(:,4)*0.03281,ascale,...
%         minrng,...
%         maxrng,...
%         usecolormap,...
%         cptfullfile);
    colorbar('FontSize',16,'XColor','w','YColor','w');
    if sum(~isnan(vr)) == 0
        errordlg('No Valid Data','Plotting Error');
    end
    disp(['DAV range (m/s) = ' num2str(nanmin(vr)) ' to ' num2str(nanmax(vr))])
    caxis([nanmin(vr) nanmax(vr)])  %resets the color bar axis from 0 to 64 to span the velocity mag range
    title('Depth-Averaged Velocities (m/s)','Color','w');
end
xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
box on

% Make the changes to figure
% Defaults for Presentation Stlye Figure
% --------------------------------------
BkgdColor   = 'black';
AxColor     = 'white';
FigColor    = 'black'; % [0.3 0.3 0.3]
FntSize     = 14;
figure(fig_planview_handle)

set(gcf,'Color',BkgdColor);
set(gca,'FontSize',FntSize)
set(get(gca,'Title'),'FontSize',FntSize)
set(gca,'Color',FigColor)
set(gca,'XColor',AxColor)
set(gca,'YColor',AxColor)
set(gca,'ZColor',AxColor)
set(findobj(gcf,'tag','Colorbar'),'FontSize',FntSize,'XColor',AxColor,'YColor',AxColor);
set(get(gca,'Title'),'FontSize',FntSize,'Color',AxColor)
set(get(gca,'xLabel'),'FontSize',FntSize,'Color',AxColor)
set(get(gca,'yLabel'),'FontSize',FntSize,'Color',AxColor)

% Format the ticks for UTM and allow zooming and panning
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM
hdlzm = zoom;
set(hdlzm,'ActionPostCallback',@mypostcallback_zoom);
set(hdlzm,'Enable','on');
hdlpn = pan;
set(hdlpn,'ActionPostCallback',@mypostcallback_pan);
set(hdlpn,'Enable','on');

disp('Plotting Complete...')


%% Embedded functions 
function mypostcallback_zoom(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when zooming) 

function mypostcallback_pan(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when panning) 

