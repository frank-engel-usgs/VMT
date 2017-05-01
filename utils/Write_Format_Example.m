% This example shows how to write three sets of data: the first two go to
% the same worksheet of the same file (a new sheet is created), the third
% goes to an existing sheet (Sheet3) of a different file. Each has some
% different formatting properties to show how the font, interior, range and
% border interfaces are used.
%
% Note: if you want to use this function from outside of the current 
% directory, use PATHTOOL and add this folder to the search path. You can
% this run EXCEL_WRITE_FORMAT and its other functions from whatever
% directory you're using.

clear
clc

fileNames = {'Test Spreadsheet' 'Test Spreadsheet','Another Spreadsheet.xls'};
Data{1} = {'Heading 1' 'Heading 2' 'Heading 3','Heading 4'};
Data{2} = eye(4);
Data{3} = peaks;
topLeft = {'B2','B3',[6 27]};
sheetNames = {'New Sheet',[],'Sheet3'};

%properties structures:
s1.Font.Bold = 1;
s1.Font.Color = RGB_2_BGR_Hex([0.05 0.35 0.7]); %note RGB_2_BGR_HEX call
s1.Font.Name = 'Lucida Sans';
s1.Border.OutsideAll.Weight = 4;
s1.Border.OutsideAll.Color = RGB_2_BGR_Hex([0.4 0 0]);
s1.Border.OutsideAll.TintAndShade = 0.1;
s1.Range.ColumnWidth = 14;
s1.Range.RowHeight = 25;
s1.Range.HorizontalAlignment = 'Center';
s1.Range.VerticalAlignment = 'Distributed';

s2.Font.Italic = 1;
s2.Font.Underline = 'xlUnderlineStyleDouble';
s2.Font.Color = RGB_2_BGR_Hex([0.3 0.3 0.3]);
s2.Font.Name = 'Calibri';
s2.Font.Size = 11;
s2.Border.InsideAll.LineStyle = 'DashDot';
s2.Interior.Color = RGB_2_BGR_Hex([0.75 0.75 0.75]);
s2.Interior.TintAndShade = 0.9;
s2.Border.OutsideAll.LineStyle = 'Continuous';
s2.Range.VerticalAlignment = 'Top';
s2.Range.RowHeight = 20;

s3.Range.NumberFormat = '#,##0.0#;[Red]-#,##0.0#';
s3.Interior.Pattern = 13;
s3.Interior.PatternColor = RGB_2_BGR_Hex([0 0.5 0]);
s3.Border.EdgeTop.LineStyle = 'Continuous';
s3.Border.EdgeTop.Weight = 4;

%example of a 'misc' interface (note this affects Excel itself not just the
% workbook: go to the View Tab, and check the Formula Bar box (in the
% 'show' panel) to display it again.
s3.Application.DisplayFormulaBar = 0;

%example of some invalid properties (warning messages should appear
%in the command line):
s3.NotAnInterface.A = false;
s3.font.Size = 10; %note the case sensitivity
s3.Font.size = 10; %note the case sensitivity
s3.Font.Size = 'ten';
%checks by Process_ routines:
s3.Interior.Color = [1 0 0];
s3.Font.Name = 'NotAFont';

%create cell array of property structures
propStruct = {s1 s2,s3};

%send to write function and output the full filenames:
fileNamesNew = Excel_Write_Format(fileNames,Data,topLeft,sheetNames,propStruct);

U = unique(fileNamesNew);
%open files:
for n = 1:length(U)
    winopen(U{n})
end

