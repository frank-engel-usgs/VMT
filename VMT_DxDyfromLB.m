function A = VMT_DxDyfromLB(z,A,V)
% Computes the x distance and y distance from the point on the left bank.
% Left bank is defined by the mean flow direction for the set of transects.
%
% P.R. Jackson, USGS, 1-21-09

%V.mfd
%V.m

if V.mfd >= 270 | V.mfd < 90
    for zi = 1 : z
        A(zi).Comp.dx = abs(V.xw-A(zi).Comp.xm);
        if V.m >= 0
            A(zi).Comp.dy = abs(V.ys-A(zi).Comp.ym);
        elseif V.m < 0
            A(zi).Comp.dy = abs(V.yn-A(zi).Comp.ym);
        end
    end
elseif V.mfd >= 90 & V.mfd < 270
    for zi = 1 : z
        A(zi).Comp.dx = abs(V.xe-A(zi).Comp.xm);
        if V.m >= 0
            A(zi).Comp.dy = abs(V.yn-A(zi).Comp.ym);
        elseif V.m < 0
            A(zi).Comp.dy = abs(V.ys-A(zi).Comp.ym);
        end
    end
end




