function Map = VMT_LoadMap(filetype,coord,varargin);
% This routine loads a map file from either a text file or a .mat file. 
%
% Input:  filetype = 'txt' for a text file (2 col (x,y), no headers); 'mat' for a matlab data file 
%        coord    = 'UTM' for UTM coordinates or 'LL' for latitude, longitude (in dec deg)
%        zone     = zone for UTM coordinates (Removed from Input--will be
%        determined from the data automatically)
% 
% 
% P.R. Jackson, 12-9-08
% Last Modified: Frank L. Engel, 7/25/2013

if ~isempty(varargin)
    guiprefs = varargin{1};
else
    guiprefs = [];
end

switch filetype
    case{'txt'}
        [file,shorepath] = uigetfile(...
            {'*.txt;*.csv','All Text Files'; '*.*','All Files'},...
            'Select Map Text File',...
            fullfile(guiprefs.shoreline_path,guiprefs.shoreline_file));
        
%         defaultpath = 'C:\';
%         shorepath = [];
%         if 0 %exist('VMT\LastDir.mat') == 2
%             load('VMT\LastDir.mat');
%             if exist(shorepath) == 7
%                 [file,shorepath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Map Text File',shorepath);       
%             else
%                 [file,shorepath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Map Text File',defaultpath);
%             end
%         else
%             [file,shorepath] = uigetfile({'*.txt;*.csv','All Text Files'; '*.*','All Files'},'Select Map Text File',defaultpath);
%         end
        
        if ischar(file) % User did not hit cancel
            infile = [shorepath file];
            %disp('Loading Map File...' );
            %disp(infile);
            data = dlmread(infile);
            switch coord
                case{'LL'}
                    % convert lat long into UTMe and UTMn
                    [Map.UTMe,Map.UTMn,Map.UTMzone] = deg2utm(data(:,1),data(:,2));
                case{'UTM'}
                    Map.UTMe = data(:,1);
                    Map.UTMn = data(:,2);
                    %Map.UTMzone = zone;
            end
        else
            Map = [];
            return
        end
                
    case{'mat'} %assumes Map data structure (above) is present
        [file,shorepath] = uigetfile(...
            '*.mat',...
            'Select Map File',...
            fullfile(guiprefs.shoreline_path,guiprefs.shoreline_file));
        
        if ischar(file) % User did not hit cancel
            infile = [shorepath file];
            %disp('Loading Map File...' );
            %disp(infile);
            load(infile);
        else
            Map = [];
            return
        end
end

Map.infile = infile;

%Save the shorepath
% if exist('LastDir.mat') == 2
    % save('LastDir.mat','shorepath','-append')
% else
    % save('LastDir.mat','shorepath')
% end