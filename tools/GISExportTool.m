function [VelOut,goodrows] = GISExportTool(drange,ref,tav,probetype)
% GIS Table Creation Tool (formerly ASCII2GIS)

% This program reads in an ADCP input file or files generated from WinRiver
% Classic ASCII output or SonTek MAT-File output and outputs the
% Georeferenced mean velocity, temperature, depth, and backscatter data to
% a file for input into GIS.

% drange = [depth1 depth2] %range of depths over which to average the data
% ('dfs' option)
% (full range of data if blank)  %Added 12-20-10

% drange = single value for 'hab' option (height above bottom in m)

% ref = 'dfs' or 'hab';  %'dsf' = depth from surface; 'hab' = height above
% bottom

% tav = averaging time in seconds (leave empty for no averaging)

%Updated directional averaging PRJ 2/8/11
%Updated save path PRJ 3/10/11
%Added *.anv file export PRJ 5-11-11
%Added averaging capability PRJ 3-20-12
%Added SonTek compatability FLE 12-07-2017

% P.R. Jackson 6-25-10


%% USer inputs
append_data = 1;
comp_us = 1; %Compute shear velocity

if isempty(tav)
    avg_data = 0;
else
    avg_data = 1;
end

%% Check the inputs

if nargin == 0
    drange = [];
    ref = 'dfs';
    probetype = 'TRDI';
elseif nargin < 2
    ref = 'dfs';
    probetype = 'TRDI';
end

%% Read and Convert the Data

% Determine Files to Process
% Ask the user to select files:
% -----------------------------
guiprefs = getpref('VMT');
switch probetype
    case 'TRDI'
        current_file = fullfile(guiprefs.ascii.path,guiprefs.ascii.file{1});
        [zFileName,zPathName] = uigetfile({'*_ASC.TXT','ASCII (*_ASC.TXT)'}, ...
            'Select the WinRiver Classic ASCII Output Files', ...
            current_file, ...
            'MultiSelect','on');
        
    case 'SonTek'
        current_file = fullfile(guiprefs.sontek.path,guiprefs.sontek.file{1});
        [zFileName,zPathName] = uigetfile({'*.MAT'}, ...
            'Select the RiverSurveryLive Matlab Output Files', ...
            current_file, ...
            'MultiSelect','on');
end

if ischar(zPathName) % The user did not hit "Cancel"
    % Determine number of files to be processed
    if  isa(zFileName,'cell')
        z=size(zFileName,2);
        zFileName=sort(zFileName);
    else
        z=1;
        zFileName={zFileName};
    end
    %msgbox('Loading Data...Please Be Patient','Conversion Status','help','replace');
    % Read in Selected Files
    % Initialize row counter
    
    % Query for an output file name and location
    [ofile,opath] = uiputfile('*.csv','Save file name',zPathName);
    outfile = [opath ofile];
    
    % Begin master loop
    
    VelOut = [];  %Matrix for output of velocity data
    
    wbh = waitbar(0,'Converting Data Files...Please Be Patient');
    
    for zi=1:z
        %Clear variables
        clear DAVeast DAVnorth DAVmag DAVdir DAVvert ustar zo cod i j
        
        % Open txt data file
        if  isa(zFileName,'cell')
            file2load=strcat(zPathName,'\',zFileName(zi));
            file2load=char(file2load);
        else
            file2load=strcat(zPathName,zFileName);
        end
        
        switch probetype
            case 'TRDI'
                % screenData 0 leaves bad data as -32768, 1 converts to NaN
                screenData=1;
                
                % tfile reads the data from an RDI ASCII output file and puts the
                % data in a Matlab data structure with major groups of:
                % Sup - supporing data
                % Wat - water data
                % Nav - navigation data including GPS.
                % Sensor - Sensor data
                % Q - discharge related data
                ignoreBS = 0;
                [A]=tfile(file2load,screenData,ignoreBS);
            case 'SonTek'
                A = parseSonTekVMT(file2load);
        end
        
        %Extract only Lat lon data
        latlon(:,1)=A.Nav.lat_deg(:,:);
        latlon(:,2)=A.Nav.long_deg(:,:);
        
        %Rescreen data to remove missing data (30000 value)
        indx1 = find(abs(latlon(:,1)) > 90);
        indx2 = find(abs(latlon(:,2)) > 180);
        latlon(indx1,1)=NaN;
        latlon(indx2,2)=NaN;
        
        indx3 = find(~isnan(latlon(:,1)) & ~isnan(latlon(:,2)));
        latlon = latlon(indx3,:);
        
        
        %Extract the Depths
        BeamDepths  = A.Nav.depth(indx3,:);
        Depth = nanmean(A.Nav.depth(indx3,:),2);
        
        %Filter Backscatter
        A = VMT_FilterBS(1,A);
        
        
        %Extract the averaged velocities and backscatter (layer average)
        if isempty(drange)
            disp(['Extracting DFS Range = Full'])
            DAVeast  = VMT_LayerAveMean(A.Wat.binDepth(:,indx3),A.Wat.vEast(:,indx3));
            DAVnorth = VMT_LayerAveMean(A.Wat.binDepth(:,indx3),A.Wat.vNorth(:,indx3));
            DAVvert  = VMT_LayerAveMean(A.Wat.binDepth(:,indx3),A.Wat.vVert(:,indx3));
            DABack   = VMT_LayerAveMean(A.Wat.binDepth(:,indx3),A.Clean.bsf(:,indx3));
            %DAVeast  = nanmean(A.Wat.vEast(:,indx3),1)';
            %DAVnorth = nanmean(A.Wat.vNorth(:,indx3),1)';
            %DAVvert  = nanmean(A.Wat.vVert(:,indx3),1)';
            %DABack   = nanmean(A.Clean.bsf(:,indx3),1)';
            DAVeast  = DAVeast';
            DAVnorth = DAVnorth';
            DAVvert  = DAVvert';
            DABack   = DABack';
        elseif strcmp(ref,'dfs')
            disp(['Extracting DFS Range = ' num2str(drange(1)) ' to ' num2str(drange(2)) ' m'])
            indxr = find(A.Wat.binDepth(:,1) >= drange(1) & A.Wat.binDepth(:,1) <= drange(2));
            DAVeast  = VMT_LayerAveMean(A.Wat.binDepth(indxr,indx3),A.Wat.vEast(indxr,indx3));
            DAVnorth = VMT_LayerAveMean(A.Wat.binDepth(indxr,indx3),A.Wat.vNorth(indxr,indx3));
            DAVvert  = VMT_LayerAveMean(A.Wat.binDepth(indxr,indx3),A.Wat.vVert(indxr,indx3));
            DABack   = VMT_LayerAveMean(A.Wat.binDepth(indxr,indx3),A.Clean.bsf(indxr,indx3));
            %DAVeast  = nanmean(A.Wat.vEast(indxr,indx3),1)';
            %DAVnorth = nanmean(A.Wat.vNorth(indxr,indx3),1)';
            %DAVvert  = nanmean(A.Wat.vVert(indxr,indx3),1)';
            %DABack   = nanmean(A.Clean.bsf(indxr,indx3),1)';
            DAVeast  = DAVeast';
            DAVnorth = DAVnorth';
            DAVvert  = DAVvert';
            DABack   = DABack';
        elseif strcmp(ref,'hab')
            disp(['Extracting HAB Range = ' num2str(drange(1)) ' to ' num2str(drange(2)) ' m'])
            i = 1;
            for j = 1:length(indx3)
                bed = nanmean(A.Nav.depth(indx3(j),:),2)';
                indxr = find(A.Wat.binDepth(:,1) <= (bed - drange(1)) & A.Wat.binDepth(:,1) >= (bed-drange(2)));
                %             DAVeast(i)  = VMT_LayerAveMean(A.Wat.binDepth(indxr,indx3(j)),A.Wat.vEast(indxr,indx3(j)));
                %             DAVnorth(i) = VMT_LayerAveMean(A.Wat.binDepth(indxr,indx3(j)),A.Wat.vNorth(indxr,indx3(j)));
                %             DAVvert(i)  = VMT_LayerAveMean(A.Wat.binDepth(indxr,indx3(j)),A.Wat.vVert(indxr,indx3(j)));
                %             DABack(i)   = VMT_LayerAveMean(A.Wat.binDepth(indxr,indx3(j)),A.Clean.bsf(indxr,indx3(j)));
                DAVeast(i)  = nanmean(A.Wat.vEast(indxr,indx3(j)),1);
                DAVnorth(i) = nanmean(A.Wat.vNorth(indxr,indx3(j)),1);
                DAVvert(i)  = nanmean(A.Wat.vVert(indxr,indx3(j)),1);
                DABack(i)   = nanmean(A.Clean.bsf(indxr,indx3(j)),1)';
                
                i = i + 1;
            end
            
            DAVeast  = DAVeast';
            DAVnorth = DAVnorth';
            DAVvert  = DAVvert';
            DABack   = DABack';
        end
        
        % Compute the magnitude from the components
        DAVmag   = sqrt(DAVeast.^2 + DAVnorth.^2);
        
        % Compute the average direction from the velocity components
        DAVdir = 90 - (atan2(DAVnorth, DAVeast))*180/pi; %Compute the atan from the velocity componentes, convert to radians, and rotate to north axis
        qindx = find(DAVdir < 0);
        if ~isempty(qindx)
            DAVdir(qindx) = DAVdir(qindx) + 360;  %Must add 360 deg to Quadrant 4 values as they are negative angles from the +y axis
        end
        
        %Extract the Sensors
        Pitch = A.Sensor.pitch_deg(indx3);
        Roll  = A.Sensor.roll_deg(indx3);
        Heading  = A.Sensor.heading_deg(indx3);
        Temp  = A.Sensor.temp_degC(indx3);
        
        %Extract the time stamps
        MTyear      = A.Sup.year(indx3) + 2000; %works for data file after the year 2000
        MTmon       = A.Sup.month(indx3);
        MTday       = A.Sup.day(indx3);
        MThour      = A.Sup.hour(indx3);
        MTmin       = A.Sup.minute(indx3);
        MTsec       = A.Sup.second(indx3) + A.Sup.sec100(indx3)/100;
        MTdatenum   = datenum([MTyear MTmon MTday MThour MTmin MTsec]);
        
        %Extract Ens No
        EnsNo = A.Sup.ensNo(indx3);
        
        
        if comp_us %Compute normalized, bed origin profiles to prepare for log law fitting (PRJ, 8-31-12)
            d_ens   = nanmean(A.Nav.depth(indx3,:),2)';  %Average depth from the four beams for every ensemble
            z_bins  = repmat(d_ens,size(A.Wat.binDepth(:,indx3),1),1) - A.Wat.binDepth(:,indx3);  %matrix on bin depths ref to bottom
            z_norm  = z_bins./repmat(d_ens,size(A.Wat.binDepth(:,indx3),1),1);  %Matrix of normalized, bed origin bin depths
        end
        
        
        if 0  %Fit individual profiles to log law
            clear i j
            i = 1;
            for j = 1:length(indx3)
                dfit = nanmean(A.Nav.depth(indx3(j),:),2);
                zfit = dfit - A.Wat.binDepth(:,1);
                znorm = zfit./dfit;
                indxfr = find(znorm >= 0.2 & znorm <= 1); %takes only data above 0.2H
                ufit = A.Wat.vMag(indxfr,indx3(j))/100;
                zfit = zfit(indxfr);
                indxgd = find(~isnan(ufit));
                if ~isempty(indxgd)
                    [ustar(i),zo(i),cod(i)] = fitLogLawV2(ufit(indxgd),zfit(indxgd),dfit);
                    if cod(i) < 0.25 | ustar(i) < 0 | zo(i) > 1.0  %screens the results
                        ustar(i) = nan;
                        zo(i) = nan;
                    end
                else
                    ustar(i) = nan;
                    zo(i) = nan;
                    cod(i) = nan;
                end
                i = i + 1;
            end
            ustar = ustar';
            zo = zo';
            cod = cod';
        else % Fill with nans if not computing (turn off pending more testing--PRJ 6-30-11)
            ustar = nan.*ones(size(EnsNo));
            zo  = nan.*ones(size(EnsNo));
            cod = nan.*ones(size(EnsNo));
        end
        
        % Perform temporal averaging  (Added 3-20-12 PRJ)
        if avg_data
            disp(['Performing temporal averaging over ' num2str(tav) ' second intervals.'])
            %tav = 30; %Averaging time in seconds
            if (MTdatenum(1) + tav/(3600*24)) >= MTdatenum(end)  %uses limits of data if averaging period exceeds data limits
                tav_vec = [MTdatenum(1) MTdatenum(end)];
            else
                tav_vec = MTdatenum(1):(tav/(3600*24)):MTdatenum(end);  %Vector of serial dates representing the start and end of each averaging period
            end
            for i = 1:length(tav_vec)-1
                av_indx = find(MTdatenum >= tav_vec(i) & MTdatenum < tav_vec(i+1));
                EnsNo_av(i) = nanmean(ceil(EnsNo(av_indx)));
                MTdatenum_av(i) = nanmean(MTdatenum(av_indx));
                latlon_av(i,:) = nanmean(latlon(av_indx,:),1);
                Heading_av(i) = nanmean(Heading(av_indx));  %this will break down near due north
                Pitch_av(i) = nanmean(Pitch(av_indx));
                Roll_av(i) = nanmean(Roll(av_indx));
                Temp_av(i) = nanmean(Temp(av_indx));
                Depth_av(i) = nanmean(Depth(av_indx));
                BeamDepths_av(i,:) = nanmean(BeamDepths(av_indx,:),1);
                DABack_av(i) = nanmean(DABack(av_indx));
                DAVeast_av(i) = nanmean(DAVeast(av_indx));
                DAVnorth_av(i) = nanmean(DAVnorth(av_indx));
                DAVvert_av(i) = nanmean(DAVvert(av_indx));
                
                
                % Compute the magnitude and direction from the averaged
                % components
                
                DAVmag_av = sqrt(DAVeast_av.^2 + DAVnorth_av.^2);
                DAVdir_av = 90 - (atan2(DAVnorth_av, DAVeast_av))*180/pi; %Compute the atan from the velocity componentes, convert to radians, and rotate to north axis
                qindx = find(DAVdir_av < 0);
                if ~isempty(qindx)
                    DAVdir_av(qindx) = DAVdir_av(qindx) + 360;  %Must add 360 deg to Quadrant 4 values as they are negative angles from the +y axis
                end
                
                if comp_us  %Compute the shear velocity
                    %Compute the mean, normalized profile (bed origin)
                    [znm,vm] = VMT_ComputeNormProf(z_norm(:,av_indx),A.Wat.vMag(:,av_indx),30);
                    
                    %Fit the normalized profile with the log law
                    gd_indx = ~isnan(vm);
                    u_fit = vm(gd_indx)./100;
                    z_fit = znm(gd_indx)*Depth_av(i);
                    [ustar_av(i),zo_av(i),cod_av(i)] = fitLogLawV2(u_fit,z_fit,Depth_av(i));
                else
                    ustar_av(i) = nanmean(ustar(av_indx));
                    zo_av(i) = nanmean(zo(av_indx));
                    cod_av(i) = nanmean(cod(av_indx));
                end
            end
        end
        
        
        %Clear the structure
        clear A
        
        %Save the data
        
        if avg_data
            outmat = [EnsNo_av' datevec(MTdatenum_av) latlon_av Heading_av' Pitch_av' Roll_av' Temp_av' Depth_av' BeamDepths_av DABack_av' DAVeast_av' DAVnorth_av' DAVmag_av' DAVdir_av' DAVvert_av' ustar_av' zo_av' cod_av'];
        else
            outmat = [EnsNo MTyear MTmon MTday MThour MTmin MTsec latlon Heading Pitch Roll Temp Depth BeamDepths DABack DAVeast DAVnorth DAVmag DAVdir DAVvert ustar zo cod];
        end
        
        % Replace nans with -9999 (ARCGIS takes nans to be zero when exporting to
        % shapefile)
        if 0  % Fill the nans
            for i = 7:size(outmat,2)
                outmat(:,i) = inpaint_nans(outmat(:,i));
            end
        else  %fill with -9999
            outmat(isnan(outmat)) = -9999;
        end
        
        
        
        
        if append_data & zi == 1
            %outfile = [fileName(1:end-4) '_GIS.csv'];
            firstfile = outfile;
        elseif ~append_data
            [ofile,opath] = uiputfile('*.csv','Save file name',ascii2gispath);
            outfile = [opath ofile];
            %outfile = [fileName(1:end-4) '_GIS.csv'];
        elseif append_data & zi > 1
            outfile = firstfile;
        end
        
        
        
        if append_data & zi == 1
            ofid   = fopen(outfile, 'wt');
            switch probetype
                case 'TRDI'
                    outcount = fprintf(ofid,'EnsNo,Year,Month,Day,Hour,Min,Sec,Lat_WGS84,Lon_WGS84,Heading_deg,Pitch_deg,Roll_deg,Temp_C,Depth_m,B1Depth_m,B2Depth_m,B3Depth_m,B4Depth_m,BackScatter_db,DAVeast_cmps,DAVnorth_cmps,DAVmag_cmps,DAVdir_deg,DAVvert_cmps,U_star_mps,Z0_m,COD\n');
                case 'SonTek'
                    outcount = fprintf(ofid,'EnsNo,Year,Month,Day,Hour,Min,Sec,Lat_WGS84,Lon_WGS84,Heading_deg,Pitch_deg,Roll_deg,Temp_C,Depth_m,B1Depth_m,B2Depth_m,B3Depth_m,B4Depth_m,B5Depth_m,BackScatter_db,DAVeast_cmps,DAVnorth_cmps,DAVmag_cmps,DAVdir_deg,DAVvert_cmps,U_star_mps,Z0_m,COD\n');
            end
        elseif ~append_data
            ofid   = fopen(outfile, 'wt');
            switch probetype
                case 'TRDI'
                    outcount = fprintf(ofid,'EnsNo,Year,Month,Day,Hour,Min,Sec,Lat_WGS84,Lon_WGS84,Heading_deg,Pitch_deg,Roll_deg,Temp_C,Depth_m,B1Depth_m,B2Depth_m,B3Depth_m,B4Depth_m,BackScatter_db,DAVeast_cmps,DAVnorth_cmps,DAVmag_cmps,DAVdir_deg,DAVvert_cmps,U_star_mps,Z0_m,COD\n');
                case 'SonTek'
                    outcount = fprintf(ofid,'EnsNo,Year,Month,Day,Hour,Min,Sec,Lat_WGS84,Lon_WGS84,Heading_deg,Pitch_deg,Roll_deg,Temp_C,Depth_m,B1Depth_m,B2Depth_m,B3Depth_m,B4Depth_m,B5Depth_m,BackScatter_db,DAVeast_cmps,DAVnorth_cmps,DAVmag_cmps,DAVdir_deg,DAVvert_cmps,U_star_mps,Z0_m,COD\n');
            end
        elseif append_data & zi > 1
            ofid   = fopen(outfile, 'at');
        end
        switch probetype
            case 'TRDI'
                outcount = fprintf(ofid,'%6.0f,%4.0f,%2.0f,%2.0f,%2.0f,%2.0f,%2.2f,%3.10f,%3.10f,%3.3f,%3.3f,%3.3f,%3.1f,%3.2f,%3.2f,%3.2f,%3.2f,%3.2f,%3.0f,%3.2f,%3.2f,%3.2f,%3.1f,%3.2f,%2.4f,%2.4f,%1.4f\n',outmat');
            case 'SonTek'
                outcount = fprintf(ofid,'%6.0f,%4.0f,%2.0f,%2.0f,%2.0f,%2.0f,%2.2f,%3.10f,%3.10f,%3.3f,%3.3f,%3.3f,%3.1f,%3.2f,%3.2f,%3.2f,%3.2f,%3.2f,%3.2f,%3.0f,%3.2f,%3.2f,%3.2f,%3.1f,%3.2f,%2.4f,%2.4f,%1.4f\n',outmat');
        end
        fclose(ofid);
        
        if avg_data
            [Easting,Northing,utmzone] = deg2utm(latlon_av(:,1),latlon_av(:,2));
            VelOut = [VelOut; Easting Northing zeros(size(Easting)) (DAVeast_av)'./100 (DAVnorth_av)'./100];
        else
            [Easting,Northing,utmzone] = deg2utm(latlon(:,1),latlon(:,2));
            VelOut = [VelOut; Easting Northing zeros(size(Easting)) DAVeast./100 DAVnorth./100];
        end
        
        clear outmat latlon EnsNo MTyear MTmon MTday MThour MTmin MTsec latlon Heading Pitch Roll Temp Depth BeamDepths DABack DAVeast DAVnorth DAVmag DAVdir DAVvert ustar zo cod Easting Northing utmzone
        clear EnsNo_av MTdatenum_av latlon_av Heading_av Pitch_av Roll_av Temp_av Depth_av BeamDepths_av DABack_av DAVeast_av DAVnorth_av DAVmag_av DAVdir_av DAVvert_av ustar_av zo_av cod_av
        
        waitbar(zi/z); %update the waitbar
    end
    delete(wbh) %remove the waitbar
    
    msgbox('Conversion Complete','Conversion Status','help','replace');
    
    % Save an *.anv file (for iRIC model interface)
    goodrows = [];
    for i = 1:size(VelOut,1)
        rowsum = sum(isnan(VelOut(i,:)));
        if rowsum == 0
            goodrows = [goodrows; i];
        end
    end
    %outfile = [fileName(1:end-4) '_DAV.anv'];
    outfile = [outfile(1:end-4) '.anv'];
    ofid    = fopen(outfile, 'wt');
    outcount = fprintf(ofid,'%8.2f  %8.2f  %5.2f  %3.3f  %3.3f\n',VelOut(goodrows,:)');
    fclose(ofid);
else % User hit cancel, return empty inputs
    VelOut      = [];
    goodrows    = [];
end



