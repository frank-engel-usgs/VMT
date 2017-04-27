function [z,A,V,zmin,zmax,log_text,fig_contour_handle] = VMT_PlotXSCont(z,A,V,var,exag,plot_english,allow_flux_flip,start_bank)
% Plots contours for the variable 'var' within the mean cross section given
% by the structure V. IF data is not supplied, user will be prompted to
% load data (browse to data).
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-10-08 
% Last modified: F.L. Engel, USGS, 2/20/2013



%disp(['Plotting Mean Cross Section Contour Plot: ' var])
log_text = {['Plotting Mean Cross Section Contour Plot']};

%% User Input

%exag=50;    %Vertical exaggeration
if exist('plot_english') == 0
    plot_english = 0;  %plot english units (else metric)
    disp('No units specified, plotting in metric units by default')
end

%% Load the data if not supplied
if isempty(z) & isempty(A) & isempty(V) 
    [zPathName,zFileName,zf] = VMT_SelectFiles;  %Have the user select the preprocessed input files
    eval(['load ' zPathName '\' zFileName{1}]);
end


%% Plot contours

% See if PLOT 3 exists already, if so clear the figure
fig_contour_handle = findobj(0,'name','Mean Cross Section Contour');

if ~isempty(fig_contour_handle) &&  ishandle(fig_contour_handle)
    figure(fig_contour_handle); clf
else
    fig_contour_handle = figure('name','Mean Cross Section Contour'); clf
    %set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1])
end

% Turn off the menu bar, and keep only specified tools
disableMenuBar(fig_contour_handle)

clvls = 60;

%Find the direction of primary discharge (flip if necessary)
binwidth  = abs(diff(V.mcsDist,1,2));
binwidth  = horzcat(binwidth(:,1), binwidth);
binheight = abs(diff(V.mcsDepth,1,1));
binheight = vertcat(binheight, binheight(1,:));
flux = nansum(nansum(V.u./100.*binwidth.*binheight)); %Not a true measured discharge because of averaging, smoothing, edges, etc. but close 

% if zerosecq
%     pdmin = nanmin(nanmin(V.vp));
%     pdmax = nanmax(nanmax(V.vp));
% else
%     pdmin = nanmin(nanmin(V.u));
%     pdmax = nanmax(nanmax(V.u));
% end 
switch allow_flux_flip
    case true
        if flux < 0; %abs(pdmin) > abs(pdmax)
            flipxs = 1;
        else
            flipxs = 0;
        end
    case false
        if flux < 0; %abs(pdmin) > abs(pdmax)
            msgbox({'===NOTICE===';
                'VMT has detected that the Mean Cross Section';
                'flux is negative. However, the user has selected';
                'not to allow VMT to flip the Cross Section.'},...
                'Negative flux detected');
        end
        flipxs = 0;
end

% Determine vector sign convention based on start_bank
% Add negative sign to reverse the +x direction (we take RHR with +x into
% the page lookign DS, matlab uses opposite convention)
% 
% When the user selects a right start_bank, let the flipxs be turned on so
% that the computations are correct. Otherwise, turn flipxs off. In the
% plotting, use the start_bank to enable flipping of the XDir in the plot
% ONLY if 'auto'
switch start_bank
    case 'right_bank'
        flipxs = 1;
    otherwise % 'left_bank' or 'auto'
        flipxs = 0;
end

if flipxs 
    %disp(['Streamwise Flow Direction (Normal to mean XS; deg) = ' num2str(V.phi - 180)])
    %disp(['Primary Flow Direction (deg) = ' num2str(V.phisp - 180)])
    strmwise = V.phi - 180;
    pflowd = V.phisp - 180;
    if strmwise < 0
        strmwise = 360 + strmwise;
    end
    if pflowd < 0
        pflowd = 360 + pflowd;
    end
    msg_str_1 = {['   Streamwise Flow Direction (Normal to mean XS; deg) = ' num2str(V.phi - 180)];...
        ['   Primary Flow Direction (deg) = ' num2str(V.phisp - 180)]};
else
    %disp(['Streamwise Flow Direction (Normal to mean XS; deg) = ' num2str(V.phi)])
    %disp(['Primary Flow Direction (deg) = ' num2str(V.phisp)])
    msg_str_1 = {['   Streamwise Flow Direction (Normal to mean XS; deg) = ' num2str(V.phi)];...
        ['   Primary Flow Direction (deg) = ' num2str(V.phisp)]};
end
%disp(['Deviation from Streamwise Direction (deg) = ' num2str(V.alphasp)])
%disp(['Horizontal Grid Node Spacing (m) = ' num2str(A(1).hgns)])

%Display in message box for compiled version
msg_string = {['   Deviation from Streamwise Direction (deg) = ' num2str(V.alphasp)];...
    ...['   Horizontal Grid Node Spacing (m) = ' num2str(A(1).hgns)]...
    };
%msgbox([msg_str_1, msg_string],'VMT Cross Section Characteristics','help','replace');
log_text = vertcat(log_text,msg_str_1,msg_string);

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
    case{'east'} %Plots the east velocity
        wtp=['V.mcsEastSmooth'];
        zmin=floor(nanmin(nanmin(V.mcsEastSmooth)));
        zmax=ceil(nanmax(nanmax(V.mcsEastSmooth)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'error'} %Plots the error velocity
        wtp=['V.mcsErrorSmooth'];
        zmin=floor(nanmin(nanmin(V.mcsErrorSmooth)));
        zmax=ceil(nanmax(nanmax(V.mcsErrorSmooth)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'north'} %Plots the north velocity
        wtp=['V.mcsNorthSmooth'];
        zmin=floor(nanmin(nanmin(V.mcsNorthSmooth)));
        zmax=ceil(nanmax(nanmax(V.mcsNorthSmooth)));
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
    case{'flowangle'} %Plots the flow direction (N = 0.0 deg)
        wtp=['V.mcsDirSmooth'];
        zmin=floor(nanmin(nanmin(V.mcsDirSmooth)));
        zmax=ceil(nanmax(nanmax(V.mcsDirSmooth)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'vorticity_vw'} 
        wtp=['V.vorticity_vw'];
        zmin=floor(nanmin(V.vorticity_vw(:)));
        zmax=ceil(nanmax(V.vorticity_vw(:)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'vorticity_zsd'}
        wtp=['V.vorticity_zsd'];
        zmin=floor(nanmin(V.vorticity_zsd(:)));
        zmax=ceil(nanmax(V.vorticity_zsd(:)));
        zinc = (zmax - zmin) / clvls;
        zlevs = zmin:zinc:zmax;
    case{'vorticity_roz'} 
        wtp=['V.vorticity_roz'];
        zmin = floor(nanmin(V.vorticity_roz(:)));
        zmax = ceil(nanmax(V.vorticity_roz(:)));
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


figure(fig_contour_handle); hold all
plotref = getpref('VMT','plotref');
switch plotref
    case 'dfs'
        if plot_english
            convfact = 0.03281; %cm/s to ft/s
            switch var
                case{'backscatter'}
                    convfact = 1.0;
                case{'flowangle'}
                    convfact = 1.0;
            end
            contour_handle = pcolor(V.mcsDist*3.281,V.mcsDepth*3.281,eval(wtp)*convfact); hold on
            shading interp
            %[~,contour_handle] = contour(V.mcsDist*3.281,V.mcsDepth*3.281,eval(wtp)*convfact,zlevs*convfact,'Fill','on','Linestyle','none'); hold on  %wtp(1,:)
            bed_handle         = plot(V.mcsDist(1,:)*3.281,V.mcsBed*3.281,'w', 'LineWidth',2); hold on
        else
            contour_handle = pcolor(V.mcsDist,V.mcsDepth,eval(wtp)); hold on
            shading interp
            %[~,contour_handle] = contour(V.mcsDist,V.mcsDepth,eval(wtp),zlevs,'Fill','on','Linestyle','none'); hold on  %wtp(1,:)
            bed_handle         = plot(V.mcsDist(1,:),V.mcsBed,'w', 'LineWidth',2); hold on
        end
        
    case 'hab'
        if plot_english
            convfact = 0.03281; %cm/s to ft/s
            switch var
                case{'backscatter'}
                    convfact = 1.0;
                case{'flowangle'}
                    convfact = 1.0;
            end
            HABdiff = bsxfun(@minus,V.mcsBed,V.mcsDepth); HABdiff(HABdiff<0) = nan;
            contour_handle = pcolor(V.mcsDist*3.281,HABdiff*3.281,eval(wtp)*convfact); hold on
            shading interp
            %[~,contour_handle] = contour(V.mcsDist*3.281,V.mcsDepth*3.281,eval(wtp)*convfact,zlevs*convfact,'Fill','on','Linestyle','none'); hold on  %wtp(1,:)
            eta = V.eta*3.281;
            wse = eta + V.mcsBed*3.281;
            bed_handle         = plot(V.mcsDist(1,:)*3.281,wse,'w--', 'LineWidth',2); hold on
            
        else
            HABdiff = bsxfun(@minus,V.mcsBed,V.mcsDepth); HABdiff(HABdiff<0) = nan;
            contour_handle = pcolor(V.mcsDist,HABdiff,eval(wtp)); hold on
            shading interp
            %[~,contour_handle] = contour(V.mcsDist,V.mcsDepth,eval(wtp),zlevs,'Fill','on','Linestyle','none'); hold on  %wtp(1,:)
            % Instead of plotting bed, plot the WSE. Name is still kept for
            % coding purposes
            eta = V.eta;
            wse = eta + V.mcsBed;
            bed_handle         = plot(V.mcsDist(1,:),wse,'w--', 'LineWidth',2); hold on
        end
        

end

if plot_english
    unitlabel = '(ft/s)';
else
    unitlabel = '(cm/s)';
end

switch var
    case{'streamwise'}
        title_handle = title(['Streamwise Velocity ' unitlabel]);
    case{'transverse'}
        title_handle = title(['Transverse Velocity ' unitlabel]);
    case{'vertical'}
        title_handle = title(['Vertical Velocity ' unitlabel]);
    case{'mag'}
        title_handle = title(['Velocity Magnitude (Streamwise and Transverse) ' unitlabel]);
    case{'east'}
        title_handle = title(['East Velocity ' unitlabel]);
    case{'north'}
        title_handle = title(['North Velocity ' unitlabel]);
    case{'error'}
        title_handle = title(['Error Velocity ' unitlabel]);
    case{'primary_zsd'}
        title_handle = title(['Primary Velocity (Zero Secondary Discharge Definition) ' unitlabel]);
    case{'secondary_zsd'}
        title_handle = title(['Secondary Velocity (Zero Secondary Discharge Definition) ' unitlabel]);
    case{'primary_roz'}
        title_handle = title(['Primary Velocity (Rozovskii Definition) ' unitlabel]);
    case{'secondary_roz'}
        title_handle = title(['Secondary Velocity (Rozovskii Definition) ' unitlabel]);
    case{'primary_roz_x'}
        title_handle = title(['Primary Velocity (Rozovskii Definition; Downstream Component) ' unitlabel]);
    case{'primary_roz_y'}
        title_handle = title(['Primary Velocity (Rozovskii Definition; Cross-Stream Component) ' unitlabel]);
    case{'secondary_roz_x'}
        title_handle = title(['Secondary Velocity (Rozovskii Definition; Downstream Component) ' unitlabel]);
    case{'secondary_roz_y'}
        title_handle = title(['Secondary Velocity (Rozovskii Definition; Cross-Stream Component) ' unitlabel]);
    case{'backscatter'}
        title_handle = title('Backscatter Intensity (dB)');
    case{'flowangle'}
        title_handle = title('Flow Direction (deg)');
    case{'vorticity_vw'}
        title_handle = title('Streamwise Vorticity');
    case{'vorticity_zsd'}
        title_handle = title('Streamwise Vorticity (Zero Secondary Discharge Definition)');
    case{'vorticity_roz'}
        title_handle = title('Streamwise Vorticity (Rozovskii Definition)');
        %     case{'dirdevp'}
        %         title('Deviation from Primary Flow Direction (deg)')
end
colorbar_handle = colorbar; hold all



switch plotref
    case 'dfs'
        if plot_english
            caxis([zmin*convfact zmax*convfact])
            xlim([nanmin(nanmin(V.mcsDist*3.281)) nanmax(nanmax(V.mcsDist*3.281))])
            ylim([0 max(V.mcsBed*3.281)])
            set(gca,'YDir','reverse')
            ylabel_handle = ylabel('Depth (ft)');
            xlabel_handle = xlabel('Distance (ft)');
            if flipxs && strcmpi(start_bank,'auto')
                set(gca,'XDir','reverse')
            end
        else
            caxis([zmin zmax])
            xlim([nanmin(nanmin(V.mcsDist)) nanmax(nanmax(V.mcsDist))])
            ylim([0 max(V.mcsBed)])
            set(gca,'YDir','reverse')
            ylabel_handle = ylabel('Depth (m)');
            xlabel_handle = xlabel('Distance (m)');
            if flipxs && strcmpi(start_bank,'auto')
                set(gca,'XDir','reverse')
            end
        end
    case 'hab'
        if plot_english
            caxis([zmin*convfact zmax*convfact])
            xlim([nanmin(nanmin(V.mcsDist*3.281)) nanmax(nanmax(V.mcsDist*3.281))])
            ylim([min([eta V.mcsBed*3.281]) max(wse)])
            set(gca,'YDir','normal')
            ylabel_handle = ylabel('Height above bottom (ft)');
            xlabel_handle = xlabel('Distance (ft)');
            if flipxs && strcmpi(start_bank,'auto')
                set(gca,'XDir','reverse')
            end
        else
            caxis([zmin zmax])
            xlim([nanmin(nanmin(V.mcsDist)) nanmax(nanmax(V.mcsDist))])
            ylim([min([eta V.mcsBed]) max([wse])])
            set(gca,'YDir','normal')
            ylabel_handle = ylabel('Height above bottom (m)');
            xlabel_handle = xlabel('Distance (m)');
            if flipxs && strcmpi(start_bank,'auto')
                set(gca,'XDir','reverse')
            end
        end
end


if strcmp(var,'vorticity_vw')||strcmp(var,'vorticity_zsd')||strcmp(var,'vorticity_roz')
    rng = zmax - zmin;
    cmr = [linspace(0,1,25)'];
    cmr = [cmr; linspace(1,1,25)'];
    cmg = [linspace(0,1,25)'];
    cmg = [cmg; linspace(1,0,25)'];
    cmb = [linspace(1,1,25)'];
    cmb = [cmb; linspace(1,0,25)'];
    figure(gcf)
    colormap([cmr cmg cmb])
    caxis([-rng/2 rng/2])
else
    colormap jet
end

% Tag the elements in the figure
set(contour_handle,                 'Tag','ContouredVelocities')
set(bed_handle,                     'Tag','PlotBedElevation')
set(colorbar_handle,                'Tag','Colorbar')
set(title_handle,                   'Tag','ContourPlotTitle')
set(ylabel_handle,                  'Tag','yLabelText')
set(xlabel_handle,                  'Tag','xLabelText')

% Adjust the plot
set(gca,...
    'DataAspectRatio',   [exag 1 1],...
    'PlotBoxAspectRatio',[exag 1 1]...
    ...'FontSize',          14)
    )
% set(get(gca,'Title'),   'FontSize',14,'Color','w') 
% set(get(gca,'xlabel'),  'FontSize',14,'Color','w') 
% set(get(gca,'ylabel'),  'FontSize',14,'Color','w') 
% set(gca,...
%     'XColor','w',...
%     'YColor','w',...
%     'ZColor','w',...
%     'Color',[0.3 0.3 0.3])
% set(gcf,...
%     'InvertHardCopy','off',...
%     'Color','k')
%figure('Name','Cross Section','NumberTitle','off')
% scrsz = get(0,'ScreenSize');
% figure('OuterPosition',[1 scrsz(4) scrsz(3) scrsz(4)])

%figure(5); clf; compass(V.mcsEast,V.mcsNorth) 

