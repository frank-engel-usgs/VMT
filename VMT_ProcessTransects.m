function [A,V,log_text] = VMT_ProcessTransects(z,A,setends,unitQcorrection,eta,start_bank)
% Driver program to process multiple transects at a single cross-section
% for velocity mapping.
%
% Among other things, it:
%
%   Determines the best fit mean cross-section line from multiple transects
%   Map ensembles to mean c-s line
%   Determine uniform mean c-s grid for vector interpolating
%   Determine location of mapped ensemble points for interpolating
%   Interpolate individual transects onto uniform mean c-s grid
%   Average mapped mean cross-sections from individual transects together 
%   Rotate velocities into u, v, and w components
%
% (adapted from code by J. Czuba)
%
% P.R. Jackson, USGS, 12-9-08 
% Last modified: F.L. Engel, USGS, 5/20/2013



log_text = {'   Processing Data...Please Be Patient.'};

try
    %disp('Processing Data...')
    warning off
        
    %% Map ensembles to mean cross-section
    [A,V,map_xs_log_text] = VMT_MapEns2MeanXS(z,A,setends,start_bank);
    %msgbox('Processing Data...Please Be Patient','VMT Status','help','replace');
    log_text = vertcat(log_text, map_xs_log_text);
    
    %% Set the probe type
    if A(1).Sup.wm == 3 % RiverRay
        V.probeType = 'RR';
    else
    %V.probeType = A(1).probeType;
        V.probeType = 'RG';
    end
    
    %% Write bed elevation to V struct
    V.eta = eta;
    
    %% Grid the measured data along the mean cross-section
    %[A,V] = VMT_GridData2MeanXS(z,A,V);
    [A,V] = VMT_GridData2MeanXS(z,A,V,unitQcorrection);
    if unitQcorrection
        log_text = vertcat(log_text,...
            {'      Streamwise unit discharge continuity enforced'});
    end
    %msgbox('Processing Data...Please Be Patient','VMT Status','help','replace');
    %log_text = {log_text; grid_data_log_text};

    %% Computes the mean data for the mean cross-section 
    %[A,V] = VMT_CompMeanXS(z,A,V);
    [A,V,comp_xs_log_text] = VMT_CompMeanXS(z,A,V);
    %msgbox('Processing Data...Please Be Patient','VMT Status','help','replace');
    log_text = vertcat(log_text, comp_xs_log_text);

    %% Decompose the velocities into u, v, and w components
    [A,V] = VMT_CompMeanXS_UVW(z,A,V);
    %msgbox('Processing Data...Please Be Patient','VMT Status','help','replace'); 

    %% Decompose the velocities into primary and secondary components
    [A,V,comp_prisec_log_text] = VMT_CompMeanXS_PriSec(z,A,V);
    %msgbox('Processing Data...Please Be Patient','VMT Status','help','replace'); 
    log_text = vertcat(log_text, comp_prisec_log_text);

    %% Perform the Rozovskii computations
    [V,roz_log_text] = VMT_Rozovskii(V,A);
    log_text = vertcat(log_text, roz_log_text);
    
    %figure(4); clf
    %plot3(V.mcsX,V.mcsY,V.mcsDepth(1))
    %disp('Processing Completed')
    log_text = vertcat(log_text, '   Processing Completed.');
catch err
    if isdeployed
        errLogFileName = fullfile(pwd,...
            ['errorLog' datestr(now,'yyyymmddHHMMSS') '.txt']);
        msgbox({['An unexpected error occurred. Error code: ' err.identifier];...
            ['Error details are being written to the following file: '];...
            errLogFileName},...
            'VMT Status: Unexpected Error',...
            'error');
        fid = fopen(errLogFileName,'W');
        fwrite(fid,err.getReport('extended','hyperlinks','off'));
        fclose(fid);
        rethrow(err)
    else
        msgbox(['An unexpected error occurred. Error code: ' err.identifier],...
            'VMT Status: Unexpected Error',...
            'error');
        rethrow(err);
    end
end


%% Notes:

%1. I removed scripts at the end of the original code that computes
%standard deviations (12-9-08)
