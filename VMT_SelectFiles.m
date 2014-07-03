function [zPathName,zFileName,zf] = VMT_SelectFiles;
% Prompts the user to select preprocessed transect files output by
% VMT_ReadFiles.
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-11-08
% Last modified: 3/21/2013
% Frank L. Engel, USGS IL WSC


%% Load the files

% Prompt user for directory containing files
defaultpath = 'C:\';
matpath = [];
if 0 %exist('VMT\LastDir.mat','file') == 2
    load('VMT\LastDir.mat');
    if exist(matpath,'dir') == 7
        matpath = uigetdir(matpath,'Select the Directory Containing Processed Data Files (*.mat)');
    else
        matpath = uigetdir(defaultpath,'Select the Directory Containing Processed Data Files (*.mat)');
    end
else
    matpath = uigetdir(defaultpath,'Select the Directory Containing Processed Data Files (*.mat)');
end
zPathName = matpath;
Files = dir(zPathName);
allFiles = {Files.name};
filefind=strfind(allFiles,'.mat')';
filesidx=nan(size(filefind,1),1);
for i=1:size(filefind,1)
    filesidx(i,1)=size(filefind{i},1);
end
filesidx=find(filesidx>0);
files=allFiles(filesidx);

if isempty(files)
    errordlg(['No *.MAT files found in ' matpath '.  Ensure you have chosen the correct directory and VMT processed files are present.']);
end

% Allow user to select which files are to be processed
selection = listdlg('ListSize',[300 300],'ListString', files,'Name','Select Data Files');
zFileName = files(selection);

% Determine number of files to be processed
if  isa(zFileName,'cell')
    zf=size(zFileName,2);
    zFileName = sort(zFileName);       
else
    zf=1;
    zFileName={zFileName}
end

%% Save the path
% if exist('LastDir.mat','file') == 2
    % save('LastDir.mat','matpath','-append')
% else
    % save('LastDir.mat','matpath')
% end
