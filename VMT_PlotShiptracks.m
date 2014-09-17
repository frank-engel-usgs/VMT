function hf = VMT_PlotShiptracks(A,V,z,setends,hf)
% Plots the shiptracks, and interpolated grid in the VMT GUI axes. Also
% plots the mean cross section normal vector, and the mean flow direction
% vector.
%
% F.L. Engel, USGS, 2/20/2013

% See if PLOT 1 exists already, if so clear the figure
% fig_shiptracks_handle = findobj(0,'name','Shiptracks');


if ~isempty(hf) &&  ishandle(hf)
    %figure(fig_shiptracks_handle); clf
    axes(hf)
    cla
    set(hf,'NextPlot','replacechildren')
else
    hf = figure('name','Shiptracks'); clf
    set(gca,'DataAspectRatio',[1 1 1])
        %...'PlotBoxAspectRatio',[1 1 1],...
        
end


for zi = 1 : z
    axes(hf); hold on
    plot(hf,A(zi).Comp.xUTMraw,A(zi).Comp.yUTMraw,'b'); hold on
    
    % Plot the various reject and/or adjusted GPS location data for
    % reference
    %plot(A(zi).Comp.xUTM,A(zi).Comp.yUTM,'r'); hold on
    plot(hf,...
        ...A(zi).Comp.xUTMraw(A(zi).Comp.gps_reject_locations),...
        ...A(zi).Comp.yUTMraw(A(zi).Comp.gps_reject_locations),'g.',...
        ...A(zi).Comp.xUTMraw(A(zi).Comp.gps_repeat_locations),...
        ...A(zi).Comp.yUTMraw(A(zi).Comp.gps_repeat_locations),'y.',...
        A(zi).Comp.xUTMraw(A(zi).Comp.gps_fly_aways),...
        A(zi).Comp.yUTMraw(A(zi).Comp.gps_fly_aways),'r.')
end

% Gets a user text file with fixed cross section end points
% If at this point, the data have already been processed, and user has
% selected endpoint file. Just load it.
if setends
    setendpoints = getpref('VMT','setendpoints');
    data = dlmread(fullfile(setendpoints.path,setendpoints.file));
    x = data(:,1);
    y = data(:,2);

    axes(hf); hold on
    plot(hf,x,y,'go','MarkerSize',10); hold on
    
end

% Plot the equation of the best fit line
xrng = V.xe - V.xw;
yrng = V.yn - V.ys;

if xrng >= yrng
    P(1) = V.m;
    P(2) = V.b;
    
    axes(hf); hold on;
    plot(hf,V.mcsX(1,:),polyval(P,V.mcsX(1,:)),'g-')
else
    P(1) = 1/V.m;
    P(2) = -V.b/V.m;
    
    axes(hf); hold on;
    plot(hf,polyval(P,V.mcsY(1,:)),V.mcsY(1,:),'g-')
end

% Determine the direction of the streamwise coordinate, which
% is taken as perpendicular to the mean cross section. Theta is
% expressed in geographical (N = 0 deg, clockwise positive)
% coordinates. This method uses a vector based approach which
% is insensitive to orientation of the cross section.

% First compute the normal unit vector to the mean
% cross section
N = [-V.dy/sqrt(V.dx^2+V.dy^2)...
    V.dx/sqrt(V.dx^2+V.dy^2)];

% Compute the mean flow direction in the cross section. To do
% this, we also have to convert from geographic angle to
% arimetic angle
arimfddeg = geo2arideg(V.mfd);
[xmfd,ymfd] = pol2cart(arimfddeg*pi/180,1);
M = [xmfd ymfd];

% Now compute the angle between the normal and mean flow
% direction unit vectors
vdif = acos(dot(N,M)/(norm(N)*norm(M)))*180/pi;

% If the angle is greater than 90 degs, the normal vector needs
% to be reversed before resolving the u,v coordinates
if vdif >= 90
    N = -N;
end

% Plot N and M to check (scale of the vectors is 10% of the
% total length of the cross section)
midy = V.ys+abs(yrng)/2;
midx = V.xw+xrng/2;
axes(hf); hold on;
quiver(hf,...
    midx,midy,N(1)*V.dl*0.1,...
    N(2)*V.dl*0.1,1,'k')
quiver(hf,...
    midx,midy,M(1)*V.dl*0.1,...
    M(2)*V.dl*0.1,1,'r')

%Plot data to check
xensall = [];
yensall = [];
for zi = 1 : z
    plot(hf,A(zi).Comp.xm,A(zi).Comp.ym,'b.')
    %xensall = [xensall; A(zi).Comp.xm];
    %yensall = [yensall; A(zi).Comp.ym];
end
% plot(A(3).Comp.xm,A(3).Comp.ym,'xg')
% plot(A(4).Comp.xm,A(4).Comp.ym,'oy')
xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
box on
grid on
%Plot a legend in Figure 1
%figure(1); hold on
%legend('Shoreline','GPS(corr)','GPS(raw)','Best Fit','Trans 1
%(mapped)','Other Trans (mapped)')

%Plot the MCS on figure 1
axes(hf); hold on
plot(hf,V.xLeftBank,V.yLeftBank,'gs','MarkerFaceColor','g'); hold on  %Green left bank start point
plot(hf,V.xRightBank,V.yRightBank,'rs','MarkerFaceColor','r'); hold on %Red right bank end point
plot(hf,V.mcsX(1,:),V.mcsY(1,:),'k+'); hold on
axes(hf); 
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])


% % Format the ticks for UTM and allow zooming and panning
% axes(hf);
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM
% hdlzm_fig1 = zoom;
% set(hdlzm_fig1,'ActionPostCallback',@mypostcallback_zoom);
% set(hdlzm_fig1,'Enable','on');
% hdlpn_fig1 = pan;
% set(hdlpn_fig1,'ActionPostCallback',@mypostcallback_pan);
% set(hdlpn_fig1,'Enable','on');

%%%%%%%%%%%%%%%%
% SUBFUNCTIONS %
%%%%%%%%%%%%%%%%
function mypostcallback_zoom(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when zooming) 

function mypostcallback_pan(obj,evd)
ticks_format('%6.0f','%8.0f'); %formats the ticks for UTM (when panning) 

