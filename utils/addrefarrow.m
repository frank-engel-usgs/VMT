function addrefarrow(h,x,y,u,v)

% addrefarrow(h,x,y,u,v)
%
% This is a quick hack to add a scale/reference arrow at a desired position
% given by  the input argument (x,y).  The scale arrow length in the x
% direction is given by u, in the y direction by v.  
%
% The input handle h is created by the quiver command
% h = quiver(.....
%
% WARNING, this function modifies the data contained in the quiver graphics
% group handle h!
%
% R. Moucha, GEOTOP-UQAM-MCGILL
% March 29, 2007

% Retrieve 2D data from quiver group

X = get(h,'Xdata');
Y = get(h,'Ydata');
U = get(h,'Udata');
V = get(h,'Vdata');

% Since we are adding a single arrow, we
% must use vectors and not grid matrices.
X = X(:);
Y = Y(:);
U = U(:);
V = V(:);

% Add scale arrow position and lengths
X(end+1) = x;
Y(end+1) = y;
U(end+1) = u;
V(end+1) = v;

% Update the arrows
set(h,'Xdata',X,'Ydata',Y,'Udata',U,'Vdata',V)
