 function hh = quiverc2(varargin)

% changed Tobias Höffken 3-14-05
% totally downstripped version of the former
% split input field into n segments and do a quiver qhich each of them 
 
% Modified version of Quiver to plots velocity vectors as arrows 
% with components (u,v) at the points (x,y) using the current colormap 

% Bertrand Dano 3-3-03
% Copyright 1984-2002 The MathWorks, Inc. 

% changed T. Höffken 14.03.05, for high data resolution
% using fixed color "spacing" of 20

%QUIVERC Quiver color plot.
%   QUIVERC(X,Y,U,V) plots velocity vectors as arrows with components (u,v)
%   at the points (x,y).  The matrices X,Y,U,V must all be the same size
%   and contain corresponding position and velocity components (X and Y
%   can also be vectors to specify a uniform grid).  QUIVER automatically
%   scales the arrows to fit within the grid.
%
%   QUIVERC(U,V) plots velocity vectors at equally spaced points in
%   the x-y plane.
%
%   QUIVERC(U,V,S) or QUIVER(X,Y,U,V,S) automatically scales the 
%   arrows to fit within the grid and then stretches them by S.  Use
%   S=0 to plot the arrows without the automatic scaling.
%
%   QUIVERC(...,LINESPEC) uses the plot linestyle specified for
%   the velocity vectors.  Any marker in LINESPEC is drawn at the base
%   instead of an arrow on the tip.  Use a marker of '.' to specify
%   no marker at all.  See PLOT for other possibilities.
%
%   QUIVERC(...,'filled') fills any markers specified.
%
%   H = QUIVERC(...) returns a vector of line handles.
%
%   Example:
%      [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%      z = x .* exp(-x.^2 - y.^2); [px,py] = gradient(z,.2,.15);
%      contour(x,y,z), hold on
%      quiverc(x,y,px,py), hold off, axis image
%
%   See also FEATHER, QUIVER3, PLOT. 
%   Clay M. Thompson 3-3-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.21 $  $Date: 2002/06/05 20:05:16 $ 
%-------------------------------------------------------------
n=20; %# of colors

nin = nargin;

error(nargchk(2,5,nin));

% Check numeric input arguments
if nin<4, % quiver(u,v) or quiver(u,v,s)
  [msg,x,y,u,v] = xyzchk(varargin{1:2});
else
  [msg,x,y,u,v] = xyzchk(varargin{1:4});
end
if ~isempty(msg), error(msg); end

%----------------------------------------------
% Define colormap 
vr = sqrt(u.^2+v.^2);
CC = colormap;
colit = ceil(((vr-min(vr(:)))./(max(vr(:))-min(vr(:))))*n);


%----------------------------------------------
ucell = cell(20,1);
vcell = cell(20,1);
for it=(1:1:n)
    ucell{it}=ones(size(u))*NaN;
    vcell{it}=ones(size(u))*NaN;    
end

for jt=(1:1:length(u))
    %it = ceil(((vr(jt)-min(vr(:)))/(max(vr(:))-min(vr(:))))*n);
    ucell{min(n,max(colit(jt),1))}(jt) = u(jt);
    vcell{min(n,max(colit(jt),1))}(jt) = v(jt);
end

figure;
hold on;
for it=(1:1:n)
    c = CC(ceil(it/n*64),:);
    hh=quiver(x,y,ucell{it},vcell{it},varargin{5}*it/n,'Color',c);
    hold on;
end


    

    

