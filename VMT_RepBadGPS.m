function A = VMT_RepBadGPS(z,A)
% Replaces bad GPS data with bottom track data.
%
% (adapted from code by J. Czuba)
%
% Known bugs--Will result in bad values if GPS and Bottom track are both
% bad.  FIXED-9-8-09 with interpolation of missing bottom track from good
% data (may have issues with lots of missing data).
%
% Added capability to detect fly-away GPS points. Works in most cases, but
% may still miss a few fly-aways. Identified fly-aways are replaced with
% interpolation of bottom track (FLE 12-12-12)
%
% Rearranged the identification of bad values to use logical indexing,
% which is faster, and easier to trace (FLE 12-12-12)
%
% P.R. Jackson, USGS, 12-9-08 
% Last modified: F.L. Engel, USGS 12/12/2012


%% Replace bad GPS with BT

for zi = 1 : z

%ADDED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Check for GPS data
    if  sum(nansum(A(zi).Nav.lat_deg)) == 0
        %Modify to solve GPS problems AGREGUE YO
        A(zi).Comp.xUTMraw=A(zi).Nav.totDistEast;
        A(zi).Comp.yUTMraw=A(zi).Nav.totDistNorth;  
        
        warndlg('No GPS data detected!')
    else
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%     
%     % Prescreen GPS data (Added 4-8-10)
%     % Eliminated uncessary "find" statement FLE 12-12-12
    bad_long    = A(zi).Nav.long_deg < -180 | A(zi).Nav.long_deg > 180;
    bad_lat     = A(zi).Nav.lat_deg < -90 | A(zi).Nav.lat_deg > 90;
    A(zi).Nav.long_deg(bad_long)    = NaN;
    A(zi).Nav.long_deg(bad_lat)     = NaN;
    A(zi).Nav.lat_deg(bad_long)     = NaN;
    A(zi).Nav.lat_deg(bad_lat)      = NaN;

    % Convert lat long into xUTM and yUTM
    [A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,A(zi).Comp.utmzone] = ...
        deg2utm(A(zi).Nav.lat_deg,A(zi).Nav.long_deg);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end

    
    
    %Check if data spans two UTM zones (Added 1-16-09 P.R. Jackson)
    %(requires mapping toolbox)
   % multiple_utm_zones = strmatch(A(zi).Comp.utmzone(:,1), A(zi).Comp.utmzone);
%     if sum(indx) < length(A(zi).Comp.utmzone)
%         disp('Caution:  Data Spans Multiple UTM Zones')  %This is not
%         %working yet (1-16-09)
%     end
    
%     [latlim,lonlim] = utmzone(A(zi).Comp.utmzone(1));
%     latindx = find(A(zi).Nav.lat_deg < latlim(1) | A(zi).Nav.lat_deg > latlim(2));
%     lonindx = find(A(zi).Nav.lon_deg < lonlim(1) | A(zi).Nav.lon_deg > lonlim(2));
%     if ~isempty(latindx) | ~isempty(lonindx)
%         beep
%         disp('Caution:  Data Spans Multiple UTM Zones')
%     end    

    % Check for repeat values of gps position
    chk        = [1; diff(A(zi).Comp.xUTMraw)];
    repeat_gps = chk==0;
    
    % Check for dropped ensembles
    dropped_ensembles = isnan(A(zi).Comp.xUTMraw) | isnan(A(zi).Comp.yUTMraw);
    
    % Check for GPS fly-aways
    % Delta time
    delta_time_elapsed = [0; diff(A(zi).Sup.timeElapsed_sec)];
    
    % The fly away filter will only consider "valid" numbers in the GPS
    % data. First, screen out any NaNs and replace with 0.
    x = A(zi).Comp.xUTMraw; %x(dropped_ensembles) = 0;
    y = A(zi).Comp.yUTMraw; %y(dropped_ensembles) = 0;
    
    % Compute the velocity of the location from start bank to end bank
    dist1   = abs([0; hypot(y(1:end-1) - y(2:end),x(1:end-1) - x(2:end))]);
    vel1    = dist1./delta_time_elapsed;
    
    % Compute the velocity of the location from end bank to start bank
    dist2   = abs([hypot(y(2:end) - y(1:end-1),x(2:end) - x(1:end-1)); 0]);
    vel2    = dist2./delta_time_elapsed;
    
    % Compute a threshold velocity based on the data
    vel_threshold   = 1.5*(nanstd([dist1;dist2]) + nanmedian([dist1;dist2]))./...
        (std(delta_time_elapsed) + median(delta_time_elapsed));
    suspect1        = (dist1>vel_threshold);
    suspect2        = (dist2>vel_threshold);
    
    % Logical index of fly-aways
    %fly_aways       = suspect1 | suspect2;
    fly_aways       = suspect1 & suspect2;
    
    % Create a logical index of TRUE for bad values
    %A(zi).Comp.bv =(isnan(A(zi).Comp.xUTMraw) + (chk==0)) > 0;
    A(zi).Comp.gps_reject_locations = ...
        dropped_ensembles   |...
        repeat_gps          |...
        fly_aways;
    
    A(zi).Comp.gps_fly_aways         = fly_aways;
    A(zi).Comp.gps_dropped_ensembles = dropped_ensembles; 
    A(zi).Comp.gps_repeat_locations  = repeat_gps;    
                
    %Identify and interpolate missing bottom track data  (Added 9-8-09,
    %P.R. Jackson)  Required to stop bad data return when missing GPS and
    %bottom track.
    bvbt_indx                           = find(A(zi).Nav.totDistEast == -32768);
    A(zi).Nav.totDistEast(bvbt_indx)    = NaN;
    A(zi).Nav.totDistENorth(bvbt_indx)  = NaN;
    gvbt_indx                           = ~isnan(A(zi).Nav.totDistEast);
    A(zi).Nav.totDistEast(bvbt_indx)    = interp1(A(zi).Sup.ensNo(gvbt_indx),A(zi).Nav.totDistEast(gvbt_indx),A(zi).Sup.ensNo(bvbt_indx));
    A(zi).Nav.totDistNorth(bvbt_indx)   = interp1(A(zi).Sup.ensNo(gvbt_indx),A(zi).Nav.totDistNorth(gvbt_indx),A(zi).Sup.ensNo(bvbt_indx));

    % If bad values exist replace them with Bottom Track
    if any(A(zi).Comp.gps_reject_locations)

        % Bracket bad sections, identifying the index of corresponding to
        % the first good data point (bg) and last good data point (ed) for
        % each segment
        [I,~]   = ind2sub(size(A(zi).Comp.gps_reject_locations),find(A(zi).Comp.gps_reject_locations==1));
        df      = diff(I);
        nbrk    = sum(df>1)+1;
        [I2,~]  = ind2sub(size(df),find(df>1));
        bg(1)   = (I(1)-1);
        for n = 2 : nbrk
            bg(n) = (I(I2(n-1)+1)-1);
        end
        for n = 1 : nbrk -1
            ed(n) = (I(I2(n))+1);
        end
        ed(nbrk)  = I(end)+1;

        % Now, determine position based on bottom track starting from the
        % beginning and end of bad sections then average them together
        
        % Create a canvas through preallocation
        A(zi).Comp.xUTMf    = NaN(length(A(zi).Comp.xUTMraw),1);
        A(zi).Comp.xUTMb    = NaN(length(A(zi).Comp.xUTMraw),1);
        A(zi).Comp.yUTMf    = NaN(length(A(zi).Comp.yUTMraw),1);
        A(zi).Comp.yUTMb    = NaN(length(A(zi).Comp.yUTMraw),1);
        BG                  = NaN(length(A(zi).Comp.yUTMraw),1);
        ED                  = NaN(length(A(zi).Comp.yUTMraw),1);

        xUTM                = NaN(length(A(zi).Comp.xUTMraw),3);
        yUTM                = NaN(length(A(zi).Comp.yUTMraw),3);

        % Screen bad locations out
        A(zi).Comp.xUTM     = A(zi).Comp.xUTMraw;
        A(zi).Comp.yUTM     = A(zi).Comp.yUTMraw;
        A(zi).Comp.xUTM(A(zi).Comp.gps_reject_locations)   = NaN;
        A(zi).Comp.yUTM(A(zi).Comp.gps_reject_locations)   = NaN;

        for i = 1 : nbrk
            for j = bg(i)+1 : ed(i)-1
                if bg(i) > 0
                    A(zi).Comp.xUTMf(j,1)               =...
                        A(zi).Comp.xUTMraw(bg(i),1)     -...
                        A(zi).Nav.totDistEast(bg(i),1)  +...
                        A(zi).Nav.totDistEast(j,1);
                    A(zi).Comp.yUTMf(j,1)               =...
                        A(zi).Comp.yUTMraw(bg(i),1)     -...
                        A(zi).Nav.totDistNorth(bg(i),1) +...
                        A(zi).Nav.totDistNorth(j,1);
                    ED(j,1)=((j-bg(i))./(ed(i)-bg(i)));
                    BG(j,1)=((ed(i)-j)./(ed(i)-bg(i)));
                end
                if ed(i) < length(A(zi).Nav.lat_deg)
                    A(zi).Comp.xUTMb(j,1)               =...
                        A(zi).Comp.xUTMraw(ed(i),1)     -...
                        A(zi).Nav.totDistEast(ed(i),1)  +...
                        A(zi).Nav.totDistEast(j,1);
                    A(zi).Comp.yUTMb(j,1)               =...
                        A(zi).Comp.yUTMraw(ed(i),1)     -...
                        A(zi).Nav.totDistNorth(ed(i),1) +...
                        A(zi).Nav.totDistNorth(j,1);
                end
            end

            if  bg(i) > 0 && ed(i) < length(A(zi).Nav.lat_deg)
                xUTM(:,1)=A(zi).Comp.xUTM;
                xUTM(:,2)=A(zi).Comp.xUTMf.*BG;
                xUTM(:,3)=A(zi).Comp.xUTMb.*ED;
                yUTM(:,1)=A(zi).Comp.yUTM;
                yUTM(:,2)=A(zi).Comp.yUTMf.*BG;
                yUTM(:,3)=A(zi).Comp.yUTMb.*ED;
                xUTM(xUTM==0)=NaN;
                yUTM(yUTM==0)=NaN;
                A(zi).Comp.xUTM=nansum(xUTM,2);
                A(zi).Comp.yUTM=nansum(yUTM,2);

                A(zi).Comp.xUTMf=NaN(length(A(zi).Comp.xUTMraw),1);
                A(zi).Comp.xUTMb=NaN(length(A(zi).Comp.xUTMraw),1);
                A(zi).Comp.yUTMf=NaN(length(A(zi).Comp.yUTMraw),1);
                A(zi).Comp.yUTMb=NaN(length(A(zi).Comp.yUTMraw),1);
                xUTM=NaN(length(A(zi).Comp.xUTMraw),3);
                yUTM=NaN(length(A(zi).Comp.yUTMraw),3);
            else
                xUTM(:,1)=A(zi).Comp.xUTM;
                xUTM(:,2)=A(zi).Comp.xUTMf;
                xUTM(:,3)=A(zi).Comp.xUTMb;
                yUTM(:,1)=A(zi).Comp.yUTM;
                yUTM(:,2)=A(zi).Comp.yUTMf;
                yUTM(:,3)=A(zi).Comp.yUTMb;
                xUTM(xUTM==0)=NaN;
                yUTM(yUTM==0)=NaN;
                A(zi).Comp.xUTM=nanmean(xUTM,2);
                A(zi).Comp.yUTM=nanmean(yUTM,2);

                A(zi).Comp.xUTMf=NaN(length(A(zi).Comp.xUTMraw),1);
                A(zi).Comp.xUTMb=NaN(length(A(zi).Comp.xUTMraw),1);
                A(zi).Comp.yUTMf=NaN(length(A(zi).Comp.yUTMraw),1);
                A(zi).Comp.yUTMb=NaN(length(A(zi).Comp.yUTMraw),1);
                xUTM=NaN(length(A(zi).Comp.xUTMraw),3);
                yUTM=NaN(length(A(zi).Comp.yUTMraw),3);
            end
        end
    else
        A(zi).Comp.xUTM=A(zi).Comp.xUTMraw;
        A(zi).Comp.yUTM=A(zi).Comp.yUTMraw;
    end
    
    keep A z zi
%     clear I I2 J J2 bg chk df ed i j nbrk sbt xUTM yUTM n zi BG ED
%     clear bad_lat bad_long repeat_gps fly_aways suspect*
%     clear dist* bvbt_indx gvbt_indx multiple_utm_zones vel* delta_time_elapsed
end
