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

% COMPILE AND RELEASE NOTES
% Before releasing a new version of the software, ensure the following
% tasks have been completed:
%   1. Review and update User Guide. Ensure that the version date and
%   revision are correct. Save as a PDF in the doc folder.
%   2. Update the html function library (code to do this is in the IF
%   statement below). 
%   3. Update CHANGELOG.md from a Bash window with the command:
%       git log --pretty --decorate > CHANGELOG.md
%   4. Make a commit and push. Note the commit ID. This will be the version
%   to tag
%   5. Tag the version from Bash window using:
%       git tag -a v4.xx-rcx [commit hex id] -m "Message about version."
%       git push origin v4.xx-rcx
%   6. Run this file. Save result on local machine
%   7. Build/modify Inno Script Studio file to create self-instaling exe.
%   Include a copy of the LICENSE file (3 clause BSD).
%   8. Update OSW website.

% Destination of EXE
% ------------------
[fname,pathname] = uiputfile('VMT.exe','Select where to save VMT compiled executable');

[~, filename,ext] = fileparts(fname);

% Update documentation
% --------------------
if 0
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

% Software icon
copyfile('VMT.ico',[pathname 'VMT.ico'])

% Documentation
backup([pwd filesep 'doc'],[pathname 'doc'],[],'/E /Y')

% Default colormaps
backup([pwd filesep 'cpt'],[pathname 'cpt'],[],'/E /Y')

