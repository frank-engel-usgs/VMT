function directory_name = uigetdir2(varargin)

%UIGETDIR2 Standard dialog box for selecting a directory which remembers
%last selected directory.
%   UIGETDIR2 is a wrapper for Matlab's UIGETDIR function which adds the
%   ability to remember the last selected directory.  UIGETDIR2 stores
%   information about the last selected directory in a mat file which it
%   looks for when called.
%
%   UIGETDIR2 can only remember the selected directory if the current
%   directory is writable so that a mat file can be stored.  Only
%   successful directory selections update the folder remembered.  If the
%   user cancels the directory selection dialog box then the remembered
%   path is left the same.
%
%   Usage is the same as UIGETDIR.
%
%   uigetdir('','Dialog box text')  Empty start path will invoke use of
%                                   last used directory if dialog text is
%                                   desired
%
%
%   See also UIGETDIR, UIGETFILE, UIPUTFILE.

%   Written by Chris J Cannell
%   Contact ccannell@gmail.com for questions or comments.
%   01/05/2006  Created
%   04/18/2007  Script checks if an empty string is passed as the first
%               argument, if so then last used directory is used in its
%               place (thanks to Jonathan Erickson for the bug report)


% name of mat file to save last used directory information
lastDirMat = 'lastUsedDir.mat';


%% Check passed arguments and load saved directory
% if start path is specified and not empty call uigetdir with arguments
% from user, if no arguments are passed or start path is empty load saved
% directory from mat file
if nargin > 0 && ~isempty(varargin{1})
    % call uigetdir with arguments passed from uigetdir2 function
    directory_name = uigetdir(varargin{:});
else
    % set default dialog open directory to the present working directory
    lastDir = pwd;
    % load last data directory
    if exist(lastDirMat, 'file') ~= 0
        % lastDirMat mat file exists, load it
        load('-mat', lastDirMat)
        % check if lastDataDir variable exists and contains a valid path
        if (exist('lastUsedDir', 'var') == 1) && ...
                (exist(lastUsedDir, 'dir') == 7)
            % set default dialog open directory
            lastDir = lastUsedDir;
        end
    end

    % check if second argument (dialog box text) was passed
    if nargin == 2
        % call uigetdir with saved directory and second argument from user
        directory_name = uigetdir(lastDir,varargin{2});
    else
        % call uigetdir with saved directory
        directory_name = uigetdir(lastDir);
    end
end


%% Store last used directory
% if the user did not cancel the directory dialog then update
% lastDirMat mat file with the folder selected
if ~isequal(directory_name,0)
    try
        % save last folder used to lastDirMat mat file
        lastUsedDir = directory_name;
        save(lastDirMat, 'lastUsedDir');
    catch
        % error saving lastDirMat mat file, display warning, the folder
        % will not be remembered
        disp(['Warning: Could not save file ''', lastDirMat, '''']);
    end
end
