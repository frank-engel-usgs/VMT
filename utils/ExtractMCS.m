function [y,elev,wse] = ExtractMCS

%%
%Loads and plots the mean cross section bathymetry for a series of files
%from .mat files output from VMT.  Flips XS if looking upstream so all XS
%should be oriented looking DS. 

%P.R. Jackson, USGS, 7/16/09

%% Load the files

% Prompt user for directory containing files
zPathName = uigetdir('','Select the Directory Containing Processed Data Files (*.mat)');
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

%%
figure(1); clf
clrs = colormap(jet(zf));
for i = 1:zf
    wse(i)= input(['Water surface elevation (meters) for file ' zFileName{i} ' = ']);
    load([zPathName '\' zFileName{i}]);
    
    %Check the XS to see if it needs to be flipped
    %Find the direction of primary discharge (flip if necessary)
    binwidth  = diff(V.mcsDist,1,2);
    binwidth  = horzcat(binwidth(:,1), binwidth);
    binheight = diff(V.mcsDepth,1,1);
    binheight = vertcat(binheight, binheight(1,:));
    flux = nansum(nansum(V.u./100.*binwidth.*binheight)); %Not a true measured discharge because of averaging, smoothing, etc. but close 

    if flux < 0; %abs(pdmin) > abs(pdmax)
        flipxs = 1;
    else
        flipxs = 0;
    end
    if ~flipxs
        y{i} = V.mcsDist(1,:);
    else
        y{i} = max(V.mcsDist(1,:)) - V.mcsDist(1,:);
    end
    elev{i} = wse(i) - V.mcsBed;
    plot(y{i},elev{i},'-','Color',clrs(i,:)); hold on
end
%set(gca,'YDir','reverse')
xlabel('Distance (m)')
ylabel('Elevation (m)')
legend(zFileName,'Interpreter','none')