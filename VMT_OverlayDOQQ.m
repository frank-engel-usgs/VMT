function [guiprefs,log_text] = VMT_OverlayDOQQ(guiprefs,varargin)
% Prompts the user for a geotiff DOQQ (USGS) and overlays the aerial image
% in the plan view vector plot.  User can select multiple files. 
%
% Currently only supports a geotiff in UTM corrdinates (USGS DOQQ for
% example) as the image is not projected and is plotted as XY data.  
%
% Added save path functionality (PRJ, 6-23-10)
%
% P.R. Jackson, USGS 6-14-10
% Last modified: F.L. Engel, USGS, 7/25/2013


if ~isempty(varargin)
    skip_ui = varargin{1};
else
    skip_ui = false;
end

% See if PLOT 1 exists already, if not, make the figure
fig_planview_handle = findobj(0,'name','Plan View Map');
if ~isempty(fig_planview_handle) &&  ishandle(fig_planview_handle)
    figure(fig_planview_handle);
else
    fig_planview_handle = figure('name','Plan View Map'); clf
    %set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
end

if ~skip_ui
    if exist('guiprefs','var') && isfield(guiprefs,'aerial_path')
        if iscell(guiprefs.aerial_file)
            [guiprefs.aerial_file,guiprefs.aerial_path] = uigetfile(...
                {'*.tif;*.shp;*.asc;*.grd;*.ddf','All Background Files'; '*.*','All Files'},...
                'Select Background File(s)',...
                'Multiselect', 'on',...
                fullfile(guiprefs.aerial_path,guiprefs.aerial_file{1}));
        else
            [guiprefs.aerial_file,guiprefs.aerial_path] = uigetfile(...
                {'*.tif;*.shp;*.asc;*.grd;*.ddf','All Background Files'; '*.*','All Files'},...
                'Select Background File(s)',...
                'Multiselect', 'on',...
                fullfile(guiprefs.aerial_path,guiprefs.aerial_file));
        end
    else
        [guiprefs.aerial_file,guiprefs.aerial_path] = uigetfile(...
            {'*.tif;*.shp;*.asc;*.grd;*.ddf','All Background Files'; '*.*','All Files'},...
            'Select Background File(s)',...
            'Multiselect', 'on',...
            pwd);
    end
end

if ischar(guiprefs.aerial_file) % User did not hit cancel, 1 file selected
    figure(fig_planview_handle);
    hdlmap = mapshow(fullfile(guiprefs.aerial_path,guiprefs.aerial_file)); hold on
    uistack(hdlmap,'bottom')
    log_text = vertcat({'Adding background image:'},guiprefs.aerial_file);
    set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
    axis image on
elseif iscell(guiprefs.aerial_file) % User did not hit cancel, multiple files selected
    figure(fig_planview_handle);
    for i = 1:length(guiprefs.aerial_file);
        hdlmap = mapshow(fullfile(guiprefs.aerial_path,guiprefs.aerial_file{i})); hold on
        uistack(hdlmap,'bottom')
        log_text = vertcat({'Adding background image:'},guiprefs.aerial_file{i});
    end
    set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
    axis image on
end


% Format the ticks for UTM and allow zooming and panning
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM
hdlzm = zoom;
set(hdlzm,'ActionPostCallback',@mypostcallback_zoom);
set(hdlzm,'Enable','on');
hdlpn = pan;
set(hdlpn,'ActionPostCallback',@mypostcallback_pan);
set(hdlpn,'Enable','on');


%% Embedded functions 
function mypostcallback_zoom(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when zooming) 

function mypostcallback_pan(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when panning) 

    
    
    
    