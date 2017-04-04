function [A,V] = VMT_GridData2MeanXS(z,A,V,unitQcorrection)
% This routine generates a uniformly spaced grid for the mean cross section and 
% maps (interpolates) individual transects to this grid.   
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-9-08
% Last modified: F.L. Engel, USGS 2/20/2013

%% User Input

xgdspc      = A(1).hgns; %Horizontal Grid node spacing in meters
ygdspc      = A(1).vgns; %double(A(1).Sup.binSize_cm)/100; %Vertical Grid node spacing in meters

% For now, take the minumum bin size as the vertical resolution. 
% Later, I will specify this in the GUI (FLE)
%ygdspc      = min(min(double(A(1).Sup.binSize_cm)/100)); %Vertical Grid node spacing in meters
if 0
    xgdspc  = V.meddens + V.stddens;  %Auto method should include 67% of the values
    %disp(['X Grid Node Auto Spacing = ' num2str(xgdspc) ' m'])
    log_text = ['X Grid Node Auto Spacing = ' num2str(xgdspc) ' m'];
end


%% Determine uniform mean c-s grid for vector interpolating

% Determine mean cross-section velocity vector grid. Allow for explicit
% specification of vertical grid node spacing Also, using linspace doesn't
% necessarily give exactly hgns spaced grid nodes, so the method has been
% adjusted (this is important for user that want to output to a model
% grid). A fragment of length<xgdspc may be truncated. The impact on this
% for data analysis should be minor.
switch V.startBank
    case 'right_bank'
        V.mcsDist = 0:xgdspc:V.dl;
    otherwise % left bank or auto
        V.mcsDist = 0:xgdspc:V.dl;
end
for zi = 1:z
    minDepth(zi) = min(A(zi).Wat.binDepth(:));
    maxDepth(zi) = max(A(zi).Wat.binDepth(:));
end
V.mcsDepth              = ...
    min(minDepth):ygdspc:max(maxDepth);
[V.mcsDist, V.mcsDepth] = meshgrid(V.mcsDist,V.mcsDepth');


% Define the MCS XY points. (REVISED PRJ, 10-18-12)
% Coordinate assignments depend on the starting 
% point and the slope of the cross section. Theta is limited to 0 to 180
% (geographic) and 90 to 270 (arithmetic).  For COS, arithmetic angles
% between 90 and 270 are always negative so no need to add additional IF
% statement based on the slope.  However, SIN theta (aritmetic) is positive 
% in MFD quadrants 2 and 4 and negative in 1 and 3. Therefore, we use the slope
% (positive in MFD quadrants 1 and 3, negative in 2 and 4) to determine whether to add or
% subtract the incremental distances from the start point.  (MFD = mean
% flow direction, used to define quadrants above and below)

if V.xLeftBank == V.xe % MFD Quadrants 2 and 3 (east start)
    V.mcsX = V.xLeftBank - V.mcsDist(1,:).*cosd(geo2arideg(V.theta));
else % MFD Quadrants 1 and 4 (west start)
    V.mcsX = V.xLeftBank + V.mcsDist(1,:).*cosd(geo2arideg(V.theta));
end

if V.yLeftBank == V.yn % MFD Quadrants 1 and 2 (north start)
    if V.m >= 0 %MFD Quadrant 2
        V.mcsY = V.yLeftBank - V.mcsDist(1,:).*sind(geo2arideg(V.theta)); 
    else %MFD Quadrant 1
        V.mcsY = V.yLeftBank + V.mcsDist(1,:).*sind(geo2arideg(V.theta));
    end
else % MFD Quadrants 3 and 4 (south start)
    if V.m >= 0 %MFD Quadrant 4
        V.mcsY = V.yLeftBank + V.mcsDist(1,:).*sind(geo2arideg(V.theta)); 
    else %MFD Quadrant 3
        V.mcsY = V.yLeftBank - V.mcsDist(1,:).*sind(geo2arideg(V.theta));
    end
end

V.mcsX = meshgrid(V.mcsX,V.mcsDepth(:,1));
V.mcsY = meshgrid(V.mcsY,V.mcsDepth(:,1));


% %Plot the MCS on figure 1
% figure(1); hold on
% plot(V.xLeftBank,V.yLeftBank,'gs','MarkerFaceColor','g'); hold on  %Green left bank start point
% plot(V.xRightBank,V.yRightBank,'rs','MarkerFaceColor','r'); hold on %Red right bank end point
% plot(V.mcsX(1,:),V.mcsY(1,:),'k+'); hold on
% figure(1); set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
% clear zi
% 
% % Format the ticks for UTM and allow zooming and panning
% figure(1);
% ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM
% hdlzm_fig1 = zoom;
% set(hdlzm_fig1,'ActionPostCallback',@mypostcallback_zoom);
% set(hdlzm_fig1,'Enable','on');
% hdlpn_fig1 = pan;
% set(hdlpn_fig1,'ActionPostCallback',@mypostcallback_pan);
% set(hdlpn_fig1,'Enable','on');


%% If specified, correct the streamwise velocity by enforcing mass 
% flux (capacitor) continuity
if unitQcorrection
    A = VMT_unitQcont(A,V,z);
end

%% Interpolate individual transects onto uniform mean c-s grid
% Fill in uniform grid based on individual transects mapped onto the mean
% cross-section by interpolating between adjacent points
% 
% Originally, the data matrices contained monotonic, finite values. With
% the inclusion of RiverRay data, this assuption is no longer valid. To
% interpolate the quasi-scattered data requires vectorizing and isolating
% the valid data, and then using the TriScatteredInterp class. Ultimately,
% this method should produce the same results with RioGrande data, but with
% marked speed improvements (vecotrized operations are faster in Matlab).
% NOTE: TriScattertedInterp has been replaced by scatteredInterpolant in
% R2013+
% [FLE 3/25/2014]

XI = V.mcsDist(:);
YI = V.mcsDepth(:);

%ZI = interp2(X,Y,Z,XI,YI)
for zi = 1 : z
    % Vectorize inputs to interp2, index valid data, and preallocate the
    % result vectors
    [nrows,ncols] = size(A(zi).Comp.itDist);
    X             = A(zi).Comp.itDist; 
    Y             = A(zi).Comp.itDepth;
    valid         = ~isnan(X) & ~isnan(Y);
           
    % Inputs
    bs      = A(zi).Clean.bs(:,A(zi).Comp.vecmap);
    vE      = A(zi).Clean.vEast(:,A(zi).Comp.vecmap);
    vN      = A(zi).Clean.vNorth(:,A(zi).Comp.vecmap);
    vV      = A(zi).Clean.vVert(:,A(zi).Comp.vecmap);
    vEr     = A(zi).Clean.vError(:,A(zi).Comp.vecmap);
    enstime = datenum(...
        [A(zi).Sup.year(A(zi).Comp.vecmap)+2000,...
        A(zi).Sup.month(A(zi).Comp.vecmap),...
        A(zi).Sup.day(A(zi).Comp.vecmap),...
        A(zi).Sup.hour(A(zi).Comp.vecmap),...
        A(zi).Sup.minute(A(zi).Comp.vecmap),...
        (A(zi).Sup.second(A(zi).Comp.vecmap)+A(zi).Sup.sec100(A(zi).Comp.vecmap)./100)])';
    A(zi).Comp.enstime = enstime;
    enstime = repmat(enstime,nrows,1);
    
    % Create scatteredInterpolant class
    switch V.probeType
        case 'RG'
            A(zi).Comp.mcsBack  = interp2(X,Y,bs,V.mcsDist,V.mcsDepth);
            A(zi).Comp.mcsEast  = interp2(X,Y,vE,V.mcsDist,V.mcsDepth);
            A(zi).Comp.mcsNorth = interp2(X,Y,vN,V.mcsDist,V.mcsDepth);
            A(zi).Comp.mcsVert  = interp2(X,Y,vV,V.mcsDist,V.mcsDepth);
            A(zi).Comp.mcsError = interp2(X,Y,vEr,V.mcsDist,V.mcsDepth);
            A(zi).Comp.mcsTime  = interp2(X,Y,enstime,V.mcsDist,V.mcsDepth);
        otherwise
            F = TriScatteredInterp(X(valid),Y(valid),bs(valid));
            
            % Interpolate to each output
            mcsBack  = F(XI,YI);
            F.V      = vE(valid);
            mcsEast  = F(XI,YI);
            F.V      = vN(valid);
            mcsNorth = F(XI,YI);
            F.V      = vV(valid);
            mcsVert  = F(XI,YI);
            F.V      = vEr(valid);
            mcsError = F(XI,YI);
            F.V      = enstime(valid);
            mcsTime  = F(XI,YI);
            
            % Reshape and save to outputs
            A(zi).Comp.mcsBack  = reshape(mcsBack  ,size(V.mcsX));
            A(zi).Comp.mcsEast  = reshape(mcsEast  ,size(V.mcsX));
            A(zi).Comp.mcsNorth = reshape(mcsNorth ,size(V.mcsX));
            A(zi).Comp.mcsVert  = reshape(mcsVert  ,size(V.mcsX));
            A(zi).Comp.mcsError = reshape(mcsError ,size(V.mcsX));
            A(zi).Comp.mcsTime  = reshape(mcsTime  ,size(V.mcsX));
    end
    %A(zi).Comp.mcsBack = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
    %    A(zi).Clean.bs(:,A(zi).Comp.vecmap),V.mcsDist, V.mcsDepth);
    %A(zi).Comp.mcsBack(A(zi).Comp.mcsBack>=255) = NaN;
    %A(zi).Comp.mcsEast = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
    %    A(zi).Clean.vEast(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
    %A(zi).Comp.mcsNorth = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
    %    A(zi).Clean.vNorth(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
    %A(zi).Comp.mcsVert = interp2(A(zi).Comp.itDist, A(zi).Comp.itDepth, ...
    %    A(zi).Clean.vVert(:,A(zi).Comp.vecmap), V.mcsDist, V.mcsDepth);
    
    %Compute magnitude
    A(zi).Comp.mcsMag = sqrt(A(zi).Comp.mcsEast.^2 + A(zi).Comp.mcsNorth.^2);
    
    
    %For direction, compute from the velocity components
    A(zi).Comp.mcsDir = ari2geodeg((atan2(A(zi).Comp.mcsNorth,A(zi).Comp.mcsEast))*180/pi); 
    
    A(zi).Comp.mcsBed  = interp1(A(zi).Comp.itDist(1,:),...
        nanmean(A(zi).Nav.depth(A(zi).Comp.vecmap,:),2),V.mcsDist(1,:));
    
end

% clear zi

%%%%%%%%%%%%%%%%
% SUBFUNCTIONS %
%%%%%%%%%%%%%%%%
function mypostcallback_zoom(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when zooming) 

function mypostcallback_pan(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when panning) 
