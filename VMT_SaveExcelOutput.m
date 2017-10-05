function [log_text] = VMT_SaveExcelOutput(excel_path,excel_file,outputType,dataPath,dataFiles,V,A,z,Map,wse,PVdata)
% Function to save Excel spreadsheet of the VMT output information
%
% Written by: Frank L. Engel (fengel@usgs.gov)


% Check for existing file
[excel_file,excel_path] = uiputfile('*.xlsx','Save *.xlsx file',...
    fullfile(excel_path,excel_file));

if ischar(excel_path) % The user did not hit "Cancel"
    outfile = fullfile(excel_path,excel_file);
    %log_text = vertcat(log_text,{outfile});
    
    % Delete the old file if it exists
    if exist(outfile, 'file') == 2
        log_text = {'Warning: The file';...
            ['   ' outfile];...
            'already exists. Overwriting file...'};
        delete(outfile)
    end
end

switch outputType
    case 'Multiple'
        % Multiple MAT Files Loaded
        % -----
        hwait = waitbar(0,'Exporting Excel File...');
        log_text = {'Writing data to Excel file...';...
            'Multiple transected loaded. Will export Planview Data Only!'};
        
        % Load ActiveX Heading Styles
        H = ActiveXHeadings();
        
        % Construct the Smoothed_Planview Sheet
        % -----
        % Save the actual Planview plot data, which includes the smoothed
        % results
        workingSheet = {'Smoothed_Planview'};
        workingTopLeft = {'A2' 'B2' 'A1'};
        workingPropStruct = {H.d1,H.n2,H.h3};
        % Compute distance from the LEFT bank using the MCS endpoints
        %PVDist = hypot(V.xLeftBank-PVdata.outmat(1,:),V.yLeftBank-PVdata.outmat(2,:));
        vmin = num2str(V.plotSettings.planview.depth_range_min);
        vmax = num2str(V.plotSettings.planview.depth_range_max);
        PVheaders = {...
            'Timestamp'...
            'UTM Easting (WGS84), in meters'...
            'UTM Northing (WGS84), in meters'...
            'Distance, in meters'...
            ['EastDAV_cms_dpthrng_' vmin '_to_' vmax 'm']...
            ['NorthDAV_cms_dpthrng_' vmin '_to_' vmax 'm']...
            'Velocity magnitude, in cm/s'...
            'Velocity direction, in deg. from true north'};
        
        PVtable = [...
            PVdata.outmat(1,:);...
            PVdata.outmat(2,:);...
            PVdata.outmat(7,:);...;...
            PVdata.outmat(4,:).*100;...
            PVdata.outmat(5,:).*100;...
            sqrt(PVdata.outmat(4,:).^2 + PVdata.outmat(5,:).^2).*100;...
            ari2geodeg(atan2(PVdata.outmat(5,:), PVdata.outmat(4,:))*180/pi)];
        %PVtable = (sortrows(PVtable',3))';
        PVtable(isnan(PVtable)) = -9999;
        PVtable = PVtable';
        timestamp = cellstr(nandatestr(PVdata.outmat(6,:)'));
        %PVout = horzcat(cellstr(nandatestr(PVdata.outmat(6,:)')), num2cell(PVtable'));
        %PVout = vertcat(PVheaders,PVout);
        i=1;
        j = i;
        sout{i} = timestamp;
        i=i+1;
        sout{i} = PVtable;
        i=i+1;
        sout{i} = PVheaders(1,:);
        sheetNames = repmat(workingSheet,1,i);
        waitbar(2/7,hwait)
        
        % Construct the Planview Sheet data
        % -----
        workingSheet = {'Planview'};
        workingTopLeft = horzcat(workingTopLeft,...
            {'A2' 'B2' 'C2' 'A1'});
        workingPropStruct = horzcat(workingPropStruct,...
            {H.d1,H.t1,H.n2,H.h3});
        
        vmin = num2str(V.plotSettings.planview.depth_range_min);
        vmax = num2str(V.plotSettings.planview.depth_range_max);
        pvheaders = {...
            'Timestamp' 'FileName' 'UTM_East' 'UTM_North' 'Dist_m' 'Bed_Elev_m'...
            ['EastDAV_cm/s, dpth rng ' vmin ' to ' vmax ' m']...
            ['NorthDAV_cm/s, dpth rng ' vmin ' to ' vmax ' m']...
            'Vel_mag_cm/s' 'Vel_dir_deg'};
        
        % Initialize Variables
        pvdata = []; Dist = []; ID = {};
        X = []; Y = []; E = []; T = [];
        Ve = []; Vn =[]; Vm = []; Vd = [];
        
        % Concatenate data from all MAT files into arrays
        % Preserve the plotSettings information in V struct as called in
        % runtime. This info will be copied to the V struct after loading
        % all files. This ensures that the gui state vars are properly
        % loaded.
        Vbak = V;
        for k = 1:length(dataFiles)
            % Load current MAT-file
            load(fullfile(dataPath,dataFiles{k}))
            
            % Location, Time and Bathy
            ID = vertcat(ID,repmat(dataFiles(k),length(V.mcsX(1,:)),1));
            X = [X V.mcsX(1,:)];
            Y = [Y V.mcsY(1,:)];
            Dist = [Dist sort(V.mcsDist(1,:),'descend')];
            E = [E V.mcsBedElev];
            T = [T V.mcsTime(1,:)];
            
            % Build layer-averaged velocities
            indx = find(V.mcsDepth(:,1) < str2num(vmin) | V.mcsDepth(:,1) > str2num(vmax));
            V.mcsX(indx,:) = nan;
            V.mcsY(indx,:) = nan;
            V.mcsEast(indx,:) = nan;
            V.mcsNorth(indx,:) = nan;
            Ve = [Ve VMT_LayerAveMean(V.mcsDepth,V.mcsEast)];
            Vn = [Vn VMT_LayerAveMean(V.mcsDepth,V.mcsNorth)];
            Vm = [Vm sqrt(VMT_LayerAveMean(V.mcsDepth,V.mcsEast).^2 + VMT_LayerAveMean(V.mcsDepth,V.mcsNorth).^2)];
            Vd = [Vd ari2geodeg(atan2(VMT_LayerAveMean(V.mcsDepth,V.mcsNorth),VMT_LayerAveMean(V.mcsDepth,V.mcsEast))*180/pi)];
            
            %waitbar(k/(length(dataFiles)+1),hwait)
        end
        for fn = fieldnames(Vbak)'
            V.(fn{1}) = Vbak.(fn{1});
        end
        
        % Put output into 1 matrix
        pvdata = [...
            X; Y; Dist; E;... % Bathy and locations
            Ve; Vn; Vm; Vd... % Velocity
            ];
        pvdata(isnan(pvdata)) = -9999;
        
        % Create table and write to Excel
        %pvout = num2cell(pvdata');
        %pvout = horzcat(ID,pvout);
        timestamp = cellstr(nandatestr(T));
        %pvout = vertcat(pvheaders,horzcat(timestamp,pvout));
        j = i;
        i=i+1;
        sout{i} = timestamp;
        i=i+1;
        sout{i} = ID;
        i=i+1;
        sout{i} = pvdata';
        i=i+1;
        sout{i} = pvheaders(1,:);
        sheetNames = horzcat(sheetNames, repmat(workingSheet,1,i-j));
        waitbar(4/7,hwait)
        
        % Construct VMTSummary Sheet Data
        % -----
        workingSheet = {'VMTSummary'};
        workingTopLeft = horzcat(workingTopLeft,...
            {'A2' 'A5' 'E3' 'F3' 'A6' 'A9' 'A10' 'A15' 'A16',... Headers
            'B2' 'B6' 'B11' 'B3' 'A1'});
        workingPropStruct = horzcat(workingPropStruct,...
            {H.t1,H.h2,H.t2,H.t1,H.t1,H.h2,H.t1,H.h2,H.t1,...
            H.d1,H.n2,H.n2,H.d1,H.h1});
        
        % If loading older VMT files, the version tag might not be there.
        if ~any(strcmp('version',fieldnames(V)))
            V.version = 'Older VMT Mat-files loaded. Reprocess for version.';
            V.release = 'n/a';
        end
        j = i;
        i=i+1;
        sout{i} = {'VMT version: ';'Date Processed: '};
        i=i+1;
        sout{i} = {'MEAN CROSS SECTION (MCS) PROPERTIES'};
        i=i+1;
        sout{i} = {'Path:'; 'Files:'};
        i=i+1;
        sout{i} = vertcat(dataPath,dataFiles');
        i=i+1;
        sout{i} = {'Horz. Grid Node Spacing (m):';...
            'Vert. Grid Node Spacing (m):'};
        i=i+1;
        sout{i} = {'SMOOTHED (SPATIALLY-AVERAGED) DATA PROPERTIES'};
        i=i+1;
        sout{i} = {'Smoothed Planview:';...
            'Vector Spacing, in ground distance (m):';...
            'Vector Smoothing, in ground distance (m):'};
        i=i+1;
        sout{i} = {'DATA STRUCTURE'};
        i=i+1;
        sout{i} = {'1. These data are the computed output from The Velocity Mapping Toolbox (VMT).';...
            '2. VMT maps the loaded ADCP data to a mean cross-section (MCS), typically a line of best fit to the ADCP positions.';...
            '3. The ADCP data are then interpolated to a user specified grid (see Cells F6:F7).';...
            '4. VMT then averages the mapped and interpolated data to the MCS grid.';...
            '5. For more information, see the VMT homepage: ';...
            '=HYPERLINK("http://hydroacoustics.usgs.gov/movingboat/VMT/VMT.shtml")';...
            'Planview:';...
            '1. Units are indicated in the column titles.';...
            '2. Values are for layer-avg quanties. Thus "dpthrng_0_to_Infm" would represent layer-averaging over the entire depth.';...
            '3. If the user specifies a depth range, the column title will indicate it (e.g. "dpthrng_1.2_to_5m" would show resultant layer-averaged velocities over depths from 1.2 to 5 meters).';...
            '4. NULL or missing data are represented as "-9999".';...
            ...'MeanCrossSection:';...
            ...'1. Data are in vectorized i,j structure, where i is the index into the horizontal, j is index to vertical. Thus, the first j rows correspond to vertical i.';...
            ...'2. Bed elevation is computed as the entered water surface elevation minus depth at each vertical location (if WSE=0, the elevations will be negative).';...
            ...'3. NULL or missing data are represented as "-9999".';...
            'Smoothed_Planview:';...
            '1. Units are indicated in the column titles.';...
            '2. Data are the actual vectors shown in the Planview plot, and reflect any user specified smoothing and/or spacings.';...
            '3. Values are for layer-avg quanties. Thus "dpthrng_0_to_Infm" would represent layer-averaging over the entire depth.';...
            '4. If the user specifies a depth range, the column title will indicate it (e.g. "dpthrng_1.2_to_5m" would show resultant layer-averaged velocities over depths from 1.2 to 5 meters).';...
            '5. NULL or missing data are represented as "-9999".';...
            ...'Smoothed_MeanCrossSection:';...
            ...'1. Units are indicated in the column titles.';...
            ...'2. Data are the actual vectors shown in the Mean Cross Section plot, and reflect any user specified smoothing and/or spacings.';...
            ...'3. NULL or missing data are represented as "-9999".';...
            'Further Notes:';...
            '1. Timestamp values represent the average time over which the data are sampled. In the case of the Planview ';...
            '   and MeanCrossSection worksheets, timestamps are the average based on the nearest ensembles (from the ADCP)';...
            '   mapped to each grid node. For smoothed outputs, the timestamps are the average time over the smoothing window.';...
            '   Thus if the smoothing window is 2, the time is the average of the 2 grid nodes on either side (5 nodes) of the';...
            '   center of the smoothing window.';...
            '2. Secondary flow definitions: ZSD = Zero Secondary Discharge definition; ROZ = Rozovsky definition.';...
            '3. Other definitions: DAV = depth=-averaged velocity; WGS84 = World Geodetic System of 1984; dpthrng = depth range; Inf = infinity; m = meters; cm/s or cms = centimeters per second; deg. = degrees.'};
        i=i+1;
        sout{i} = {V.version V.release};
        i=i+1;
        sout{i} = {V.plotSettings.shiptracks.horizontal_grid_node_spacing;...
            V.plotSettings.shiptracks.vertical_grid_node_spacing};
        i=i+1;
        sout{i} = {num2str(V.plotSettings.planview.vector_spacing_plan_view*V.plotSettings.shiptracks.horizontal_grid_node_spacing);...
            num2str(2*V.plotSettings.planview.smoothing_window_size*V.plotSettings.shiptracks.horizontal_grid_node_spacing)};
        i=i+1;
        sout{i} = {datestr(now)};
        % Writing title last (in A1) sets the active cell to that
        % location.
        i=i+1;
        sout{i} = {'VMT SUMMARY OF OUTPUT: MULTIPLE CROSS-SECTIONS'};
        sheetNames = horzcat(sheetNames, repmat(workingSheet,1,i-j));
        waitbar(5/7,hwait)
        
        % Write the Excel Files Sheet
        % -----
        % Using one call to the ActiveX Server is faster than calling
        % multiple times.
        fileNames = repmat({fullfile(excel_path,excel_file)},1,i);
        topLeft = workingTopLeft;
        propStruct = workingPropStruct;
        
        waitbar(6/7,hwait,'Writing the Excel file, please be patient...')
        fileNamesNew = Excel_Write_Format(fileNames,sout,topLeft,sheetNames,propStruct);
        waitbar(1,hwait)
        
        % Delete "Sheet1" from the excel file
        % -----
        objExcel = actxserver('Excel.Application');
        objExcel.Workbooks.Open(fullfile(excel_path,excel_file));
        try
            objExcel.ActiveWorkbook.Worksheets.Item('Sheet1').Delete;
        catch % Do nothing
        end
        % Save, close and clean up.
        objExcel.ActiveWorkbook.Save;
        objExcel.ActiveWorkbook.Close;
        objExcel.Quit;
        objExcel.delete;
        
        % Open the Workbook to view outside Matlab/VMT
        U = unique(fileNamesNew);
        for n = 1:length(U)
            winopen(U{n})
        end
            
    case 'Single'
        % Single Cross Section Loaded
        % -----
        hwait = waitbar(0,'Exporting Excel File...');
        log_text = {'Writing data to Excel file...'};
        ID = PVdata.outfile;         % File name for for each data point in the
        
        % Misc. Computations
        % Get the streamwise direction from true north to report in the
        % excel file (depends on start bank)
        switch V.startBank
            case 'right_bank'
                strmwise = V.phi - 180;
                if strmwise < 0
                    strmwise = 360 + strmwise;
                end
                vsgn = 1;
            otherwise % 'left_bank' or 'auto'
                strmwise = V.phi;
                vsgn = -1;
        end
        % Compute the ZSD positive secondary flow direction
        poszsdvs = V.phisp - 90;
        if poszsdvs < 0
            poszsdvs = 360 + poszsdvs;
        end
        for zi=1:z;
            mintime(zi) = nanmin(A(zi).Comp.enstime);
            maxtime(zi) = nanmin(A(zi).Comp.enstime);
        end
        
        % Load AxtiveX Heading Styles
        H = ActiveXHeadings();
        
        % Construct the Smoothed_MeanCrossSection Sheet
        % -----
        % Save the actual MCS plot data, which includes the smoothed
        % results
        % Distance is from the LEFT bank
        % Doesn't include the reference vector
        workingSheet = {'Smoothed_MeanCrossSection'};
        workingTopLeft = {'A2' 'B2' 'A1'};
        workingPropStruct = {H.d1,H.n2,H.h3};
        compstr = [V.plotSettings.mcs.contour '_' V.plotSettings.mcs.secondary_flow_vector_variable];
        dist    = V.plotSettings.mcs.mcsQuivers(1:end-1,1);
        depth   = V.plotSettings.mcs.mcsQuivers(1:end-1,2);
        vcomp   = vsgn*V.plotSettings.mcs.mcsQuivers(1:end-1,3)/V.plotSettings.mcs.vector_scale_cross_section; %Must remove scale factor and correct sign for XS flipping
        switch V.plotSettings.planview.plotref
            case 'dfs'
                wcomp   = V.plotSettings.mcs.mcsQuivers(1:end-1,4)/...
                    (-V.plotSettings.mcs.vector_scale_cross_section/...
                    V.plotSettings.mcs.vertical_exaggeration); %Must remove scale factor and exaggeration and reverse sign (all done in plotting)
            case 'hab'
                wcomp   = V.plotSettings.mcs.mcsQuivers(1:end-1,4)/...
                    (V.plotSettings.mcs.vector_scale_cross_section/...
                    V.plotSettings.mcs.vertical_exaggeration); %Must remove scale factor and exaggeration
        end
        
        % Compute an UTM coordinate for the vector
        pUTMx = interp1(V.mcsDist(1,:),V.mcsX(1,:),dist);
        pUTMy = interp1(V.mcsDist(1,:),V.mcsY(1,:),dist);
        
        % Compute a Time for each vector
        pTime = interp1(V.mcsDist(1,:),V.mcsTime(1,:),dist);
        
        % Compute the streamwise component at each vector in the MCS plot
        switch V.plotSettings.mcs.contour
            case 'streamwise'   %Plots the streamwise velocity
                wtp=['V.uSmooth'];
            case 'transverse'  %Plots the transverse velocity
                wtp=['V.vSmooth'];
            case 'vertical'  %Plots the vertical velocity
                wtp=['V.wSmooth'];
            case 'mag'  %Plots the velocity magnitude
                wtp=['V.mcsMagSmooth'];
            case 'east'  %Plots the east velocity
                wtp=['V.mcsEastSmooth'];
            case 'error'  %Plots the error velocity
                wtp=['V.mcsErrorSmooth'];
            case 'north'  %Plots the north velocity
                wtp=['V.mcsNorthSmooth'];
            case 'primary_zsd'   %Plots the primary velocity with zero secondary discharge definition
                wtp=['V.vpSmooth'];
            case 'secondary_zsd'  %Plots the secondary velocity with zero secondary discharge definition
                wtp=['V.vsSmooth'];
            case 'primary_roz'   %Plots the primary velocity with Rozovskii definition
                wtp=['V.Roz.upSmooth'];
            case 'secondary_roz'  %Plots the secondary velocity with Rozovskii definition
                wtp=['V.Roz.usSmooth'];
            case 'primary_roz_x'   %Plots the primary velocity with Rozovskii definition (downstream component)
                wtp=['V.Roz.upxSmooth'];
            case 'primary_roz_y'   %Plots the primary velocity with Rozovskii definition (cross-stream component)
                wtp=['V.Roz.upySmooth'];
            case 'secondary_roz_x'  %Plots the secondary velocity with Rozovskii definition (downstream component)
                wtp=['V.Roz.usxSmooth'];
            case 'secondary_roz_y'  %Plots the secondary velocity with Rozovskii definition (cross-stream component)
                wtp=['V.Roz.usySmooth'];
            case 'backscatter'  %Plots the backscatter
                wtp=['V.mcsBackSmooth'];
            case 'flowangle'  %Plots the flow direction (N = 0.0 deg)
                wtp=['V.mcsDirSmooth'];
            case 'vorticity_vw'
                wtp=['V.vorticity_vw'];
            case 'vorticity_zsd'
                wtp=['V.vorticity_zsd'];
            case 'vorticity_roz'
                wtp=['V.vorticity_roz'];
        end
        Ucomp = eval(wtp);
        ucomp = interp2(V.mcsDist,V.mcsDepth,Ucomp,dist,depth);
        
        % This includes the smoothed data results from the plots.
        % This is for EACH VECTOR on the MCS plot
        u_str = regexprep(lower(V.plotSettings.mcs.contour),'(\<[a-z])','${upper($1)}');
        v_str = regexprep(lower(V.plotSettings.mcs.secondary_flow_vector_variable),'(\<[a-z])','${upper($1)}');
        mcsheaders = {...
            'Timestamp'...
            'UTM Easting (WGS84), in meters'...
            'UTM Northing (WGS84), in meters'...
            'Depth from surface, in meters'...
            'Distance from left bank, in meters'...
            ...'Bed Elevation, in meters'...
            [u_str ' Velocity, in cm/s']...
            [v_str ' Velocity, in cm/s']...
            'Vertical Velocity, in cm/s'...
            };
        mcsdata = [...
            pUTMx(:)...
            pUTMy(:)...
            depth(:)...
            dist(:)...
            ucomp(:)...
            vcomp(:)...
            wcomp(:)];
        % Keep only data where there is a full 3D vector (u,v,w)
        ridx = ~isnan(ucomp);
        mcsdata = mcsdata(ridx,:);
        mcsdata(isnan(mcsdata)) = -9999;
        timestamp = cellstr(nandatestr(pTime(ridx)));
        %mcsout = vertcat(mcsheaders,horzcat(cellstr(nandatestr(pTime(ridx))), num2cell(mcsdata)));
        i=1;
        j=1;
        sout{i} = timestamp;
        i=i+1;
        sout{i} = mcsdata;
        i=i+1;
        sout{i} = mcsheaders(1,:);
        sheetNames = repmat(workingSheet,1,i);
        waitbar(1/7,hwait)
        
        % Construct the Smoothed_Planview Sheet
        % -----
        % Save the actual Planview plot data, which includes the smoothed
        % results
        workingSheet = {'Smoothed_Planview'};
        workingTopLeft = horzcat(workingTopLeft,...
            {'A2' 'B2' 'A1'});
        workingPropStruct = horzcat(workingPropStruct,...
            {H.d1,H.n2,H.h3});
        % Compute distance from the LEFT bank using the MCS endpoints
        PVDist = hypot(V.xLeftBank-PVdata.outmat(1,:),V.yLeftBank-PVdata.outmat(2,:));
        vmin = num2str(V.plotSettings.planview.depth_range_min);
        vmax = num2str(V.plotSettings.planview.depth_range_max);
        PVheaders = {...
            'Timestamp'...
            'UTM Easting (WGS84), in meters'...
            'UTM Northing (WGS84), in meters'...
            'Distance, in meters'...
            ['EastDAV_cms_dpthrng_' vmin '_to_' vmax 'm']...
            ['NorthDAV_cms_dpthrng_' vmin '_to_' vmax 'm']...
            'Velocity magnitude, in cm/s'...
            'Velocity direction, in deg. from true north'};
        PVtable = [...
            PVdata.outmat(1,:);...
            PVdata.outmat(2,:);...
            PVDist;...
            PVdata.outmat(4,:).*100;...
            PVdata.outmat(5,:).*100;...
            sqrt(PVdata.outmat(4,:).^2 + PVdata.outmat(5,:).^2).*100;...
            ari2geodeg(atan2(PVdata.outmat(5,:), PVdata.outmat(4,:))*180/pi)];
        PVtable = (sortrows(PVtable',3))';
        PVtable(isnan(PVtable)) = -9999;
        PVtable = PVtable';
        timestamp = cellstr(nandatestr(PVdata.outmat(6,:)'));
        %PVout = horzcat(cellstr(nandatestr(PVdata.outmat(6,:)')), num2cell(PVtable'));
        %PVout = vertcat(PVheaders,PVout);
        j = i;
        i=i+1;
        sout{i} = timestamp;
        i=i+1;
        sout{i} = PVtable;
        i=i+1;
        sout{i} = PVheaders(1,:);
        sheetNames = horzcat(sheetNames, repmat(workingSheet,1,i-j));
        waitbar(2/7,hwait)
        
        % Construct the MeanCrossSection Sheet
        % -----
        % This does not include the smoothed data results from the plots.
        % This is for EACH grid node specified by hgns/vgns
        workingSheet = {'MeanCrossSection'};
        workingTopLeft = horzcat(workingTopLeft,...
            {'A2' 'B2' 'A1'});
        workingPropStruct = horzcat(workingPropStruct,...
            {H.d1,H.n2,H.h3});
        MCSheaders = {...
            'Timestamp'...
            'UTM Easting (WGS84), in meters' ...
            'UTM Northing (WGS84), in meters'...
            'Depth from surface, in meters'...
            'Distance from Left Bank, in meters'...
            'Bed Elevation, in meters'...
            ...'Bed Elevation, in meters'...
            'East Velocity, in cm/s'...
            'North Velocity, in cm/s'...
            'Vertical Velocity, in cm/s'...
            'Velocity Magnitude, in cm/s'...
            'Velocity Direction, in degrees from true north'...
            'Streamwise Velocity, in cm/s'...
            'Transverse Velocity, in cm/s'...
            'Primary Velocity (ZSD), in cm/s'...
            'Secondary Velocity (ZSD), in cm/s'...
            'Primary Velocity (ROZ, downstream comp.), in cm/s'...
            'Secondary Velocity (ROZ, cross-stream comp.), in cm/s'};
        
        vectorized_bed = meshgrid(V.mcsBedElev,V.mcsDepth(:,1));
        MCSdata = [...
            V.mcsX(:)...
            V.mcsY(:)...
            V.mcsDepth(:)...
            V.mcsDist(:)...
            vectorized_bed(:)...
            ...(str2num(wse) - V.mcsDepth(:))...
            ...repmat((wse - V.mcsBed(:)),size(V.mcsX,1),1)...
            V.mcsEast(:)...
            V.mcsNorth(:)...
            V.mcsVert(:)...
            V.mcsMag(:)...
            V.mcsDir(:)...
            V.u(:)...
            V.v(:)...
            V.vp(:)...
            V.vs(:)...
            V.Roz.upx(:)...
            V.Roz.usy(:)];
        MCSdata(isnan(MCSdata)) = -9999;
        timestamp = cellstr(nandatestr(V.mcsTime(:)));
        j = i;
        i=i+1;
        sout{i} = timestamp;
        i=i+1;
        sout{i} = MCSdata;
        i=i+1;
        sout{i} = MCSheaders(1,:);
        sheetNames = horzcat(sheetNames, repmat(workingSheet,1,i-j));
        waitbar(3/7,hwait)
        
        % Construct the Planview Sheet data
        % -----
        workingSheet = {'Planview'};
        workingTopLeft = horzcat(workingTopLeft,...
            {'A2' 'B2' 'A1'});
        workingPropStruct = horzcat(workingPropStruct,...
            {H.d1,H.n2,H.h3});
        
        vmin = num2str(V.plotSettings.planview.depth_range_min);
        vmax = num2str(V.plotSettings.planview.depth_range_max);
        pvheaders = {...
            'Timestamp'...
            ...'FileName'...
            'UTM Easting (WGS84), in meters' 'UTM Northing (WGS84), in meters' 'Distance, in meters' 'Bed Elevation, in meters'...
            ['EastDAV_cms_dpthrng_' vmin '_to_' vmax 'm']...
            ['NorthDAV_cms_dpthrng_' vmin '_to_' vmax 'm']...
            'Velocity magnitude, in cm/s' 'Velocity direction, in deg. from true north'};
        
        % Create block style matrix of all processed data
        % This does not include the smoothed data results from the plots.
        % This is for EACH grid node specified by hgns/vgns, with the
        % layer-averaging applied
        pvdata = [];
        
        % Stationing from LEFT bank
        Dist = V.mcsDist;
        
        % Build bathy data matrix
        pvdata = [V.mcsX(1,:); V.mcsY(1,:); Dist(1,:); V.mcsBedElev];
        
        % Build layer-averaged velocities
        indx = find(V.mcsDepth(:,1) < str2num(vmin) | V.mcsDepth(:,1) > str2num(vmax));
        V.mcsX(indx,:) = nan;
        V.mcsY(indx,:) = nan;
        V.mcsEast(indx,:) = nan;
        V.mcsNorth(indx,:) = nan;
        pvdata = [...
            pvdata;...
            VMT_LayerAveMean(V.mcsDepth,V.mcsEast);...
            VMT_LayerAveMean(V.mcsDepth,V.mcsNorth);...
            sqrt(VMT_LayerAveMean(V.mcsDepth,V.mcsEast).^2 + VMT_LayerAveMean(V.mcsDepth,V.mcsNorth).^2);...
            ari2geodeg(atan2(VMT_LayerAveMean(V.mcsDepth,V.mcsNorth), VMT_LayerAveMean(V.mcsDepth,V.mcsEast))*180/pi)];
        pvdata(isnan(pvdata)) = -9999;
        timestr = nandatestr(V.mcsTime(1,:));
        timestamp = cellstr(timestr);
        j = i;
        i=i+1;
        sout{i} = timestamp;
        i=i+1;
        sout{i} = pvdata';
        i=i+1;
        sout{i} = pvheaders(1,:);
        sheetNames = horzcat(sheetNames, repmat(workingSheet,1,i-j));
        waitbar(4/7,hwait)
        
        % Construct VMTSummary Sheet Data
        % -----
        workingSheet = {'VMTSummary'};
        workingTopLeft = horzcat(workingTopLeft,...
            {'A2' 'A5' 'E3' 'F3' 'A6' 'A21' 'A22' 'A31' 'A32' 'A43' 'A44',... Headers
            'B2' 'B6' 'B9' 'B13' 'B16' 'B23' 'B32' 'B3' 'A1'});
        workingPropStruct = horzcat(workingPropStruct,...
            {H.t1,H.h2,H.t2,H.t1,H.t1,H.h2,H.t1,H.h2,H.t1,H.h2,H.t1,...
            H.d1 H.n2 H.d1 H.n2 H.n2 H.n2 H.n2,H.d1,H.h1});
        
        j = i;
        i=i+1;
        sout{i} = {'VMT version: ';'Date Processed: '};
        i=i+1;
        sout{i} = {'MEAN CROSS SECTION (MCS) PROPERTIES'};
        i=i+1;
        sout{i} = {'Path:'; 'Files:'};
        i=i+1;
        sout{i} = vertcat(dataPath,dataFiles);
        i=i+1;
        sout{i} = {'Horz. Grid Node Spacing (m):';...
            'Vert. Grid Node Spacing (m):';...
            'Water Surface Elevation (m):';...
            'Time of first velocity sample:';...
            'Time of last velocity sample:';...
            'Time of first velocity grid node:';...
            'Time of last velocity grid node:';...
            'Slope:';...
            'Intercept:';...
            'Theta (mean XS orientation, in deg. from true north):';...
            'MCS Endpoints:';...
            'Left Bank:';...
            'Right Bank:';...
            'Total Length in meters:'};
        i=i+1;
        sout{i} = {'SMOOTHED (SPATIALLY-AVERAGED) DATA PROPERTIES'};
        i=i+1;
        sout{i} = {'Smoothed Planview:';...
            'Vector Spacing, in ground distance (m):';...
            'Vector Smoothing, in ground distance (m):';...
            'Smoothed Mean Cross Section:';...
            'Horizontal Vector Spacing, in ground distance (m):';...
            'Horizontal Vector Smoothing, in ground distance (m):';...
            'Vertical Vector Spacing, in ground distance (m):';...
            'Vertical Vector Smoothing, in ground distance (m):'};
        i=i+1;
        sout{i} = {'FLOW ORIENTATION'};
        i=i+1;
        sout{i} = {'Mean Flow Direction (deg. from true north):';...
            'Positive Streamwise Flow Direction (Normal to mean XS; deg. from true north):';...
            'Positive Transverse Flow Direction (Parallel to mean XS; deg. from true north):';...
            'Positive Primary Flow Direction (ZSD; deg. from true north):';...
            'Positive Secondary Flow Direction (ZSD; deg. from true north):';...
            'Positive Primary Flow Direction (ROZ, downstream component; deg. from true north):';...
            'Positive Secondary Flow Direction (ROZ, cross-stream component; deg. from true north):';...
            'Positive Vertical Velocity is up or towards the water surface';...
            'NOTE: Primary and secondary flow computations are defined for rivers. These computations are unreliable when applied to lakes and similar water bodies.'};
        i=i+1;
        sout{i} = {'DATA STRUCTURE'};
        i=i+1;
        sout{i} = {'1. These data are the computed output from The Velocity Mapping Toolbox (VMT).';...
            '2. VMT maps the loaded ADCP data to a mean cross-section (MCS), typically a line of best fit to the ADCP positions.';...
            '3. The ADCP data are then interpolated to a user specified grid (see Cells F6:F7).';...
            '4. VMT then averages the mapped and interpolated data to the MCS grid.';...
            '5. For more information, see the VMT homepage: ';...
            '=HYPERLINK("http://hydroacoustics.usgs.gov/movingboat/VMT/VMT.shtml")';...
            'Planview:';...
            '1. Units are indicated in the column titles.';...
            '2. Values are for layer-avg quanties. Thus "dpthrng_0_to_Infm" would represent layer-averaging over the entire depth.';...
            '3. If the user specifies a depth range, the column title will indicate it (e.g. "dpthrng_1.2_to_5m" would show resultant layer-averaged velocities over depths from 1.2 to 5 meters).';...
            '4. NULL or missing data are represented as "-9999".';...
            'MeanCrossSection:';...
            '1. Data are in vectorized i,j structure, where i is the index into the horizontal, j is index to vertical. Thus, the first j rows correspond to vertical i.';...
            '2. Bed elevation is computed as the entered water surface elevation minus depth at each vertical location (if WSE=0, the elevations will be negative).';...
            '3. NULL or missing data are represented as "-9999".';...
            'Smoothed_Planview:';...
            '1. Units are indicated in the column titles.';...
            '2. Data are the actual vectors shown in the Planview plot, and reflect any user specified smoothing and/or spacings.';...
            '3. Values are for layer-avg quanties. Thus "dpthrng_0_to_Infm" would represent layer-averaging over the entire depth.';...
            '4. If the user specifies a depth range, the column title will indicate it (e.g. "dpthrng_1.2_to_5m" would show resultant layer-averaged velocities over depths from 1.2 to 5 meters).';...
            '5. NULL or missing data are represented as "-9999".';...
            'Smoothed_MeanCrossSection:';...
            '1. Units are indicated in the column titles.';...
            '2. Data are the actual vectors shown in the Mean Cross Section plot, and reflect any user specified smoothing and/or spacings.';...
            '3. NULL or missing data are represented as "-9999".';...
            'Further Notes:';...
            '1. Timestamp values represent the average time over which the data are sampled. In the case of the Planview ';...
            '   and MeanCrossSection worksheets, timestamps are the average based on the nearest ensembles (from the ADCP)';...
            '   mapped to each grid node. For smoothed outputs, the timestamps are the average time over the smoothing window.';...
            '   Thus if the smoothing window is 2, the time is the average of the 2 grid nodes on either side (5 nodes) of the';...
            '   center of the smoothing window.';...
            '2. Secondary flow definitions: ZSD = Zero Secondary Discharge definition; ROZ = Rozovsky definition.';...
            '3. Other definitions: DAV = depth=-averaged velocity; WGS84 = World Geodetic System of 1984; dpthrng = depth range; Inf = infinity; m = meters; cm/s or cms = centimeters per second; deg. = degrees.'};
        i=i+1;
        sout{i} = {V.version V.release};
        i=i+1;
        sout{i} = {V.plotSettings.shiptracks.horizontal_grid_node_spacing;...
            V.plotSettings.shiptracks.vertical_grid_node_spacing;...
            {A(1).wse}};
        i=i+1;
        sout{i} = {datestr(nanmin(mintime));...
            datestr(nanmax(maxtime));...
            datestr(nanmin(V.mcsTime(:)));...
            datestr(nanmax(V.mcsTime(:)))};
        i=i+1;
        sout{i} = {V.m; V.b; V.theta};
        i=i+1;
        sout{i} = {'UTM Easting (WGS84), in meters'	'UTM Northing (WGS84), in meters';...
            V.xLeftBank V.yLeftBank;...
            V.xRightBank V.yRightBank;...
            '' V.dl};
        i=i+1;
        sout{i} = {num2str(V.plotSettings.planview.vector_spacing_plan_view*V.plotSettings.shiptracks.horizontal_grid_node_spacing);...
            num2str(2*V.plotSettings.planview.smoothing_window_size*V.plotSettings.shiptracks.horizontal_grid_node_spacing);...
            '';...
            num2str(V.plotSettings.mcs.horizontal_vector_spacing*V.plotSettings.shiptracks.horizontal_grid_node_spacing);...
            num2str(2*V.plotSettings.mcs.horizontal_smoothing_window*V.plotSettings.shiptracks.horizontal_grid_node_spacing);...
            num2str(V.plotSettings.mcs.vertical_vector_spacing*V.plotSettings.shiptracks.vertical_grid_node_spacing);...
            num2str(2*V.plotSettings.mcs.vertical_smoothing_window*V.plotSettings.shiptracks.vertical_grid_node_spacing)};
        i=i+1;
        sout{i} = {num2str(V.mfd);...
            num2str(V.phi);...
            num2str(V.theta);...
            num2str(V.phisp);...
            num2str(poszsdvs);...
            num2str(V.phi);...
            num2str(V.theta)};
        i=i+1;
        sout{i} = {datestr(now)};
        % Writing title last (in A1) sets the active cell to that
        % location.
        i=i+1;
        sout{i} = {'VMT SUMMARY OF OUTPUT: SINGLE CROSS-SECTION'};
        sheetNames = horzcat(sheetNames, repmat(workingSheet,1,i-j));
        waitbar(5/7,hwait)
        
        % Write the Excel Files Sheet
        % -----
        % Using one call to the ActiveX Server is faster than calling
        % multiple times.
        fileNames = repmat({fullfile(excel_path,excel_file)},1,i);
        topLeft = workingTopLeft;
        propStruct = workingPropStruct;
        
        waitbar(6/7,hwait,'Writing the Excel file, please be patient...')
        fileNamesNew = Excel_Write_Format(fileNames,sout,topLeft,sheetNames,propStruct);
        waitbar(1,hwait)
        
        % Delete "Sheet1" from the excel file
        % -----
        objExcel = actxserver('Excel.Application');
        objExcel.Workbooks.Open(fullfile(excel_path,excel_file));
        try
            objExcel.ActiveWorkbook.Worksheets.Item('Sheet1').Delete;
        catch % Do nothing
        end
        % Save, close and clean up.
        objExcel.ActiveWorkbook.Save;
        objExcel.ActiveWorkbook.Close;
        objExcel.Quit;
        objExcel.delete;
        
        % Open the Workbook to view outside Matlab/VMT
        U = unique(fileNamesNew);
        for n = 1:length(U)
            winopen(U{n})
        end
        
        %         else
        %             % Return default excel_path and excel_file
        %             excel_path = guiprefs.excel_path;
        %             excel_file = guiprefs.excel_file;
        %             outfile = fullfile(excel_path,excel_file);
        %             log_text = {'User aborted Excel export...'};
        %         end
        
    otherwise
end
log_text = vertcat(log_text,{'Excel output complete.'});...
    delete(hwait)

function H = ActiveXHeadings()
% Create ActiveX Property Structures for formatting Excel documents
% All heading types are sub-structs of H, and can be passed to
% Excel_Write_Format.

% Property Types

% Heading 1
H.h1.Font.Bold = 0;
H.h1.Font.Color = RGB_2_BGR_Hex([0.05 0.35 0.7]); %note RGB_2_BGR_HEX call
H.h1.Font.Name = 'Arial Black';
H.h1.Font.Size = 14;
H.h1.Range.ColumnWidth = 83;
H.h1.Range.RowHeight = 20;
H.h1.Range.HorizontalAlignment = 'Left';
H.h1.Range.VerticalAlignment = 'Center';

% Heading 2
H.h2.Font.Bold = 1;
H.h2.Font.Color = RGB_2_BGR_Hex([0 0 0]); %note RGB_2_BGR_HEX call
H.h2.Font.Name = 'Arial';
H.h2.Font.Size = 12;
H.h2.Range.ColumnWidth = 83;
H.h2.Range.RowHeight = 15;
H.h2.Range.HorizontalAlignment = 'Left';
H.h2.Range.VerticalAlignment = 'Distributed';

% Heading 3
H.h3.Font.Bold = 1;
H.h3.Font.Color = RGB_2_BGR_Hex([0 0 0]); %note RGB_2_BGR_HEX call
H.h3.Font.Name = 'Arial';
H.h3.Font.Size = 12;
H.h3.Range.WrapText = 1;
H.h3.Range.ColumnWidth = 20;
%H.h3.Range.RowHeight = 15;
H.h3.Range.HorizontalAlignment = 'Left';
H.h3.Range.VerticalAlignment = 'Top';

% Body Text 1 (wide column)
H.t1.Font.Bold = 0;
H.t1.Font.Color = RGB_2_BGR_Hex([0 0 0]); %note RGB_2_BGR_HEX call
H.t1.Font.Name = 'Calibri';
H.t1.Font.Size = 11;
H.t1.Range.ColumnWidth = 83;
H.t1.Range.RowHeight = 15;
H.t1.Range.HorizontalAlignment = 'Left';

% Body Text 2 (narrow column)
H.t2.Font.Bold = 0;
H.t2.Font.Color = RGB_2_BGR_Hex([0 0 0]); %note RGB_2_BGR_HEX call
H.t2.Font.Name = 'Calibri';
H.t2.Font.Size = 11;
H.t2.Range.ColumnWidth = 10;
H.t2.Range.RowHeight = 15;
H.t2.Range.HorizontalAlignment = 'Left';

% Date and Time
H.d1.Font.Bold = 0;
H.d1.Font.Color = RGB_2_BGR_Hex([0 0 0]); %note RGB_2_BGR_HEX call
H.d1.Font.Name = 'Calibri';
H.d1.Font.Size = 11;
H.d1.Range.ColumnWidth = 31;
H.d1.Range.RowHeight = 15;
H.d1.Range.HorizontalAlignment = 'Right';
H.d1.Range.NumberFormat = 'mm/dd/yyyy h:mm:ss';

% Number 1 (rounded to nearest whole number)
H.n1.Font.Bold = 0;
H.n1.Font.Color = RGB_2_BGR_Hex([0 0 0]); %note RGB_2_BGR_HEX call
H.n1.Font.Name = 'Calibri';
H.n1.Font.Size = 11;
H.n1.Range.ColumnWidth = 31;
H.n1.Range.RowHeight = 15;
H.n1.Range.HorizontalAlignment = 'Right';
H.n1.Range.NumberFormat = '0';

% Number 2 (Rounded to nearest tenth)
H.n2.Font.Bold = 0;
H.n2.Font.Color = RGB_2_BGR_Hex([0 0 0]); %note RGB_2_BGR_HEX call
H.n2.Font.Name = 'Calibri';
H.n2.Font.Size = 11;
H.n2.Range.ColumnWidth = 31;
H.n2.Range.RowHeight = 15;
H.n2.Range.HorizontalAlignment = 'Right';
H.n2.Range.NumberFormat = '0.0';