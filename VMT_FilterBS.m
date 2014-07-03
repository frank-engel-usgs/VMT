function A = VMT_FilterBS(z,A)
% This routine filters the backscatter data.
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-9-08 


%% Filter
% filter backscatter when climbing walls

for zi = 1 : z

    A(zi).Clean.backstandf=nan(double(A(zi).Sup.nBins),A(zi).Sup.noe);
    A(zi).Clean.bsf=nan(double(A(zi).Sup.nBins),A(zi).Sup.noe);

    % Determine the standard deviation of the backscatter for the four beams in
    % one bin in one ensemble
    back=A(zi).Wat.backscatter;
    back(back>=255) = NaN;
    A(zi).Clean.backstandf = std(back,0,3);

    % Remove backscatter intensities >= 255 (bad value) and backscatter
    % intensities with a standard deviation greater than 10 (mainly climbing
    % walls)
    A(zi).Clean.bsf = nanmean(A(zi).Wat.backscatter,3);
    A(zi).Clean.bsf(A(zi).Clean.bsf>=255) = NaN;
    %A(zi).Clean.bsf(A(zi).Clean.backstandf>10)=NaN;  %Removed STD screening PRJ 2-15-11

    A(zi).Nav.depth(A(zi).Nav.depth==-32768)=NaN;

end
