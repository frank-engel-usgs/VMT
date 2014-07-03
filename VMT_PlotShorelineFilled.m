function VMT_PlotShorelineFilled(Map)
% Plots a shoreline map given the shoreline data structure 'Map' (see
% VMT_LoadMap.m) on the current map
%
% Shoreline is is filled with channel cutout in this version. 
%
% See Also: VMT_PlotShoreline
%
% P.R. Jackson, 12-9-08

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
        figure(gcf); hold on 
        patch(Map.UTMe(indx),Map.UTMn(indx),'k','EdgeColor',[0.706 0.706 0.573],'LineWidth',1); hold on
    elseif i == length(brks)+1
        ll = brks(i-1)+1;
        ul = length(Map.UTMe);
        indx =ll:ul;
        figure(gcf); hold on 
        patch(Map.UTMe(indx),Map.UTMn(indx),[0.8,0.733,0.533],'EdgeColor',[0.706 0.706 0.573],'LineWidth',1); hold on
    elseif i > 1 & i < length(brks)+1
        ll = brks(i-1)+1;
        ul = brks(i)-1;
        indx =ll:ul;
        figure(gcf); hold on 
        patch(Map.UTMe(indx),Map.UTMn(indx),[0.8,0.733,0.533],'EdgeColor',[0.706 0.706 0.573],'LineWidth',1); hold on
    end   
end
%xlabel('UTM Easting (m)')
%ylabel('UTM Northing (m)')
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])