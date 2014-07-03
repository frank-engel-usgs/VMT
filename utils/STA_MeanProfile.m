function sta = STA_MeanProfile(fitProf,units)
% Compute the mean priole from stationary measurements at a point.
% Currently assumes units are metric.

% P.R. Jackson 10.12.10

%% Read and Process the Data

% Determine Files to Process
% Prompt user for directory containing files
zPathName = uigetdir('','Select the Directory Containing ASCII Output Data Files (*.txt)');
Files = dir(zPathName);
allFiles = {Files.name};
filefind=strfind(allFiles,'ASC.TXT')';
filesidx=nan(size(filefind,1),1);
for i=1:size(filefind,1)
    filesidx(i,1)=size(filefind{i},1);
end
filesidx=find(filesidx>0);
files=allFiles(filesidx);

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
        
    %Compute the mean profile
    sta.depth = nanmean(nanmean(A.Nav.depth,2)); %Mean Depth
    sta.vmag  = nanmean(A.Wat.vMag,2)./100;
    indx = find(~isnan(sta.vmag));
    sta.vmag = sta.vmag(indx);
    sta.binDepth = nanmean(A.Wat.binDepth,2);
    sta.binDepth = sta.binDepth(indx);
    
    % Orient with origin at the bed
    sta.z = sta.depth - sta.binDepth;
    
    switch units
        case{'metric'}
            figure(1); hold on; subplot(ceil(z/3),3,zi)
            plot(sta.vmag,sta.z,'ko','MarkerFaceColor','k')
            xlabel('Velocity (m/s)')
            ylabel('Height above bottom (m)')
            ylim([0 ceil(sta.depth)])
        case{'english'}
            sta.depth = sta.depth*3.281;
            sta.vmag = sta.vmag*3.281;
            sta.binDepth = sta.binDepth*3.281;
            sta.z = sta.z*3.281;
            figure(1); hold on; subplot(ceil(z/3),3,zi)
            plot(sta.vmag,sta.z,'ko','MarkerFaceColor','k')
            xlabel(upper('Velocity, in feet per second'))
            ylabel(upper('Height above bottom, in feet'))
            ylim([0 ceil(sta.depth)])
    end
    

    %Fit the profile
    if fitProf
        % First, fit a log law to get u* and zo

        disp('Log Law Fit')
        disp('     u*      zo      cod   ')
        [ustar,zo,ks,cod,Xpred,zpred,delta] = fitLogLaw(sta.vmag',sta.z');
        sta.ustar(zi) = ustar;
        sta.zo(zi) = zo;
        sta.ks(zi) = ks;
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

        [aii,n,cod,Xpred,zpred,delta] = fitPowerLawFull(sta.vmag'./ustar,sta.z'./zo,1,sta.depth./zo);
        
        

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

        [aii,n,cod,Xpred,zpred,delta] = fitPowerLawFull(sta.vmag'./ustar,sta.z'./zo,0,sta.depth./zo);

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
        
    clear A
    
    % Determine the file name
    idx=strfind(fileName,'.');
    namecut = fileName(1:idx(1)-5);
    
    clear latlon idx namecut 
    
    % Compute the depth average velocity
    sta.dam(zi) = -1*VMT_LayerAveMean(sta.z,sta.vmag);
end

msgbox('Processing Complete','Processing Status','help','replace');


end