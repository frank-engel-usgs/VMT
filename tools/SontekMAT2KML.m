function SontekMAT2KML(varargin)
% Creates KML of ADCP shiptracks for Sontek RSL v3.60 MAT-files 
%
% This program reads in a Sontek RiverSurveyLive ENU MAT-file or files  and
% outputs the GPS position into a KML file which can be displayed in Google
% Earth.
%
%(adapted from ASCII2KML)

% Frank L. Engel, 6/4/2014

% Parse arguments
nVar = numel(varargin);
if nVar == 2
    inpath = varargin{1};
    infile = varargin{2};
elseif nVar == 1
    if strcmpi('-help',varargin{1})
        % Help menu
        HelpTxt = {...
            'Creates KML of ADCP shiptracks for Sontek RSL v3.60 MAT-files';...
            '';...
            'INPUTS';...
            '   inputfilepath: full path to the directory containing RSL';...
            '                  MAT-files';...
            '   inputfiles:     name(s) of the RiverSurveyorLive MAT-file';...
            '';...
            'OUTPUTS';...
            '   KML file with the same name as the inputfile(s)';...
            '';...
            'SUMMARY';...
            '   This program reads in a Sontek RiverSurveyLive ENU MAT-file';...
            '   or files  and outputs the GPS position into a KML file which';...
            '   can be displayed in Google Earth.';...
            '';...
            'EXAMPLES';...
            '   Load a MAT-file of ENU Bottom Track ADCP data produced in';...
            '   RiverSurveryorLive v3.60 to produce a KML file of the';...
            '   shiptrack.';...
            '      SontekMAT2KML <path> <filename.mat>';...
            '';...
            '   To make the program prompt for files, specify NO arguments:';...
            '      SontekMAT2KML';...
            '';...
            '   Display this help.';...
            '      SontekMAT2KML -help';
            '';...
            'Original code concept by Jon Czuba, modified by P.R. Jackson';...
            'for use in VMT (TDRI ASCII support).';...
            'Created by: Frank L. Engel, USGS';...
            'Last modified: 2014/05/30';
            };
        disp(HelpTxt)
        return
    else
        error('Incorrect number of input arguments or invalid switch')
    end
elseif nVar == 0 % Prompt user to load files
    inpath = [];
    infile = [];
else
    error('Incorrect number of input arguments or invalid switch')
end


% Read and Convert the Data
% Determine Files to Process
% Prompt user for directory containing files
if ~isempty(inpath) && ~isempty(infile)
    current_file = fullfile(inpath,infile);
else
    current_file = pwd;
end
[zFileName,zPathName] = uigetfile({'*.mat','RSL-MAT (*.mat)'}, ...
    'Convert RSL MAT-file(s) to KML: Select the RSL MAT Output Files', ...
    current_file, ...
    'MultiSelect','on');
if ~ischar(zFileName) && ~iscell(zFileName) % User hit cancel, get out quick
    log_text = {};
    zPathName = inpath;
    zFileName = infile;
    return
end

% Determine number of files to be processed
if  isa(zFileName,'cell')
    z=size(zFileName,2);
    zFileName=sort(zFileName);       
else
    z=1;
    zFileName={zFileName}
end
%msgbox('Loading Data...Please Be Patient','Conversion Status','help','replace');
% Read in Selected Files
% % Initialize row counter
% j=0;
% st=['A'; 'B'; 'C'; 'D'; 'E'; 'F'];
% Begin master loop
log_text = {...
    'Writing KML Files to directory:';
    zPathName};
wbh = waitbar(0,'Writing KML Files...Please Be Patient');
for zi=1:z
    % Open txt data file
    if  isa(zFileName,'cell')
        fileName=strcat(zPathName,filesep,zFileName(zi));
        fileName=char(fileName);
    else
        fileName=strcat(zPathName,zFileName);
    end
    load(fileName,'-mat')

    %Extract only Lat lon data
    latlon(:,1)=GPS.Latitude(:);
    latlon(:,2)=GPS.Longitude(:);
    
    %Rescreen data to remove missing data (30000 value)
    indx1 = find(abs(latlon(:,1)) > 90);
    indx2 = find(abs(latlon(:,2)) > 180);
    latlon(indx1,1)=NaN;
    latlon(indx2,2)=NaN;
    
    indx3 = find(~isnan(latlon(:,1)) & ~isnan(latlon(:,2)));
    latlon = latlon(indx3,:); 
    
    clear BottomTrack GPS Processing RawGPSData Setup Summary System Transformation_Matrices WaterTrack
    
    % Determine the file name
    [~,namecut,~] = fileparts(fileName);
    namecut = [zPathName namecut];
        
    % Write latitude and longitude into a KML file
    %msgbox('Writing KML Files...','Conversion Status','help','replace');
    pwr_kml(namecut,latlon);
    
    clear latlon idx namecut 
    waitbar(zi/z); %update the waitbar
end
delete(wbh) %remove the waitbar
msgbox('Conversion Complete','Conversion Status','help','replace');

% % Save the paths
% if exist('LastDir.mat') == 2
%     save('LastDir.mat','ascii2kmlpath','-append')
% else
%     save('LastDir.mat','ascii2kmlpath')
% end

% Original function (req. outputs for VMT integration)
% [log_text,zPathName,zFileName] = SontekMAT2KML(varargin)

%%
function pwr_kml(name,latlon)
%makes a kml file for use in google earth
%input:  name of track, one matrix containing latitude and longitude
%usage:  pwr_kml('track5',latlon)

header=['<kml xmlns="http://earth.google.com/kml/2.0"><Placemark><description>"' name '"</description><LineString><tessellate>1</tessellate><coordinates>'];
footer='</coordinates></LineString></Placemark></kml>';

fid = fopen([name 'ShipTrack.kml'], 'wt');
d=flipud(rot90(fliplr(latlon)));
fprintf(fid, '%s \n',header);
fprintf(fid, '%.6f,%.6f,0.0 \n', d);
fprintf(fid, '%s', footer);
fclose(fid);

