function [exyz]=depthxyz(depthRaw,vbeam,freq,draft,pitchRaw,roll,heading,beamAngle,...
    unitsID,x,y,elev,ens);
% depthxyz computes the x,y, and z components of the location where each
% beam reflects from the streambed using the algorithm provided by Gary
% Murdock, RDI, 10-25-2002
%
% INPUT
% depthRaw - matrix of beam depths
% draft - draft of instrument
% pitchRaw - pitch vector from ADCP in degrees
% roll - roll vector from ADCP in degrees
% heading - heading vector from ADCP in degrees
% beamAngle - beam angle of instrument in degrees
% unitsID - units identifier
% x - x-coordinate(Easting) of center of ADCP
% y - y-coordinate(Northing) of center of ADCP
% elev - elevation of water-surface at ADCP
% ens - vector of ensemble numbers
%
% OUTPUT
%
% exyz - matrix with rows of ensembles and columns of x,y, and z
%
% David S. Mueller
% U.S. Geological Survey
% Office of Surface Water
% dmueller@usgs.gov
% 
% June 29, 2006
    % Correct draft for units
    if unitsID=='ft'
            draft=double(draft)*0.0328083;
        else
            draft=double(draft)*.01;
    end;
    
    % Depending on how you got here, elev may be a char array. Check and
    % convert if necessary
    if ischar(elev); elev = str2num(elev); end;
       
    % Create geo matrix of x, y, and elevation of transducers    
    geo=[x,y,-1.*repmat(draft,size(y))+elev];    

    % Compute slant range of each beam
    if ischar(beamAngle)
        beamAngleR=str2double(beamAngle).*pi/180;
    else
        beamAngleR=beamAngle.*pi/180;
    end
    range=(depthRaw-draft)./cos(beamAngleR);
    
    % Adjust heading, pitch, and roll
    rollR=roll.*pi/180;
    %pitchRawR=pitchRaw.*pi/180;
    pitchR=pitchRaw.*pi/180;
    headingR=heading.*pi/180;
    %pitchR=atan(tan(pitchRawR).*cos(rollR));
    

    % Compute sine and cosine values
    ch=cos(headingR);
    sh=sin(headingR);
    cp=cos(pitchR);
    sp=sin(pitchR);
    cr=cos(rollR);
    sr=sin(rollR);
    
    % Configure transformation vectors for east, north, and vertical
    trans2e=[ch.*cr+sh.*sp.*sr sh.*cp ch.*sr-sh.*sp.*cr];
    trans2n=[-sh.*cr+ch.*sp.*sr ch.*cp -sh.*sr-ch.*sp.*cr];
    trans2u=[-cp.*sr sp cp.*cr];
    
    % Create matrix to convert from slant range to xyz
    rng2xyz=[0 -sin(beamAngleR) -cos(beamAngleR);...
             -sin(beamAngleR) 0 -cos(beamAngleR);...
               0 sin(beamAngleR) -cos(beamAngleR);...
               sin(beamAngleR) 0 -cos(beamAngleR)];
           
     % Compute xyz for each beam
    beam1xyz=repmat(rng2xyz(1,:),size(range,1),1).*repmat(range(:,1),1,3);
    beam2xyz=repmat(rng2xyz(2,:),size(range,1),1).*repmat(range(:,2),1,3);
    beam3xyz=repmat(rng2xyz(3,:),size(range,1),1).*repmat(range(:,3),1,3);
    beam4xyz=repmat(rng2xyz(4,:),size(range,1),1).*repmat(range(:,4),1,3);   
    
    % Create matrix to rotate 1 MHz data 45 degrees
    rot1mhz=deg2rad(-45);
    
    xyz1mhz=[cos(rot1mhz) sin(rot1mhz);...
             -sin(rot1mhz) cos(rot1mhz)];    
    
    idxfreq=find(freq==1);
    
    beam1xyz(idxfreq,1:2)=beam1xyz(idxfreq,1:2)*xyz1mhz;
    beam2xyz(idxfreq,1:2)=beam2xyz(idxfreq,1:2)*xyz1mhz;
    beam3xyz(idxfreq,1:2)=beam3xyz(idxfreq,1:2)*xyz1mhz;
    beam4xyz(idxfreq,1:2)=beam4xyz(idxfreq,1:2)*xyz1mhz;
   
    % Create matrix for vertical beam
    vbeam(vbeam<=0)=nan;
    beam5xyz=[zeros(size(vbeam,1),2) -1.*(vbeam-draft)];
    
    
    % Correct beam 1 xyz for heading, pitch, and roll
    beam1enu(:,1)=ens;
    beam1enu(:,2)=sum(trans2e.*beam1xyz,2);
    beam1enu(:,3)=sum(trans2n.*beam1xyz,2);
    beam1enu(:,4)=sum(trans2u.*beam1xyz,2);
    
    % Translate and compute elevation
    beam1enu(:,2:4)=beam1enu(:,2:4)+geo;
    
    % Correct beam 2 xyz for heading, pitch, and roll and compute elevation
    beam2enu(:,1)=ens;
    beam2enu(:,2)=sum(trans2e.*beam2xyz,2);
    beam2enu(:,3)=sum(trans2n.*beam2xyz,2);
    beam2enu(:,4)=sum(trans2u.*beam2xyz,2);
    beam2enu(:,2:4)=beam2enu(:,2:4)+geo;
    
    % Correct beam 3 xyz for heading, pitch, and roll and compute elevation
    beam3enu(:,1)=ens;
    beam3enu(:,2)=sum(trans2e.*beam3xyz,2);
    beam3enu(:,3)=sum(trans2n.*beam3xyz,2);
    beam3enu(:,4)=sum(trans2u.*beam3xyz,2);
    beam3enu(:,2:4)=beam3enu(:,2:4)+geo;
    
    % Correct beam 4 xyz for heading, pitch, and roll and compute elevation
    beam4enu(:,1)=ens;
    beam4enu(:,2)=sum(trans2e.*beam4xyz,2);
    beam4enu(:,3)=sum(trans2n.*beam4xyz,2);
    beam4enu(:,4)=sum(trans2u.*beam4xyz,2);
    beam4enu(:,2:4)=beam4enu(:,2:4)+geo;
    
    % Correct beam 5 xyz for heading, pitch, and roll and compute elevation
    beam5enu(:,1)=ens;
    beam5enu(:,2)=sum(trans2e.*beam5xyz,2);
    beam5enu(:,3)=sum(trans2n.*beam5xyz,2);
    beam5enu(:,4)=sum(trans2u.*beam5xyz,2);
    beam5enu(:,2:4)=beam5enu(:,2:4)+geo;
    
    % Create final matrix
    exyz=[beam1enu;beam2enu;beam3enu;beam4enu;beam5enu];
    exyz=sortrows(exyz,1);

