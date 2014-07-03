%% Read in multiple ASCII .TXT Files
% This program reads in multiple ASCII text files into a single structure.

% August 5, 2008
% Jon Czuba
% USGS - Illinois Water Science Center

%% Determine Files to Process
% Prompt user for directory containing files
zPathName = uigetdir;
Files = dir(zPathName);
allFiles = {Files.name};
filefind=strfind(allFiles,'ASC.TXT')';
filesidx=nan(size(filefind,1),1);
for i=1:size(filefind,1)
    filesidx(i,1)=size(filefind{i},1);
end
filesidx=find(filesidx>0);
files=allFiles(filesidx);

% Allow user to select which files are to be processed
selection = listdlg('ListSize',[300 300],'ListString', files);
zFileName = files(selection);

% Determine number of files to be processed
if  isa(zFileName,'cell')
    z=size(zFileName,2);
    zFileName=sort(zFileName);       
else
    z=1;
    zFileName={zFileName}
end

%% Read in Selected Files
% Initialize row counter
j=0;
st=['A'; 'B'; 'C'; 'D'; 'E'; 'F'];
% Begin master loop
for zi=1:z
    % Open txt data file
    if  isa(zFileName,'cell')
        fileName=strcat(zPathName,'\',zFileName(zi));
        fileName=char(fileName);
    else
        fileName=strcat(zPathName,zFileName);
    end

    % screenData 0 leaves bad data as -32768, 1 converts to NaN
    screenData=1;

    % tfile reads the data from an RDI ASCII output file and puts the
    % data in a Matlab data structure with major groups of:
    % Sup - supporing data
    % Wat - water data
    % Nav - navigation data including GPS.
    % Sensor - Sensor data
    % Q - discharge related data
	ignoreBS = 0;
    [A(zi)]=tfile(fileName,screenData,ignoreBS);

end

%% Save data returned by tfile to .mat with same prefix as ASCII
idx=strfind(zFileName,'_');
namecut=zFileName{1}(1:idx{1}(1)-1);
numcut1=zFileName{1}(idx{1}(3)-2:idx{1}(3)-1);
numcut2=zFileName{z}(idx{z}(3)-2:idx{z}(3)-1);
savefile=strcat(namecut,'_',numcut1,'_',numcut2,'.mat');
save(savefile, 'A','z')

%% Clear Unwanted Variables

clear Files allFiles fileName filefind files filesidx i j screenData selection...
    st zPathName zi idx namecut numcut1 numcut2