function VMT_BuildTecplotFile(V,savefile)
% Takes the processed data structure and writes a TecPlot ASCII data file.
%
% Frank L. Engel, USGS
% Last Edited: 2/20/2013
%
% TecPlot Variable List
% +=======================================================================+
% |   NAME             |   DESCRIPTION                                    |
% +=======================================================================+
% |   X                |   UTM Easting (m)                                |
% |   Y                |   UTM Northing (m)                               |
% |   Depth            |   depth (m)                                      |
% |   Dist             |   dist across XS, oreinted looking u/s (m)       |
% |   u                |   stream-wise velocity magnitude per bin (cm/s)  |
% |   v                |   cross-stream velocity magnitude per bin (cm/s) |
% |   w                |   vertical velocity magnitude per bin (cm/s)     |
% |   vp               |   primary vel. component-0 discharge meth. (cm/s)|
% |   vs               |   secondary vel. comp.-0 discharge meth. (cm/s)  |
% |   U (Rotated)      |   depth-avg. stream-wise magnitude (cm/s)        |
% |   V (Rotated)      |   depth-avg. cross-stream magnitude (cm/s)       |
% |   ux (Rotated)     |   component of vel. in X dir., rotated (cm/s)    |
% |   uy (Rotated)     |   component of vel. in Y dir., rotated (cm/s)    |
% |   uz (Rotated)     |   component of vel. in Z dir., rotated (cm/s)    |
% |   Mag              |   vel magnitude (need better desc.) (cm/s)       |
% |   Bscat            |   backscatter (units?)                           |
% |   Dir              |   direction deviation (degrees)                  |
% |   vp (Roz)         |   primary vel. per bin using Rozovskii (cm/s)    |
% |   vs (Roz)         |   secondary vel. per bin using Rozovskii (cm/s)  |
% |   vpy (Roz)        |   cross-stream comp. of primary vel. (cm/s)      |
% |   vsy(Roz)         |   cross-stream comp. of secondary vel. (cm/s)    |
% |   phi_deg (Roz)    |   depth-avg. vel. vector angle (degrees)         |
% |   theta_deg (Roz)  |   individual bin vel. vector angle (degrees)     |
% +=======================================================================+
% 


format long

%disp('Creating TecPlot Data Grid...')
% Create block style matrix of all processed data
tecdata = [];

% Sort the Distances such that when plotting in 2D (Dist. vs. Depth), 
% you are looking upstream into the transect
Dist = sort(V.mcsDist,2,'descend');

% Create phi in degrees for each bin to place into Tecplot matrix
for k = 1:size(V.mcsMag,1)
    phi_deg(k,:) = V.Roz.phi_deg;
    U(k,:) = V.Roz.U;
    V1(k,:) = V.Roz.V; % renamed V1 to be different than struc V
end

% Rotate the depth-avg. vectors (no W vector computed)
Z = zeros(size(V.mcsMag,1),size(V.mcsMag,2));
[U_rot, V_rot, W_rot] = vrotation(U,V1,Z,V.Roz.alpha);

% Build tecplot data matrix
for k = 1:size(V.mcsX,2)
    for i = 1:size(V.mcsX,1)
        tempvec = [V.mcsX(i,k) V.mcsY(i,k) V.mcsDepth(i,k) Dist(i,k) ...
            V.u(i,k) V.v(i,k) V.w(i,k) V.vp(i,k) V.vs(i,k) U_rot(i,k) ...
            V_rot(i,k) V.Roz.ux(i,k) V.Roz.uy(i,k) ...
            V.Roz.uz(i,k) V.mcsMag(i,k) V.mcsBack(i,k) ...
            V.mcsDir(i,k) V.Roz.up(i,k) V.Roz.us(i,k) ...
            V.Roz.upy(i,k) V.Roz.usy(i,k) ...
            phi_deg(i,k) V.Roz.theta_deg(i,k)];
        tecdata = [tecdata; tempvec];
    end
end

% Replace NaNs with a no data numeric value
nodata = -999;
n = find(isnan(tecdata));
tecdata(n) = nodata;

% Name of output file (needs to be modified to take handle args from GUI)
%outfile=['tecplot_Rosovskii_outfile.dat'];
outfile = [savefile(1:end-4) '.dat'];

% Print out a TECPLOT FILE
fid = fopen(outfile,'w');
fprintf(fid, 'TITLE     = "AVEXSEC_TECOUT"\n');
fprintf(fid, 'VARIABLES = "X"\n');
fprintf(fid, '"Y"\n');
fprintf(fid, '"Depth"\n');
fprintf(fid, '"Dist"\n');
fprintf(fid, '"u"\n');
fprintf(fid, '"v"\n');
fprintf(fid, '"w"\n');
fprintf(fid, '"vp"\n');
fprintf(fid, '"vs"\n');
fprintf(fid, '"U (Rotated)"\n');
fprintf(fid, '"V (Rotated)"\n');
fprintf(fid, '"ux (Rotated)"\n');
fprintf(fid, '"uy (Rotated)"\n');
fprintf(fid, '"uz (Rotated)"\n');
fprintf(fid, '"Mag"\n');
fprintf(fid, '"Bscat"\n');
fprintf(fid, '"Dir"\n');
fprintf(fid, '"vp (Roz)"\n');
fprintf(fid, '"vs (Roz)"\n');
fprintf(fid, '"vpy (Roz)"\n');
fprintf(fid, '"vsy (Roz)"\n');
fprintf(fid, '"phi_deg (Roz)"\n');
fprintf(fid, '"theta_deg (Roz)"\n');
fprintf(fid, 'ZONE T="ZONE 1"\n');
fprintf(fid, ' I=%d  J=1',i);
fprintf(fid, '  K=%d',k);
fprintf(fid, ' F=POINT\n');
fprintf(fid, 'DT=(SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE)\n');
for m = 1:size(tecdata,1)
    fprintf(fid,'%13.10f %13.10f %10.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f %4.8f\n',tecdata(m,:));
end
fclose(fid);

%disp('Saving Tecplot ASCII Data file...')
%directory = pwd;
%fileloc = [directory '\' outfile];
%disp(outfile)


format short