function [A,V,log_text] = VMT_CompMeanXS(z,A,V)
% Computes the mean cross section data from individual transects
% that have been previously mapped to a common grid.
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-9-08



%% Average mapped mean cross-sections from individual transects together

% Averaging for backscatter is only computed for Rio Grande probes
% Procedure for SonTek probes is different

switch V.probeType
    % Assign mapped uniform grid vectors to the same array for averaging
    % Put all of the Sontek data in one place, then interpolate values at
    % the MCS grid
    case 'M9'
        
        x       = []; 
        y       = []; 
        East    = [];
        North   = [];
        Vert    = [];
        Error   = [];
        for zi = 1: z
            
            Dir(:,:,zi) = A(zi).Comp.mcsDir(:,:);
            Bed(:,:,zi) = A(zi).Comp.mcsBed(:,:);
            
            xx    = meshgrid(A(zi).Comp.dl,A(zi).Wat.binDepth(:,1));
            x     = [x; xx(:)];
            y     = [y; A(zi).Wat.binDepth(:)];
            East  = [East;  A(zi).Wat.vEast(:)];
            North = [North; A(zi).Wat.vNorth(:)];
            Vert  = [Vert;  A(zi).Wat.vVert(:)];
            Error = [Error; A(zi).Wat.vError(:)];
        end

        % FIXME: I call griddate 3 times. Need to rewrite to create 1
        % delauney tri, and replace the V data.
        V.mcsEast  = griddata(x,y,East,V.mcsDist,V.mcsDepth);
        V.mcsNorth = griddata(x,y,North,V.mcsDist,V.mcsDepth);
        V.mcsVert  = griddata(x,y,Vert,V.mcsDist,V.mcsDepth);
        V.mcsError = griddata(x,y,Error,V.mcsDist,V.mcsDepth);
        
    otherwise % Could be 'RG' or 'RR'
        for zi = 1 : z
            
            Back(:,:,zi)  = A(zi).Comp.mcsBack(:,:);
            Dir(:,:,zi)   = A(zi).Comp.mcsDir(:,:);
            Mag(:,:,zi)   = A(zi).Comp.mcsMag(:,:);
            East(:,:,zi)  = A(zi).Comp.mcsEast(:,:);
            North(:,:,zi) = A(zi).Comp.mcsNorth(:,:);
            Vert(:,:,zi)  = A(zi).Comp.mcsVert(:,:);
            Error(:,:,zi) = A(zi).Comp.mcsError(:,:);
            Bed(:,:,zi)   = A(zi).Comp.mcsBed(:,:);
            
        end
        
        numavg = nansum(~isnan(Mag),3);
        numavg(numavg==0) = NaN;
        enscnt = nanmean(numavg,1);
        [I,J] = ind2sub(size(enscnt),find(enscnt>=1));  %Changed to >= 1 PRJ 12-10-08  (uses data even if only one measurement)
        
        
        Backone= Back;
        Backone(~isnan(Back))=1;
        V.countBack = nansum(Backone,3);
        V.countBack(V.countBack==0)=NaN;
        V.mcsBack = nanmean(Back,3);
        
        
        Magone = Mag;
        Vertone = Vert;
        Bedone = Bed;
        
        
        Magone(~isnan(Mag))=1;
        Vertone(~isnan(Vert))=1;
        Bedone(~isnan(Bed))=1;
        
        
        V.countMag = nansum(Magone,3);
        V.countVert = nansum(Vertone,3);
        V.countBed = nansum(Bedone,3);
        
        V.countMag(V.countMag==0)=NaN;
        V.countVert(V.countVert==0)=NaN;
        V.countBed(V.countBed==0)=NaN;
        
        % Average mapped mean cross-sections from individual transects together
        
        %V.mcsDir = nanmean(Dir,3);  % Will not average correctly in all cases due to 0-360
        %wrapping (PRJ, 9-29-10)
        %V.mcsMag = nanmean(Mag,3);  %Mag recomputed from north, east, up components(PRJ, 3-21-11)
        V.mcsEast  = nanmean(East,3);
        V.mcsNorth = nanmean(North,3);
        V.mcsVert  = nanmean(Vert,3);
        V.mcsError = nanmean(Error,3);
    
    

end % switch Probe type

        %Average Magnitude
        V.mcsMag = sqrt(V.mcsEast.^2 + V.mcsNorth.^2 + V.mcsVert.^2);
        
        %Average the flow direction
        V.mcsDir = ari2geodeg((atan2(V.mcsNorth, V.mcsEast))*180/pi);
        % V.mcsDir = 90 - (atan2(V.mcsNorth, V.mcsEast))*180/pi; %Compute the atan from the velocity componentes, convert to radians, and rotate to north axis
        % qindx = find(V.mcsDir < 0);
        %     if ~isempty(qindx)
        %         V.mcsDir(qindx) = V.mcsDir(qindx) + 360;  %Must add 360 deg to Quadrant 4 values as they are negative angles from the +y axis
        %     end
        
        V.mcsBed = nanmean(Bed,3);
        
        %Compute the Bed Elevation in meters (Takes the mean value of the entered
        %WSE timeseries if file loaded)
        %disp(['Assigned Water Surface Elevation (WSE; in meters) = ' num2str(mean(A(1).wse))])
        if isstruct(A(1).wse) % Tide file loaded
            % PATCH -- will modify this to interpolate WSE for each
            % sample. For now, just use the first elevation [FLE 1/5/2015]
            log_text = ['      WSE in meters [tide file loaded]) = ' num2str(mean(A(1).wse.elev(1)))];
            V.mcsBedElev = mean(A(1).wse.elev(1)) - V.mcsBed;
        else
            log_text = ['      WSE in meters) = ' num2str(mean(A(1).wse))];
            V.mcsBedElev = mean(A(1).wse) - V.mcsBed;
        end


return

% Remove values (Omitted 11/23/10, PRJ)
% Clean up
% switch A(1).probeType
%     case 'RG'
%         V.mcsBack(:,1:J(1)-1)=NaN;
%         V.mcsBack(:,J(end)+1:end)=NaN;
%         V.countBack(:,1:J(1)-1)=NaN;
%         V.countBack(:,J(end)+1:end)=NaN;
% end
%
% V.mcsDir(:,1:J(1)-1)=NaN;
% V.mcsDir(:,J(end)+1:end)=NaN;
% V.mcsMag(:,1:J(1)-1)=NaN;
% V.mcsMag(:,J(end)+1:end)=NaN;
% V.mcsEast(:,1:J(1)-1)=NaN;
% V.mcsEast(:,J(end)+1:end)=NaN;
% V.mcsNorth(:,1:J(1)-1)=NaN;
% V.mcsNorth(:,J(end)+1:end)=NaN;
% V.mcsVert(:,1:J(1)-1)=NaN;
% V.mcsVert(:,J(end)+1:end)=NaN;
% V.mcsBed(:,1:J(1)-1)=NaN;
% V.mcsBed(:,J(end)+1:end)=NaN;
% V.countMag(:,1:J(1)-1)=NaN;
% V.countVert(:,1:J(1)-1)=NaN;
% V.countBed(:,1:J(1)-1)=NaN;
% V.countMag(:,J(end)+1:end)=NaN;
% V.countVert(:,J(end)+1:end)=NaN;
% V.countBed(:,J(end)+1:end)=NaN;


