function varargout = VMT_BatchMode(varargin)
% VMT_BATCHMODE MATLAB code for VMT_BatchMode.fig
%      VMT_BATCHMODE, by itself, creates a new VMT_BATCHMODE or raises the existing
%      singleton*.
%
%      H = VMT_BATCHMODE returns the handle to a new VMT_BATCHMODE or the handle to
%      the existing singleton*.
%
%      VMT_BATCHMODE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VMT_BATCHMODE.M with the given input arguments.
%
%      VMT_BATCHMODE('Property','Value',...) creates a new VMT_BATCHMODE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VMT_BatchMode_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VMT_BatchMode_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VMT_BatchMode

% Last Modified by GUIDE v2.5 29-Apr-2014 13:07:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VMT_BatchMode_OpeningFcn, ...
                   'gui_OutputFcn',  @VMT_BatchMode_OutputFcn, ...
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


% --- Executes just before VMT_BatchMode is made visible.
function VMT_BatchMode_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VMT_BatchMode (see VARARGIN)

% Choose default command line output for VMT_BatchMode
handles.output = hObject;

% Ensure path to utils & docs is available
% ----------------------------------------
if ~isdeployed
    utilspath = [pwd filesep 'utils'];
    docspath  = [pwd filesep 'doc'];
    toolspath = [pwd filesep 'tools'];
    addpath(utilspath,docspath,toolspath)
end

% Update handles structure
guidata(hObject, handles);

% Create GUI Parameters
guiparams.horizontal_smoothing_window = 1;
guiparams.vertical_smoothing_window = 1;
guiparams.water_surface_elevation = 0;
guiparams.set_cross_section_endpoints = false;
guiparams.unit_discharge_correction   = false;
guiparams.mcs_id = cell(500,1);
guiparams.full_path_to_ascii_file = [];
guiparams.horizontal_grid_node_spacing = 1;
guiparams.vertical_grid_node_spacing = 0.4;
guiparams.data_folder = pwd;
guiparams.data_files = [];
guiparams.table_data = [];
guiparams.shiptracks = [];

% Store the appication data
setappdata(handles.figure1,'guiparams',guiparams)

% UIWAIT makes VMT_BatchMode wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VMT_BatchMode_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in BatchProcessVelocity.
function BatchProcessVelocity_Callback(hObject, eventdata, handles)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
mcs_id = guiparams.mcs_id;
horizontal_grid_node_spacing = guiparams.horizontal_grid_node_spacing;
data_folder = guiparams.data_folder;
data_files = guiparams.data_files;
table_data = guiparams.table_data;
Map = [];

mcs_id = cell2mat(table_data(:,1));
zt      = unique(mcs_id);

for zti = 1:length(zt)
    trans2process = data_files(mcs_id == zt(zti));
    
    % Read the file(s)
    % ----------------
    [~,~,savefile,A,z] = ...
        VMT_ReadFiles(data_folder,trans2process);
    guiparams.savefile = savefile;
        
    % Process each Transect
    % Preprocess the data:
    % --------------------
    A = VMT_PreProcess(z,A);
    
       
    % Process the transects:
    % ----------------------
    A(1).hgns = guiparams.horizontal_grid_node_spacing;
    A(1).vgns = guiparams.vertical_grid_node_spacing;
    A(1).wse  = guiparams.water_surface_elevation;  %Set the WSE to entered value
    [A,V,~] = VMT_ProcessTransects(z,A,...
        guiparams.set_cross_section_endpoints,guiparams.unit_discharge_correction);
    
    % Compute the smoothed variables
    % ------------------------------
    % This is required so that the V struc is complete at any point during
    % runtime.
    V = VMT_SmoothVar(V, ...
        ...guiparams.contour, ...
        guiparams.horizontal_smoothing_window, ...
        guiparams.vertical_smoothing_window);
    
    for zi = 1:z
        shiptracks{zti,zi} = [A(zi).Comp.xUTMraw A(zi).Comp.yUTMraw];
    end
    
    % Save each file
    %[pathstr,filename,extension] = fileparts([guiparams.data_folder guiparams.savefile]);
    %savefile = fullfile(pathstr,[filename extension]);
    save(savefile,'A','V','z','Map')
    clear A V z 
end

% Plot the shiptracks as groups
colors = repmat('bgryck',1,500);
for zti = 1:length(zt)
    st = cell2mat(shiptracks(zti,:)');
    stX = st(:,1);
    stY = st(:,2);
    
    figure(10)
    plot(stX,stY,[colors(zti) '.']); hold on
end

xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
axis square
box on
grid on
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM

guiparams.shiptracks = shiptracks;
setappdata(handles.figure1,'guiparams',guiparams)
    


% --- Executes on button press in SelectFiles.
function SelectFiles_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
% guiprefs = getappdata(handles.figure1,'guiprefs');

% Ask the user to select files:
% -----------------------------
current_file = pwd; %fullfile(guiprefs.ascii_path,guiprefs.ascii_file{1});
[filename,pathname] = uigetfile({'*_ASC.TXT','ASCII (*_ASC.TXT)'}, ...
    'Select the ASCII Output Files', ...
    current_file, ...
    'MultiSelect','on');

if ischar(pathname) % The user did not hit "Cancel"
    guiparams.data_folder = pathname;
    if ischar(filename)
        filename = {filename};
    end
    guiparams.data_files = filename;
%     guiparams.mat_file = '';
    
    setappdata(handles.figure1,'guiparams',guiparams)
    
% Populate the table
% Ensure UItable is empty before filling it with current selection
set(handles.TransectGroupings,'data',single.empty(500,2,0));

% Construct table
table_data = [num2cell(ones(numel(filename),1)) filename'];
guiparams.mcs_id = num2cell(ones(numel(filename),1));

% Push it to the UItable
set(handles.TransectGroupings,'data',table_data);

% Store parameters
guiparams.table_data = table_data;
setappdata(handles.figure1,'guiparams',guiparams)


%     % Update the preferences:
%     % -----------------------
%     guiprefs = getappdata(handles.figure1,'guiprefs');
%     guiprefs.ascii_path = pathname;
%     guiprefs.ascii_file = filename;
%     setappdata(handles.figure1,'guiprefs',guiprefs)
%     store_prefs(handles.figure1,'ascii')
    
end


% --- Executes on button press in ClearList.
function ClearList_Callback(hObject, eventdata, handles)
% hObject    handle to ClearList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ensure UItable is empty before filling it with current selection
set(handles.TransectGroupings,'data',single.empty(500,2,0));



function HorizontalGridNodeSpacing_Callback(hObject, eventdata, handles)
%  Get Application Data
guiparams = getappdata(handles.figure1,'guiparams');

horizontal_grid_node_spacing = str2double(get(handles.HorizontalGridNodeSpacing,'String'));

guiparams.horizontal_grid_node_spacing = horizontal_grid_node_spacing;
setappdata(handles.figure1,'guiparams',guiparams)


function ExportMultibeamBathymetry_Callback(hObject, eventdata, handles)

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
mcs_id = guiparams.mcs_id;
horizontal_grid_node_spacing = guiparams.horizontal_grid_node_spacing;
water_surface_elevation = guiparams.water_surface_elevation;
data_folder = guiparams.data_folder;
data_files = guiparams.data_files;
table_data = guiparams.table_data;
Map = [];

mcs_id = cell2mat(table_data(:,1));
zt      = unique(mcs_id);

for zti = 1:length(zt)
    trans2process = data_files(mcs_id == zt(zti));
    
    % Read the file(s)
    % ----------------
    [~,~,savefile,A,z] = ...
        VMT_ReadFiles(data_folder,trans2process);
    guiparams.savefile = savefile;
        
    % Process each Transect
    % Preprocess the data:
    % --------------------
    A = VMT_PreProcess(z,A);
    
       
    % Process the transects:
    % ----------------------
    A(1).hgns = guiparams.horizontal_grid_node_spacing;
    A(1).wse  = guiparams.water_surface_elevation;  %Set the WSE to entered value
%     [A,V,~] = VMT_ProcessTransects(z,A,...
%         guiparams.set_cross_section_endpoints,guiparams.unit_discharge_correction);

    A = VMT_MBBathy(z,A,savefile,20,[],water_surface_elevation,1);
           
end





function VerticalGridNodeSpacing_Callback(hObject, eventdata, handles)
%  Get Application Data
guiparams = getappdata(handles.figure1,'guiparams');

vertical_grid_node_spacing = str2double(get(handles.VerticalGridNodeSpacing,'String'));

guiparams.vertical_grid_node_spacing = vertical_grid_node_spacing;
setappdata(handles.figure1,'guiparams',guiparams)


function WaterSurfaceElevation_Callback(hObject, eventdata, handles)
%  Get Application Data
guiparams = getappdata(handles.figure1,'guiparams');

water_surface_elevation = str2double(get(handles.WaterSurfaceElevation,'String'));

guiparams.water_surface_elevation = water_surface_elevation;
setappdata(handles.figure1,'guiparams',guiparams)

% --------------------------------------------------------------------
function loadDataCallback(hObject, eventdata, handles)
% Read Files into Data Structure using tfile.

% Get the Application data:
% -------------------------
guiparams = getappdata(handles.figure1,'guiparams');
guiprefs = getappdata(handles.figure1,'guiprefs');

% Ask the user to select files:
% -----------------------------
current_file = fullfile(guiprefs.ascii_path,guiprefs.ascii_file{1});
[filename,pathname] = uigetfile({'*_ASC.TXT','ASCII (*_ASC.TXT)'}, ...
    'Select the ASCII Output Files', ...
    current_file, ...
    'MultiSelect','on');

if ischar(pathname) % The user did not hit "Cancel"
    guiparams.data_folder = pathname;
    if ischar(filename)
        filename = {filename};
    end
    guiparams.data_files = filename;
%     guiparams.mat_file = '';
    
    setappdata(handles.figure1,'guiparams',guiparams)
    
   
    
%     % Update the preferences:
%     % -----------------------
%     guiprefs = getappdata(handles.figure1,'guiprefs');
%     guiprefs.ascii_path = pathname;
%     guiprefs.ascii_file = filename;
%     setappdata(handles.figure1,'guiprefs',guiprefs)
%     store_prefs(handles.figure1,'ascii')
    
    
%     % Read the file(s)
%     % ----------------
%     [~,~,savefile,A,z] = ...
%         VMT_ReadFiles(guiparams.data_folder,guiparams.data_files);
%     guiparams.savefile = savefile;
%     guiparams.A        = A;
%     guiparams.z        = z;
%     setappdata(handles.figure1,'guiparams',guiparams)

end
% [EOF] loadDataCallback


% --- Executes when entered data in editable cell(s) in TransectGroupings.
function TransectGroupings_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to TransectGroupings (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% Get the application data
guiparams = getappdata(handles.figure1,'guiparams');

guiparams.table_data = get(handles.TransectGroupings,'data');

setappdata(handles.figure1,'guiparams',guiparams);


% --- Executes on button press in SaveBatchJob.
function SaveBatchJob_Callback(hObject, eventdata, handles)
% hObject    handle to SaveBatchJob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get application data
guiparams = getappdata(handles.figure1,'guiparams');

% Get whatever is in the UItable
data = get(handles.TransectGroupings,'data');
numXS = length(data);

% Write to an Excel File
[filename,pathname] = uiputfile('*.xlsx','Save Batch File As',guiparams.data_folder);
data = [...
    {guiparams.data_folder, guiparams.horizontal_grid_node_spacing, guiparams.vertical_grid_node_spacing, guiparams.water_surface_elevation};...
    data, cell(numXS,2)];
xlswrite(fullfile(pathname,filename),data);



% --- Executes on button press in LoadBatchJob.
function LoadBatchJob_Callback(hObject, eventdata, handles)
% hObject    handle to LoadBatchJob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get application data
guiparams = getappdata(handles.figure1,'guiparams');

[filename,pathname] = uigetfile('*.xlsx','Load Batch File',guiparams.data_folder);
[ndata, text, alldata] = xlsread(fullfile(pathname,filename));
data = alldata(2:end,1:2);
set(handles.TransectGroupings,'data',data);

guiparams.data_folder                  = alldata{1};
guiparams.data_files                   = data(:,2);
guiparams.horizontal_grid_node_spacing = ndata(1,2);
guiparams.vertical_grid_node_spacing   = ndata(1,3);
guiparams.water_surface_elevation      = ndata(1,4);
guiparams.table_data                   = get(handles.TransectGroupings,'data');

set(handles.HorizontalGridNodeSpacing, 'String', guiparams.horizontal_grid_node_spacing)
set(handles.VerticalGridNodeSpacing,   'String', guiparams.vertical_grid_node_spacing)
set(handles.WaterSurfaceElevation,     'String', guiparams.water_surface_elevation)

setappdata(handles.figure1,'guiparams',guiparams)

function mypostcallback_zoom(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when zooming) 

function mypostcallback_pan(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when panning) 
