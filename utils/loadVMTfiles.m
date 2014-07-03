function [A,z] = loadVMTfiles

FilterSpec = '*.vmt;';
DialogTitle = 'Choose VMT A structure file:';
[FileName,PathName,~] = uigetfile(FilterSpec,DialogTitle)

load([PathName FileName],'-mat')

z = numel(A);

A(1).probeType = 'RG';
A(1).hgns = 0.25;
A(1).vgns = 0.05;
A(1).wse = 0;