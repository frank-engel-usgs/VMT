function VMT_BlankShoreline(X,Y,Map)
% This function is not implemented currently.
% 
% Effectivly clips a contour plot to a shoreline boundary by overlaying a
% patch to block out land.  Requires the mapping toolbox.  X is the UTM
% easting vector of the data extent, Y is the northing vector, and Map is
% the MAP data structure for the shoreline file.

%P.R. Jackson, 4-13-09

%Define the map polygon

x2 = [min(X) min(X) max(X) max(X) min(X)];
y2 = [min(Y) max(Y) max(Y) min(Y) min(Y)];


%Define the shoreline polygons

brks = find(Map.UTMe == -9999);  %Assumes shoreline is doen first followed by -9999 breaks to signal islands (interior polygons)

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
    
    x1 = Map.UTMe(indx); 
    y1 = Map.UTMn(indx); 
    
    %Ensure both are CW polygons (external contours)

    if ~ispolycw(x1,y1)
        [x1,y1] = poly2cw(x1,y1);
    end

    if ~ispolycw(x2, y2)
        [x2,y2] = poly2cw(x2, y2);
    end

    
    if i == 1;
        %Find the exclusion overlap
        [x3, y3] = polybool('xor', x1, y1, x2, y2);
    else
        %Find the intersection for islands
        [x3, y3] = polybool('intersection', x1, y1, x2, y2);
    end

    figure(gcf); hold on

    [f, v] = poly2fv(x3, y3);
    patch('Faces', f,'Vertices', v, 'FaceColor', [0.8,0.733,0.533],'EdgeColor', 'none'); hold on

    %plot(x1, y1,'Color',[0.706 0.706 0.573],'LineWidth',1); hold on
    %plot(x2, y2,'m-'); hold on
    
    xlim([min(x2) max(x2)])
    ylim([min(y2) max(y2)])
  
end


xlabel('UTM Easting (m)')
ylabel('UTM Northing (m)')
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])