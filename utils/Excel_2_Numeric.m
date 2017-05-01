function vec = Excel_2_Numeric(ExcelString)
% Take an excel cell reference (e.g. B3) into numerical indices suitable for
% MATLAB (e.g. 3,2).
% This function also uses EXCEL_REF_CHECK to ensure the cell reference is
% valid.
% See also: NUMERIC_2_EXCEL, EXCEL_REF_CHECK 
vec = [];

%split up Excel reference into letters and a number:
[letterInd numberInd] = Excel_Ref_Check(ExcelString);
letter = ExcelString(letterInd);
number = ExcelString(numberInd);

%cast alphabetical column reference to ASCII numbers and scale from 1 - 26
letterCast = cast(letter,'double') - 64;


%row index value:
vec(1) = str2double(number);

%total up the value of each order to produce a column index value
vec(2) = sum(letterCast.*(26.^(length(letter)-1:-1:0)));




