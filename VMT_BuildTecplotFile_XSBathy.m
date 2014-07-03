function VMT_BuildTecplot_XSBathy(V,savefile)
% Takes the processed data structure and writes a TecPlot ASCII data file
% containing the mean cross section bathymetry.
% Modified from code by Frank L. Engel, USGS
%
% P.R. Jackson, USGS
% Last Edited: 2/20/2013
%
% 11-7-11: Fixed the issue with improper IJK dimensions which caused files
% to not load properly into Tecplot. (PRJ)
%
% TecPlot Variable List
% +=======================================================================+
% |   NAME             |   DESCRIPTION                                    |
% +=======================================================================+
% |   X                |   UTM Easting (m)                                |
% |   Y                |   UTM Northing (m)                               |
% |   BedDepth         |   Bed depth (m)                                  |
% |   Dist             |   dist across XS, oriented looking u/s (m)       |
% |   BedElev          |   Bed elevation (m)                              |
% +=======================================================================+
% 


format long

% disp('Creating TecPlot Data Grid...')
% Create block style matrix of all processed data
tecdata = [];

% Sort the Distances such that when plotting in 2D (Dist. vs. Depth), 
% you are looking upstream into the transect
Dist = sort(V.mcsDist,2,'descend');

% Build tecplot data matrix
tecdata = [V.mcsX(1,:)' V.mcsY(1,:)' V.mcsBed' Dist(1,:)'...
    V.mcsBedElev'];

%size(tecdata)
% Replace NaNs with a no data numeric value
nodata = -999;
n = find(isnan(tecdata));
tecdata(n) = nodata;

% Name of output file (needs to be modified to take handle args from GUI)
%outfile=['tecplot_Rosovskii_outfile.dat'];
outfile = [savefile(1:end-4) '_XSBathy.dat'];

% Print out a TECPLOT FILE
fid = fopen(outfile,'w');
fprintf(fid, 'TITLE     = "AVEXSEC_TECOUT"\n');
fprintf(fid, 'VARIABLES = "X"\n');
fprintf(fid, '"Y"\n');
fprintf(fid, '"BedDepth"\n');
fprintf(fid, '"Dist"\n');
fprintf(fid, '"BedElev"\n');
fprintf(fid, 'ZONE T="ZONE 1"\n');
fprintf(fid, ' I=%d  J=1',size(tecdata,1));
fprintf(fid, '  K=1');
fprintf(fid, ' F=POINT\n');
fprintf(fid, 'DT=(SINGLE SINGLE SINGLE SINGLE SINGLE)\n');
for m = 1:size(tecdata,1)
    fprintf(fid,'%13.10f %13.10f %10.8f %6.8f %10.8f\n',tecdata(m,:));
end
fclose(fid);

disp('Saving Tecplot ASCII XS Bathy Data file...')
%directory = pwd;
%fileloc = [directory '\' outfile];
disp(outfile)


format short