function sta = STA_MeanProfileV2(fitProf,units,StrDir)
% Compute the mean profile from stationary measurements at a point.
% Currently assumes incomming units are metric--can convert using the 'units' input.

% fitProf = 1 for log and power law fitting of the profile
% units = 'metric or 'english' (for output plots)

%V2 modifies the original code to use the streamwise component of velocity
%rather than the velocity magnitude. It aslo allows the user to fit only a range of the flow profile.
%P.R. Jackson, 2-10-11

% P.R. Jackson 10.12.10

if nargin < 3
    StrDir = [];
end

%% Read and Process the Data

% Determine Files to Process
% Prompt user for directory containing files
defaultpath = 'C:\';
stapath = [];
if exist('VMT\LastDir.mat') == 2
    load('VMT\LastDir.mat');
    if exist(stapath) == 7
        stapath = uigetdir(stapath,'Select the Directory Containing ASCII Output Data Files (*.txt)');
    else
        stapath = uigetdir(defaultpath,'Select the Directory Containing ASCII Output Data Files (*.txt)');
    end
else
    stapath = uigetdir(defaultpath,'Select the Directory Containing ASCII Output Data Files (*.txt)');
end
zPathName = stapath;
Files = dir(zPathName);
allFiles = {Files.name};
filefind = strfind(allFiles,'ASC.TXT')';
filesidx=nan(size(filefind,1),1);
for i=1:size(filefind,1)
    filesidx(i,1)=size(filefind{i},1);
end
filesidx=find(filesidx>0);
files=allFiles(filesidx);

if isempty(files)
    errordlg(['No ASC.TXT files found in ' stapath '.  Ensure data files are in the form "*_ASC.TXT" (Standard WRII naming convention).']);
end

% Allow user to select which files are to be processed
selection = listdlg('ListSize',[300 300],'ListString', files,'Name','Select Data Files');
zFileName = files(selection);

% Determine number of files to be processed
if  isa(zFileName,'cell')
    z=size(zFileName,2);
    zFileName=sort(zFileName);       
else
    z=1;
    zFileName={zFileName}
end
msgbox('Loading Data...Please Be Patient','Processing Status','help','replace');

% Set the fitting region (new 2-10-11, PRJ)
if fitProf
    choice = questdlg('Do you want to fit the full profile?','Fitting Setup',...
        'Yes','No','Yes');
        switch choice
            case 'Yes'
                fitrng = [0 1]; %z/H (normalized) so z/H = 0 at bed and 1 at surface
            case 'No'
                disp('Enter Normalized (z/H) Fit Range')
                prompt = {'Lower Bound','Upper Bound'};
                dlg_title = 'Fitting Setup';
                num_lines = 1;
                def = {num2str(0),num2str(0.2)};  %Wall region only by default (Nezu and Nakagawa 1993)
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                [ftl, status1] = str2num(answer{1});
                [ftu, status2] = str2num(answer{2});
                fitrng = [ftl ftu];
        end
end

% Read in Selected Files
% Initialize row counter
j=0;
figure(1); clf

% Begin master loop
for zi=1:z
    % Open txt data file
    if  isa(zFileName,'cell')
        fileName=strcat(zPathName,'\',zFileName(zi));
        fileName=char(fileName);
    else
        fileName=strcat(zPathName,zFileName);
    end

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
    [A]=tfile(fileName,screenData,ignoreBS);
    %Extract only Lat lon data
    latlon(:,1)=A.Nav.lat_deg(:,:);
    latlon(:,2)=A.Nav.long_deg(:,:);
    
    switch A.Sup.units(1,:) 
        case{'ft'}
            error('Units must be metric to start')
    end
    
    % Write the data to a file
    msgbox('Processing Data...','Processing Status','help','replace');
    
    %Rescreen data to remove missing data (30000 value)
    indx1 = find(abs(latlon(:,1)) > 90);
    indx2 = find(abs(latlon(:,2)) > 180);
    latlon(indx1,1)=NaN;
    latlon(indx2,2)=NaN;
    
    sta.lat = nanmean(latlon(:,1));
    sta.lon = nanmean(latlon(:,2));
    
    %Compute the median profile using a normalized profile (added 3-20-12,
    %PRJ)
    if 1
        [sta.binDepth,zm,sta.vEast,sta.vNorth,sta.vVert,sta.vmag,sta.obsav,sta.depth] = ComputeNormalizedProfile(nanmean(A.Nav.depth,2)',A.Wat.binDepth,A.Wat.vEast,A.Wat.vNorth,A.Wat.vVert);
        sta.binDepth = sta.binDepth';
        sta.vEast = sta.vEast./100; %convert to m/s from cm/s
        sta.vNorth = sta.vNorth./100; %convert to m/s from cm/s
        sta.vmag = sta.vmag./100; %convert to m/s from cm/s
        sta.vVert = sta.vVert./100; %convert to m/s from cm/s
    end

    %OLD METHOD--Compute the mean profile (magnitude)
    if 0
        sta.depth = nanmean(nanmean(A.Nav.depth,2)); %Mean Depth
        sta.vmag  = nanmean(A.Wat.vMag,2)./100;  %Mean v magnitude in m/s
        indx = find(~isnan(sta.vmag));  
        sta.vmag = sta.vmag(indx); % Use only data with no nans
        sta.binDepth = nanmean(A.Wat.binDepth,2);
        sta.binDepth = sta.binDepth(indx);
    
        %Compute the streamwise component (need Vnorth, Veast to get average
        %Vdir
        sta.vNorth  = nanmean(A.Wat.vNorth,2)./100;  %Mean v north in m/s
        sta.vNorth  = sta.vNorth(indx); % Use only data with no nans
        sta.vEast   = nanmean(A.Wat.vEast,2)./100;  %Mean v east in m/s
        sta.vEast   = sta.vEast(indx); % Use only data with no nans
    end

    % Compute the average direction from mean ve and vn (so i don't have to
    % average directions on a 0-360 scale)
    sta.vDir = 90 - (atan2(sta.vNorth, sta.vEast))*180/pi; %Compute the atan from the velocity componentes, convert to radians, and rotate to north axis
    qindx = find(sta.vDir < 0);
    if ~isempty(qindx)
        sta.vDir(qindx) = sta.vDir(qindx) + 360;  %Must add 360 deg to Quadrant 4 values as they are negative angles from the +y axis
    end
      
    % Define the streamwise direction as the mean flow direction unless
    % provided by user
    if isempty(StrDir)
        sta.mvNorth = nanmean(sta.vNorth);  %Mean vnorth (single value)
        sta.mvEast  = nanmean(sta.vEast);   %Mean veast (single value)
        %Compute the overall mean flow direction
        sta.mvDir = 90 - (atan2(sta.mvNorth, sta.mvEast))*180/pi; %Compute the atan from the velocity components, convert to radians, and rotate to north axis
        
        if sta.mvDir < 0
            sta.mvDir = sta.mvDir + 360;  %Must add 360 deg to Quadrant 4 values as they are negative angles from the +y axis
        end
        sta.Streamwise = sta.mvDir;
        disp(['Using Streamwise Direction of ' num2str(sta.Streamwise) ' degrees from true north'])
    else
        sta.Streamwise = StrDir;
        disp(['Using Streamwise Direction of ' num2str(sta.Streamwise) ' degrees from true north'])
    end
    
    % Determine the deviation of a vector from streamwise velocity
    sta.psi = (sta.vDir-sta.Streamwise);

    % Determine streamwise (U) and transverse (V)
    sta.U = cosd(sta.psi).*sta.vmag;
    sta.V = sind(sta.psi).*sta.vmag;
    
    % Orient with origin at the bed
    sta.z = sta.depth - sta.binDepth;

    switch units
        case{'metric'}
            figure(1); hold on; %subplot(ceil(z/3),3,zi)
            plot(sta.U,sta.z,'ko','MarkerFaceColor','k'); hold on
            xlabel('Velocity (m/s)')
            ylabel('Height above bottom (m)')
            ylim([0 ceil(sta.depth)])
            xlim([0 max(sta.U)+0.1])
            plot([0 max(sta.U)+0.1],[sta.depth sta.depth],'k--')
            text((max(sta.U)+0.1)/2,sta.depth,'Water Surface')
        case{'english'}
            sta.depth = sta.depth*3.281;
            sta.U = sta.U*3.281;
            sta.binDepth = sta.binDepth*3.281;
            sta.z = sta.z*3.281;
            figure(1); hold on; %subplot(ceil(z/3),3,zi)
            plot(sta.U,sta.z,'ko','MarkerFaceColor','k'); hold on
            xlabel(upper('Velocity, in feet per second'))
            ylabel(upper('Height above bottom, in feet'))
            ylim([0 ceil(sta.depth)])
            xlim([0 max(sta.U)+0.1])
            plot([0 max(sta.U)+0.1],[sta.depth sta.depth],'k--')
            text((max(sta.U)+0.1)/2,sta.depth,'Water Surface')
    end
    

    %Fit the profile
    if fitProf
        
        % Determine if any manual editing is necessary
        choice = questdlg('Do you want to manually edit the data?','Data Editor',...
        'Yes','No','No');
        switch choice
            case 'Yes'
                manedit = 1;
            case 'No'
                manedit = 0;
        end
        
        if manedit
            disp('Select profile data points to remove using mouse')
            [sta.U,sel_indx] = DataEditor(sta.U);
        end
        
        % Apply the fitting range
        sta.znorm = sta.z./sta.depth;
        indxfr = find(sta.znorm >= fitrng(1) & sta.znorm <= fitrng(2) & ~isnan(sta.U));
        
        % First, fit a log law to get u* and zo

        disp('Log Law Fit')
        disp('   u*       zo        cod   ')
        %figure(1); clf; plot(sta.U(indxfr),sta.z(indxfr),'ko-'); pause
        [ustar,zo,cod] = fitLogLawV2(sta.U(indxfr),sta.z(indxfr),sta.depth);
        disp([num2str(ustar,3) '   ' num2str(zo,3) '      ' num2str(cod,3)])
        zeval = linspace(0,sta.depth);
        ueval = ustar./0.41.*log(zeval./zo);
        figure(1); hold on; plot(ueval,zeval,'r-')
        %[ustar,zo,ks,cod,Xpred,zpred,delta] = fitLogLaw(sta.U(indxfr)',sta.z(indxfr)');
        sta.ustar(zi) = ustar;
        sta.zo(zi) = zo;
        sta.cod = cod;
        sta.ks(zi) = 30*zo;
        %sta.ks(zi) = ks;
        if 0
            sta.cod(zi) = cod;
            figure(1); hold on; subplot(ceil(z/3),3,zi)
            %plot(X,z,'ko','MarkerFaceColor','k'); hold on
             plot(Xpred,zpred,'r-'); hold on
            % plot(Xpred+delta',zpred,'r:',Xpred-delta',zpred,'r:'); hold on
             %plot([0 1],[sta.depth sta.depth],'k--'); hold on  %Mean flow depth for period
             grid on
             %ylabel('Mean Height Above Bottom (ft)')
             %xlabel('Mean Velocity (ft/s)')
             disp([ustar zo cod])


            % Now, fit with power law (fixed at 1/6)

            disp('Fixed Exponent Power Law Fit')
            disp('     a      n      cod     ChenProd')

            [aii,n,cod,Xpred,zpred,delta] = fitPowerLawFull(sta.U'./ustar,sta.z'./zo,1,sta.depth./zo);



             figure(1); hold on; subplot(ceil(z/3),3,zi)
             % plot(X,z,'bo','MarkerFaceColor','b'); hold on
             plot(Xpred.*ustar,zpred.*zo,'r--'); hold on
             %plot(Xpred+delta,zpred,'r:',Xpred-delta,zpred,'r:'); hold on
             %plot([0 1],[25.00 25.00],'k--'); hold on
             chenprod = aii*n*2.718281828*0.41; %product of a*n*e*kappa(Von Karman cst) == 1 for exact fit with log law
              disp([aii n cod chenprod])
              sta.aii_p1(zi) = aii;
              sta.n_p1(zi) = n;
              sta.cod_p1(zi) = cod;
              sta.cp_p1(zi) = chenprod;

             % Now, fit with power law (variable exponent)

            disp('Variable Exponent Power Law Fit')
            disp('     a      n      cod     ChenProd')

            [aii,n,cod,Xpred,zpred,delta] = fitPowerLawFull(sta.U'./ustar,sta.z'./zo,0,sta.depth./zo);

             figure(1); hold on; subplot(ceil(z/3),3,zi)
             % plot(X,z,'bo','MarkerFaceColor','b'); hold on
             plot(Xpred.*ustar,zpred.*zo,'r:'); hold on
             %plot(Xpred+delta,zpred,'r:',Xpred-delta,zpred,'r:'); hold on
             %plot([0 1],[25.00 25.00],'k--'); hold on
             chenprod = aii*n*2.718281828*0.41; %product of a*n*e*kappa(Von Karman cst) == 1 for exact fit with log law
             disp([aii n cod chenprod])
              sta.aii_p2(zi) = aii;
              sta.n_p2(zi) = n;
              sta.cod_p2(zi) = cod;
              sta.cp_p2(zi) = chenprod;
        end
          
    end
        
    clear A
    
    % Determine the file name
    idx=strfind(fileName,'.');
    namecut = fileName(1:idx(1)-5);
    
    clear latlon idx namecut 
    
    % Compute the depth average velocity (streamwise)
    sta.DAVstws(zi) = VMT_LayerAveMean(sta.z,sta.U);
    
    % Compute the depth average vertical velocity 
    sta.DAVvert(zi) = VMT_LayerAveMean(sta.z,sta.vVert);
    
end

msgbox('Processing Complete','Processing Status','help','replace');


% Save the paths
if exist('LastDir.mat') == 2
    save('LastDir.mat','stapath','-append')
else
    save('LastDir.mat','stapath')
end

end