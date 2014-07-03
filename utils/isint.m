function [ Y ] = isint( X )
%
% ISINT     True for integer numbers
%
%    Y = ISINT(X) returns true (1) is X is an integer, false (0) otherwise.
% Created by Frederico D'Almeida: http://www.mathworks.com/matlabcentral/fileexchange/1309-general-extra-toolbox/content/isint.m

if isa(X,'uint8')
   Y = ones(size(X));
else
   Y = logical(X==round(X));
end
end

