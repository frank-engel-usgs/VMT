function VMT_PlotTransCont(z,A,V,var,zerosecq)
% No longer used in current version
% This function plots contours for the variable 'var' for all the transects.
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-10-08 



%% Plot contours

clvls = 60;

switch var
    case{'primary'}  %Plots the primary velocity
        if zerosecq
            wtp=['A(zi).Comp.vp'];
            zmin=floor(nanmin(nanmin(V.vp)));
            zmax=ceil(nanmax(nanmax(V.vp)));
        else
            wtp=['A(zi).Comp.u'];
            zmin=floor(nanmin(nanmin(V.u)));
            zmax=ceil(nanmax(nanmax(V.u)));
        end
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'secondary'} %Plots the secondary velocity
        if zerosecq
            wtp=['A(zi).Comp.vs'];
            zmax=ceil(max(abs(nanmin(nanmin(V.vs))),abs(nanmax(nanmax(V.vs)))));
        else
            wtp=['A(zi).Comp.v'];
            zmax=ceil(max(abs(nanmin(nanmin(V.v))),abs(nanmax(nanmax(V.v)))));
        end
        zmin=-zmax;
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'vertical'} %Plots the vertical velocity
        wtp=['A(zi).Comp.w'];
        zmax=ceil(max(abs(nanmin(nanmin(V.w))),abs(nanmax(nanmax(V.w)))));
        zmin=-zmax;
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'backscatter'} %Plots the backscatter
        wtp=['A(zi).Comp.mcsBack'];
        zmin=floor(nanmin(nanmin(V.mcsBack)));
        zmax=ceil(nanmax(nanmax(V.mcsBack)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'mag'} %Plots the velocity magnitude
        wtp=['A(zi).Comp.mcsMag'];
        zmin=floor(nanmin(nanmin(V.mcsMag)));
        zmax=ceil(nanmax(nanmax(V.mcsMag)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'dirdevp'} %Plots the directional deviation from the primary velocity
        wtp=['A(zi).Comp.mcsDirDevp'];
        zmax=ceil(max(abs(nanmin(nanmin(V.mcsDirDevp))),abs(nanmax(nanmax(V.mcsDirDevp)))));
        zmin=-zmax;
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
end






           
figure1 = figure;

for zi = 1 : z

    subplot(2,(rem(z,2)+z)/2,zi,'Parent',figure1,'YDir','reverse');
    % Plot Streamwise Velocity (u)
    hold on;
    box on
    xlim([nanmin(nanmin(V.mcsDist)) nanmax(nanmax(V.mcsDist))])
    %ylim([0 25])
    ylim([0 ceil(max(V.mcsBed))])
    contour(V.mcsDist,V.mcsDepth,eval(wtp(1,:)),zlevs,'Fill','on','Linestyle','none')
    %quiver(mcsDist,mcsDepth,-v,-w)
    plot(V.mcsDist(1,:),A(zi).Comp.mcsBed,'k')
    if zi == 1
        switch i
            case 1
                title('Streamwise (Primary) Velocity, centimeters/second')
            case 2
                title('Transverse (Secondary) Velocity, centimeters/second')
            case 3
                title('Vertical Velocity, centimeters/second')
            case 4
                title('Backscatter Intensity, dB')
            case 5
                title('Velocity Magnitude (Primary and Secondary), centimeters/second')
            case 6
                title('Deviation from Primary Flow Direction, degrees')
        end
    end
    if zi == ceil(z/2)
        ylabel('Depth, meters')
    end
    if zi == z
        xlabel('Distance, meters')
    end
    %set(gca,'DataAspectRatio',[4 1 1],'PlotBoxAspectRatio',[4 1 1])
    colorbar
    %caxis([-60 210])
    caxis([zmin zmax])
end
%     colorbar([0.6743 0.3586 0.01788 0.3184]);

