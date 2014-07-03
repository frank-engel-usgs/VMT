function VMT_Shoreline2GE_3D(A,Map,vscale,voffset)
% Outputs the shoreline (3-D) from VMT to Google Earth (saved as a .kmz
% file in the VMTProcFiles directory).  The file is then opened in Google
% Earth is for viewing.
%
% P.R. Jackson, USGS, 1-19-09


brks = find(Map.UTMe == -9999);

for i = 1:length(brks)+1
    if i == 1
        ll = 1;
        if ~isempty(brks)
            ul = brks(i)-1;
        else
            ul = length(Map.UTMe);
        end
        indx =ll:ul;
    elseif i == length(brks)+1
        ll = brks(i-1)+1;
        ul = length(Map.UTMe);
        indx =ll:ul;
    elseif i > 1 & i < length(brks)+1
        ll = brks(i-1)+1;
        ul = brks(i)-1;
        indx =ll:ul;
    end
    
    gex = Map.UTMe(indx);
    gey = Map.UTMn(indx);
    gez = vscale.*voffset.*ones(size(Map.UTMn(indx)));
    
    utmzonemat = repmat(A(1).Comp.utmzone(2,:),size(gex)); %
    [sllat,sllon] = utm2deg(gex,gey,utmzonemat);
    
    outfile = [Map.infile(1:end-4) '_' num2str(i)];
    
    GEplot_3DShoreLine(outfile,sllat,sllon,gez); 
    %eval(['!' outfile '.kmz'])
    
    clear gex gey gez utmzonemat sllat sllon 
    
end
