function Make_VMT
% MAKE_VMT is a Matlab native "make" file for distributing VMT
% Run this script to compile VMT on a local machine running Matlab. It will
% also copy all externals (i.e., doc, and background image)
% Assumes all components are in the present working directory.
% 
% See also: mcc, copyfile, backup (FEX)
% 
% Frank L. Engel, USGS, IL WSC

addpath utils
addpath tools

% Destination of EXE
% ------------------
[fname,pathname] = uiputfile('VMT.exe','Select where to save VMT compiled executable');

[~, filename,ext] = fileparts(fname);

% Update documentation
% --------------------
if 1
    sdir = pwd;
    cd ..
    m2html('mfiles','VMT', 'htmldir', [sdir filesep 'doc'], 'recursive','on','template','frame','index','menu');
    cd (sdir)
end
% Command string
% --------------
% com_str = ['-o ' ...
%     filename ...
%     ' -W WinMain -T link:exe -d ' ...
%     pathname...
%     ' -N -p map -p stats -p images -p utils -p doc -p tools -v '...
%     'VMT.m -a VMT.fig'];
com_str = ['-o ' ...
    filename ...
    ' -W WinMain -T link:exe -d ' ...
    pathname...
    ' -N -p map -p stats -p utils -p doc -p tools -v '...
    'VMT.m -a VMT.fig'];

% Compile
% -------
eval(['mcc ' com_str])

% Package documentation and externals
% -----------------------------------

% Background image
copyfile('VMT_Background.png',[pathname 'VMT_Background.png'])

% Documentation
backup([pwd filesep 'doc'],[pathname 'doc'],[],'/E /Y')

% Default colormaps
backup([pwd filesep 'cpt'],[pathname 'cpt'],[],'/E /Y')

