function VMT_PlotShoreline(Map)
% Plots a shoreline map given the shoreline data structure 'Map' (see
% VMT_LoadMap.m) on the current map
%
% P.R. Jackson, 12-9-08
% Last Modified: Frank L. Engel, 3/13/2013

if isempty(Map) % User hit cancel when selecting shoreline file
    return
end

% See if PLOT 1 exists already, if not make it
fig_planview_handle = findobj(0,'name','Plan View Map');

if ~isempty(fig_planview_handle) &&  ishandle(fig_planview_handle)
    figure(fig_planview_handle);
else
    fig_planview_handle = figure('name','Plan View Map'); clf
    %set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
end

brks = find(Map.UTMe == -9999);

for i = 1:length(brks)+1
    if i == 1
        ll = 1;
        if ~isempty(brks)
            ul = brks(i)-1;
        else
            ul = length(Map.UTMe);
        end
        indx =ll:ul;
    elseif i == length(brks)+1
        ll = brks(i-1)+1;
        ul = length(Map.UTMe);
        indx =ll:ul;
    elseif i > 1 & i < length(brks)+1
        ll = brks(i-1)+1;
        ul = brks(i)-1;
        indx =ll:ul;
    end
    figure(fig_planview_handle); hold on
    plot(Map.UTMe(indx),Map.UTMn(indx),'Color', [.3 .3 .3],'LineWidth',2); hold on  
    %patch(Map.UTMe(indx),Map.UTMn(indx),'k','EdgeColor','none'); hold on
    
end
%xlabel('UTM Easting (m)')
%ylabel('UTM Northing (m)')
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])