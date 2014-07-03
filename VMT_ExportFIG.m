function VMT_ExportFIG(savepath,to_export,BkgdColor,AxColor,FigColor,FntSize,Res,Format)
% Exports the given figure and formats it according to the
% specified properties:
%
% BkgdColor: Background Color (outside of figure space)
% AxColor:   Axes Color 
% FigColor:  Figure window color (inside figure Space)
% FntSize:   Fontsize for axes labels and title
% Res:       resolution (dpi)
% Format:    'png' or 'eps'
%
% P.R. Jackson, USGS, 8-6-12
% Last modified: F.L. Engel 2/20/2013

% Make figure current focus
hf = figure(findobj('name',to_export));
figure(hf); 
set(gcf, 'PaperPositionMode', 'auto');
box on
if ~isempty(BkgdColor)
    set(gcf,'Color',BkgdColor);
end

if ~isempty(FntSize)
    set(gca,'FontSize',FntSize)
    set(get(gca,'Title'),'FontSize',FntSize) 
end

if ~isempty(FigColor)
    set(gca,'Color',FigColor)
end

if ~isempty(AxColor)
    set(gca,'XColor',AxColor)
    set(gca,'YColor',AxColor)
    set(gca,'ZColor',AxColor)
    set(findobj(gcf,'tag','Colorbar'),'FontSize',FntSize,'XColor',AxColor,'YColor',AxColor);
    set(get(gca,'Title'),'FontSize',FntSize,'Color',AxColor)
    set(get(gca,'xLabel'),'FontSize',FntSize,'Color',AxColor)
    set(get(gca,'yLabel'),'FontSize',FntSize,'Color',AxColor)
end

set(gcf,'InvertHardCopy','off')

%Save the figure

switch Format 
    case 'png'
        [file,pathname] = uiputfile('*.png',[to_export ' Export'],savepath);
        fileout = [pathname file];
        %fileout = [path '_Figure' num2str(fignum)];
        %disp(fileout)
        set(gcf, 'PaperPositionMode', 'auto');
        print(hf,'-dpng', '-noui', '-painters',['-r' num2str(Res)],fileout)
    case 'eps'
        [file,pathname] = uiputfile('*.eps',[to_export ' Export'],savepath);
        fileout = [pathname file];
        %fileout = [path '_Figure' num2str(fignum)];
        %disp(fileout)
        set(gcf, 'PaperPositionMode', 'auto');
        print(hf,'-depsc', '-noui', '-painters',['-r' num2str(Res)],fileout)
    % Default
    otherwise
        [file,pathname] = uiputfile('*.png',[to_export ' Export'],savepath);
        fileout = [pathname file];
        %fileout = [path '_Figure' num2str(fignum)];
        %disp(fileout)
        set(gcf, 'PaperPositionMode', 'auto');
        print(hf,'-dpng', '-noui', '-painters',['-r' num2str(Res)],fileout)
end






