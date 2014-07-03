function varargout = VMT_BuildCustomFlatFile(varargin)
% --- THE VELOCITY MAPPING TOOLBOX ---
% VMT_BUILDCUSTOMFLATFILE is a sub-GUI of VMT which allows the user to
% create custom CSV flatfiles of VMT outputs.
%__________________________________________________________________________
% Frank L. Engel, U.S. Geological Survey, Illinois Water Science Center
% (fengel@usgs.gov)
%
% Code contributed by P.R. Jackson, D. Parsons, D. Mueller, and J. Czuba.
%__________________________________________________________________________
% 
% VMT_BUILDCUSTOMFLATFILE creates a interactive dual-listbox with sort
% controls. This basic GUI allows users to select items in populated
% listbox (AvailableItems), and move them to a Selected List of Items
% (SelectedItems). The user can move any or all items freely from box to
% box. Additionally, the user can sort items in the Selected Items listbox.
% 
% This GUI can be customized and tied to software outputs. One potential
% use is to generate custom output files, where the user can specify
% exactly what variables are needed in the output file.
% 
% Written by: Frank L. Engel, USGS ILWSC
% Last Modified: 2014-04-09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VMT_BuildCustomFlatFile_OpeningFcn, ...
                   'gui_OutputFcn',  @VMT_BuildCustomFlatFile_OutputFcn, ...
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


% --- Executes just before VMT_BuildCustomFlatFile is made visible.
function VMT_BuildCustomFlatFile_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VMT_BuildCustomFlatFile (see VARARGIN)

% Choose default command line output for VMT_BuildCustomFlatFile
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize the GUI parameters:
% ------------------------------
guiparams = createGUIparams;

% Store the application data
% --------------------------
setappdata(handles.figure1,'guiparams',guiparams)

% Initialize the GUI:
% -------------------
initGUI(handles)

% UIWAIT makes VMT_BuildCustomFlatFile wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VMT_BuildCustomFlatFile_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in AvailableItems.
function AvailableItems_Callback(hObject, eventdata, handles)
% hObject    handle to AvailableItems (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AvailableItems contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AvailableItems

% --- Executes on selection change in SelectedItems.
function SelectedItems_Callback(hObject, eventdata, handles)
% hObject    handle to SelectedItems (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectedItems contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectedItems


% --- Executes on button press in AddSelected.
function AddSelected_Callback(hObject, eventdata, handles)
% hObject    handle to AddSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% See what's already in each listbox
AvailableItems = get(handles.AvailableItems,'string');
SelectedItems  = get(handles.SelectedItems, 'string');

% See what's selected in the Available Items listbox
idx            = get(handles.AvailableItems,'value');
SelectedStr    = AvailableItems(idx);
NotSelectedStr = AvailableItems(~ismember(AvailableItems,SelectedStr));

% Push SelectedStr into Selected Items and remove from Available Items
set(handles.SelectedItems,  'String', vertcat(SelectedItems,SelectedStr))
set(handles.AvailableItems, 'String', NotSelectedStr)

% Deselect Items in both boxes
set(handles.AvailableItems, 'Value', [])
set(handles.SelectedItems,  'Value', [])

% Set the enable for the export button
set_enable(handles,'itemsareselected')


% --- Executes on button press in AddAll.
function AddAll_Callback(hObject, eventdata, handles)
% hObject    handle to AddAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% See what's already in each listbox
AvailableItems = get(handles.AvailableItems,'string');
SelectedItems  = get(handles.SelectedItems, 'string');

% Push AvailableItems into Selected Items and remove from Available Items
set(handles.SelectedItems,  'String', vertcat(SelectedItems,AvailableItems))
set(handles.AvailableItems, 'String', [])

% Deselect Items in both boxes
set(handles.AvailableItems, 'Value', [])
set(handles.SelectedItems,  'Value', [])

% Set the enable for the export button
set_enable(handles,'itemsareselected')


% --- Executes on button press in RemoveSelected.
function RemoveSelected_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveSelected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% See what's already in each listbox
AvailableItems = get(handles.AvailableItems,'string');
SelectedItems  = get(handles.SelectedItems, 'string');

% See what's selected in the Selected Items listbox
idx            = get(handles.SelectedItems,'value');
SelectedStr    = SelectedItems(idx);
NotSelectedStr = SelectedItems(~ismember(SelectedItems,SelectedStr));

% Push SelectedStr into Available Items and remove from Selected Items
set(handles.AvailableItems,'String', vertcat(AvailableItems,SelectedStr))
set(handles.SelectedItems, 'String', NotSelectedStr)

% Deselect Items in both boxes
set(handles.AvailableItems, 'Value', [])
set(handles.SelectedItems,  'Value', [])

% Set the enable for the export button
if isempty(NotSelectedStr)
    set_enable(handles,'noitemsselected')
end


% --- Executes on button press in RemoveAll.
function RemoveAll_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% See what's already in each listbox
AvailableItems = get(handles.AvailableItems,'string');
SelectedItems  = get(handles.SelectedItems, 'string');

% Push SelectedItems into Available Items and remove from Selected Items
set(handles.AvailableItems,'String', vertcat(AvailableItems,SelectedItems))
set(handles.SelectedItems, 'String', [])

% Deselect Items in both boxes
set(handles.AvailableItems, 'Value', [])
set(handles.SelectedItems,  'Value', [])

% Set the enable for the export button
set_enable(handles,'noitemsselected')


% --- Executes on button press in MoveUp.
function MoveUp_Callback(hObject, eventdata, handles)
% hObject    handle to MoveUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% See what's already in each listbox
AvailableItems = get(handles.AvailableItems,'string');
SelectedItems  = get(handles.SelectedItems, 'string');

% See what's selected in the Selected Items listbox
idx            = get(handles.SelectedItems,'value');
SelectedStr    = SelectedItems(idx);
NotSelectedStr = SelectedItems(~ismember(SelectedItems,SelectedStr));

% Re-sort
if idx > 1 % top item not selected
    top    = SelectedItems(1:idx-1);
    bot    = SelectedItems(idx+1:end);
    sorted = vertcat(top(1:end-1),SelectedStr,top(end),bot);

    % Move the list items
    set(handles.SelectedItems,'String',sorted)
    
    % Follow Selected
    set(handles.SelectedItems,'Value', idx-1)
end
    

% --- Executes on button press in MoveDown.
function MoveDown_Callback(hObject, eventdata, handles)
% hObject    handle to MoveDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% See what's already in each listbox
AvailableItems = get(handles.AvailableItems,'string');
SelectedItems  = get(handles.SelectedItems, 'string');

% See what's selected in the Selected Items listbox
idx            = get(handles.SelectedItems,'value');
SelectedStr    = SelectedItems(idx);
NotSelectedStr = SelectedItems(~ismember(SelectedItems,SelectedStr));

% Re-sort
if idx < length(SelectedItems) % last item not selected
    top    = SelectedItems(1:idx-1);
    bot    = SelectedItems(idx+1:end);
    sorted = vertcat(top,bot(1),SelectedStr,bot(2:end));

    % Move the list items
    set(handles.SelectedItems,'String',sorted)
    
    % Follow Selected
    set(handles.SelectedItems,'Value', idx+1)
end


% --- Executes on button press in SaveCSVFile.
function SaveCSVFile_Callback(hObject, eventdata, handles)
% hObject    handle to SaveCSVFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guiparams      = getappdata(handles.figure1,'guiparams');
guiprefs       = guiparams.prefs;
SelectedItems  = get(handles.SelectedItems, 'string');
% msgbox(vertcat({'The following Item(s) are sellected:'},SelectedItems))

% Check if there is a default output location in prefs, if not, initialize
% one
if ispref('VMT','csvexport')
    csvexport = getpref('VMT','csvexport');
    if exist(csvexport.path,'dir')
        guiprefs.csvexport_path = csvexport.path;
    else
        guiprefs.csvexport_path = pwd;
    end
    if exist(fullfile(csvexport.path,csvexport.file),'file')
        guiprefs.csvexport_file = csvexport.file;
    else
        guiprefs.csvexport_file = '';
    end
else % Initialize csvexport
    guiprefs.csvexport_path = pwd;
    guiprefs.csvexport_file = '';
    
    csvexport.path = pwd;
    csvexport.file = '';
    setpref('VMT','csvexport',csvexport)
end

% If a single cross-section is loaded, then just create the output,
% otherwise, process multiple before creating output.
switch guiparams.gp_vmt.gui_state
    case 'fileloaded'
        % Find selected items within the list of available items
        Lia = ismember(...
            guiparams.available_variables_ascii(:,1),...
            SelectedItems);
        vars = guiparams.available_variables_ascii(Lia,2);
        
        % Build the output data (no header)
        outdata = [];
        maxr1 = size(guiparams.gp_vmt.V.mcsX,1);
        for i = 1:length(vars)
            if any(strfind(vars{i},'Roz')) % Use different logic to access Roz struct
                Roz = regexp(vars{i},'\.','split');
                [r,c] = size(guiparams.gp_vmt.V.Roz.(Roz{end}));
                maxr2 = size(guiparams.gp_vmt.V.Roz.up,1);
                if r == maxr1
                    outdata(:,i) = guiparams.gp_vmt.V.Roz.(Roz{end})(:);
                else
                    outdata(:,i) = reshape(repmat(guiparams.gp_vmt.V.Roz.(Roz{end}),maxr2,1),maxr2*c,1);
                end
            else
                [r,c] = size(guiparams.gp_vmt.V.(vars{i}));
                if r == maxr1
                    outdata(:,i) = guiparams.gp_vmt.V.(vars{i})(:);
                else
                    outdata(:,i) = reshape(repmat(guiparams.gp_vmt.V.(vars{i}),maxr1,1),maxr1*c,1);
                end
            end
        end
        
        % Header
        outheader = SelectedItems';
        
        % Change NaNs to -9999
        outdata(isnan(outdata)) = -9999;
              
        % Prompt user where to save the output file
        [the_file,the_path] = ...
            uiputfile({'*.csv','Comma Separated Values File (*.csv)'}, ...
            'Choose where to save the output CSV file', ...
            fullfile(guiprefs.csvexport_path,guiprefs.csvexport_file));
        
        if ischar(the_file) % User did not hit cancel
            % Write the file
            str1 = repmat('%s, ',1,i); str1 = str1(1:end-2);
            str2 = repmat('%f, ',1,i); str2 = str2(1:end-2);
            headformat = [str1 '\n'];
            dataformat = [str2 '\n'];
            fid = fopen(fullfile(the_path,the_file),'w');
            fprintf(fid,headformat,outheader{:});
            fprintf(fid,dataformat,outdata');
            fclose(fid);
            
            % Update preferences
            csvexport.path = the_path;
            csvexport.file = the_file;
            setpref('VMT','csvexport',csvexport)
        end
        
        
    case 'multiplematfiles'
        % Have to load each mat file, so give user feedback
        hwait = waitbar(0,'Processing multiple input files, please be patient...');
        
        % Find selected items within the list of available items
        Lia = ismember(...
            guiparams.available_variables_multi_mat(:,1),...
            SelectedItems);
        vars = guiparams.available_variables_multi_mat(Lia,2);
                
        % Preallocation
        drng          = [guiparams.gp_vmt.depth_range_min guiparams.gp_vmt.depth_range_max];
        windowSize    = guiparams.gp_vmt.smoothing_window_size;
        QuiverSpacing = guiparams.gp_vmt.vector_spacing_plan_view;
        
        % Load and process each file, and retain selected variables
        % The output should be the same as what the quiver spacing
        % indicates
        zf = length(guiparams.gp_vmt.mat_file);
        for n = 1:zf
            waitbar(n/(zf+1),hwait)
            load(fullfile(guiparams.gp_vmt.mat_path,guiparams.gp_vmt.mat_file{n}))
            
            
            if ~isempty(drng)
                indx = find(V.mcsDepth(:,1) < drng(1) | V.mcsDepth(:,1) > drng(2));
                
                %Set all data outside depth range to nan
                V.mcsX(indx,:) = nan;
                V.mcsY(indx,:) = nan;
                V.mcsEast(indx,:) = nan;
                V.mcsNorth(indx,:) = nan;
                clear indx
            end
            
            %Compute mean positions
            V.mcsX1 = nanmean(V.mcsX,1);
            V.mcsY1 = nanmean(V.mcsY,1);
            
            %Compute the depth (or layer) averaged velocity (new method)
            V.mcsEast1  = VMT_LayerAveMean(V.mcsDepth,V.mcsEast);
            V.mcsNorth1 = VMT_LayerAveMean(V.mcsDepth,V.mcsNorth);
            
            %Smooth using a running mean defined by WindowSize (averages
            %'2*windowsize+1' ensembles together (centered on node (boxcar filter))
            if windowSize == 0
                V.mcsX1sm     = V.mcsX1;
                V.mcsY1sm     = V.mcsY1;
                V.mcsEast1sm  = V.mcsEast1;
                V.mcsNorth1sm = V.mcsNorth1;
            else
                V.mcsEast1sm  = nanmoving_average(V.mcsEast1,windowSize);  %added 1-7-10, prj
                V.mcsNorth1sm = nanmoving_average(V.mcsNorth1,windowSize);
                V.mcsX1sm     = V.mcsX1;
                V.mcsY1sm     = V.mcsY1;
            end
            
            % Screen for locations that don't have valid ensembles
            for zi = 1 : z
                Mag(:,:,zi) = A(zi).Comp.mcsMag(:,:);
                %Mag(:,:,zi) = A(zi).Clean.vMag(:,:);
            end
            numavg = nansum(~isnan(Mag),3);
            numavg(numavg==0) = NaN;
            enscnt = nanmean(numavg,1);
            [I,J] = ind2sub(size(enscnt),find(enscnt>=1));  %Changed to 1 from 2 (PRJ, 12-12-08)
            et = windowSize+J(1):QuiverSpacing:J(end);
            
            if n == 1
                %table(1:493,1:7)=NaN;
                lenp = 0;
            end
            
            % Dump output to aggregating table
            len = length(V.mcsX1sm(1,et));
            table(lenp+1:len+lenp,1)=V.mcsX1sm(1,et);
            table(lenp+1:len+lenp,2)=V.mcsY1sm(1,et);
            table(lenp+1:len+lenp,3)=V.mcsDist(1,et);
            table(lenp+1:len+lenp,4)=V.mcsBed(1,et);
            table(lenp+1:len+lenp,5)=V.mcsBedElev(1,et);
            table(lenp+1:len+lenp,6)=nanmean(V.mcsEast1sm(:,et),1);
            table(lenp+1:len+lenp,7)=nanmean(V.mcsNorth1sm(:,et),1);
            lenp = length(V.mcsX1sm(1,et))+lenp;
            
            clear A V z Mag numavg et enscnt I J   
        end
        
        % Compute velocity mag and dir
        table(:,8)=sqrt(table(:,6).^2+table(:,7).^2);
        table(:,9)=ari2geodeg(atan2(table(:,7),table(:,6))*180/pi);
                
        % Header
        outheader = SelectedItems';
        i = length(outheader);
        
        % Retain only selected items in table, and change NaNs to -9999
        outdata = table(:,Lia);
        outdata(isnan(outdata)) = -9999;
        
        % Prompt user where to save the output file
        [the_file,the_path] = ...
            uiputfile({'*.csv','Comma Separated Values File (*.csv)'}, ...
            'Choose where to save the output CSV file', ...
            fullfile(guiprefs.csvexport_path,guiprefs.csvexport_file));
        
        if ischar(the_file) % User did not hit cancel
            % Write the file
            str1 = repmat('%s, ',1,i); str1 = str1(1:end-2);
            str2 = repmat('%f, ',1,i); str2 = str2(1:end-2);
            headformat = [str1 '\n'];
            dataformat = [str2 '\n'];
            fid = fopen(fullfile(the_path,the_file),'w');
            fprintf(fid,headformat,outheader{:});
            fprintf(fid,dataformat,outdata');
            fclose(fid);
            
            % Update preferences
            csvexport.path = the_path;
            csvexport.file = the_file;
            setpref('VMT','csvexport',csvexport)
        end
        
    otherwise
end

% Take care of waitbar if used
if exist('hwait','var') && ishandle(hwait)
    waitbar(1,hwait)
    delete(hwait)
end


function [guiparams] = createGUIparams

% Get the VMT current state for use by the sub-GUI
% ------------------------------------------------
hVMTgui                 = getappdata(0,'hVMTgui');
guiparams_vmt           = getappdata(hVMTgui,'guiparams');
guiprefs_vmt            = getappdata(hVMTgui,'guiprefs');
guiparams.gp_vmt        = guiparams_vmt;
guiparams.prefs         = guiprefs_vmt;

% Lists of avalialible variables
guiparams.available_variables  = {};
guiparams.selected_variables   = {};
guiparams.available_variables_ascii = {...
... Label                       Fieldname ...    
    'X'                         'mcsX';...
    'Y'                         'mcsY';...
    'Z'                         'mcsDepth';...
    'Distance'                  'mcsDist';...
    'Bed depth'                 'mcsBed';...
    'Bed elevation'             'mcsBedElev';...
    'East velocity'             'mcsEast';...
    'North velocity'            'mcsNorth';...
    'Up velocity'               'mcsVert';...
    'Velocity magnitude'        'mcsMag';...
    'Velocity direction'        'mcsDir';...
    'U velocity'                'u';...
    'V velocity'                'v';...
    'W velocity'                'w';...
    'Backscatter (smooth)'      'mcsBack';...
    'U (zsd) velocity'          'vp';...
    'V (zsd) velocity'          'vs';...
    'U (roz) velocity'          'Roz.up';...
    'V (roz) velocity'          'Roz.us';...
    'U (smoothed) vel'          'uSmooth';...
    'V (smoothed) vel'          'vSmooth';...
    'W (smoothed) vel'          'wSmooth';...
    'U (zsd,smoothed) vel'      'vpSmooth';...
    'V (zsd,smoothed) vel'      'vsSmooth';...
    'U (roz,smoothed) vel'      'Roz.upSmooth';...
    'V (roz,smoothed) vel'      'Roz.usSmooth';...
    'Backscatter (smooth)'      'mcsBackSmooth';...
    'Vel Direction (smooth)'    'mcsDirSmooth';...
    };
guiparams.available_variables_single_mat = {...
... Label                       Fieldname ...    
    'X'                         'mcsX';...
    'Y'                         'mcsY';...
    'Z'                         'mcsDepth';...
    'Distance'                  'mcsDist';...
    'Bed depth'                 'mcsBed';...
    'Bed elevation'             'mcsBedElev';...
    'East velocity'             'mcsEast';...
    'North velocity'            'mcsNorth';...
    'Up velocity'               'mcsVert';...
    'Velocity magnitude'        'mcsMag';...
    'Velocity direction'        'mcsDir';...
    'U velocity'                'u';...
    'V velocity'                'v';...
    'W velocity'                'w';...
    'Backscatter (smooth)'      'mcsBack';...
    'U (zsd) velocity'          'vp';...
    'V (zsd) velocity'          'vs';...
    'U (roz) velocity'          'Roz.up';...
    'V (roz) velocity'          'Roz.us';...
    'U (smoothed) vel'          'uSmooth';...
    'V (smoothed) vel'          'vSmooth';...
    'W (smoothed) vel'          'wSmooth';...
    'U (zsd,smoothed) vel'      'vpSmooth';...
    'V (zsd,smoothed) vel'      'vsSmooth';...
    'U (roz,smoothed) vel'      'Roz.upSmooth';...
    'V (roz,smoothed) vel'      'Roz.usSmooth';...
    'Backscatter (smooth)'      'mcsBackSmooth';...
    'Vel Direction (smooth)'    'mcsDirSmooth';...
    };
guiparams.available_variables_multi_mat = {...
... Label                       Fieldname ...    
    'X'                         'mcsX';...
    'Y'                         'mcsY';...
    ...'Z'                         'mcsDepth';...
    'Distance'                  'mcsDist';...
    'Bed depth'                 'mcsBed';...
    'Bed elevation'             'mcsBedElev';...
    'Layer-avg east vel'        'davE';...
    'Layer-avg north vel'       'davN';...
    'Velocity magnitude'        'Vmag';...
    'Velocity direction'        'Vdir';...
    };
guiparams.available_variables_nodata  = {};


% % Check if VMT has a processed file in memory. If not, display message
% % asking user to process some data
% if isempty(guiparams.gp_vmt.mat_file) && ~isempty(guiparams.gp_vmt.data_files) && ~isempty(guiparams.gp_vmt.V) % ASCII Loaded
%     msgbox('ASCII Loaded')
%     guiparams.state = 'ascii_loaded';
%     %set_enable(handles,'ascii')
% elseif ~isempty(guiparams.gp_vmt.mat_file)
%     if ischar(guiparams.gp_vmt.mat_file) % Single MAT file loaded
%         msgbox('Single MAT loaded')
%         guiparams.state = 'single_mat_loaded';
%         %set_enable(handles,'single-mat')
%     elseif iscell(guiparams.gp_vmt.mat_file) % Multiple MAT files loaded
%         msgbox('Multiple MAT files loaded')
%         guiparams.state = 'multiple_mat_loaded';
%         %set_enable(handles,'multi-mat')
%     end
% elseif isempty(guiparams.gp_vmt.V) % Nothing loaded, stop
%     msgbox('Nothing loaded, aborting.')
%     guiparams.state = 'nothing_loaded';
%     %set_enable(handles,'nodata')
% end


% Grab the currently loaded variables and put them into the list

% --------------------------------------------------------------------
function initGUI(handles)
% Initialize the UI controls in the GUI.

guiparams = getappdata(handles.figure1,'guiparams');

% Update the GUI:
% ---------------
switch guiparams.gp_vmt.gui_state
    case 'fileloaded'
        set_enable(handles,'ascii')
    case 'multiplematfiles'
        set_enable(handles,'multi-mat')
    case 'init'
        set_enable(handles,'nodata')
    otherwise
        set_enable(handles,'nodata')
end
% [EOF] initGUI


% --------------------------------------------------------------------
function set_enable(handles,enable_state)

% Get the application data
guiparams = getappdata(handles.figure1,'guiparams');

% Preload variables to list in Available Items box
switch enable_state
    case 'ascii'
        % See what's already in each listbox
        AvailableItems = get(handles.AvailableItems,'string');
        SelectedItems  = get(handles.SelectedItems, 'string');
        
        % Update items based on state
        set(handles.AvailableItems, 'string', guiparams.available_variables_ascii(:,1))
        set(handles.SelectedItems,  'string', {})
    case 'single-mat'
        % See what's already in each listbox
        AvailableItems = get(handles.AvailableItems,'string');
        SelectedItems  = get(handles.SelectedItems, 'string');
        
        % Update items based on state
        set(handles.AvailableItems, 'string', guiparams.available_variables_single_mat(:,1))
        set(handles.SelectedItems,  'string', {})
    case 'multi-mat'
        % See what's already in each listbox
        AvailableItems = get(handles.AvailableItems,'string');
        SelectedItems  = get(handles.SelectedItems, 'string');
        
        % Update items based on state
        set(handles.AvailableItems, 'string', guiparams.available_variables_multi_mat(:,1))
        set(handles.SelectedItems,  'string', {})
    case 'nodata'
        % See what's already in each listbox
        AvailableItems = get(handles.AvailableItems,'string');
        SelectedItems  = get(handles.SelectedItems, 'string');
        
        % Update items based on state
        set(handles.AvailableItems, 'string', guiparams.available_variables_nodata)
        set(handles.SelectedItems,  'string', {})
    case 'itemsareselected'
        set(handles.SaveCSVFile,'enable','on')
    case 'noitemsselected'
        set(handles.SaveCSVFile,'enable','off')
end

% Save the application data
setappdata(handles.figure1,'guiparams',guiparams);
