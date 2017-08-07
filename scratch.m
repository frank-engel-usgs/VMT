i = 1:10:length(V.u);
n = zeros(size(V.mcsDist(1,i)));
s = V.mcsDist(1,i);
u = V.u(1,i);
v = V.v(1,i);
w = V.w(1,i);
E = V.mcsX(1,i);
N = V.mcsY(1,i);
theta2 = geo2arideg(V.theta);
[x,y,z] = csrotation(v,u,w,-theta2);

figure(10);clf
quiver(s,n,u,v)
axis equal

figure(11);clf
quiver(E,N,V.mcsEast(1,i),V.mcsNorth(1,i))
hold on
quiver(E,N,x,-y,'k')
axis equal