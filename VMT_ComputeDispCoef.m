function [k,kc,Ey,Q] = VMT_ComputeDispCoef(z,A,V)
% Driver function to extract VMT data for computation of the longitudinal
% dispersion coefficient.
%
% P.R. Jackson, USGS 11-17-10

%% Define the processing steps
extrp = 1;  %extrapolate profiles to the bed and water surface
extend_to_banks = 1;  %extend data to shore
shoretype = 'triangular';

%% Extract the required data

% Compute the starting and ending distances
b = [nanmean(nanmean(V.mcsEast,2)) nanmean(nanmean(V.mcsNorth,2)) 0];  %vector with the mean flow components and zero vertical
for zi = 1:z
    %Determine the starting banks
    
    a = [A(zi).Nav.totDistEast(end) A(zi).Nav.totDistNorth(end) 0];
    c = cross(a,b);
    if c(3) > 0
        left_start_bank(zi) = 1;
    elseif c(3) < 0
        left_start_bank(zi) = 0;
    else
        left_start_bank(zi) = nan;
    end
    
    %Get the shore distances  (define start shore as left shore looking DS)
    if left_start_bank(zi) == 1
        startSDist(zi) = A(zi).Q.startDist(1);
        endSDist(zi)   = A(zi).Q.endDist(1);
    elseif left_start_bank(zi) == 0
        startSDist(zi) = A(zi).Q.endDist(1);
        endSDist(zi)   = A(zi).Q.startDist(1);
    else
        errordlg('Starting Bank Cannot Be Determined')
    end
end
startDist = min(startSDist)  %Take the minimum distances because VMT uses the closest points to shore as a start and end
endDist   = min(endSDist)

% Check the starting and ending distance for zero values

if startDist == 0 | endDist == 0;
    disp('Edge Distance of ZERO was detected--Manually enter distances in (m)')
    prompt = {'Start Distance (m)','End Distance (m)'};
    dlg_title = 'Edge Distances (manual)';
    num_lines = 1;
    def = {num2str(startDist),num2str(endDist)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    [startDist, status1] = str2num(answer{1});
    [endDist, status2]   = str2num(answer{2});
end
    

% Define the input vectors
beddepth  = V.mcsBed';
travdist  = V.mcsDist(1,:)';
vertdepth = V.mcsDepth(:,1);
downstvel = V.vpSmooth'/100;  %old (uses the streawise velocity) V.uSmooth'/100;  % in m/s  Now uses the primary velocity ZSD definition  V.vpSmooth'/100

%Remove edge nans (caused by interpolation near boundary)
indx = find(~isnan(beddepth) & sum(isnan(downstvel),2) ~= length(vertdepth));
addstart = travdist(indx(1));
addend   = travdist(end) - travdist(indx(end));
beddepth = beddepth(indx(1):indx(end));
travdist = travdist(indx(1):indx(end));
travdist = travdist - travdist(1);  %Resets zero at first point
downstvel = downstvel(indx(1):indx(end),:);

%Tack on extra to the edges to accoutn for the missing edge data
startDist = startDist + addstart;
endDist   = endDist + addend;

%% Call the script to compute the dispersion coeficient
[k,kc,Ey,Q] = ADCP_DispCoef(beddepth,travdist,vertdepth,downstvel,startDist,endDist,extrp,extend_to_banks,shoretype);


