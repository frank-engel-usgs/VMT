function VMT_ExportFIG(path,fignum,BkgdColor,AxColor,FigColor,FntSize,Res,Format)

%This script exports the given figure and formats it according to the
%specified properties:

%BkgdColor: Background Color (outside of figure space)
%AxColor:   Axes Color 
%FigColor:  Figure window color (inside figure Space)
%FntSize:   Fontsize for axes labels and title
%Res:       resolution (dpi)
%Format:    'png' or 'eps'

%P.R. Jackson, USGS, 8-6-12

figure(fignum); 
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
end

set(gcf,'InvertHardCopy','off')

%Save the figure

switch Format 
    case 'png'
        [file,path] = uiputfile('*.png','Save file name')
        fileout = [path file];
        %fileout = [path '_Figure' num2str(fignum)];
        disp(fileout)
        set(gcf, 'PaperPositionMode', 'auto');
        print(['-f' num2str(fignum)],'-dpng', '-noui', '-painters',['-r' num2str(Res)],fileout)
    case 'eps'
        [file,path] = uiputfile('*.eps','Save file name')
        fileout = [path file];
        %fileout = [path '_Figure' num2str(fignum)];
        disp(fileout)
        set(gcf, 'PaperPositionMode', 'auto');
        print(['-f' num2str(fignum)],'-depsc', '-noui', '-painters',['-r' num2str(Res)],fileout)
    % Default
    otherwise
        [file,path] = uiputfile('*.png','Save file name')
        fileout = [path file];
        %fileout = [path '_Figure' num2str(fignum)];
        disp(fileout)
        set(gcf, 'PaperPositionMode', 'auto');
        print(['-f' num2str(fignum)],'-dpng', '-noui', '-painters',['-r' num2str(Res)],fileout)
end






