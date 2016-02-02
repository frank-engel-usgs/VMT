function varargout = VMT_GraphicsControl(varargin)
% --- THE VELOCITY MAPPING TOOLBOX ---
% VMT_GRAPHICSCONTROL is a sub-GUI of VMT which allows the user to
% dynamically adjust the figures.
%__________________________________________________________________________
% Frank L. Engel, U.S. Geological Survey, Illinois Water Science Center
% (fengel@usgs.gov)
%
% Code contributed by P.R. Jackson, D. Parsons, D. Mueller, and J. Czuba.
%__________________________________________________________________________

% Last Modified by GUIDE v2.5 24-Jul-2013 14:55:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @VMT_GraphicsControl_OpeningFcn, ...
    'gui_OutputFcn',  @VMT_GraphicsControl_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before VMT_GraphicsControl is made visible.
function VMT_GraphicsControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VMT_GraphicsControl (see VARARGIN)

% Choose default command line output for VMT_GraphicsControl
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize the GUI parameters:
% ------------------------------
guiparams = createGUIparams;

% Store the application data
% --------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Load the GUI preferences:
% -------------------------
load_prefs(handles.figure1)

% Initialize the GUI:
% -------------------
initGUI(handles)
% set_enable(handles,'init')

% UIWAIT makes VMT_GraphicsControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% [EOF] VMT_GraphicsControl_OpeningFcn


% --- Outputs from this function are returned to the command line.
function varargout = VMT_GraphicsControl_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in UseDataLimitsPlanview.
function UseDataLimitsPlanview_Callback(hObject, eventdata, handles)

% Get the Application Data
% ------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.use_data_limits_planview = logical(get(hObject,'Value')); % boolean

if ~guiparams.use_data_limits_planview % User wants to set limits
    % Update the GUI:
    % ---------------
    set_enable(handles,'setplanviewon')
else
    % Re-populate edit boxes with the data limits
    % -------------------------------------------
    % Compute the data limits to populate edit boxes
    PVdata = guiparams.gp_vmt.iric_anv_planview_data.outmat';
    PVdata(:,4:5) = PVdata(:,4:5).*100; % in cm/s
    vr = sqrt(PVdata(:,4).^2+PVdata(:,5).^2);
    guiparams.min_velocity_planview  = nanmin(vr);
    guiparams.max_velocity_planview  = nanmax(vr);
    
    % Ensure correct units
    if ~guiparams.gp_vmt.english_units
        % No further action
    else
        guiparams.min_velocity_planview = guiparams.min_velocity_planview*0.03281;
        guiparams.max_velocity_planview = guiparams.max_velocity_planview*0.03281;
        %guiparams.min_velocity_mcs      = guiparams.min_velocity_mcs*0.03281;
        %guiparams.max_velocity_mcs      = guiparams.max_velocity_mcs*0.03281;
    end
    set(handles.MinVelocityPlanview, 'String', guiparams.min_velocity_planview);
    set(handles.MaxVelocityPlanview, 'String', guiparams.max_velocity_planview);
    
    % Update the GUI:
    % ---------------
    set_enable(handles,'setplanviewoff')
end

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] VMT_GraphicsControl_OutputFcn





function MinVelocityPlanview_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_value = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_value);

% Modify the Application data:
% ----------------------------
if is_a_number
    guiparams.min_velocity_planview = new_value;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.min_velocity_planview)
end
% [EOF] MinVelocityPlanview_Callback





function MaxVelocityPlanview_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_value = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_value);

% Modify the Application data:
% ----------------------------
if is_a_number
    guiparams.max_velocity_planview = new_value;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.max_velocity_planview)
end
% [EOF] MaxVelocityPlanview_Callback



% --- Executes on selection change in ColormapPlanview.
function ColormapPlanview_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
guiprefs  = getappdata(handles.figure1,'guiprefs');

% Modify the Application data:
% ----------------------------
idx_variable = get(hObject,'Value');
guiparams.idx_colormap_planview = idx_variable;
guiparams.colormap_planview = guiparams.colormaps_planview(idx_variable).string;

if strcmpi('Browse for more (cpt)...',guiparams.colormap_planview)
    [FileName,PathName] = uigetfile('*.cpt','Select the cpt colormap file',...
        fullfile(guiprefs.cpt_path,guiprefs.cpt_file));
    guiparams.cpt_planview = fullfile(PathName,FileName);
    
    % Update the preferences:
    % -----------------------
    guiprefs.cpt_path = PathName;
    guiprefs.cpt_file = FileName;
    setappdata(handles.figure1,'guiprefs',guiprefs)
    store_prefs(handles.figure1,'cptplanview')
end

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] ColormapPlanview_Callback



% --- Executes on button press in UseDataLimitsMCS.
function UseDataLimitsMCS_Callback(hObject, eventdata, handles)
% Get the Application Data
% ------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.use_data_limits_mcs = logical(get(hObject,'Value')); % boolean

if ~guiparams.use_data_limits_mcs % User wants to set limits
    % Update the GUI:
    % ---------------
    set_enable(handles,'setmcson')
else
    % Re-populate edit boxes with the data limits
    % -------------------------------------------
    % Compute the data limits to populate edit boxes
    switch guiparams.gp_vmt.contour
        case 'streamwise'
            vmin = nanmin(guiparams.gp_vmt.V.uSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.uSmooth(:));
        case 'transverse'
            vmin = nanmin(guiparams.gp_vmt.V.vSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.vSmooth(:));
        case 'vertical'
            vmin = nanmin(guiparams.gp_vmt.V.wSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.wSmooth(:));
        case 'mag'
            vmin = nanmin(guiparams.gp_vmt.V.mcsMagSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.mcsMagSmooth(:));
        case 'east'
            vmin = nanmin(guiparams.gp_vmt.V.mcsMagSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.mcsMagSmooth(:));
        case 'north'
            vmin = nanmin(guiparams.gp_vmt.V.mcsEastSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.mcsNorthSmooth(:));
        case 'primary_zsd'
            vmin = nanmin(guiparams.gp_vmt.V.vpSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.vpSmooth(:));
        case 'secondary_zsd'
            vmin = nanmin(guiparams.gp_vmt.V.vsSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.vsSmooth(:));
        case 'primary_roz'
            vmin = nanmin(guiparams.gp_vmt.V.Roz.upSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.Roz.upSmooth(:));
        case 'secondary_roz'
            vmin = nanmin(guiparams.gp_vmt.V.Roz.usSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.Roz.usSmooth(:));
        case 'primary_roz_x'
            vmin = nanmin(guiparams.gp_vmt.V.Roz.upxSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.Roz.upxSmooth(:));
        case 'primary_roz_y'
            vmin = nanmin(guiparams.gp_vmt.V.Roz.upySmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.Roz.upySmooth(:));
        case 'secondary_roz_x'
            vmin = nanmin(guiparams.gp_vmt.V.Roz.usxSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.Roz.usxSmooth(:));
        case 'secondary_roz_y'
            vmin = nanmin(guiparams.gp_vmt.V.Roz.usySmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.Roz.usySmooth(:));
        case 'backscatter'
            vmin = nanmin(guiparams.gp_vmt.V.mcsBackSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.mcsBackSmooth(:));
        case 'flowangle'
            vmin = nanmin(guiparams.gp_vmt.V.mcsDirSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.mcsDirSmooth(:));
    end
    guiparams.min_velocity_mcs              = vmin;
    guiparams.max_velocity_mcs              = vmax;
    
    % Ensure correct units
    if ~guiparams.gp_vmt.english_units
        % No further action
    else
        %guiparams.min_velocity_planview = guiparams.min_velocity_planview*0.03281;
        %guiparams.max_velocity_planview = guiparams.max_velocity_planview*0.03281;
        guiparams.min_velocity_mcs      = guiparams.min_velocity_mcs*0.03281;
        guiparams.max_velocity_mcs      = guiparams.max_velocity_mcs*0.03281;
    end
    set(handles.MinVelocityMCS, 'String', guiparams.min_velocity_mcs);
    set(handles.MaxVelocityMCS, 'String', guiparams.max_velocity_mcs);
    
    % Update the GUI:
    % ---------------
    set_enable(handles,'setmcsoff')
end

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] UseDataLimitsMCS_Callback


function MinVelocityMCS_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric):
% ----------------------------------------------------------------
new_value = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_value);

% Modify the Application data:
% ----------------------------
if is_a_number
    guiparams.min_velocity_mcs = new_value;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.min_velocity_mcs)
end
% [EOF] MinVelocityMCS_Callback




function MaxVelocityMCS_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric):
% ----------------------------------------------------------------
new_value = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_value);

% Modify the Application data:
% ----------------------------
if is_a_number
    guiparams.max_velocity_mcs = new_value;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.max_velocity_mcs)
end
% [EOF] MaxVelocityMCS_Callback



% --- Executes on selection change in ColormapMCS.
function ColormapMCS_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
guiprefs  = getappdata(handles.figure1,'guiprefs');

% Modify the Application data:
% ----------------------------
idx_variable = get(hObject,'Value');
guiparams.idx_colormap_mcs = idx_variable;
guiparams.colormap_mcs = guiparams.colormaps_mcs(idx_variable).string;

if strcmpi('Browse for more (cpt)...',guiparams.colormap_mcs)
    [FileName,PathName] = uigetfile('*.cpt','Select the cpt colormap file',...
        fullfile(guiprefs.cpt_path,guiprefs.cpt_file));
    guiparams.cpt_mcs = fullfile(PathName,FileName);
    
    % Update the preferences:
    % -----------------------
    guiprefs.cpt_path = PathName;
    guiprefs.cpt_file = FileName;
    setappdata(handles.figure1,'guiprefs',guiprefs)
    store_prefs(handles.figure1,'cptmcs')
end

% Re-store the Application data:
% ------------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% [EOF] ColormapMCS_Callback



function ReferenceVelocity_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_value = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_value);
is_positive = new_value>=0;

% Modify the Application data:
% ----------------------------
if is_a_number && is_positive
    guiparams.reference_velocity = new_value;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.reference_velocity)
end
% [EOF] ReferenceVelocity_Callback




% --- Executes on button press in UseDefaults.
function UseDefaults_Callback(hObject, eventdata, handles)
% Get the Application Data
% ------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the Application data:
% ----------------------------
guiparams.use_defaults = logical(get(hObject,'Value')); % boolean

if ~guiparams.use_defaults % User wants to set limits
    % Update the GUI:
    % ---------------
    set_enable(handles,'setrefon')
else
    [~,J] = ind2sub(size(guiparams.gp_vmt.V.vp(1,:)),find(~isnan(guiparams.gp_vmt.V.vp(1,:))==1));
    et = J(1):guiparams.gp_vmt.horizontal_vector_spacing:J(end);
    [r, ~]=size(guiparams.gp_vmt.V.vp);
    bi = 1:guiparams.gp_vmt.vertical_vector_spacing:r;
    switch guiparams.gp_vmt.secondary_flow_vector_variable
        case 'transverse'
            reference_velocity = ceil(max(max(abs(guiparams.gp_vmt.V.vSmooth(bi,et)))));
        case 'secondary_zsd'
            reference_velocity = ceil(max(max(abs(guiparams.gp_vmt.V.vsSmooth(bi,et)))));
        case 'secondary_roz'
            reference_velocity = ceil(max(max(abs(guiparams.gp_vmt.V.Roz.usSmooth(bi,et)))));
        case 'secondary_roz_y'
            reference_velocity = ceil(max(max(abs(guiparams.gp_vmt.V.Roz.usySmooth(bi,et)))));
        case 'primary_roz_y'
            reference_velocity = ceil(max(max(abs(guiparams.gp_vmt.V.Roz.upySmooth(bi,et)))));
    end
    
    distance = 0.06*max(guiparams.gp_vmt.V.mcsDist(:));
    depth    = 0.95*max(guiparams.gp_vmt.V.mcsBed(:));
    if guiparams.gp_vmt.english_units
        reference_velocity = reference_velocity*0.03281; % cm/s to ft/s
        distance = distance*3.281;
        depth    = depth*3.281;
    end
    
    
    set(handles.ReferenceVelocity, 'String', num2str(reference_velocity))
    set(handles.Distance,          'String', num2str(distance))
    set(handles.Depth,             'String', num2str(depth))
    
    % Re-store the Application data:
    % ------------------------------
    guiparams.reference_velocity = reference_velocity;
    guiparams.distance           = distance;
    guiparams.depth              = depth;
    setappdata(handles.figure1,'guiparams',guiparams)
    
    % Update the GUI:
    % ---------------
    set_enable(handles,'setrefoff')
end


% [EOF] UseDefaults_Callback


function Distance_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_value = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_value);
is_positive = new_value>=0;

% Modify the Application data:
% ----------------------------
if is_a_number && is_positive
    guiparams.distance = new_value;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.distance)
end
% [EOF] Distance_Callback





function Depth_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Get the new entry and make sure it is valid (numeric, positive):
% ----------------------------------------------------------------
new_value = str2double(get(hObject,'String'));
is_a_number = ~isnan(new_value);
is_positive = new_value>=0;

% Modify the Application data:
% ----------------------------
if is_a_number && is_positive
    guiparams.depth = new_value;
    
    % Re-store the Application data:
    % ------------------------------
    setappdata(handles.figure1,'guiparams',guiparams)
    
else % Reject the (incorrect) input
    set(hObject,'String',guiparams.depth)
end
% [EOF] Depth_Callback




% --- Executes on button press in ApplyChanges.
function ApplyChanges_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
guiprefs  = getappdata(handles.figure1,'guiprefs');
z   = guiparams.gp_vmt.z;
A   = guiparams.gp_vmt.A;
V   = guiparams.gp_vmt.V;
Map = guiparams.gp_vmt.Map;

% See if PLOT 1 exists already, if so grab the handle.
fig_planview_handle = findobj(0,'name','Plan View Map');

% If PLOT 1 exists, go ahead and apply any changes
if ~isempty(fig_planview_handle) &&  ishandle(fig_planview_handle)
    figure(fig_planview_handle);
    % Plot the data:
    % --------------
    %msgbox('Plotting Plan View','VMT Status','help','replace');
    depth_range = [guiparams.gp_vmt.depth_range_min guiparams.gp_vmt.depth_range_max];
    
    minrng = guiparams.min_velocity_planview;
    maxrng = guiparams.max_velocity_planview;
    usecolormap = guiparams.colormap_planview;
    cptfullfile = guiparams.cpt_planview;
    [~,~,~] = VMT_PlotPlanViewQuivers(z,A,V,Map, ...
        depth_range, ...
        guiparams.gp_vmt.vector_scale_plan_view, ...
        guiparams.gp_vmt.vector_spacing_plan_view, ...
        guiparams.gp_vmt.smoothing_window_size, ...
        guiparams.gp_vmt.display_shoreline, ...
        guiparams.gp_vmt.english_units,...
        guiparams.gp_vmt.mat_file, ...
        guiparams.gp_vmt.mat_path,...
        guiparams.gp_vmt.plotref,... % PLOT2
        minrng,...
        maxrng,...
        usecolormap,...
        cptfullfile); % PLOT2
    
    % Plot Shoreline
    if guiparams.gp_vmt.display_shoreline
        
        if ischar(guiprefs.shoreline_file) % User did not hit cancel
            mapdata = dlmread(fullfile(guiprefs.shoreline_path,guiprefs.shoreline_file));
            Map.UTMe   = mapdata(:,1);
            Map.UTMn   = mapdata(:,2);
            Map.infile = fullfile(guiprefs.shoreline_path,guiprefs.shoreline_file);
            %Map.UTMzone = zone;
        else
            Map = [];
        end
        VMT_PlotShoreline(Map)
    end
    
    % Overlay DOQQ
    if guiparams.gp_vmt.add_background
        [~,~] = VMT_OverlayDOQQ(guiprefs,true);
    end
end

% See if PLOT 3 exists already, if so clear the figure
fig_contour_handle = findobj(0,'name','Mean Cross Section Contour');

% If PLOT 3 exists, go ahead and apply any changes
if ~isempty(fig_contour_handle) &&  ishandle(fig_contour_handle)
    figure(fig_contour_handle);
    
    % Modify reference vector, only if it's already being plotted
    if guiparams.gp_vmt.plot_secondary_flow_vectors
        if ~guiparams.gp_vmt.english_units
            [~,A,V,plot_cont_log_text] = VMT_PlotXSContQuiver(z,A,V, ...
                guiparams.gp_vmt.contour, ...
                guiparams.gp_vmt.vector_scale_cross_section, ...
                guiparams.gp_vmt.vertical_exaggeration, ...
                guiparams.gp_vmt.horizontal_vector_spacing, ...
                guiparams.gp_vmt.vertical_vector_spacing, ...
                guiparams.gp_vmt.secondary_flow_vector_variable, ...
                guiparams.gp_vmt.include_vertical_velocity, ...
                guiparams.gp_vmt.english_units,...
                guiparams.gp_vmt.allow_vmt_flip_flux,...
                guiparams.gp_vmt.start_bank,...
                guiparams.reference_velocity,...
                guiparams.distance,...
                guiparams.depth); %#ok<ASGLU> % PLOT3
        else
            [~,A,V,plot_cont_log_text] = VMT_PlotXSContQuiver(z,A,V, ...
                guiparams.gp_vmt.contour, ...
                guiparams.gp_vmt.vector_scale_cross_section, ...
                guiparams.gp_vmt.vertical_exaggeration, ...
                guiparams.gp_vmt.horizontal_vector_spacing, ...
                guiparams.gp_vmt.vertical_vector_spacing, ...
                guiparams.gp_vmt.secondary_flow_vector_variable, ...
                guiparams.gp_vmt.include_vertical_velocity, ...
                guiparams.gp_vmt.english_units,...
                guiparams.gp_vmt.allow_vmt_flip_flux,...
                guiparams.gp_vmt.start_bank,...
                guiparams.reference_velocity.*30.48,... %cm/s
                guiparams.distance.*0.3048,...          %m
                guiparams.depth.*0.3048); %#ok<ASGLU> % PLOT3
        end
    end
    
    % Set data limits
    caxis([
        guiparams.min_velocity_mcs
        guiparams.max_velocity_mcs])
    
    % Apply the color map
    if ~strcmpi('Browse for more (cpt)...',guiparams.colormap_mcs)
        colormap(guiparams.colormap_mcs)
    else
        cptcmap(guiparams.cpt_mcs)
    end
end

% Force plots to be formated properly
% -----------------------------------
if guiparams.gp_vmt.presentation
    UpdatePlotStyle(hObject, eventdata, handles)
else
    UpdatePlotStyle(hObject, eventdata, handles)
end
% [EOF] ApplyChanges_Callback


% --- Executes on button press in Close.
function Close_Callback(hObject, eventdata, handles)

close(handles.figure1)

% [EOF] Close_Callback

% --------------------------------------------------------------------
function initGUI(handles)
% Initialize the UI controls in the GUI.

guiparams = getappdata(handles.figure1,'guiparams');

% Plan View Map Panel
set(handles.UseDataLimitsPlanview,    'Value',  guiparams.use_data_limits_planview);
set(handles.MinVelocityPlanview,      'String', guiparams.min_velocity_planview);
set(handles.MinVelocityPlanviewUnits, 'String', guiparams.min_velocity_planview_units);
set(handles.MaxVelocityPlanview,      'String', guiparams.max_velocity_planview);
set(handles.MaxVelocityPlanviewUnits, 'String', guiparams.max_velocity_planview_units);
set(handles.ColormapPlanview,         'String',{guiparams.colormaps_planview.string}, ...
    'Value', guiparams.idx_colormap_planview)

% Mean Cross Section Contours
set(handles.UseDataLimitsMCS,           'Value',  guiparams.use_data_limits_mcs);
set(handles.MinVelocityMCS,             'String', guiparams.min_velocity_mcs);
set(handles.MinVelocityMCSUnits,        'String', guiparams.min_velocity_mcs_units);
set(handles.MaxVelocityMCS,             'String', guiparams.max_velocity_mcs);
set(handles.MaxVelocityMCSUnits,        'String', guiparams.max_velocity_mcs_units);
set(handles.UseDefaults,                'Value',  guiparams.use_defaults);
set(handles.ReferenceVelocity,          'String', guiparams.reference_velocity);
set(handles.ReferenceVelocityUnits,     'String', guiparams.reference_velocity_units);
set(handles.Distance,                   'String', guiparams.distance);
set(handles.DistanceUnits,              'String', guiparams.distance_units);
set(handles.Depth,                      'String', guiparams.depth);
set(handles.DepthUnits,                 'String', guiparams.depth_units);
set(handles.ColormapMCS,                'String',{guiparams.colormaps_mcs.string}, ...
    'Value', guiparams.idx_colormap_mcs);

% Update the GUI:
% ---------------
if iscell(guiparams.gp_vmt.mat_file) % Multiple mat files loaded
    set_enable(handles,'initmultiple')
else
    set_enable(handles,'init')
end
% [EOF] initGUI

function [guiparams] = createGUIparams

% Get the VMT current state for use by the sub-GUI
% ------------------------------------------------
hVMTgui                 = getappdata(0,'hVMTgui');
guiparams_vmt           = getappdata(hVMTgui,'guiparams');
guiparams.gp_vmt        = guiparams_vmt;

% Check to see what plots already exist
% -------------------------------------
fig_planview_handle = findobj(0,'name','Plan View Map');
fig_mcs_handle = findobj(0,'name','Mean Cross Section Contour');
% if ~isempty(fig_planview_handle) &&  ishandle(fig_planview_handle)
%     figure(fig_planview_handle); clf
% else
%     fig_planview_handle = figure('name','Plan View Map'); clf
%     %set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
% end

%%%%%%%%%%%%%%%%%
% Plan View Map %
%%%%%%%%%%%%%%%%%
guiparams.use_data_limits_planview      = 1;

if ~isempty(fig_planview_handle) && ishandle(fig_planview_handle)
    % Compute the data limits to populate edit boxes
    PVdata = guiparams.gp_vmt.iric_anv_planview_data.outmat';
    PVdata(:,4:5) = PVdata(:,4:5).*100; % in cm/s
    vr = sqrt(PVdata(:,4).^2+PVdata(:,5).^2);
    guiparams.min_velocity_planview  = nanmin(vr);
    guiparams.max_velocity_planview  = nanmax(vr);
else
    guiparams.min_velocity_planview  = 0;
    guiparams.max_velocity_planview  = 0;
end

% Colormap choices
guiparams.idx_colormap_planview  = 1;
idx = 1;
guiparams.colormaps_planview(idx).string   = 'Jet';
idx = idx + 1;
guiparams.colormaps_planview(idx).string   = 'HSV';
idx = idx + 1;
guiparams.colormaps_planview(idx).string   = 'Hot';
idx = idx + 1;
guiparams.colormaps_planview(idx).string   = 'Cool';
idx = idx + 1;
guiparams.colormaps_planview(idx).string   = 'Spring';
idx = idx + 1;
guiparams.colormaps_planview(idx).string   = 'Summer';
idx = idx + 1;
guiparams.colormaps_planview(idx).string   = 'Autumn';
idx = idx + 1;
guiparams.colormaps_planview(idx).string   = 'Winter';
idx = idx + 1;
guiparams.colormaps_planview(idx).string   = 'Gray';
idx = idx + 1;
guiparams.colormaps_planview(idx).string   = 'Bone';
idx = idx + 1;
guiparams.colormaps_planview(idx).string   = 'Copper';
idx = idx + 1;
guiparams.colormaps_planview(idx).string   = 'Pink';
idx = idx + 1;
guiparams.colormaps_planview(idx).string   = 'Browse for more (cpt)...';
guiparams.colormap_planview = ...
    guiparams.colormaps_planview(guiparams.idx_colormap_planview).string;
guiparams.cpt_planview                     = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mean Cross Section Contours %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
guiparams.use_data_limits_mcs           = 1;
guiparams.use_defaults                  = 1;

if ~isempty(fig_mcs_handle) && ishandle(fig_mcs_handle)
if iscell(guiparams.gp_vmt.mat_file) % Multiple mat files loaded
    guiparams.min_velocity_mcs   = 0;
    guiparams.max_velocity_mcs   = 0;
    guiparams.distance           = 0;
    guiparams.depth              = 0;
    guiparams.reference_velocity = 0; % cm/s to ft/s
else
    % Compute the data limits for the edit box, based on the currently selected
    % contour plot variable
    switch guiparams.gp_vmt.contour
        case 'streamwise'
            vmin = nanmin(guiparams.gp_vmt.V.uSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.uSmooth(:));
        case 'transverse'
            vmin = nanmin(guiparams.gp_vmt.V.vSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.vSmooth(:));
        case 'vertical'
            vmin = nanmin(guiparams.gp_vmt.V.wSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.wSmooth(:));
        case 'mag'
            vmin = nanmin(guiparams.gp_vmt.V.mcsMagSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.mcsMagSmooth(:));
        case 'east'
            vmin = nanmin(guiparams.gp_vmt.V.mcsMagSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.mcsMagSmooth(:));
        case 'north'
            vmin = nanmin(guiparams.gp_vmt.V.mcsEastSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.mcsNorthSmooth(:));
        case 'error'
            vmin = nanmin(guiparams.gp_vmt.V.mcsError(:));
            vmax = nanmax(guiparams.gp_vmt.V.mcsError(:));
        case 'primary_zsd'
            vmin = nanmin(guiparams.gp_vmt.V.vpSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.vpSmooth(:));
        case 'secondary_zsd'
            vmin = nanmin(guiparams.gp_vmt.V.vsSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.vsSmooth(:));
        case 'primary_roz'
            vmin = nanmin(guiparams.gp_vmt.V.Roz.upSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.Roz.upSmooth(:));
        case 'secondary_roz'
            vmin = nanmin(guiparams.gp_vmt.V.Roz.usSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.Roz.usSmooth(:));
        case 'primary_roz_x'
            vmin = nanmin(guiparams.gp_vmt.V.Roz.upxSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.Roz.upxSmooth(:));
        case 'primary_roz_y'
            vmin = nanmin(guiparams.gp_vmt.V.Roz.upySmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.Roz.upySmooth(:));
        case 'secondary_roz_x'
            vmin = nanmin(guiparams.gp_vmt.V.Roz.usxSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.Roz.usxSmooth(:));
        case 'secondary_roz_y'
            vmin = nanmin(guiparams.gp_vmt.V.Roz.usySmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.Roz.usySmooth(:));
        case 'backscatter'
            vmin = nanmin(guiparams.gp_vmt.V.mcsBackSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.mcsBackSmooth(:));
        case 'flowangle'
            vmin = nanmin(guiparams.gp_vmt.V.mcsDirSmooth(:));
            vmax = nanmax(guiparams.gp_vmt.V.mcsDirSmooth(:));
        case 'vorticity_vw'
            vmin = nanmin(guiparams.gp_vmt.V.vorticity_vw(:));
            vmax = nanmax(guiparams.gp_vmt.V.vorticity_vw(:));
        case 'vorticity_zsd'
            vmin = nanmin(guiparams.gp_vmt.V.vorticity_zsd(:));
            vmax = nanmax(guiparams.gp_vmt.V.vorticity_zsd(:));
        case 'vorticity_roz'
            vmin = nanmin(guiparams.gp_vmt.V.vorticity_roz(:));
            vmax = nanmax(guiparams.gp_vmt.V.vorticity_roz(:));
    end
    guiparams.min_velocity_mcs              = vmin;
    guiparams.max_velocity_mcs              = vmax;
    
    % Reference arrow
    % Find first full row of data. Typically this is row 1 with RG data,
    % however it may not be for M9 and/or RR data.
    i = 1;
    while any(isnan(guiparams.gp_vmt.V.vp(i,:)))
        i=i+1;
        if i > size(guiparams.gp_vmt.V.vp,1)
            break
        end
    end
    % If a bad ensemble exists, the above while loop might not find a
    % result. If that happens, just use row 1 anyway
%     try
%         [I,J] = ind2sub(size(guiparams.gp_vmt.V.vp(i,:)),find(~isnan(guiparams.gp_vmt.V.vp(i,:))==1));
%     catch err
%         [I,J] = ind2sub(size(guiparams.gp_vmt.V.vp(1,:)),find(~isnan(guiparams.gp_vmt.V.vp(1,:))==1));
%     end
    
    % Find first full row of data. Typically this is row 1 with RG data,
    % however it may not be for M9 and/or RR data.
    i = 1;
    while any(isnan(guiparams.gp_vmt.V.vp(i,:)))
        i=i+1;
        if i > size(guiparams.gp_vmt.V.vp,1)
            break
        end
    end
    i=5; % This is a temporary fix
    % If a bad ensemble exists, the above while loop might not find a
    % result. If that happens, just use row 1 anyway
    try
        [I,J] = ind2sub(size(guiparams.gp_vmt.V.vp(i,:)),find(~isnan(guiparams.gp_vmt.V.vp(i,:))==1));
    catch err
        [I,J] = ind2sub(size(guiparams.gp_vmt.V.vp(1,:)),find(~isnan(guiparams.gp_vmt.V.vp(1,:))==1));
    end
    
    et = J(1):guiparams.gp_vmt.horizontal_vector_spacing:J(end);
    [r, ~]=size(guiparams.gp_vmt.V.vp);
    bi = 1:guiparams.gp_vmt.vertical_vector_spacing:r;
    switch guiparams.gp_vmt.secondary_flow_vector_variable
        case 'transverse'
            guiparams.reference_velocity = ceil(max(max(abs(guiparams.gp_vmt.V.vSmooth(bi,et)))));
        case 'secondary_zsd'
            guiparams.reference_velocity = ceil(max(max(abs(guiparams.gp_vmt.V.vsSmooth(bi,et)))));
        case 'secondary_roz'
            guiparams.reference_velocity = ceil(max(max(abs(guiparams.gp_vmt.V.Roz.usSmooth(bi,et)))));
        case 'secondary_roz_y'
            guiparams.reference_velocity = ceil(max(max(abs(guiparams.gp_vmt.V.Roz.usySmooth(bi,et)))));
        case 'primary_roz_y'
            guiparams.reference_velocity = ceil(max(max(abs(guiparams.gp_vmt.V.Roz.upySmooth(bi,et)))));
    end
    
    guiparams.distance = 0.06*max(guiparams.gp_vmt.V.mcsDist(:));
    guiparams.depth    = 0.95*max(guiparams.gp_vmt.V.mcsBed(:));
    if guiparams.gp_vmt.english_units
        guiparams.reference_velocity = guiparams.reference_velocity*0.03281; % cm/s to ft/s
        guiparams.distance           = guiparams.distance*3.281;
        guiparams.depth              = guiparams.depth*3.281;
    end
end
else
    guiparams.min_velocity_mcs   = 0;
    guiparams.max_velocity_mcs   = 0;
    guiparams.distance           = 0;
    guiparams.depth              = 0;
    guiparams.reference_velocity = 0; % cm/s to ft/s
end

guiparams.idx_colormap_mcs              = 1;

% Colormap choices
idx = 1;
guiparams.colormaps_mcs(idx).string   = 'Jet';
idx = idx + 1;
guiparams.colormaps_mcs(idx).string   = 'HSV';
idx = idx + 1;
guiparams.colormaps_mcs(idx).string   = 'Hot';
idx = idx + 1;
guiparams.colormaps_mcs(idx).string   = 'Cool';
idx = idx + 1;
guiparams.colormaps_mcs(idx).string   = 'Spring';
idx = idx + 1;
guiparams.colormaps_mcs(idx).string   = 'Summer';
idx = idx + 1;
guiparams.colormaps_mcs(idx).string   = 'Autumn';
idx = idx + 1;
guiparams.colormaps_mcs(idx).string   = 'Winter';
idx = idx + 1;
guiparams.colormaps_mcs(idx).string   = 'Gray';
idx = idx + 1;
guiparams.colormaps_mcs(idx).string   = 'Bone';
idx = idx + 1;
guiparams.colormaps_mcs(idx).string   = 'Copper';
idx = idx + 1;
guiparams.colormaps_mcs(idx).string   = 'Pink';
idx = idx + 1;
guiparams.colormaps_mcs(idx).string   = 'Browse for more (cpt)...';
guiparams.colormap_mcs = ...
    guiparams.colormaps_mcs(guiparams.idx_colormap_mcs).string;
guiparams.cpt_mcs                      = [];

% Set the units
switch guiparams.gp_vmt.contour
    case 'backscatter'
        guiparams.min_velocity_mcs_units   = 'dB';
        guiparams.max_velocity_mcs_units   = 'dB';
        if ~guiparams.gp_vmt.english_units
            guiparams.min_velocity_planview_units   = 'cm/s';
            guiparams.max_velocity_planview_units   = 'cm/s';
            %guiparams.min_velocity_mcs_units        = 'cm/s';
            %guiparams.max_velocity_mcs_units        = 'cm/s';
            guiparams.reference_velocity_units      = 'cm/s';
            guiparams.distance_units                = 'm';
            guiparams.depth_units                   = 'm';
        else
            guiparams.min_velocity_planview_units   = 'ft/s';
            guiparams.max_velocity_planview_units   = 'ft/s';
            %guiparams.min_velocity_mcs_units        = 'ft/s';
            %guiparams.max_velocity_mcs_units        = 'ft/s';
            guiparams.reference_velocity_units      = 'ft/s';
            guiparams.distance_units                = 'ft';
            guiparams.depth_units                   = 'ft';
        end
    case 'flowangle'
        guiparams.min_velocity_mcs_units   = 'deg';
        guiparams.max_velocity_mcs_units   = 'deg';
        if ~guiparams.gp_vmt.english_units
            guiparams.min_velocity_planview_units   = 'cm/s';
            guiparams.max_velocity_planview_units   = 'cm/s';
            %guiparams.min_velocity_mcs_units        = 'cm/s';
            %guiparams.max_velocity_mcs_units        = 'cm/s';
            guiparams.reference_velocity_units      = 'cm/s';
            guiparams.distance_units                = 'm';
            guiparams.depth_units                   = 'm';
        else
            guiparams.min_velocity_planview_units   = 'ft/s';
            guiparams.max_velocity_planview_units   = 'ft/s';
            %guiparams.min_velocity_mcs_units        = 'ft/s';
            %guiparams.max_velocity_mcs_units        = 'ft/s';
            guiparams.reference_velocity_units      = 'ft/s';
            guiparams.distance_units                = 'ft';
            guiparams.depth_units                   = 'ft';
        end
    otherwise
        if ~guiparams.gp_vmt.english_units
            guiparams.min_velocity_planview_units   = 'cm/s';
            guiparams.max_velocity_planview_units   = 'cm/s';
            
            guiparams.min_velocity_mcs_units        = 'cm/s';
            guiparams.max_velocity_mcs_units        = 'cm/s';
            guiparams.reference_velocity_units      = 'cm/s';
            guiparams.distance_units                = 'm';
            guiparams.depth_units                   = 'm';
        else
            guiparams.min_velocity_planview_units   = 'ft/s';
            guiparams.max_velocity_planview_units   = 'ft/s';
            
            guiparams.min_velocity_mcs_units        = 'ft/s';
            guiparams.max_velocity_mcs_units        = 'ft/s';
            guiparams.reference_velocity_units      = 'ft/s';
            guiparams.distance_units                = 'ft';
            guiparams.depth_units                   = 'ft';
            
            guiparams.min_velocity_planview = guiparams.min_velocity_planview*0.03281;
            guiparams.max_velocity_planview = guiparams.max_velocity_planview*0.03281;
            guiparams.min_velocity_mcs      = guiparams.min_velocity_mcs*0.03281;
            guiparams.max_velocity_mcs      = guiparams.max_velocity_mcs*0.03281;
        end
end
% [EOF] createGUIparams

% --------------------------------------------------------------------
function set_enable(handles,enable_state)

guiparams = getappdata(handles.figure1,'guiparams');

switch enable_state
    case 'init'
        % Plan View Map Panel
        set([handles.UseDataLimitsPlanview
            handles.ColormapPlanview],'Enable', 'on');
        set([handles.MinVelocityPlanview
            handles.MinVelocityPlanviewUnits
            handles.MaxVelocityPlanview
            handles.MaxVelocityPlanviewUnits], 'Enable', 'off');
        
        % Mean Cross Section Contours
        set([handles.UseDataLimitsMCS
            handles.UseDefaults
            handles.ColormapMCS],'Enable', 'on');
        set([handles.MinVelocityMCS
            handles.MinVelocityMCSUnits
            handles.MaxVelocityMCS
            handles.MaxVelocityMCSUnits
            handles.ReferenceVelocity
            handles.ReferenceVelocityUnits
            handles.Distance
            handles.DistanceUnits
            handles.Depth
            handles.DepthUnits], 'Enable', 'off');
    case 'initmultiple'
        % Plan View Map Panel
        set([handles.UseDataLimitsPlanview
            handles.ColormapPlanview],'Enable', 'on');
        set([handles.MinVelocityPlanview
            handles.MinVelocityPlanviewUnits
            handles.MaxVelocityPlanview
            handles.MaxVelocityPlanviewUnits], 'Enable', 'off');
        
        % Mean Cross Section Contours
        set([handles.UseDataLimitsMCS
            handles.UseDefaults
            handles.ColormapMCS],'Enable', 'off');
        set([handles.MinVelocityMCS
            handles.MinVelocityMCSUnits
            handles.MaxVelocityMCS
            handles.MaxVelocityMCSUnits
            handles.ReferenceVelocity
            handles.ReferenceVelocityUnits
            handles.Distance
            handles.DistanceUnits
            handles.Depth
            handles.DepthUnits], 'Enable', 'off');
    case 'setplanviewon'
        % Plan View Map Panel
        set([handles.UseDataLimitsPlanview
            handles.ColormapPlanview],'Enable', 'on');
        set([handles.MinVelocityPlanview
            handles.MinVelocityPlanviewUnits
            handles.MaxVelocityPlanview
            handles.MaxVelocityPlanviewUnits], 'Enable', 'on');
    case 'setplanviewoff'
        % Plan View Map Panel
        set([handles.UseDataLimitsPlanview
            handles.ColormapPlanview],'Enable', 'on');
        set([handles.MinVelocityPlanview
            handles.MinVelocityPlanviewUnits
            handles.MaxVelocityPlanview
            handles.MaxVelocityPlanviewUnits], 'Enable', 'off');
    case 'setmcson'
        % Mean Cross Section Contours
        set([handles.UseDataLimitsMCS
            handles.ColormapMCS],'Enable', 'on');
        set([handles.MinVelocityMCS
            handles.MinVelocityMCSUnits
            handles.MaxVelocityMCS
            handles.MaxVelocityMCSUnits
            ], 'Enable', 'on');
    case 'setmcsoff'
        % Mean Cross Section Contours
        set([handles.UseDataLimitsMCS
            handles.ColormapMCS],'Enable', 'on');
        set([handles.MinVelocityMCS
            handles.MinVelocityMCSUnits
            handles.MaxVelocityMCS
            handles.MaxVelocityMCSUnits
            ], 'Enable', 'off');
    case 'setrefon'
        set([handles.ReferenceVelocity
            handles.ReferenceVelocityUnits
            handles.Distance
            handles.DistanceUnits
            handles.Depth
            handles.DepthUnits], 'Enable', 'on');
    case 'setrefoff'
        set([handles.ReferenceVelocity
            handles.ReferenceVelocityUnits
            handles.Distance
            handles.DistanceUnits
            handles.Depth
            handles.DepthUnits], 'Enable', 'off');
    otherwise
end
% [EOF] set_enable

% --------------------------------------------------------------------
function UpdatePlotStyle(hObject, eventdata, handles)
% Get the Application Data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');

% Modify the existing figures
% ---------------------------
% Find what plots exist already
hf = findobj('type','figure');
valid_names = {'Plan View Map'; 'Mean Cross Section Contour'};

if guiparams.gp_vmt.presentation
    % Defaults for Presentation Stlye Figure
    BkgdColor   = 'black';
    AxColor     = 'white';
    AxColor2    = [0.3 0.3 0.3];
    FigColor    = 'black'; % [0.3 0.3 0.3]
    FntSize     = 14;
else
    % Defaults for Print Stlye Figure
    BkgdColor   = 'white';
    AxColor     = 'black';
    FigColor    = 'white'; % [0.3 0.3 0.3]
    FntSize     = 14;
end
% Loop through valid figures and adjust
% -------------------------------------
if ~isempty(hf) &&  any(ishandle(hf))
    
    for i = 1:length(valid_names)
        switch valid_names{i}
            case 'Plan View Map'
                % Focus the figure
                hff = findobj('name','Plan View Map');
                if ~isempty(hff) &&  ishandle(hff)
                    figure(hff)
                    
                    % Make the changes to figure
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
                end
            case 'Mean Cross Section Contour'
                % Focus the figure
                hff = findobj('name','Mean Cross Section Contour');
                if ~isempty(hff) &&  ishandle(hff)
                    figure(hff)
                    
                    % Make the changes to figure
                    set(gcf,'Color',BkgdColor);
                    set(gca,'FontSize',FntSize)
                    set(get(gca,'Title'),'FontSize',FntSize)
                    set(gca,'Color',AxColor2)
                    set(gca,'XColor',AxColor)
                    set(gca,'YColor',AxColor)
                    set(gca,'ZColor',AxColor)
                    set(findobj(gcf,'tag','Colorbar'),'FontSize',FntSize,'XColor',AxColor,'YColor',AxColor);
                    set(get(gca,'Title'),'FontSize',FntSize,'Color',AxColor)
                    set(get(gca,'xLabel'),'FontSize',FntSize,'Color',AxColor)
                    set(get(gca,'yLabel'),'FontSize',FntSize,'Color',AxColor)
                    set(findobj(gca,'tag','PlotBedElevation')   ,'color'    ,AxColor)
                    set(findobj(gca,'tag','ReferenceVectorText'),'color'    ,AxColor)
                end
            otherwise
        end
    end
    
    
end

% [EOF] UpdatePlotStyle
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function load_prefs(hfigure)
% Load the GUI preferences.  Also, initialize preferences if they don't
% already exist.

% Preferences:
% 'cptplanview'     Path and filenames of current graphic (cpt) files for planview
% 'cptmcs'          Path and filenames of current graphic (cpt) files for MCS
% 'shoreline;
% 'aerial'

if ispref('VMT','cptplanview')
    cptplanview = getpref('VMT','cptplanview');
    if exist(cptplanview.path,'dir')
        guiprefs.cpt_path = cptplanview.path;
    else
        guiprefs.cpt_path = pwd;
    end
    
    if exist(fullfile(cptplanview.path,cptplanview.file),'file')
        guiprefs.cpt_file = cptplanview.file;
    else
        guiprefs.cpt_file = [];
    end
    
else % Initialize graphics
    guiprefs.cpt_path = pwd;
    guiprefs.cpt_file = [];
    
    cptplanview.path = pwd;
    cptplanview.file = [];
    setpref('VMT','cptplanview',cptplanview)
end

if ispref('VMT','cptmcs')
    cptmcs = getpref('VMT','cptmcs');
    if exist(cptmcs.path,'dir')
        guiprefs.cpt_path = cptmcs.path;
    else
        guiprefs.cpt_path = pwd;
    end
    
    if exist(fullfile(cptmcs.path,cptmcs.file),'file')
        guiprefs.cpt_file = cptmcs.file;
    else
        guiprefs.cpt_file = [];
    end
    
else % Initialize graphics
    guiprefs.cpt_path = pwd;
    guiprefs.cpt_file = [];
    
    cptmcs.path = pwd;
    cptmcs.file = [];
    setpref('VMT','cptplanview',cptplanview)
end
if ispref('VMT','shoreline')
    shoreline = getpref('VMT','shoreline');
    if exist(shoreline.path,'dir')
        guiprefs.shoreline_path = shoreline.path;
    else
        guiprefs.shoreline_path = pwd;
    end
    
    if exist(fullfile(shoreline.path,shoreline.file),'file')
        guiprefs.shoreline_file = shoreline.file;
    else
        guiprefs.shoreline_file = [];
    end
end
if ispref('VMT','aerial')
    aerial = getpref('VMT','aerial');
    if exist(aerial.path,'dir')
        guiprefs.aerial_path = aerial.path;
    else
        guiprefs.aerial_path = pwd;
    end
    if iscell(aerial.file)
        if exist(fullfile(aerial.path,aerial.file{1}),'file')
            guiprefs.aerial_file = aerial.file;
        else
            guiprefs.aerial_file = [];
        end
    else
        if exist(fullfile(aerial.path,aerial.file),'file')
            guiprefs.aerial_file = aerial.file;
        else
            guiprefs.aerial_file = [];
        end
    end
end

% Store the prefs
% ---------------
setappdata(hfigure,'guiprefs',guiprefs)

function store_prefs(hfigure,pref)
% Store preferences in the Application data and in the persistent
% preferences data.

% Preferences:
% 'cptplanview'     Path and filenames of current graphic (cpt) files for planview
% 'cptmcs'          Path and filenames of current graphic (cpt) files for MCS

guiprefs = getappdata(hfigure,'guiprefs');

switch pref
    case 'cptplanview'
        cptplanview.path = guiprefs.cpt_path;
        cptplanview.file = guiprefs.cpt_file;
        setpref('VMT','cptplanview',cptplanview)
    case 'cptmcs'
        cptmcs.path = guiprefs.cpt_path;
        cptmcs.file = guiprefs.cpt_file;
        setpref('VMT','cptmcs',cptmcs)
    otherwise
end

% [EOF] store_prefs