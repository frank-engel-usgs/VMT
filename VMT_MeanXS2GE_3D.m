function VMT_MeanXS2GE_3D(A,V,pathstr,filestr,vscale,voffset)
% Outputs the mean cross section (3-D) from VMT to Google Earth (saved as a
% .kmz file in the VMTProcFiles directory).  The file is then opened in
% Google Earth for viewing.
%
% P.R. Jackson, USGS, 1-16-09


%Output the mean cross section to Google Earth

%lncol = ['-r';'-b';'-g';'-c';'-m';'-y';'-k';'-w'];
gex = nanmean(V.mcsX,1);
gey = nanmean(V.mcsY,1);
gez = vscale.*(voffset-V.mcsBed);
utmzone = cellstr(A(1).Comp.utmzone);
utmzone =  unique(utmzone(~cellfun(@isempty,utmzone)));
utmzonemat = repmat(utmzone{:},size(gex')); %
[mcslat,mcslon] = utm2deg(gex',gey',utmzonemat);
if ~isempty(pathstr)
    outfile = [pathstr '\' filestr(1:end-4)];
else
    outfile = [filestr(1:end-4)];
end
GEplot_3D(outfile,mcslat,mcslon,gez); %lncol(n,:)
eval(['!' outfile '.kmz'])