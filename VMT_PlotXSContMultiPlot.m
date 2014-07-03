function [z,A,V,zmin,zmax] = VMT_PlotXSContMultiPlot(z,A,V,var,exag)
% Currently not implemented
% Plots contours for the variable 'var' within the
% mean cross section given by the structure V. IF data is not supplied, user
% will be prompted to load data (browse to data).
%
% Multiplot allows the user to plot multiple cross sections on the same
% plot. P.R. Jackson, 6-28-10  (NOT WORKING YET)
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-10-08 



disp(['Plotting Mean Cross Section Contour Plot: ' var])

%% User Input

%exag=50;    %Vertical exaggeration


%% Load the data if not supplied
if isempty(z) & isempty(A) & isempty(V) 
    [zPathName,zFileName,zf] = VMT_SelectFiles;  %Have the user select the preprocessed input files
    eval(['load ' zPathName '\' zFileName{1}]);
end


%% Plot contours

clvls = 60;

%Find the direction of primary discharge (flip if necessary)
binwidth  = diff(V.mcsDist,1,2);
binwidth  = horzcat(binwidth(:,1), binwidth);
binheight = diff(V.mcsDepth,1,1);
binheight = vertcat(binheight, binheight(1,:));
flux = nansum(nansum(V.u./100.*binwidth.*binheight)); %Not a true measured discharge because of averaging, smoothing, etc. but close 

% if zerosecq
%     pdmin = nanmin(nanmin(V.vp));
%     pdmax = nanmax(nanmax(V.vp));
% else
%     pdmin = nanmin(nanmin(V.u));
%     pdmax = nanmax(nanmax(V.u));
% end 
if flux < 0; %abs(pdmin) > abs(pdmax)
    flipxs = 1;
else
    flipxs = 0;
end

if flipxs 
    disp(['Streamwise Flow Direction (Perp. to mean XS; deg) = ' num2str(V.phi - 180)])
    disp(['Primary Flow Direction (deg) = ' num2str(V.phisp - 180)])
else
    disp(['Streamwise Flow Direction (Perp. to mean XS; deg) = ' num2str(V.phi)])
    disp(['Primary Flow Direction (deg) = ' num2str(V.phisp)])
end
disp(['Deviation from Streamwise Direction (deg) = ' num2str(V.alphasp)])

switch var
    case{'streamwise'}  %Plots the streamwise velocity
        if flipxs
            wtp=['-V.uSmooth'];
            zmin=floor(nanmin(nanmin(-V.uSmooth)));
            zmax=ceil(nanmax(nanmax(-V.uSmooth)));
        else
            wtp=['V.uSmooth'];
            zmin=floor(nanmin(nanmin(V.uSmooth)));
            zmax=ceil(nanmax(nanmax(V.uSmooth)));
        end
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;     
    case{'transverse'} %Plots the transverse velocity
        wtp=['V.vSmooth'];
        zmax=ceil(max(abs(nanmin(nanmin(V.vSmooth))),abs(nanmax(nanmax(V.vSmooth)))));
        zmin=-zmax;
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'vertical'} %Plots the vertical velocity
        wtp=['V.wSmooth'];
        zmax=ceil(max(abs(nanmin(nanmin(V.wSmooth))),abs(nanmax(nanmax(V.wSmooth)))));
        zmin=-zmax;
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'mag'} %Plots the velocity magnitude
        wtp=['V.mcsMagSmooth'];
        zmin=floor(nanmin(nanmin(V.mcsMagSmooth)));
        zmax=ceil(nanmax(nanmax(V.mcsMagSmooth)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'primary_zsd'}  %Plots the primary velocity with zero secondary discharge definition
        if flipxs
            wtp=['-V.vpSmooth'];
            zmin=floor(nanmin(nanmin(-V.vpSmooth)));
            zmax=ceil(nanmax(nanmax(-V.vpSmooth)));
        else
            wtp=['V.vpSmooth'];
            zmin=floor(nanmin(nanmin(V.vpSmooth)));
            zmax=ceil(nanmax(nanmax(V.vpSmooth)));
        end
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;                  
    case{'secondary_zsd'} %Plots the secondary velocity with zero secondary discharge definition
        wtp=['V.vsSmooth'];
        zmax=ceil(max(abs(nanmin(nanmin(V.vsSmooth))),abs(nanmax(nanmax(V.vsSmooth)))));
        zmin=-zmax;
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'primary_roz'}  %Plots the primary velocity with Rozovskii definition
%         wtp=['V.Roz.upSmooth'];
%         zmin=floor(nanmin(nanmin(V.Roz.upSmooth)));
%         zmax=ceil(nanmax(nanmax(V.Roz.upSmooth)));
        
        if flipxs
            wtp=['-V.Roz.upSmooth'];  
            zmin=floor(nanmin(nanmin(-V.Roz.upSmooth)));
            zmax=ceil(nanmax(nanmax(-V.Roz.upSmooth)));
        else
            wtp=['V.Roz.upSmooth'];
            zmin=floor(nanmin(nanmin(V.Roz.upSmooth)));
            zmax=ceil(nanmax(nanmax(V.Roz.upSmooth)));
        end
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;                
    case{'secondary_roz'} %Plots the secondary velocity with Rozovskii definition
        wtp=['V.Roz.usSmooth'];
        zmax=ceil(max(abs(nanmin(nanmin(V.Roz.usSmooth))),abs(nanmax(nanmax(V.Roz.usSmooth)))));
        zmin=-zmax;
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'primary_roz_x'}  %Plots the primary velocity with Rozovskii definition (downstream component)
%         wtp=['V.Roz.upxSmooth'];
%         zmin=floor(nanmin(nanmin(V.Roz.upxSmooth)));
%         zmax=ceil(nanmax(nanmax(V.Roz.upxSmooth)));
      
        if flipxs
            wtp=['-V.Roz.upxSmooth'];  
            zmin=floor(nanmin(nanmin(-V.Roz.upxSmooth)));
            zmax=ceil(nanmax(nanmax(-V.Roz.upxSmooth)));
        else
            wtp=['V.Roz.upxSmooth'];
            zmin=floor(nanmin(nanmin(V.Roz.upxSmooth)));
            zmax=ceil(nanmax(nanmax(V.Roz.upxSmooth)));
        end
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax; 
    case{'primary_roz_y'}  %Plots the primary velocity with Rozovskii definition (cross-stream component)
        wtp=['V.Roz.upySmooth'];
        zmin=floor(nanmin(nanmin(V.Roz.upySmooth)));
        zmax=ceil(nanmax(nanmax(V.Roz.upySmooth)));
            
%         if flipxs
%             wtp=['-V.Roz.upySmooth'];  
%             zmin=floor(nanmin(nanmin(-V.Roz.upySmooth)));
%             zmax=ceil(nanmax(nanmax(-V.Roz.upySmooth)));
%         else
%             wtp=['V.Roz.upySmooth'];
%             zmin=floor(nanmin(nanmin(V.Roz.upySmooth)));
%             zmax=ceil(nanmax(nanmax(V.Roz.upySmooth)));
%         end
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'secondary_roz_x'} %Plots the secondary velocity with Rozovskii definition (downstream component)
        wtp=['V.Roz.usxSmooth'];
        zmax=ceil(max(abs(nanmin(nanmin(V.Roz.usxSmooth))),abs(nanmax(nanmax(V.Roz.usxSmooth)))));
        zmin=-zmax;
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'secondary_roz_y'} %Plots the secondary velocity with Rozovskii definition (cross-stream component)
        wtp=['V.Roz.usySmooth'];
        zmax=ceil(max(abs(nanmin(nanmin(V.Roz.usySmooth))),abs(nanmax(nanmax(V.Roz.usySmooth)))));
        zmin=-zmax;
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;        
    case{'backscatter'} %Plots the backscatter
        wtp=['V.mcsBackSmooth'];
        zmin=floor(nanmin(nanmin(V.mcsBackSmooth)));
        zmax=ceil(nanmax(nanmax(V.mcsBackSmooth)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'flowangle'} %Plots the flow angle (ROZ)
        wtp=['V.Roz.theta_degSmooth'];
        zmin=floor(nanmin(nanmin(V.Roz.theta_degSmooth)));
        zmax=ceil(nanmax(nanmax(V.Roz.theta_degSmooth)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;

%     case{'dirdevp'} %Plots the directional deviation from the primary velocity
%         wtp=['V.mcsDirDevp'];
%         %zmax=ceil(max(abs(nanmin(nanmin(V.mcsDirDevp))),abs(nanmax(nanmax(V.mcsDirDevp)))));
%         %zmin=-zmax;
%         zmin=floor(nanmin(nanmin(V.mcsDirDevp)));
%         zmax=ceil(nanmax(nanmax(V.mcsDirDevp)));
%         zinc = (zmax - zmin) / clvls;
%         zlevs = zmin:zinc:zmax;
end

        
figure(3); clf
contour(V.mcsDist,V.mcsDepth,eval(wtp(1,:)),zlevs,'Fill','on','Linestyle','none'); hold on
plot(V.mcsDist(1,:),V.mcsBed,'w', 'LineWidth',2); hold on

switch var
    case{'streamwise'}
        title('Streamwise Velocity (cm/s)')
    case{'transverse'}
        title('Transverse Velocity (cm/s)')
    case{'vertical'}
        title('Vertical Velocity (cm/s)')
    case{'mag'}
        title('Velocity Magnitude (Streamwise and Transverse) (cm/s)')
    case{'primary_zsd'}
        title('Primary Velocity (Zero Secondary Discharge Definition) (cm/s)')
    case{'secondary_zsd'}
        title('Secondary Velocity (Zero Secondary Discharge Definition) (cm/s)')
    case{'primary_roz'}
        title('Primary Velocity (Rozovskii Definition) (cm/s)')
    case{'secondary_roz'}
        title('Secondary Velocity (Rozovskii Definition) (cm/s)')   
    case{'primary_roz_x'}
        title('Primary Velocity (Rozovskii Definition; Downstream Component) (cm/s)')    
    case{'primary_roz_y'}
        title('Primary Velocity (Rozovskii Definition; Cross-Stream Component) (cm/s)')        
    case{'secondary_roz_x'}
        title('Secondary Velocity (Rozovskii Definition; Downstream Component) (cm/s)')        
    case{'secondary_roz_y'}
        title('Secondary Velocity (Rozovskii Definition; Cross-Stream Component) (cm/s)')         
    case{'backscatter'}
        title('Backscatter Intensity (dB)')
    case{'flowangle'}
        title('Flow Angle (deg)')
%     case{'dirdevp'}
%         title('Deviation from Primary Flow Direction (deg)')
end
hdl = colorbar; hold all
caxis([zmin zmax])
xlim([nanmin(nanmin(V.mcsDist)) nanmax(nanmax(V.mcsDist))])
ylim([0 max(V.mcsBed)])
set(gca,'YDir','reverse')
if flipxs
    set(gca,'XDir','reverse')
end
ylabel('Depth (m)','Color','w')
xlabel('Distance (m)','Color','w')
set(gca,'DataAspectRatio',[exag 1 1],'PlotBoxAspectRatio',[exag 1 1])
%set(gcf,'Color','k');
set(gca,'FontSize',14)
set(get(gca,'Title'),'FontSize',14,'Color','w') 
%set(gca,'Color','k')
set(gca,'XColor','w')
set(gca,'YColor','w')
set(gca,'ZColor','w')
set(gcf,'InvertHardCopy','off')
set(gcf,'Color',[0.2 0.2 0.2])
set(gca,'Color',[0.3 0.3 0.3])



