function [rx, ry, rz] = csrotation(X,Y,Z,phi)

% This function rotates an entrire matrix by the angle phi (in radians). 
% The output are the new vector head coordinates for each element in the 
% matrix. The required inputs (ie, X, Y, and Z matrices) must be the same 
% dimensions.
% 
% For a discussion on how vector rotation works, see: 
%         http://www.kwon3d.com/theory/transform/rot.html

% Written by:
% Frank L. Engel (fengel2@illinois.edu)

% Last edited: 5/3/2017


% Rotation matrix
Rz = [cos(phi) sin(phi) 0;...
    -sin(phi) cos(phi) 0;...
    0 0 1];

% Rotate every element in the matrix
for i=1:size(X,2)
    for j = 1:size(X,1)
        XYZ = [X(j,i);Y(j,i);Z(j,i)];
        Rotated = Rz*XYZ;
        rx(j,i) = Rotated(1);
        ry(j,i) = Rotated(2);
        rz(j,i) = Rotated(3);
    end
end