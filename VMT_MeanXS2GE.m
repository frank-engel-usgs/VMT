function VMT_MeanXS2GE(A,V,pathstr,filestr)
% Outputs the mean cross section (plan view) from VMT to Google Earth
% (saved as a .kmz file in the VMTProcFiles directory).  The file is then
% opened in Google Earth is for viewing.
%
% P.R. Jackson, USGS, 1-16-09


%Output the mean cross section to Google Earth

%lncol = ['-r';'-b';'-g';'-c';'-m';'-y';'-k';'-w'];
gex = nanmean(V.mcsX,1);
gey = nanmean(V.mcsY,1);
utmzonemat = repmat(A(1).Comp.utmzone(2,:),size(gex')); %
[mcslat,mcslon] = utm2deg(gex',gey',utmzonemat);
if ~isempty(pathstr)
    outfile = [pathstr '\' filestr(1:end-4)];
else
    outfile = [filestr(1:end-4)];
end
GEplot(outfile,mcslat,mcslon); %lncol(n,:)
eval(['!' outfile '.kmz'])