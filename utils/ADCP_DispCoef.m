function [k,kc,Eyc,Q] = ADCP_DispCoef(beddepth,travdist,vertdepth,downstvel,startDist,endDist,extrp,extend_to_banks,banktype);

%This program computes the longitudinal dispersion coefficient from ADCP
%transects.

%P.R. Jackson & N.V. Reynolds, USGS, 11/16/10

%Inputs:
% 
%     beddepth  = Depth (in meters) from the water surface to the bed (n element vector)
%     travdist  = Transverse distance (in m) across the river starting with (n element vector)
%     vertdepth = Depths (in m) from the water surface to velocity bins in the water column (m element vector)
%     downstvel = streamwise velocity distribution (+ for DS) in m/s (n x m array)
%     startDist = distance (in m) from the first profile to the starting bank 
%     endDist   = distance (in m) from the last profile to the ending bank
%     extrp     = (Binary) Set to 1 to extrapolate profiles to the bed and surface (log law); otherwise set to 0
%     extend_to_banks  = (Binary) Set to 1 to extrapolate data to the banks; otherwise set to 0
%     banktype  = (string) 'Triangular' or 'Square' (used in bank extrapolation)

%Outputs:
%     k  = Longitudinal dispersion coefficient (in m^2/s) (variable Ey)
%     kc  = Longitudinal dispersion coefficient (in m^2/s) (Constant Ey)
%     Ey = Transverse mixing coefficient (constant)
%     Q  = Approximate discharge in m^3/s



%% Basic parameters
nprof = length(beddepth);

%% Correct missing bed depths
%figure(10); clf; plot(travdist,beddepth,'k-')
% indx1 = find(isnan(beddepth));
% indx2 = find(~isnan(beddepth));
% if isnan(beddepth(1))
%     beddepth(1) = beddepth(indx2(1))/2; %Fill end nans (not filled with interpolation) 
% end
% if isnan(beddepth(end))
%     beddepth(end) = beddepth(indx2(end))/2;  %Fill end nans (not filled with interpolation) 
% end
indx1 = find(isnan(beddepth));
indx2 = find(~isnan(beddepth));
beddepth(indx1) = interp1(travdist(indx2),beddepth(indx2),travdist(indx1));  %fills the nans 

%figure(10); hold on; plot(travdist(indx1),beddepth(indx1),'r-')

%% Fit each profile with a log law 

%[ustarXS,zoXS] = ADCP_ComputeXS_ShearVelocity(downstvel,vertdepth,beddepth)
%
for i = 1:nprof
    indx = find(~isnan(downstvel(i,:)));
    if isempty(indx)
        if i == 1 | i == nprof
            beep
            error('Edge NaN Detected in Downstream Velocity')
        end
        ustar(i) = nan;
        zo(i) = nan;
    else
        z = beddepth(i)-vertdepth(indx);  % Height above the bed
        zmean(i) = nanmean(z);  %Mean height above the bed
        u = downstvel(i,indx);
        %figure(10); clf; plot(downstvel(i,indx),beddepth(i)-vertdepth(indx))
        %[ustar(i),zo(i),ks,cod,upred,zpred,delta] = fitLogLaw(u',z,beddepth(i));
        [ustar1(i),zo(i)] = fitLogLawV2(u',z,beddepth(i));
    end
end
%clean up problem values
ustar1 = real(ustar1);
indx = find(isinf(ustar1)); %turn if values to NAN
ustar1(indx) = nan;
%edge values
indx1 = find(isnan(ustar1));
indx2 = find(~isnan(ustar1));
if isnan(ustar1(1))
    ustar1(1) = ustar1(indx2(1)); %Fill end nans (not filled with interpolation) 
end
if isnan(ustar1(end))
    ustar1(end) = ustar1(indx2(end));  %Fill end nans (not filled with interpolation) 
end
indx1 = find(isnan(ustar1));
indx2 = find(~isnan(ustar1));
ustar1(indx1) = interp1(travdist(indx2),ustar1(indx2),travdist(indx1));  %fills the nans 

zo = real(zo);
indx = find(isinf(zo)); %turn if values to NAN
zo(indx) = nan;
%edge values
indx1 = find(isnan(zo));
indx2 = find(~isnan(zo));
if isnan(zo(1))
    zo(1) = zo(indx2(1)); %Fill end nans (not filled with interpolation) 
end
if isnan(zo(end))
    zo(end) = zo(indx2(end));  %Fill end nans (not filled with interpolation) 
end
indx1 = find(isnan(zo));
indx2 = find(~isnan(zo));
zo(indx1) = interp1(travdist(indx2),zo(indx2),travdist(indx1));  %fills the nans 

indx = find(zmean == 0); %turn if values to NAN
zmean(indx) = nan;
%edge values
indx1 = find(isnan(zmean));
indx2 = find(~isnan(zmean));
if isnan(zmean(1))
    zmean(1) = zmean(indx2(1)); %Fill end nans (not filled with interpolation) 
end
if isnan(zmean(end))
    zmean(end) = zmean(indx2(end));  %Fill end nans (not filled with interpolation) 
end
indx1 = find(isnan(zmean));
indx2 = find(~isnan(zmean));
zmean(indx1) = interp1(travdist(indx2),zmean(indx2),travdist(indx1));  %fills the nans 

mzo = nanmedian(zo)  %Median z0
%figure(10); clf; plot(travdist,ustar','k',travdist,shearvel,'r',travdist,ustar2','b')

%% Extrapolate top and bottom portions if required
%figure(20); clf; contour(downstvel,'Fill','on','Linestyle','none');
test = downstvel;
if extrp  %extrapolates to the bed and surface
    zgridspc = nanmean(diff(vertdepth));
    topDist  = vertdepth(1)
    ntop   = floor(topDist/zgridspc);
    top_nodes   = linspace(0,topDist-zgridspc,ntop)';
    vertdepth   = [top_nodes; vertdepth];
    downstvel = [nan*ones(length(beddepth),ntop) downstvel];  %preallocated space for new top velocities
    %figure(21); clf; contour(downstvel,'Fill','on','Linestyle','none');
    
    for i = 1:nprof
        indx = find(~isnan(downstvel(i,:)));
        
        %figure(10); clf; plot(downstvel(i,:),vertdepth,'ko-'); set(gca,'YDir','reverse'); 
        if ~isempty(indx) %all nans get no computations or extensions
            
            top_nodes_flipped = beddepth(i) - top_nodes;
            u_top = ustar1(i)/0.41*log(top_nodes_flipped/zo(i));
            %botDist = beddepth(i) - vertdepth(indx(end));
            
            last_node = find(vertdepth < beddepth(i));
            bot_nodes = vertdepth(indx(end)+1:last_node(end));
            
            %nbot   = floor(botDist/zgridspc);
            %bot_nodes = linspace(vertdepth(indx(end))+zgridspc,vertdepth(indx(end))+botDist,nbot);

            %Flip the vertical coordinate and use log fit from above to extend
            %to boundaries

            
            bot_nodes_flipped = beddepth(i) - bot_nodes;
            u_bot = ustar1(i)/0.41*log(bot_nodes_flipped/zo(i));

            %u_bot(end) = 0.0;  %Log law is singular at z = 0, so reset to zero for no slip


            % Append to data
            if ~isempty(indx)
                downstvel(i,indx(end)+1:last_node(end)) = u_bot;
            end        
            %downstvel(i,last_node(end)+1) = 0.0;  %Set to zero at bed
            %vertdepth(last_node(end)+1) = beddepth(i); %reset first invalid
            %bottom bin to bed depth
            downstvel(i,1:ntop) = u_top;
        
        end

        %figure(10); hold on; plot(u_top,top_nodes,'r.',u_bot,bot_nodes,'b.'); set(gca,'YDir','reverse'); pause
        
        clear indx last_node bot_nodes top_nodes_flipped bot_nodes_flipped u_top u_bot 
    end
end
%test2 = downstvel(:,ntop+1:end) - test;
%figure(22); clf; contour(test2,'Fill','on','Linestyle','none');

%% Compute Depth-averaged velocities

%This function computes the layer averaged mean of the downstream velocity over the measured depth range.
%Assumes the data outside the depth range have been set to NaN.
% P.R. Jackson, USGS 1-7-09
for i = 1:nprof
    lam(i) = VMT_LayerAveMean(vertdepth,downstvel(i,:)');
end

%figure(10); clf; plot(travdist,lam,'r-') % Plot to check

%lam = VMT_LayerAveMean(repmat(vertdepth,1,size(downstvel',2)),downstvel')';
lam = real(lam)';  %remove any imaginary parts
indx = find(isinf(lam)); %turn if values to NAN
lam(indx) = nan;
indx1 = find(isnan(lam));
indx2 = find(~isnan(lam));
if isnan(lam(1))
    lam(1) = lam(indx2(1))/2; %Fill end nans (not filled with interpolation) 
end
if isnan(lam(end))
    lam(end) = lam(indx2(end))/2;  %Fill end nans (not filled with interpolation) 
end
indx1 = find(isnan(lam));
indx2 = find(~isnan(lam));
lam(indx1) = interp1(travdist(indx2),lam(indx2),travdist(indx1));  %fills the nans 

%indx1 = find(isnan(lam))
%figure(10); clf; plot(travdist,lam,'r-') % Plot to check

% %Davide's method for LAM
% 
% for i=1:sztravdist+1
%     x(i)=nansum(downstvel(i,:));
%   
% end
% 
% 
% lamd=x'./beddepth;
% lamd(1)=lamd(2)/2;
% lamd(sztravdist+1)=lamd(sztravdist)/2;
% %lamd=lamd';
% figure(10); hold on; plot(travdist,lamd./3.281,'b-')
% whos
% return

%% Recompute the shear velocity using the median z0 and LAM (lower noise)
%shearvel = lam*0.41./log(zmean'./mzo);  %kappa = 0.41
if 0  %use the z0 from the normalized fit
    shearvel = lam*0.41./log((beddepth/exp(1))./zoXS);  %kappa = 0.41; %Use zmean = h/e following Sime etal 2007 as mean velocity occurs at h/e
else %uses the median of the individual profile fits
    shearvel = lam*0.41./log((beddepth/exp(1))./mzo);  %kappa = 0.41; %Use zmean = h/e following Sime etal 2007 as mean velocity occurs at h/e
end
% replace zeros with nans
indx = find(shearvel == 0);
shearvel(indx) = nan;
% Fill gaps
indx1 = find(isnan(shearvel));
indx2 = find(~isnan(shearvel));
shearvel(indx1) = interp1(travdist(indx2),shearvel(indx2),travdist(indx1));  %fills the nans 

%figure(10); clf; plot(travdist,shearvel,'r')
travdist_orig = travdist;

%% Extrapolate to the banks (following WRII)
if extend_to_banks
    ygridspc = nanmean(diff(travdist));
    nstart = floor(startDist/ygridspc)
    nend   = floor(endDist/ygridspc);
%Note: This fails for zero start or end distances
    %indx = find(~isnan(lam));

    start_nodes = linspace(0,startDist-ygridspc,nstart);
    end_nodes   = linspace(travdist(end)+ygridspc,travdist(end)+endDist,nend) + startDist;

    switch banktype
        case 'triangular'
            startBed = interp1([start_nodes(1) startDist],[0 beddepth(1)],start_nodes);
            endBed   = interp1([(travdist(end)+startDist) end_nodes(end)],[beddepth(end) 0],end_nodes);
            startLAM = lam(1).*sqrt(startBed./beddepth(1));
            endLAM   = lam(end).*sqrt(endBed./beddepth(end));
            startSHV = interp1([start_nodes(1) startDist],[0 shearvel(1)],start_nodes);  %Linear interpolation of shear velocities
            endSHV   = interp1([(travdist(end)+startDist) end_nodes(end)],[shearvel(end) 0],end_nodes);


        case 'square'
            errordlg('Not implemented yet')
    end

    travdist = [start_nodes'; travdist+startDist; end_nodes'];
    lam      = [startLAM'; lam; endLAM'];
    beddepth = [startBed'; beddepth; endBed'];
    shearvel = [startSHV'; shearvel; endSHV'];
    
    shearvel(1) = 0.1*shearvel(2);  %Reset start and end u* to nonzero to keep INT2 from blowing up (due to zero Ey at edges)
    shearvel(end) = 0.1*shearvel(end-1); 

    
    %figure(10); hold on; plot(travdist,lam,'b-') % Plot to check
    %figure(10); clf; plot(travdist,beddepth,'b-') % Plot to check

end

%% Compute the mean Cross-sectional area
XSarea = trapz(travdist,beddepth)


%% Compute bin areas
%compute the midpoints
difftrav = diff(travdist);
interim1 = 0.5*difftrav(1:end-1) + 0.5*difftrav(2:end);
interim1 = [0.5*difftrav(1); interim1];
bin_mp = cumsum(interim1);

interim2 = [0; bin_mp; travdist(end)];
delW = diff(interim2);

%figure(10); clf; plot(travdist,beddepth,'k.-');

%Interpolate the bed depths at the midpoints
beddepth_mp = interp1(travdist,beddepth,bin_mp);

%figure(10); clf; plot(travdist,beddepth,'k.-',bin_mp,beddepth_mp,'r.'); %plot to check

%Compute the areas
cumlarea = cumtrapz(interim2,[beddepth(1); beddepth_mp; beddepth(end)]);
bin_areas = diff(cumlarea);
% Fill gaps
indx1 = find(isnan(bin_areas));
indx2 = find(~isnan(bin_areas));
bin_areas(indx1) = interp1(travdist(indx2),bin_areas(indx2),travdist(indx1));  %fills the nans 


%figure(10); clf; plot(travdist,bin_areas,'k.-'); %plot to check

%Check the computation
areaClosure = 100*(XSarea - sum(bin_areas))/XSarea


    %Old area comp
    % sztravdist=size(travdist,1)-1;
    % szvertdepth=size(vertdepth,1);
    % 
    % %midpoint to the left of y-component
    % midptly=(1:sztravdist+1);
    % midptly(1)=0;
    % midptly(2)=travdist(2)-(travdist(3)-travdist(2))/2;
    % midptly(3:sztravdist-0)=(travdist(3:sztravdist)+travdist(2:sztravdist-1))/2;
    % midptly(sztravdist+1)=travdist(sztravdist)-(travdist(sztravdist-1)-travdist(sztravdist))/2;
    % 
    % %midpoint to the left of bed depth
    % midptld=(1:sztravdist+1);
    % midptld(1)=0;
    % midptld(2)=beddepth(2)-(beddepth(3)-beddepth(2))/2;
    % midptld(3:sztravdist-0)=(beddepth(3:sztravdist)+beddepth(2:sztravdist-1))/2;
    % midptld(sztravdist+1)=beddepth(sztravdist)-(beddepth(sztravdist-1)-beddepth(sztravdist))/2;
    % 
    % %midpoint to the right of y-component
    % midptry=(1:sztravdist+1);
    % midptry(1)=travdist(2)-(travdist(3)-travdist(2))/2;
    % midptry(2:sztravdist-1)=(travdist(3:sztravdist)+travdist(2:sztravdist-1))/2;
    % midptry(sztravdist)=travdist(sztravdist)-(travdist(sztravdist-1)-travdist(sztravdist))/2;
    % midptry(sztravdist+1)=0;
    % 
    % %midpoint to the right of bed depth
    % midptrd=(1:sztravdist+1);
    % midptrd(1)=beddepth(2)-(beddepth(3)-beddepth(2))/2;
    % midptrd(2:sztravdist-1)=(beddepth(3:sztravdist)+beddepth(2:sztravdist-1))/2;
    % midptrd(sztravdist)=beddepth(sztravdist)-(beddepth(sztravdist-1)-beddepth(sztravdist))/2;
    % midptrd(sztravdist+1)=0;
    % 
    % 
    % %area per bin
    % ameth2=(1:sztravdist+1);
    % ameth2(1)=(beddepth(1)+midptrd(1))*(midptry(1)-travdist(1))/2;
    % for i=2:sztravdist
    % ameth2(i)=(beddepth(i)+midptld(i)')*(travdist(i)-midptly(i)')/2+(beddepth(i)+midptrd(i)').*(midptry(i)'-travdist(i))./2;
    % end
    % ameth2(sztravdist+1)=((beddepth(sztravdist+1)+midptld(sztravdist+1))*(travdist(sztravdist+1)-midptly(sztravdist+1)))/2;

%figure(10); clf; plot(travdist,bin_areas,'k.-',travdist,ameth2,'r.-')

%Compute the depth for each subarea
d = bin_areas./delW;
% Fill gaps
indx1 = find(isnan(d));
indx2 = find(~isnan(d));
d(indx1) = interp1(travdist(indx2),d(indx2),travdist(indx1));  %fills the nans 
    % %Old depth comp
    % d2=(1:sztravdist+1);
    % d2(1)=ameth2(1)/midptry(1);
    % d2=ameth2./(midptry-midptly);
    % d2(sztravdist+1)=ameth2(sztravdist+1)./(-midptly(sztravdist+1)+travdist(sztravdist+1));
    % d2 = d2';
    
%figure(10); clf; plot(travdist,d,'k.-')


%% Compute the Approximate Discharge
Q = nansum(lam.*bin_areas)
if Q < 0
    Q = -Q;
    lam = -lam;
    shearvel = -shearvel;
end

%% Compute the mean cross-sectional velocity
Ua = Q./XSarea

%% Compute the LAM velocity deviation
uprime = lam - Ua;
%figure(10); clf; plot(travdist,uprime.*d,'b-')

%% Compute the transverse mixing coefficients (variable)
B = travdist(end) - travdist(1)  %Width
if 1
    Ey = 0.21*shearvel.*d;  %Elder approach
    % Fill gaps
    indx1 = find(isnan(Ey));
    indx2 = find(~isnan(Ey));
    Ey(indx1) = interp1(travdist(indx2),Ey(indx2),travdist(indx1));  %fills the nans
else
    % Compute the value following Shen et al. 2010
    Ustar = trapz(travdist,shearvel)/B  %Cross-sectionally averaged shear velocity
    H = XSarea/B

    theta = 0.145 + (1/3520)*(Ua/Ustar)*(B/H)^1.38

    Ey = theta*Ustar*d;

    % Fill gaps
    indx1 = find(isnan(Ey));
    indx2 = find(~isnan(Ey));
    Ey(indx1) = interp1(travdist(indx2),Ey(indx2),travdist(indx1));  %fills the nans
end

Eyc = trapz(travdist,Ey)/B;  %Constant value of tranverse mixing coefficient
%figure(10); clf; plot(travdist,Ey,'b-')

%% Compute the integrals (variable Ey)
% Integral 1
%indx = find(~isnan(uprime));
INT1 = cumtrapz(travdist,uprime.*d);
%INT1 = cumtrapz(travdist(:),uprime(:).*d(:));

% Integral 2
INT2 = cumtrapz(travdist,INT1./(Ey.*d));
%INT2 = cumtrapz(travdist(:),INT1./(Ey(:).*d(:)));

% Integral 3
INT3 = cumtrapz(travdist,INT2.*uprime.*d);
%INT3 = cumtrapz(travdist(indx),INT2.*uprime(indx).*d(indx));

if 0
    figure(10); clf;
    title('Variable Ey')
    subplot(3,1,1)
    plot(travdist,INT1,'b-')
    ylabel('INT1')
    subplot(3,1,2); plot(travdist,INT2,'b-')
    ylabel('INT2')
    subplot(3,1,3); plot(travdist,INT3,'b-')
    ylabel('INT3')
end

%% Compute and return the longitudinal dispersion coefficient

k = -INT3(end)/XSarea;
%percentdiff=100*(2111.7-k)/(2111.7);
disp(' ')
disp(['The longitudinal dispersion coefficient(K)is ' num2str(k) ' m^2/s'])
disp('          with a VARIABLE transverse mixing coefficient(Ey) ')
%disp(' ')
%disp(['Davide ended up with 2111.7 m^2/s. Which is a ' num2str(percentdiff) '% difference.  '])

%% Compute the integrals (constant Ey)

% Integral 2
INT2c = cumtrapz(travdist,INT1./(Eyc.*d));
%INT2 = cumtrapz(travdist(:),INT1./(Ey(:).*d(:)));

% Integral 3
INT3c = cumtrapz(travdist,INT2c.*uprime.*d);
%INT3 = cumtrapz(travdist(indx),INT2.*uprime(indx).*d(indx));

if 0
    figure(11); clf; title('Constant Ey')
    subplot(2,1,1); plot(travdist,INT2c,'b-')
    ylabel('INT2')
    subplot(2,1,2); plot(travdist,INT3c,'b-')
    ylabel('INT3')
end

%% Compute and return the longitudinal dispersion coefficient

kc = -INT3c(end)/XSarea;
%percentdiff=100*(2111.7-kc)/(2111.7);
disp(' ')
disp(['The longitudinal dispersion coefficient(K)is ' num2str(kc) ' m^2/s'])
disp('          with a CONSTANT transverse mixing coefficient(Ey) ')

%% Plot a combined plot
figure(8); clf
subplot(3,1,1); plot(travdist,beddepth,'k-',travdist,d,'r-'); ylabel('Bed Depth (m)')
%subplot(4,1,2); plot(travdist_orig,zo,'k-'); ylabel('z0 (m)')
subplot(3,1,2); plot(travdist,lam,'k-'); ylabel('Depth-Averaged Vel. (m/s)')
subplot(3,1,3); plot(travdist,shearvel,'k-'); ylabel('u* (m/s)')
xlabel('Transverse Distance (m)')
figure(9); clf
subplot(3,1,1); plot(travdist,bin_areas,'k-'); ylabel('Bin Areas (m^2)')
subplot(3,1,2); plot(travdist,uprime,'k-'); ylabel('uprime (m/s)')
subplot(3,1,3); plot(travdist,Ey,'k-'); ylabel('Ey (m^2/s)')
xlabel('Transverse Distance (m)')








