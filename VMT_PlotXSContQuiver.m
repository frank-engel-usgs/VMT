function [z,A,V,toquiv,log_text] = VMT_PlotXSContQuiver(z,A,V,var,sf,exag,qspchorz,qspcvert,secvecvar,vvelcomp,plot_english,allow_flux_flip,start_bank,varargin)
% This function plots the the contour plot (mean XS) for the variable 'var'
% and then plots quivers with secondary flow (vertical and transverse
% components) on top of the contour plot.  IF data is not supplied, user
% will be prompted to load data (browse to data).
%
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-10-08 
% Last modified: F.L. Engel, USGS, 2/20/2013


%% User input
if exist('plot_english') == 0
    plot_english = 0;  %plot english units (else metric)
    disp('No units specified, plotting in metric units by default')
end

AS = 1;  %Turns on and off autoscaling (0 = off, 1 = on)
if AS == 0
    MANrefvel = 25; %Reference velocity in cm/s (manual setting)
end

%% Parse any extra args
%  This is used by VMT_GraphicsControl
if any(size(varargin)>0)
    reference_velocity = varargin{1};
    distance           = varargin{2};
    depth              = varargin{3};
else
    reference_velocity = [];
    distance           = [];
    depth              = [];
end

%% Determine vector sign convention based on start_bank
% Add negative sign to reverse the +x direction (we take RHR with +x into
% the page lookign DS, matlab uses opposite convention)
switch start_bank
    case 'right_bank'
        v = 1;
    otherwise % 'left_bank' or 'auto'
        v = -1;
end

%% Plot the contour plot
if isempty(z) & isempty(A) & isempty(V)
    [z,A,V,zmin,zmax,cont_log_text,fig_contour_handle] = VMT_PlotXSCont([],[],[],var,exag,plot_english,allow_flux_flip,start_bank);
else
    [z,A,V,zmin,zmax,cont_log_text,fig_contour_handle] = VMT_PlotXSCont(z,A,V,var,exag,plot_english,allow_flux_flip,start_bank);
end
log_text = cont_log_text;

% if vvelcomp
%     disp(['Plotting Secondary Flow Vector Field: ' secvecvar ' (with vertical velocity component)'])
% else
%     disp(['Plotting Secondary Flow Vector Field: ' secvecvar ' (without vertical velocity component)'])
% end
%% Plot the secondary flow quivers

plotref = getpref('VMT','plotref');
if plot_english
    sf = sf/0.01;  %Scale factor changes with units--this makes the sf basically equal for engligh units to that for metric units
end

%User input 

clvls = 60;
%sf=3;       %Scale factor
%exag=50;    %Vertical exaggeration
%qspchorz=20;   %Vector spacing in # of ensembles

% Misc computations
if 0 %A(1).Sup.binSize_cm == 25  %Changed some stuff below--not sure of the reason this 25 cm binsize is singled out  PRJ  (singled out due to vertical velocity bias--omit for now)
    [I,J] = ind2sub(size(V.vp(2,:)),find(~isnan(V.vp(2,:))==1));  % Use row 2 because all row 1 values are nans (WHY???--set to zero for ringing?)
    et = J(1):qspchorz:J(end);
    [r c]=size(V.vp);
    bi = 1:2:r;  %8:4:r;
else
    % Valid vector "framing"
    % Find the "widest" row of validdata. Typically this is row 1 with RG data,
    % however it may not be for M9 and/or RR data.
    bb = sum(uint8(~isnan(V.vp)),2); % Row with the most valid data
    [~,i] = max(bb); 
    try
        [I,J] = ind2sub(size(V.vp(i,:)),find(~isnan(V.vp(i,:))==1));
    catch err % If something doesn't work, attempt to use first row anyway
        [I,J] = ind2sub(size(V.vp(1,:)),find(~isnan(V.vp(1,:))==1));
    end
    
    et = J(1):qspchorz:J(end);
    [r c]=size(V.vp);
    bi = 1:qspcvert:r;
end

%zmin = floor(nanmin(nanmin(V.vp))); 
%zmax = ceil(nanmax(nanmax(V.vp)));
%zinc = (zmax - zmin) / clvls;
%zlevs = zmin:zinc:zmax;

%Set the vertical velocity component
if vvelcomp  %include vertical velocity compoent in vector?
    vertcomp = V.wSmooth;
else
    vertcomp = zeros(size(V.wSmooth));
end

figure(fig_contour_handle); hold all
%quiver(V.mcsDist(bi,et),V.mcsDepth(bi,et),-sf.*V.vsSmooth(bi,et),-sf.*V.wSmooth(bi,et),0,'k')  
switch secvecvar
    case{'transverse'}  %uses secondary velocity computed in the plane of the mean cross section (i.e. transverse)
        vr = sqrt(abs((v.*sf.*V.vSmooth(bi,et)).^2 + (v.*sf./exag.*vertcomp(bi,et)).^2));
    case{'secondary_zsd'} %Uses secondary velocity computed with a zero secondary discharge
        vr = sqrt(abs((v.*sf.*V.vsSmooth(bi,et)).^2 + (v.*sf./exag.*vertcomp(bi,et)).^2));  
    case{'secondary_roz'}
        vr = sqrt(abs((v.*sf.*V.Roz.usSmooth(bi,et)).^2 + (v.*sf./exag.*vertcomp(bi,et)).^2));
    case{'secondary_roz_y'}
        vr = sqrt(abs((v.*sf.*V.Roz.usySmooth(bi,et)).^2 + (v.*sf./exag.*vertcomp(bi,et)).^2));
    case{'primary_roz_y'}
        vr = sqrt(abs((v.*sf.*V.Roz.upySmooth(bi,et)).^2 + (v.*sf./exag.*vertcomp(bi,et)).^2));
end
        
%vr=sqrt(abs(-sf.*V.vsSmooth(bi,et).^2+-sf./exag.*V.wSmooth(bi,et).^2));
[rw cl] = size(V.mcsDist(bi,et));
switch plotref
    case 'dfs'
        toquiv(:,1) = reshape(V.mcsDist(bi,et),rw*cl,1);
        toquiv(:,2) = reshape(V.mcsDepth(bi,et),rw*cl,1);
    case 'hab'
        HABdiff = bsxfun(@minus,V.mcsBed,V.mcsDepth); HABdiff(HABdiff<0) = nan;
        toquiv(:,1) = reshape(V.mcsDist(bi,et),rw*cl,1);
        toquiv(:,2) = reshape(HABdiff(bi,et),rw*cl,1);
end
switch secvecvar
    case{'transverse'}
        toquiv(:,3) = reshape(v.*sf.*V.vSmooth(bi,et),rw*cl,1); 
        refvel = ceil(max(max(abs(V.vSmooth(bi,et)))));
        %meansecvec = mean(mean(V.vSmooth(bi,et)));
    case{'secondary_zsd'}
        toquiv(:,3) = reshape(v.*sf.*V.vsSmooth(bi,et),rw*cl,1); %Add negative sign to reverse the +x direction (we take RHR with +x into the page lookign DS, matlab uses opposite convention)
        refvel = ceil(max(max(abs(V.vsSmooth(bi,et)))));
        %meansecvec = mean(mean(V.vsSmooth(bi,et)));
    case{'secondary_roz'}
        toquiv(:,3) = reshape(v.*sf.*V.Roz.usSmooth(bi,et),rw*cl,1); %Add negative sign to reverse the +x direction (we take RHR with +x into the page lookign DS, matlab uses opposite convention)
        refvel = ceil(max(max(abs(V.Roz.usSmooth(bi,et)))));
        %meansecvec = mean(mean(V.Roz.us(bi,et)));
    case{'secondary_roz_y'}
        toquiv(:,3) = reshape(v.*sf.*V.Roz.usySmooth(bi,et),rw*cl,1); %Add negative sign to reverse the +x direction (we take RHR with +x into the page lookign DS, matlab uses opposite convention)
        refvel = ceil(max(max(abs(V.Roz.usySmooth(bi,et)))));
        %meansecvec = mean(mean(V.Roz.usy(bi,et)));
    case{'primary_roz_y'}
        toquiv(:,3) = reshape(v.*sf.*V.Roz.upySmooth(bi,et),rw*cl,1); %Add negative sign to reverse the +x direction (we take RHR with +x into the page lookign DS, matlab uses opposite convention)
        refvel = ceil(max(max(abs(V.Roz.upySmooth(bi,et)))));
        %meansecvec = mean(mean(V.Roz.upy(bi,et))));
end
switch plotref
    case 'dfs'
        % In DFS, we always reverse the y axis, therefore add negative to
        % vertical vector components
        toquiv(:,4) = reshape(-sf./exag.*vertcomp(bi,et),rw*cl,1);  %Add negative sign to account for flipped vertical axes
    case 'hab'
        % In HAB, we do NOT reverse the y axis, therefore, do not negate
        % vertical component
        toquiv(:,4) = reshape(sf./exag.*vertcomp(bi,et),rw*cl,1);  %Add negative sign to account for flipped vertical axes
end
toquiv(:,5) = reshape(vr,rw*cl,1);

%Ref arrow
if isempty(distance)
    x1 = 0.06*max(max(V.mcsDist));
    x2 = 0.95*max(max(V.mcsBed));
    if AS == 0
        refvel = MANrefvel; %manual scaling
    end
else
    x1 = distance;
    x2 = depth;
    refvel = reference_velocity;
end
x3=sf.*refvel; %Set to rounded max secondary velocity (absolute value added 3/29/12 PRJ) (autoscaling)
x4=0;
x5=x3;
toquiv(end+1,1) = x1;
toquiv(end,2) = x2;
toquiv(end,3) = x3;
toquiv(end,4) = x4;
toquiv(end,5) = x5;
%quiverc(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),sf); hold on


if plot_english
    unitlabel = '(ft/s)';
else
    unitlabel = '(cm/s)';
end

if plot_english %english units
    convfact = 0.03281; %cm/s to ft/s
    switch var
        case{'backscatter'}
            convfact = 1.0; 
        case{'flowangle'}
            convfact = 1.0;
    end
    
    switch plotref
        case 'dfs'
            %ylim([0 max(V.mcsBed*3.281)])
            ylabel_handle = ylabel('Depth (ft)');
            xlabel_handle = xlabel('Distance (ft)');
            rf_label_pos = [0.06*max(max(V.mcsDist)) 0.9*max(max(V.mcsBed))].*3.28084; % Conversion is to meters
            ref_vector_text_handle = text(rf_label_pos(1), rf_label_pos(2),[num2str(refvel*0.03281,3) ' ft/s'],'FontSize',12,'Color','w');
        case 'hab'
            %ylim([0 max(V.mcsBed*3.281)])
            ylabel_handle = ylabel('Height above bottom (ft)');
            xlabel_handle = xlabel('Distance (ft)');
            rf_label_pos = [0.06*max(max(V.mcsDist)) 0.9*max(max(V.mcsBed))].*3.28084; % Conversion is to meters
            ref_vector_text_handle = text(rf_label_pos(1), rf_label_pos(2),[num2str(refvel*0.03281,3) ' ft/s'],'FontSize',12,'Color','w');
    end
    
    hh = quiverc2wcmap(toquiv(:,1)*3.281,toquiv(:,2)*3.281,toquiv(:,3)*0.03281,toquiv(:,4)*0.03281,0,toquiv(:,5)*0.03281,exag);
    %plot(V.mcsDist(1,:)*3.281,V.mcsBed*3.281,'w', 'LineWidth',2); hold on
    
    caxis([zmin*convfact zmax*convfact]) %Reset the color bar to match that in the original contour plot
    switch var        
        case{'streamwise'}
            title_handle = title({['Streamwise Velocity ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'transverse'}
            title_handle = title({['Transverse Velocity ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'vertical'}
            title_handle = title({['Vertical Velocity ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'mag'}
            title_handle = title({['Velocity Magnitude (Streamwise and Transverse) ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'east'}
            title_handle = title({['East Velocity ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'error'}
            title_handle = title({['Error Velocity ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'north'}
            title_handle = title({['North Velocity ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'primary_zsd'}
            title_handle = title({['Primary Velocity (Zero Secondary Discharge Definition) ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'secondary_zsd'}
            title_handle = title({['Secondary Velocity (Zero Secondary Discharge Definition) ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'primary_roz'}
            title_handle = title({['Primary Velocity (Rozovskii Definition) ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'secondary_roz'}
            title_handle = title({['Secondary Velocity (Rozovskii Definition) ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'primary_roz_x'}
            title_handle = title({['Primary Velocity (Rozovskii Definition; Downstream Component) ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none'); 
        case{'primary_roz_y'}
            title_handle = title({['Primary Velocity (Rozovskii Definition; Cross-Stream Component) ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');       
        case{'secondary_roz_x'}
            title_handle = title({['Secondary Velocity (Rozovskii Definition; Downstream Component) ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');       
        case{'secondary_roz_y'}
            title_handle = title({['Secondary Velocity (Rozovskii Definition; Cross-Stream Component) ' unitlabel];['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'backscatter'}
            title_handle = title({'Backscatter Intensity (dB)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'flowangle'}
            title_handle = title({'Flow Direction (deg)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'vorticity_vw'}
            title_handle = title({'Streamwise Vorticity';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'vorticity_zsd'}
            title_handle = title({'Streamwise Vorticity (Zero Secondary Discharge Definition)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'vorticity_roz'}
            title_handle = title({'Streamwise Vorticity (Rozovskii Definition)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
    end
    


    
else %metric units
    hh = quiverc2wcmap(toquiv(:,1),toquiv(:,2),toquiv(:,3),toquiv(:,4),0,toquiv(:,5),exag);
    %plot(V.mcsDist(1,:),V.mcsBed,'w', 'LineWidth',2); hold on
    %ylim([0 max(V.mcsBed)])
    switch plotref
        case 'dfs'
            ylabel_handle = ylabel('Depth (m)');
            xlabel_handle = xlabel('Distance (m)');
            rf_label_pos = [0.06*max(max(V.mcsDist)) 0.9*max(max(V.mcsBed))];
            ref_vector_text_handle = text(rf_label_pos(1), rf_label_pos(2),[num2str(refvel) ' cm/s'],'FontSize',12,'Color','w');
        case 'hab'
            ylabel_handle = ylabel('Height above bottom (m)');
            xlabel_handle = xlabel('Distance (m)');
            rf_label_pos = [0.06*max(max(V.mcsDist)) 0.9*max(max(V.mcsBed))];
            ref_vector_text_handle = text(rf_label_pos(1), rf_label_pos(2),[num2str(refvel) ' cm/s'],'FontSize',12,'Color','w');
    end
    %Reset the color bar to match that in the original contour plot
    if strcmp(var,'vorticity_vw')||strcmp(var,'vorticity_zsd')||strcmp(var,'vorticity_roz')
        rng = zmax - zmin;
        caxis([-rng/2 rng/2])
    else
        caxis([zmin zmax])
    end
    switch var        
        case{'streamwise'}
            title_handle = title({'Streamwise Velocity (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'transverse'}
            title_handle = title({'Transverse Velocity (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'vertical'}
            title_handle = title({'Vertical Velocity (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'mag'}
            title_handle = title({'Velocity Magnitude (Streamwise and Transverse) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'east'}
            title_handle = title({'East Velocity (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'error'}
            title_handle = title({'Error Velocity (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'north'}
            title_handle = title({'North Velocity (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'primary_zsd'}
            title_handle = title({'Primary Velocity (Zero Secondary Discharge Definition) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'secondary_zsd'}
            title_handle = title({'Secondary Velocity (Zero Secondary Discharge Definition) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'primary_roz'}
            title_handle = title({'Primary Velocity (Rozovskii Definition) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'secondary_roz'}
            title_handle = title({'Secondary Velocity (Rozovskii Definition) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');   
        case{'primary_roz_x'}
            title_handle = title({'Primary Velocity (Rozovskii Definition; Downstream Component) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'primary_roz_y'}
            title_handle = title({'Primary Velocity (Rozovskii Definition; Cross-Stream Component) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'secondary_roz_x'}
            title_handle = title({'Secondary Velocity (Rozovskii Definition; Downstream Component) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');       
        case{'secondary_roz_y'}
            title_handle = title({'Secondary Velocity (Rozovskii Definition; Cross-Stream Component) (cm/s)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'backscatter'}
            title_handle = title({'Backscatter Intensity (dB)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'flowangle'}
            title_handle = title({'Flow Direction (deg)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'vorticity_vw'}
            title_handle = title({'Streamwise Vorticity';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'vorticity_zsd'}
            title_handle = title({'Streamwise Vorticity (Zero Secondary Discharge Definition)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
        case{'vorticity_roz'}
            title_handle = title({'Streamwise Vorticity (Rozovskii Definition)';['with secondary flow vectors (' secvecvar ')']},'Interpreter','none');
    end
    
    

end

% Tag the elements in the figure
secondary_vector_handles = findobj(gcf,'Type','line','-not','tag','PlotBedElevation');
set(secondary_vector_handles,       'Tag','SecondaryVectors')
set(ref_vector_text_handle,         'Tag','ReferenceVectorText')
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
if 1  %Set the vector line widths
    VectorLineWidth = 1.0;
    set(secondary_vector_handles  ,'LineWidth',VectorLineWidth)
end



% scrsz = get(0,'ScreenSize');
% figure('OuterPosition',[1 scrsz(4) scrsz(3) scrsz(4)])

%Display the ratio of the mean secondary and primary velocity magnitudes 
spratio_zsd = nanmedian(nanmedian(abs(V.vs)))./nanmedian(nanmedian(abs(V.vp)));
spratio_roz = nanmedian(nanmedian(abs(V.Roz.usy)))./nanmedian(nanmedian(abs(V.Roz.up)));
% disp(['Ratio of median Secondary to median Primary Velocity (zsd) = ' num2str(spratio_zsd)])
% disp(['Ratio of median Secondary to median Primary Velocity (roz) = ' num2str(spratio_roz)])
log_text = vertcat(log_text,...
    {['   Ratio of median Secondary to median Primary Velocity (zsd) = ' num2str(spratio_zsd)];...
    ['   Ratio of median Secondary to median Primary Velocity (roz) = ' num2str(spratio_roz)]}...
    );

return


%Add labels to the reference arrow and colorbar
% text(50,12,['Vertical Distances Exaggerated by ',num2str(exag)],'FontSize',16)
% text(140,17,'10 cm/s','FontSize',16)

