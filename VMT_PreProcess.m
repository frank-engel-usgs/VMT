function A = VMT_PreProcess(z,A)
% This function is a driver to preprocess the transects data.  Several
% scripts are run including:
%
% Filter Backscatter 
% Replace bad GPS with BT
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-9-08 


%disp('Preprocessing Data...')

%% Filter the backscatter data

A = VMT_FilterBS(z,A);

%A = VMT_FilterBS_IntensityRS(z,A);

%% Variable Assignments

for zi = 1:z
    A(zi).Clean.bs     = A(zi).Clean.bsf;
    A(zi).Clean.vMag   = A(zi).Wat.vMag;
    A(zi).Clean.vEast  = A(zi).Wat.vEast;
    A(zi).Clean.vNorth = A(zi).Wat.vNorth;
    A(zi).Clean.vVert  = A(zi).Wat.vVert;
    A(zi).Clean.vDir   = A(zi).Wat.vDir;
    A(zi).Clean.vError = A(zi).Wat.vError;
end

% if 0 %A(1).Sup.binSize_cm == 25  %Set to zero due to ringing issues (from St. Clair) --omit for now
%     for zi = 1:z
%         A(zi).Clean.vMag(1,:)=NaN;
%         A(zi).Clean.vEast(1,:)=NaN;
%         A(zi).Clean.vNorth(1,:)=NaN;
%         A(zi).Clean.vVert(1,:)=NaN;
%         A(zi).Clean.bs(1,:)=NaN;
%         A(zi).Clean.vDir(1,:)=NaN;
%     end
% end


%% Replace bad GPS with BT
A = VMT_RepBadGPS(z,A);

%% Close out
%disp('Preprocessing Completed')


%% Notes:

%1. Removed a number of original scripts by JC that filled holes and
%screened data for the St. Clair River


