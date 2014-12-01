function varargout = ASCII2KML_GUI(varargin)
% ASCII2KML_GUI M-file for ASCII2KML_GUI.fig
%      ASCII2KML_GUI, by itself, creates a new ASCII2KML_GUI or raises the existing
%      singleton*.
%
%      H = ASCII2KML_GUI returns the handle to a new ASCII2KML_GUI or the handle to
%      the existing singleton*.
%
%      ASCII2KML_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASCII2KML_GUI.M with the given input arguments.
%
%      ASCII2KML_GUI('Property','Value',...) creates a new ASCII2KML_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ASCII2KML_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ASCII2KML_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ASCII2KML_GUI

% Last Modified by GUIDE v2.5 13-Mar-2011 21:26:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ASCII2KML_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ASCII2KML_GUI_OutputFcn, ...
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


% --- Executes just before ASCII2KML_GUI is made visible.
function ASCII2KML_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ASCII2KML_GUI (see VARARGIN)

% Choose default command line output for ASCII2KML_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Ensure path to utils & docs is available
% ----------------------------------------
utilspath = [pwd filesep 'utils'];
docspath  = [pwd filesep 'doc'];
toolspath = [pwd filesep 'tools'];
addpath(utilspath,docspath,toolspath)

% UIWAIT makes ASCII2KML_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ASCII2KML_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in runbutton.
function runbutton_Callback(hObject, eventdata, handles)
% hObject    handle to runbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ASCII2KML
