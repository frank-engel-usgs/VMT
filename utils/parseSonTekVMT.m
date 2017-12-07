function A = parseSonTekVMT(fullName)
%PARSESONTEK reads MAT file output from RSL for use in VMT
% Currently only supports RSL v3.60 or earlier
% NO WARRANTY OR GUARANTEE OF FUNCTIONALITY
%
% Dave Mueller, USGS
% Frank L. Engel, USGS
%
% Last modified: 04/23/2014
% 
% SEE ALSO:

% filesep     = '\';
% fullName    = [pathname filesep filename{1}];

load (fullName)
[pathstr,name,ext] = fileparts(fullName);
% Display waitbar
waitmessage=['Reading ' name ext];
hwait=waitbar(0,waitmessage);
if strcmpi(Setup.velocityReference, 'System')
    errordlg({'VMT does not support Beam Coordinates.';
        '';
        'Re-export mat-file in RiverSurveyorLive';
        'using BT, GGA, or VTG velocity reference'},'Velocity Reference Error');
    error('parseSonTekVMT: VMT does not support Beam Coordinates.')
end

% For RSL versions <1.5, the variable units were included in the field
% names. Check to see if units are in field names, if so ensure SI units
% and rename.
is_in_eng_units     = isfield(Summary,'Depth_ft');
is_in_si_units      = isfield(Summary,'Depth_m');
if is_in_eng_units || is_in_si_units
[...
    BottomTrack,...
    GPS,...
    Processing,...
    RawGPSData,...
    Setup,...
    Summary,...
    System,...
    Transformation_Matrices,...
    WaterTrack,...
    ] = fixOldMatFiles(...
    BottomTrack,...
    GPS,...
    Processing,...
    RawGPSData,...
    Setup,...
    Summary,...
    System,...
    Transformation_Matrices,...
    WaterTrack);
end
    

% Create the output structures
[Sup,Wat,Nav,Sensor,Q] = initStructures(...
    BottomTrack,...
    GPS,...
    Processing,...
    RawGPSData,...
    Setup,...
    Summary,...
    System,...
    Transformation_Matrices,...
    WaterTrack);


%%%%%%%%%%%%%%
% PARSE DATA %
%%%%%%%%%%%%%%

% Setup units conversion
if strcmpi(Summary.Units.Depth,'ft')
    cf                  = 1./3.281; % conversion factor
    System.Temperature  = (System.Temperature-32)*5/9;
else
    cf                  = 1; % conversion factor (for m)
    cf2                 = 1;   % conversion factor (for m)
end

% Only use in transect data, omit the edge measurements
idx = find(System.Step==3);

% Suplemental Data
Sup.nBins       = size(WaterTrack.Velocity,1);
Sup.binSize_cm  = repmat(System.Cell_Size(idx)'.*100.*cf,Sup.nBins,1);
Sup.bins        = repmat(Sup.nBins,size(idx));
Sup.blank_cm    = Setup.screeningDistance.*100.*cf;
Sup.draft_cm    = Setup.sensorDepth.*100.*cf;
Sup.noe         = length(idx);
switch Setup.velocityReference
    case 0
        Sup.vRef = 'System';
    case 1
        Sup.vRef = 'BT';
    case 2
        Sup.vRef = 'GGA';
    case 3
        Sup.vRef = 'VTG';
end
serialTime = @(inTime) 719529+10957+inTime./(60*60*24);
Sup.units  = repmat('cm',Sup.noe,1);
Sup.ensNo  = idx;
Sup.year   = str2num(datestr(serialTime(System.Time(idx)),'YYYY'));
Sup.month  = str2num(datestr(serialTime(System.Time(idx)),'mm'));
Sup.day    = str2num(datestr(serialTime(System.Time(idx)),'dd'));
Sup.hour   = str2num(datestr(serialTime(System.Time(idx)),'HH'));
Sup.minute = str2num(datestr(serialTime(System.Time(idx)),'MM'));
Sup.second = str2num(datestr(serialTime(System.Time(idx)),'SS'));
Sup.sec100 = str2num(datestr(serialTime(System.Time(idx)),'SS.FFF'))-Sup.second;
Sup.timeElapsed_sec = [0; cumsum(diff(System.Time(idx)))];
waitbar(0.2)

% Water track data
%cellSizeAll = repmat(Sup.binSize_cm',Sup.nBins,1);
top_of_cells        = System.Cell_Start(idx).*cf.*100; % in cm
Wat.binDepth        =...
    ((repmat((1:Sup.nBins)',1,Sup.noe)-0.5).*...
    Sup.binSize_cm+repmat(top_of_cells',Sup.nBins,1))/100; % in meters
Wat.backscatter     =...
    permute(System.SNR(:,:,idx),[1 3 2]);
isPulseCoh = any(~isnan(squeeze(WaterTrack.Correlation(:,1,idx))),1);
Wat.beamMode(isPulseCoh)   = {'PC'};
Wat.beamMode(~isPulseCoh)  = {'IC'};
Wat.beamFreq        =...
    WaterTrack.WT_Frequency(idx,:)';
Wat.vEast           =...
    squeeze(WaterTrack.Velocity(:,1,idx)).*cf.*100; % in cm/s
Wat.vNorth          =...
    squeeze(WaterTrack.Velocity(:,2,idx)).*cf.*100; % in cm/s
Wat.vVert           =...
    squeeze(WaterTrack.Velocity(:,3,idx)).*cf.*100; % in cm/s
Wat.vError          =... 
    squeeze(WaterTrack.Vel_StdDev(:,4,idx)).*cf.*100; % in cm/s
Wat.vMag            =...
    sqrt(Wat.vEast.^2 + Wat.vNorth.^2 + Wat.vVert.^2).*100; % in cm/s
Wat.vDir            =...
    ari2geodeg(atan2(Wat.vNorth,Wat.vEast).*180/pi);
waitbar(0.4)

% Navigation data
Nav.bvEast          = Summary.Boat_Vel(idx,1).*cf.*100; % in cm/s
Nav.bvNorth         = Summary.Boat_Vel(idx,2).*cf.*100; % in cm/s
Nav.bvVert          = Summary.Boat_Vel(idx,3).*cf.*100; % in cm/s
Nav.depth(:,1:4)    = BottomTrack.BT_Beam_Depth(idx,:).*cf; % in m
Nav.depth(:,5)      = BottomTrack.VB_Depth(idx,:).*cf; % in m
Nav.dsDepth         = BottomTrack.VB_Depth(idx).*cf; % in m
Nav.altitude        = GPS.Altitude(idx).*cf; % in m
Nav.altitudeChng    = [0; diff(Nav.altitude)];
Nav.lat_deg         = GPS.Latitude(idx);
Nav.long_deg        = GPS.Longitude(idx);
Nav.nSats           = GPS.Satellites(idx);
Nav.hdop            = GPS.HDOP(idx);
Nav.totDistEast     = Summary.Track(idx,1).*cf; % in m
Nav.totDistNorth    = Summary.Track(idx,2).*cf; % in m
Nav.length          = ...
    hypot(...
    Nav.totDistNorth-Nav.totDistNorth(1),...
    Nav.totDistEast-Nav.totDistEast(1));
waitbar(0.6)

% Sensor data
% Check if using RSL v3.70 by seeing if there is a separate Compass
% structure
if exist('SystemHW','var')
    if SystemHW.Frequency.F2 == 0;  %S5
        Sensor.sensor_type = 'S5';
    else 
        Sensor.sensor_type = 'M9';
    end
end
if exist('Compas','var') % [sic], Sontek spelled it wrong, this is a v 3.60 mat-file
    Sensor.pitch_deg    = Compas.Pitch(idx);
    Sensor.roll_deg     = Compas.Roll(idx);
    Sensor.heading_deg  = System.Heading(idx);
    Sensor.temp_degC    = System.Temperature(idx);
elseif exist('Compass','var') % version 3.8
    Sensor.pitch_deg    = Compass.Pitch(idx);
    Sensor.roll_deg     = Compass.Roll(idx);
    Sensor.heading_deg  = System.Heading(idx);
    Sensor.temp_degC    = System.Temperature(idx);
else % version +3.60 to 3.80
    Sensor.pitch_deg    = System.Pitch(idx);
    Sensor.roll_deg     = System.Roll(idx);
    Sensor.heading_deg  = System.Heading(idx);
    Sensor.temp_degC    = System.Temperature(idx);
end
waitbar(0.8)

% Discarge data
Q.startDist     = repmat(Setup.Edges_0__DistanceToBank.*cf,Sup.noe,1);
Q.endDist       = repmat(Setup.Edges_1__DistanceToBank.*cf,Sup.noe,1);
Q.bot           = Summary.Bottom_Q(idx).*cf.^3;
Q.top           = Summary.Top_Q(idx).*cf.^3;
switch Setup.startEdge
    case 0 % left bank
        Q.start = Summary.Left_Q.*cf.^3;
        Q.end   = Summary.Right_Q.*cf.^3;
    case 1 % right bank
        Q.start = Summary.Right_Q.*cf.^3;
        Q.end   = Summary.Left_Q.*cf.^3;
end
Q.meas      = Summary.Middle_Q.*cf.^3;

% Deal Result to A structure
A.Sup       = Sup;
A.Wat       = Wat;
A.Nav       = Nav;
A.Sensor    = Sensor;
A.Q         = Q;
waitbar(1)
delete(hwait)

%%%%%%%%%%%%%%%%
% SUBFUNCTIONS %
%%%%%%%%%%%%%%%%
function varargout = fixOldMatFiles(varargin)
disp('fixOldMatFiles is not implemented yet, use RSL v1.5 or greater.')

% oldField = 'quux';
% newField = 'corge';
% [a.(newField)] = a.(oldField);
% a = rmfield(a,oldField);
% disp(a)

function [Sup,Wat,Nav,Sensor,Q] = initStructures(varargin)
BottomTrack             = varargin{1};
GPS                     = varargin{2};
Processing              = varargin{3};
RawGPSData              = varargin{4};
Setup                   = varargin{5};
Summary                 = varargin{6};
System                  = varargin{7};
Transformation_Matrices = varargin{8};
WaterTrack              = varargin{9};

idx  = find(System.Step==3);
noe  = length(idx);
bins = size(WaterTrack.Velocity,1);

% Initialize Data Structure.
Sup=struct( 'absorption_dbpm',nan(noe,1),...
    'bins',repmat(bins,noe,1),...
    'binSize_cm',nan(noe,1),...
    'nBins',nan(1),...
    'blank_cm',nan(1),...
    'draft_cm',nan(1),...
    'ensNo',nan(noe,1),...
    'nPings',nan(1),...
    'noEnsInSeg',nan(noe,1),...
    'noe',nan(1),...
    'note1',blanks(80),...
    'note2',blanks(80),...
    'intScaleFact_dbpcnt',nan(noe,1),...
    'intUnits',repmat(blanks(5),noe,1),...
    'vRef',repmat(blanks(4),noe,1),...
    'wm',nan(1),...
    'units',repmat(blanks(2),noe,1),...
    'year',nan(noe,1),...
    'month',nan(noe,1),...
    'day',nan(noe,1),...
    'hour',nan(noe,1),...
    'minute',nan(noe,1),...
    'second',nan(noe,1),...
    'sec100',nan(noe,1),...
    'timeElapsed_sec',nan(noe,1),...
    'timeDelta_sec100',nan(1));

Wat=struct( 'binDepth',nan(bins,noe),...
    'backscatter',nan(bins,noe,4),...
    'beamFreq',nan(1,noe),...
    'beamMode',cell(1,1),...
    'vDir',nan(bins,noe),...
    'vMag',nan(bins,noe),...
    'vEast',nan(bins,noe),...
    'vError',nan(bins,noe),...
    'vNorth',nan(bins,noe),...
    'vVert',nan(bins,noe),...
    'percentGood',nan(bins,noe));
Wat.beamMode = cell(1,noe);

Nav=struct( 'bvEast',nan(noe,1),...
    'bvError',nan(noe,1),...
    'bvNorth',nan(noe,1),...
    'bvVert',nan(noe,1),...
    'depth',nan(noe,5),...
    'dsDepth',nan(noe,1),...
    'dmg',nan(noe,1),...
    'length',nan(noe,1),...
    'totDistEast',nan(noe,1),...
    'totDistNorth',nan(noe,1),...
    'altitude',nan(noe,1),...
    'altitudeChng',nan(noe,1),...
    'gpsTotDist',nan(noe,1),...
    'gpsVariable',nan(noe,1),...
    'gpsVeast',nan(noe,1),...
    'gpsVnorth',nan(noe,1),...
    'lat_deg',nan(noe,1),...
    'long_deg',nan(noe,1),...
    'nSats',nan(noe,1),...
    'hdop',nan(noe,1));

Sensor=struct(  'sensor_type','', ...
    'pitch_deg',nan(noe,1),...
    'roll_deg',nan(noe,1),...
    'heading_deg',nan(noe,1),...
    'temp_degC',nan(noe,1));

Q=struct(   'endDepth',nan(noe,1),...
    'endDist',nan(noe,1),...
    'bot',nan(noe,1),...
    'end',nan(noe,1),...
    'meas',nan(noe,1),...
    'start',nan(noe,1),...
    'top',nan(noe,1),...
    'unit',nan(bins,noe),...
    'startDepth',nan(noe,1),...
    'startDist',nan(noe,1));

Sup.noe = noe;

% % Read in Selected Files
% % Initialize the data structure
% z = length(zFileName);
% A = initStructure(z);
% 
% % Begin master loop
% for zi=1:z
%     % Open data file, determine input type by extension
%     [~, ~, ext] = fileparts(zFileName{zi});
%     fileName = fullfile(zPathName,zFileName{zi});
%     
%     switch ext
%         case '.mat' % SonTek
%             try
%              [A(zi)]=parseSonTekVMT(fileName);
%              
%             catch err
%                 erstg = {'                                                      ',...
%                     'An unknown error occurred when reading the SonTek file.'};
%                 if isdeployed
%                     errLogFileName = fullfile(pwd,...
%                         ['errorLog' datestr(now,'yyyymmddHHMMSS') '.txt']);
%                     msgbox({erstg;...
%                         ['  Error code: ' err.identifier];...
%                         ['Error details are being written to the following file: '];...
%                         errLogFileName},...
%                         'VMT Status: Unexpected Error',...
%                         'error');
%                     fid = fopen(errLogFileName,'W');
%                     fwrite(fid,err.getReport('extended','hyperlinks','off'));
%                     fclose(fid);
%                     rethrow(err)
%                 else
%                     msgbox(['An unexpected error occurred. Error code: ' err.identifier],...
%                         'VMT Status: Unexpected Error',...
%                         'error');
%                     rethrow(err);
%                 end
%             end
%         otherwise 
%     end
% end
% 
% 
% % Create a name for any user saved results
% switch ext
%     case '.mat'
%         % Save data with data/time prefix/suffix from the SonTek
%         % filenames
%         file_root_name = zFileName{1}(1:8);     % date string
%         start_num      = zFileName{1}(9:end-4);   % time string
%         end_num        = zFileName{end}(9:end-4); % time string
%         savefile       = [file_root_name '_' start_num '_' end_num '.mat'];
%         A(1).probeType = 'M9';
%     otherwise
% 
% end
% save_dir = fullfile(zPathName,'VMTProcFiles');
% [~,mess,~] = mkdir(save_dir);
% % disp(mess)
% 
% 
% savefile = fullfile(save_dir,savefile);

%%%%%%%%%%%%%%%%%%%%%%
% Embedded Functions %
%%%%%%%%%%%%%%%%%%%%%%

