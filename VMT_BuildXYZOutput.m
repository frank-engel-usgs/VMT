function xyzdata = VMT_BuildXYZOutput(V)
% Takes multiple ensembles and writes them to an xyz data file with columns
% for each variable.
%
% P.R. Jackson, 3-24-09

format long
xyzdata = [];

for i = 1:size(V.mcsX,1)
    for j = 1:size(V.mcsX,2)
        tempvec = [V.mcsX(i,j) V.mcsY(i,j) V.mcsDepth(i,j) V.mcsMag(i,j) V.mcsDir(i,j) V.u(i,j) V.v(i,j) V.w(i,j) V.vp(i,j) V.vs(i,j) V.mcsEast(i,j) V.mcsNorth(i,j) V.mcsDirDevp(i,j) V.mcsBack(i,j)];
        if ~isnan(sum(tempvec)) 
            xyzdata = [xyzdata; tempvec];
        end
    end
end
format short