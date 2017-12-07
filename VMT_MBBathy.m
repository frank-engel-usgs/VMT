function [A] = VMT_MBBathy(z,A,savefile,beamAng,magVar,wseval,saveaux)
% Computes the multibeam bathymetry from the four beams of the ADCP
% using a script by D.Mueller (USGS). Beam depths are computed for each
% transect prior to any averaging or mapping.
%
% Added the ability to export timestamps, pitch, roll, and heading
% (2/1/10)
%
% Added an identifier for each individual transect to the csv output
%(FEL, 6/14/12)
%
% V3 Adds capability to handle timeseries of WSE, PRJ 8-7-12
%
% P.R. Jackson, USGS, 8-7-12

%% Start
try
    %disp('Computing corrected beam depths')
    if isstruct(wseval)
        if length(wseval.elev) == 1
            %disp('WSE is a constant value')
            wsefiletype = 'constant';
            wsedata.elev = wseval.elev;
        else
            %disp('WSE is a timeseries')
            wsefiletype = 'vector';
            wsedata = wseval;
        end
    elseif isempty(wseval) % Expects A(zi).wse
        wsedata = 'Astruct';
        wsefiletype = 'supplied';
    else
        %disp('WSE is a constant value')
        warning off
        wsedata.elev = wseval;
        wsefiletype = 'constant';
        warning on
    end
    
    %% Step through each transect in the given set
    %figure(1); clf
    for zi = 1 : z
        
        % Work on the WSE if a vector
        %WSE vector must have a value for each ensemble, so interpolate given
        %values to ensemble times
        
        switch wsefiletype  %only process as vector if loaded file rather than single value
            case 'vector'
                %Build an ensemble time vector
                enstime = datenum([A(zi).Sup.year+2000 A(zi).Sup.month A(zi).Sup.day...
                    A(zi).Sup.hour A(zi).Sup.minute (A(zi).Sup.second+A(zi).Sup.sec100./100)]);
                
                % Interpolate the WSE values to the ENS times
                wse = interp1(wsedata.obstime,wsedata.elev,enstime);
                
                % Check probe type, process accordingly
                type = upper(A(zi).Sensor.sensor_type);
                if ismember(type,{'RG', 'SP', 'RR'})
                    % Compute position and elevation of each beam depth
                    [exyz] = depthxyz(A(zi).Nav.depth,A(zi).Sup.draft_cm,...
                        A(zi).Sensor.pitch_deg,A(zi).Sensor.roll_deg,....
                        A(zi).Sensor.heading_deg,beamAng,...
                        'm',A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,wse,A(zi).Sup.ensNo);  %magVar,removed 4-8-10
                elseif ismember(type,{'M9', 'S5'})
                    if str2double(beamAng) ~= 25
                        errordlg('Sontek ADCP data loaded, but beam angle is not 25 degrees')
                    end
                    % Compute position and elevation of each beam depth
                    [exyz] = depthxyzRS(...
                        A(zi).Nav.depth(:,1:4),...
                        A(zi).Nav.depth(:,5),...
                        A(zi).Wat.beamFreq,...
                        A(zi).Sup.draft_cm,...
                        A(zi).Sensor.pitch_deg,A(zi).Sensor.roll_deg,....
                        A(zi).Sensor.heading_deg,...
                        beamAng,...
                        'm',A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,wse,A(zi).Sup.ensNo);  %magVar,removed 4-8-10
                end
                % Compute position and elevation of each beam depth
                
            case 'constant'
                wse = wsedata.elev; %Single value
                
                % Check probe type, process accordingly
                type = upper(A(zi).Sensor.sensor_type);
                if ismember(type,{'RG', 'SP', 'RR'})
                    % Compute position and elevation of each beam depth
                    [exyz] = depthxyz(A(zi).Nav.depth,A(zi).Sup.draft_cm,...
                        A(zi).Sensor.pitch_deg,A(zi).Sensor.roll_deg,....
                        A(zi).Sensor.heading_deg,beamAng,...
                        'm',A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,wse,A(zi).Sup.ensNo);  %magVar,removed 4-8-10
                elseif ismember(type,{'M9', 'S5'})
                    if str2double(beamAng) ~= 25
                        errordlg('Sontek ADCP data loaded, but beam angle is not 25 degrees')
                    end
                    % Compute position and elevation of each beam depth
                    [exyz] = depthxyzRS(...
                        A(zi).Nav.depth(:,1:4),...
                        A(zi).Nav.depth(:,5),...
                        A(zi).Wat.beamFreq,...
                        A(zi).Sup.draft_cm,...
                        A(zi).Sensor.pitch_deg,A(zi).Sensor.roll_deg,....
                        A(zi).Sensor.heading_deg,...
                        beamAng,...
                        'm',A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,wse,A(zi).Sup.ensNo);  %magVar,removed 4-8-10
                end
                     
                
                
            case 'supplied'
                wse = A(zi).wse; %Single value, varies by transect
                % Check probe type, process accordingly
                type = upper(A(zi).Sensor.sensor_type);
                if ismember(type,{'RG', 'SP', 'RR'})
                    % Compute position and elevation of each beam depth
                    [exyz] = depthxyz(A(zi).Nav.depth,A(zi).Sup.draft_cm,...
                        A(zi).Sensor.pitch_deg,A(zi).Sensor.roll_deg,....
                        A(zi).Sensor.heading_deg,beamAng,...
                        'm',A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,wse,A(zi).Sup.ensNo);  %magVar,removed 4-8-10
                elseif ismember(type,{'M9', 'S5'})
                    if str2double(beamAng) ~= 25
                        errordlg('Sontek ADCP data loaded, but beam angle is not 25 degrees')
                    end
                    % Compute position and elevation of each beam depth
                    [exyz] = depthxyzRS(...
                        A(zi).Nav.depth(:,1:4),...
                        A(zi).Nav.depth(:,5),...
                        A(zi).Wat.beamFreq,...
                        A(zi).Sup.draft_cm,...
                        A(zi).Sensor.pitch_deg,A(zi).Sensor.roll_deg,....
                        A(zi).Sensor.heading_deg,...
                        beamAng,...
                        'm',A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,wse,A(zi).Sup.ensNo);  %magVar,removed 4-8-10
                end
        end
        
        
        
        %Build the auxillary data matrix
        if saveaux
            if ismember(type,{'RG', 'SP', 'RR'}) 
            auxmat = [A(zi).Sup.year+2000 A(zi).Sup.month A(zi).Sup.day...
                A(zi).Sup.hour A(zi).Sup.minute (A(zi).Sup.second+A(zi).Sup.sec100./100) ...
                A(zi).Sensor.heading_deg A(zi).Sensor.pitch_deg A(zi).Sensor.roll_deg ...
                repmat(zi,size(A(zi).Sup.year))]; % Added transect #(zi) FLE 6/14/12    %Had to add 2000 to year--will not work for years < 2000
            elseif ismember(type,{'M9', 'S5'})
                 auxmat = [A(zi).Sup.year A(zi).Sup.month A(zi).Sup.day...
                A(zi).Sup.hour A(zi).Sup.minute (A(zi).Sup.second+A(zi).Sup.sec100./100) ...
                A(zi).Sensor.heading_deg A(zi).Sensor.pitch_deg A(zi).Sensor.roll_deg ...
                repmat(zi,size(A(zi).Sup.year))]; % Added transect #(zi) FLE 6/14/12    %SonTek writes yyyy format
            end
            auxmat2 = [];
            for i = 1:length(A(zi).Sup.ensNo);
                [lia,lib]=ismember(exyz(:,1),A(zi).Sup.ensNo(i));
                dum = [exyz(lia,:) repmat(auxmat(i,:),nnz(lia),1)];
                auxmat2 = cat(1,auxmat2,dum);
            end
            clear auxmat dum enstime wse
        end
        
        % Store results
        idxmbb = find(~isnan(exyz(:,4))& ~isnan(exyz(:,2)));
        if zi==1
            zmbb=[exyz(idxmbb,1) exyz(idxmbb,2)...
                exyz(idxmbb,3) exyz(idxmbb,4)];
            if saveaux
                auxmbb = auxmat2(idxmbb,:);
            end
        else
            zmbb=cat(1,zmbb,[exyz(idxmbb,1)...
                exyz(idxmbb,2) exyz(idxmbb,3) exyz(idxmbb,4)]);
            if saveaux
                auxmbb = cat(1,auxmbb,auxmat2(idxmbb,:));
            end
        end
        
        A(zi).Comp.exyz = exyz(idxmbb,:);
        
        
        clear idxmbb exyz;
        %pack;
    end
    
    
    %% Save the data
    
    if 1
        %disp('Exporting multibeam bathymetry')
        %disp([savefile(1:end-4) '_mbxyz.csv'])
        outfile = [savefile(1:end-4) '.csv'];
        if saveaux
            outmat = [auxmbb];
            ofid   = fopen(outfile, 'wt');
            outcount = fprintf(ofid,'EnsNo,Easting_WGS84_m,Northing_WGS84_m,Elev_m,Year,Month,Day,Hour,Minute,Second,Heading_deg,Pitch_deg,Roll_deg,Transect\n'); % Modified to output transect # FLE 6/14/12
            outcount = fprintf(ofid,'%6.0f,%14.2f,%14.2f,%8.2f,%4.0f,%2.0f,%2.0f,%2.0f,%2.0f,%2.2f,%3.3f,%3.3f,%3.3f,%3.0f\n',outmat');
            fclose(ofid);
        else
            outmat = zmbb;
            ofid   = fopen(outfile, 'wt');
            outcount = fprintf(ofid,'EnsNo,Easting_WGS84_m,Northing_WGS84_m,Elev_m\n');
            outcount = fprintf(ofid,'%6.0f,%14.2f,%14.2f,%8.2f\n',outmat');
            fclose(ofid);
        end
        %dlmwrite([savefile(1:end-4) '_mbxyz.csv'],outmat,'precision',15);
    end
catch err
     if isdeployed
        errLogFileName = fullfile(pwd,...
            ['errorLog' datestr(now,'yyyymmddHHMMSS') '.txt']);
        msgbox({['An unexpected error occurred. Error code: ' err.identifier];...
            ['Error details are being written to the following file: '];...
            errLogFileName},...
            'VMT Status: Unexpected Error',...
            'error');
        fid = fopen(errLogFileName,'W');
        fwrite(fid,err.getReport('extended','hyperlinks','off'));
        fclose(fid);
        rethrow(err)
    else
        msgbox(['An unexpected error occurred. Error code: ' err.identifier],...
            'VMT Status: Unexpected Error',...
            'error');
        rethrow(err);
    end    
end