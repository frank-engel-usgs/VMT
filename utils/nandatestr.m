function labels = nandatestr(D,dateform,pivotyear)
% NANDATESTR executes datestr, but replaces NaN results
% with blanks. Note that datestr blows up when it
% encounters a NaN;
%
% Usage:
% date_num =today+[1:10];
% date_num(5)=NaN;
% date_str =nandatestr(date_num);
%
% Uses: isnan, datestr, strrep, size, reshape, fliplr, size
%
% Michael Robbins, 2/2000
% michael.robbins@us.cibc.com
% robbins@bloomberg.net

D(isnan(D))=0;
switch (nargin)
   case 1, a = datestr(D);
           null_str=datestr(0);
   case 2, a = datestr(D,dateform);
           null_str=datestr(0,dateform);
   case 3, a = datestr(D,dateform,pivotyear);
           null_str=datestr(0,dateform,pivotyear);
end;

b=a';
c=strrep(b(:)',null_str,setstr(' '.*ones(size(null_str))));
labels=reshape(c,fliplr(size(a)))';