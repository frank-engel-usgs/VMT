function VMT_SaveFigs(pathname,to_export,figure_style)
% Saves the figures (specified by fignums) from VMT as .PNG or EPS files
% (300 dpi).
%
% Added EPS 8-7-12
%
% FLE Changes 1/3/2013:
%   1. Edited code for formating and efficiency.
%   2. Changed the default printparameters to produce white backgrounds,
%      and recolor the bed in Fig #3 to be black.
%   3. Added functionality to apply custom cpt colormaps to the contour and
%      plan view plots (currently disabled)
%
% P.R. Jackson, USGS, 2-10-09
% Last modified: F.L. Engel, USGS, 2/20/2013





% disp('{Saving Figures...') %FIXME: migrate command line messages
if strcmpi('presentation',figure_style)
    style_print = false;
   
else
    style_print = true;
    
end

% Export Figure Defaults
BkgdColor   = 'white';
AxColor     = 'black';
FigColor    = 'white'; % [0.3 0.3 0.3]
FntSize     = 14;
Res         = 300; % dpi
Format      = 'png';

% Query the user for the format
Format = questdlg('What figure format would you prefer?', ...
    'Figure Export', ...
    'png','eps','png');

% Export the figure(s)
for i = 1:length(to_export)
    switch to_export{i}
        case 'Plan View Map'
            % Make figure current focus
            figure(findobj('name',to_export{i}))
            if style_print
                % Apply a custom colormap
                if 0
                    cptcmap('printvelocity.cpt')
                end
                
            else
                % Apply a custom colormap
                if 0
                    cptcmap('printvelocity.cpt')
                end
                BkgdColor   = 'black';
                AxColor     = 'white';
                FigColor    = 'black'; % [0.3 0.3 0.3]
            end
            
            VMT_ExportFIG(...
                pathname,...
                to_export{i},...
                BkgdColor,...
                AxColor,...
                FigColor,...
                FntSize,...
                Res,...
                Format);
            
        case 'Mean Cross Section Contour'
            % Make figure current focus
            figure(findobj('name',to_export{i}))
            if style_print
                
                %set(findobj(gcf,'tag','Colorbar')           ,'location' ,'southoutside')
                set(findobj(gca,'tag','PlotBedElevation')   ,'color'    ,'k')
                set(findobj(gca,'tag','ReferenceVectorText'),'color'    ,'k')
                
                % Apply a custom colormap for printing
                if 0
                    cptcmap('printvelocity.cpt')
                    %cptcmap('diverging_BrBg.cpt','flip',true)
                end
                
            else
                
                
                %set(findobj(gcf,'tag','Colorbar')           ,'location' ,'southoutside')
                set(findobj(gca,'tag','PlotBedElevation')   ,'color'    ,'w')
                set(findobj(gca,'tag','ReferenceVectorText'),'color'    ,'w')
                
                % Apply a custom colormap
                if 0
                    cptcmap('printvelocity.cpt')
                    %cptcmap('diverging_BrBg.cpt')
                else
                    colormap jet
                end
                
                BkgdColor = 'black';
                AxColor   = 'white';
                FigColor  = [0.3 0.3 0.3];
                
            end
            
            VMT_ExportFIG(...
                pathname,...
                to_export{i},...
                BkgdColor,...
                AxColor,...
                FigColor,...
                FntSize,...
                Res,...
                Format);
    end
end

