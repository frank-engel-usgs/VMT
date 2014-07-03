function [A,V] = VMT_GridData2MeanXS(z,A,V)
% This routine generates a uniformly spaced grid for the mean cross section and 
% maps (interpolates) individual transects to this grid.  
%
% AVG version averages the ensembles nearest each grid node (rather than
% interpolating).  
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-9-08

%% User Input

xgdspc = A(1).hgns; %Horizontal Grid node spacing in meters  (vertical grid spacing is set by bins)

%% Determine uniform mean c-s grid for vector interpolating
% Determine the end points of the mean cross-section line
% Initialize variable with mid range value
V.xe = mean(A(1).Comp.xm);
V.ys = mean(A(1).Comp.ym);
V.xw = mean(A(1).Comp.xm);
V.yn = mean(A(1).Comp.ym);

for zi = 1 : z
    
    V.xe = max(max(A(zi).Comp.xm),V.xe);
    V.ys = min(min(A(zi).Comp.ym),V.ys);
    V.xw = min(min(A(zi).Comp.xm),V.xw);
    V.yn = max(max(A(zi).Comp.ym),V.yn);
    
end

% Determine the distance between the mean cross-section endpoints
V.dx = V.xe-V.xw;
V.dy = V.yn-V.ys;

V.dl = sqrt(V.dx^2+V.dy^2);

% Determine mean cross-section velocity vector grid
V.mcsDist = linspace(0,V.dl,floor(V.dl/xgdspc));                                  %%linspace(0,V.dl,V.dl); Changed to make it user selectable (PRJ, 12-12-08)
V.mcsDepth = A(1).Wat.binDepth(:,1);
[V.mcsDist V.mcsDepth] = meshgrid(V.mcsDist,V.mcsDepth);

% Determine the angle the mean cross-section makes with the
% x-axis (longitude)
% Plot mean cross-section line
if V.m >= 0
    V.theta = atand(V.dy./V.dx);
    
    figure(1); hold on
    plot([V.xe V.xw],[V.yn V.ys],'ks'); hold on
    
    if V.mfd >= 270 | V.mfd < 90 %Flow to the north
        V.mcsX = V.xw+V.mcsDist(1,:).*cosd(V.theta);            % 
        V.mcsY = V.ys+V.mcsDist(1,:).*sind(V.theta);
        
    elseif V.mfd >= 90 & V.mfd < 270 %Flow to the south
        V.mcsX = V.xe-V.mcsDist(1,:).*cosd(V.theta);            % 
        V.mcsY = V.yn-V.mcsDist(1,:).*sind(V.theta);  
    end%
    
    plot(V.mcsX,V.mcsY,'k+'); hold on
    plot(V.mcsX(1),V.mcsY(1),'y*'); hold on

elseif V.m < 0
    V.theta = -atand(V.dy./V.dx);
    
    figure(1); hold on
    plot([V.xe V.xw],[V.ys V.yn],'ks'); hold on
    
    if V.mfd >= 270 | V.mfd < 90 %Flow to the north
        V.mcsX = V.xw+V.mcsDist(1,:).*cosd(V.theta);            % 
        V.mcsY = V.yn+V.mcsDist(1,:).*sind(V.theta);
        
    elseif V.mfd >= 90 & V.mfd < 270 %Flow to the south
        V.mcsX = V.xe-V.mcsDist(1,:).*cosd(V.theta);
        V.mcsY = V.ys-V.mcsDist(1,:).*sind(V.theta);  
    end%
   
    plot(V.mcsX,V.mcsY,'k+'); hold on
    plot(V.mcsX(1),V.mcsY(1),'y*'); hold on
    
end

V.mcsX = meshgrid(V.mcsX,V.mcsDepth(:,1));
V.mcsY = meshgrid(V.mcsY,V.mcsDepth(:,1));

clear zi

%% Determine location of mapped ensemble points for interpolating
% For all transects

%A = VMT_DxDyfromLB(z,A,V); %Computes dx and dy 

for zi = 1 : z

    % Determine if the mean cross-section line trends NW-SE or SW-NE
    % Determine the distance in radians from the left bank mean
    % cross-section point to the mapped ensemble point for an individual
    % transect
   A(zi).Comp.dx = abs(V.xe-A(zi).Comp.xm);  %This assumes the easternmost bank is the left bank--changed PRJ 1-21-09 (now uses VMT_DxDyfromLB--not working 2/1/09)

    if V.m > 0
        A(zi).Comp.dy = abs(V.yn-A(zi).Comp.ym);

    elseif V.m < 0
            A(zi).Comp.dy = abs(V.ys-A(zi).Comp.ym);

    end

    % Determine the distance in meters from the left bank mean
    % cross-section point to the mapped ensemble point for an individual
    % transect
    A(zi).Comp.dl = sqrt(A(zi).Comp.dx.^2+A(zi).Comp.dy.^2);

    % Sort vectors by dl
    A(zi).Comp.dlsort = sort(A(zi).Comp.dl,'ascend');

    % Map indices
    for i = 1 : A(zi).Sup.noe
        for k = 1 : A(zi).Sup.noe

            if A(zi).Comp.dlsort(i,1) == A(zi).Comp.dl(k,1)
                A(zi).Comp.vecmap(i,1) = k;

            end
        end
    end

    % GPS position fix
    % if distances from the left bank are the same for two ensembles the
    % the position of the right most ensemble is interpolated from adjacent
    % ensembles
    % check for repeat values of distance
    sbt(:,1)=diff(A(zi).Comp.dlsort);
    chk(1,1)=1;
    chk(2:A(zi).Sup.noe,1)=sbt(1:end,1);

    % identify repeat values
    A(zi).Comp.sd = (chk==0) > 0;

    % if repeat values exist interpolate distances from adjacent ensembles
    if sum(A(zi).Comp.sd) > 0

        % bracket repeat sections
        [I,J] = ind2sub(size(A(zi).Comp.sd),find(A(zi).Comp.sd==1));
        df=diff(I);
        nbrk=sum(df>1)+1;
        [I2,J2] = ind2sub(size(df),find(df>1));

        bg(1)=(I(1)-1);

        for n = 2 : nbrk
            bg(n)=(I(I2(n-1)+1)-1);
        end

        for n = 1 : nbrk -1
            ed(n)=(I(I2(n))+1);
        end

        ed(nbrk)=I(end)+1;

        % interpolate repeat values
        A(zi).Comp.dlsortgpsfix = A(zi).Comp.dlsort;

        for i = 1 : nbrk
            for j = bg(i)+1 : ed(i)-1
                % interpolate
                if bg(i) > 0 && ed(i) < length(A(zi).Nav.lat_deg)

                    den=(ed(i)-bg(i));
                    num2=j-bg(i);
                    num1=ed(i)-j;

                    A(zi).Comp.dlsortgpsfix(j,1)=...
                        (num1/den).*A(zi).Comp.dlsort(bg(i))+...
                        (num2/den).*A(zi).Comp.dlsort(ed(i));

                end
                
                % extrapolate end
                if ed(i) > length(A(zi).Nav.lat_deg)
                   
                    numex=ed(i)-length(A(zi).Nav.lat_deg);
                    
                    A(zi).Comp.dlsortgpsfix(j,1)=numex.*...
                        (A(zi).Comp.dlsort(bg(i))-...
                        A(zi).Comp.dlsort(bg(i)-1))+...
                        A(zi).Comp.dlsort(bg(i));
                    
                end               
            end
        end

    else
        
        A(zi).Comp.dlsortgpsfix = A(zi).Comp.dlsort;
        
    end
    
    % Determine velocity vector grid for individual transects
    [A(zi).Comp.itDist A(zi).Comp.itDepth] = ...
        meshgrid(A(zi).Comp.dlsortgpsfix,A(zi).Wat.binDepth(:,1));
    
    clear I I2 J J2 bg chk df ed i j nbrk sbt xUTM yUTM n zi...
        den num2 num1 numex
    
end

clear zi i k check
%% Average ensembles from individual transects using a spatial average to points on the uniform mean c-s grid
% Fill in uniform grid by averaging ensembles (of individual transects mapped onto the mean
% cross-section) within one-half a grid spacing on either side of a uniform mean
% c-s node. This uses all of the ensembles.

for zi = 1 : z
% reorder the ensembles so the distance increments across the c-s
A(zi).Clean.bsvecmap = A(zi).Clean.bs(:,A(zi).Comp.vecmap);
A(zi).Clean.vDirvecmap = A(zi).Clean.vDir(:,A(zi).Comp.vecmap);
A(zi).Clean.vMagvecmap = A(zi).Clean.vMag(:,A(zi).Comp.vecmap);
A(zi).Clean.vEastvecmap = A(zi).Clean.vEast(:,A(zi).Comp.vecmap);
A(zi).Clean.vNorthvecmap = A(zi).Clean.vNorth(:,A(zi).Comp.vecmap);
A(zi).Clean.vVertvecmap = A(zi).Clean.vVert(:,A(zi).Comp.vecmap);
A(zi).Clean.depthvecmap = nanmean(A(zi).Nav.depth(A(zi).Comp.vecmap,:),2)';

% determine one-half grid spacing on either side of a node
plus=V.mcsDist(1,:)+(V.mcsDist(1,2)/2);
minus=V.mcsDist(1,:)-(V.mcsDist(1,2)/2);

for j=1:size(plus,2);%columns
    
    indx = find(A(zi).Comp.itDist(1,:)<plus(1,j)&A(zi).Comp.itDist(1,:)>minus(1,j)); % Indices within bin

    % spatial average ensembles on either side of the nodes
    A(zi).Comp.mcsBack(:,j)=nanmean(A(zi).Clean.bsvecmap(:,indx),2);
    % count the non-nan values that were averaged
    A(zi).Comp.mcsBackContrib(:,j)=sum(~isnan(A(zi).Clean.bsvecmap(:,indx)),2);

    A(zi).Comp.mcsDir(:,j)=nanmean(A(zi).Clean.vDirvecmap(:,indx),2);
    A(zi).Comp.mcsDirContrib(:,j)=sum(~isnan(A(zi).Clean.vDirvecmap(:,indx)),2);

    A(zi).Comp.mcsMag(:,j)=nanmean(A(zi).Clean.vMagvecmap(:,indx),2);
    A(zi).Comp.mcsMagContrib(:,j)=sum(~isnan(A(zi).Clean.vMagvecmap(:,indx)),2);

    A(zi).Comp.mcsEast(:,j)=nanmean(A(zi).Clean.vEastvecmap(:,indx),2);
    A(zi).Comp.mcsEastContrib(:,j)=sum(~isnan(A(zi).Clean.vEastvecmap(:,indx)),2);

    A(zi).Comp.mcsNorth(:,j)=nanmean(A(zi).Clean.vNorthvecmap(:,indx),2);
    A(zi).Comp.mcsNorthContrib(:,j)=sum(~isnan(A(zi).Clean.vNorthvecmap(:,indx)),2);

    A(zi).Comp.mcsVert(:,j)=nanmean(A(zi).Clean.vVertvecmap(:,indx),2);
    A(zi).Comp.mcsVertContrib(:,j)=sum(~isnan(A(zi).Clean.vVertvecmap(:,indx)),2);

    A(zi).Comp.mcsBed(:,j)=nanmean(A(zi).Clean.depthvecmap(:,indx),2);
    A(zi).Comp.mcsBedContrib(:,j)=sum(~isnan(A(zi).Clean.depthvecmap(:,indx)),2);

end

A(zi).Comp.mcsBack(A(zi).Comp.mcsBack>=255) = NaN;

end

%% Interpolate individual transects onto uniform mean c-s grid
% Fill in uniform grid based on individual transects mapped onto the mean
% cross-section by interpolating between adjacent points

%ZI = interp2(X,Y,Z,XI,YI)
for zi = 1 : z
 
    A(zi).Comp.mcsBackI = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        A(zi).Clean.bs(:,A(zi).Comp.vecmap),V.mcsDist, V.mcsDepth);
    A(zi).Comp.mcsBackI(A(zi).Comp.mcsBackI>=255) = NaN;
    
    A(zi).Comp.mcsDirI = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        A(zi).Clean.vDir(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
    A(zi).Comp.mcsMagI = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        A(zi).Clean.vMag(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
    A(zi).Comp.mcsEastI = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        A(zi).Clean.vEast(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
    A(zi).Comp.mcsNorthI = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        A(zi).Clean.vNorth(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
    A(zi).Comp.mcsVertI = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
        A(zi).Clean.vVert(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
    
    A(zi).Comp.mcsBedI  = interp1(A(zi).Comp.itDist(1,:),...
        nanmean(A(zi).Nav.depth(A(zi).Comp.vecmap,:),2),V.mcsDist(1,:));
    
end

clear zi