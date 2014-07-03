% Prompt user for directory containing files
zPathName = uigetdir;
Files = dir(zPathName);
allFiles = {Files.name};
filefind=strfind(allFiles,'.mat')';
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
    zf=size(zFileName,2);
    zFileName=sort(zFileName);       
else
    zf=1;
    zFileName={zFileName}
end

clear Files allFiles filefind files filesidx i selection zPathName