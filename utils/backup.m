function backup(or_dir,varargin)
%
%backup(or_dir,bk_dir,warn,flags,mode)
%
%
%Function for backing up directories by copying only the files that has been
%modified. This is a simple wrapper call to the XCOPY DOS command with some default flags.
%
%or_dir -(string) original directory to back-up
%bk_dir -(string) back-up (destination) directory
%warn   -(logical) If true (default) will comfirm the user if the source and
%         destination directories are correct
%flags  -(string) Flags to XCOPY command. Default is: '/M /E /F /Y /D /H'
%mode   -(string) Determines the operation mode. Options are:
%        'xcopy'  : (default) will call xcopy DOS command with respective flags
%        'prune'  : calls xcopy command and then delete files in the backup directry that 
%                     do not exist in the original directory
%        'sync'   : syncs both directories. BOTH directories are backep up with the most
%                     up-to-date files from either directory.
%        'find'   : find files and foders in the backup directory that do not exist in the original directory
%        'arch'   : set the archive attribute to ON of files in the original directory that do not exist
%                     on the back-up directory
%
%
% IMPORTANT NOTE: for the 'prune' method, deleting files in the backup
% that does not exist  the original file will not go to recycling bin unless
% you change the default MATLAB setting.
% To set the recycle state for all MATLAB sessions, use the Preferences
% dialog box. Open the Preferences dialog and select General. To enable or
% disable recycling, click Move files to the recycle bin or Delete files
% permanently. See General Preferences for MATLAB in the Desktop Tools and
% Development Environment documentation for more information.
%
%
% Possible Flag optinos are (Windows 2000 and XP ) this will overwrite default flags:
%
% /A Copies only files with the archive attribute set, doesn't change the attribute.
% /M Copies only files with the archive attribute set, turns off the archive attribute.
% /D:m-d-y Copies files changed on or after the specified date. If no date is given, copies only those files whose source time is newer than the destination time.
% /EXCLUDE:file1 [+file2][+file3]... Specifies a list of files containing strings. When any of the strings match any part of the absolute path of the file to be copied, that file will be excluded from being copied. For example, specifying a string like \obj\ or .obj will exclude all files underneath the directory obj or all files with the .obj extension respectively.
% /P Prompts you before creating each destination file.
% /S Copies directories and subdirectories except empty ones.
% /E Copies directories and subdirectories, including empty ones. Same as /S /E. May be used to modify /T.
% /V Verifies each new file.
% /W Prompts you to press a key before copying.
% /C Continues copying even if errors occur.
% /I If destination does not exist and copying more than one file, assumes that destination must be a directory.
% /Q Does not display file names while copying.
% /F Displays full source and destination file names while copying.
% /L Displays files that would be copied.
% /H Copies hidden and system files also.
% /R Overwrites read-only files.
% /T Creates directory structure, but does not copy files. Does not include empty directories or subdirectories. /T /E includes empty directories and subdirectories.
% /U Copies only files that already exist in destination.
% /K Copies attributes. Normal Xcopy will reset read-only attributes.
% /N Copies using the generated short names.
% /O Copies file ownership and ACL information.
% /X Copies file audit settings (implies /O).
% /Y Suppresses prompting to confirm you want to overwrite an existing destination file.
% /-Y Causes prompting to confirm you want to overwrite an existing destination file.
% /Z Copies networked files in restartable mode
%
% %Example this will back-up your work directory (without changing the archive attribute)!!!
% bk_dir=[matlabroot,'\backup'];
% or_dir=[matlabroot,'\work'];
% backup(or_dir,bk_dir,[],'/a /y');



home_dir=pwd;
bk_dir=varargin{1};  %second input is the directory to which we wish to backup
warn=1;
flags=' /M /E /F /Y /D /H';
mode='xcopy';

if(nargin >= 3 )
    if(~isempty(varargin{2}))
        warn=varargin{2}; %overwrite warning flag if not called by empty brackets
    end
    if(nargin >=4)
        if(~isempty(varargin{3}))
            flags=varargin{3};
        end
        if(nargin== 5)
            mode=varargin{4};
        end
    end
end

%Display message to make sure function was called correctly

if(strcmp(mode,'xcopy'))
    try
        cd(bk_dir)
    catch
        str=['Backup directory: \n\n',bk_dir,'\n\nDoes not exist, create one (Y/N)?: '];
        resp=input(str,'s');
        if(strcmpi(resp,'y'))
            [sucess]=mkdir(bk_dir);
            if(~sucess)
                warning('Could not generate backup directory, please check writing status.')
                return
            end
        else
            warning('Unable to continue due to non-existing backup directory.')
            return
        end
    end
    cd(home_dir)

    if(warn)
        str=['***Backing-up data FROM: \n\n',or_dir,'\n\n***TO:\n\n',bk_dir,'\n\n***Please confirm (Y/N): '];
        resp=input(str,'s');

        if(strcmpi(resp,'Y'))
            fprintf('\n\n*****Starting backup*****')
        else
            warning('Quitting backup')
            return
        end
    else
        str=['***Backing-up data FROM: \n\n',or_dir,'\n\n***TO:\n\n',bk_dir,'\n\n***'];
        fprintf(str)
    end
    %Call XCOPY command
    str=['!xcopy "',or_dir,'" "',bk_dir,'" ',flags];
    tic
    eval(str)
    t=toc;
    fprintf(['***Backup complete in ', num2str(t/60),' minutes.\n']);

else %%%% In non xcopy modes
   
    switch lower(mode)
        case 'prune'
            cond='del';
            %back-up files first for prune mode
            backup(or_dir,bk_dir,warn,flags,'xcopy')
            fprintf('***Removing files in:\n');
            display(bk_dir)
            fprintf('\n***That do not exist in :\n');
            display(or_dir)
            fprintf('\n');
            resp=input('Ok (Y/N): ','s');
            if(~strcmpi(resp,'y'))
                warning('Operation cancelled.')
                return
            end
        case 'find'
            cond='src';
            %need to swap names under these conditions due to
            %the order of the for loops in helper functions...
            tmp=or_dir;
            or_dir=bk_dir;
            bk_dir=tmp;
            fprintf('***Searching for files in:\n');
            display(bk_dir)
            fprintf('\n***That do not exist in :\n');
            display(or_dir)
            fprintf('\n');
        case 'arch'
            cond='arch';
            %need to swap names under these conditions due to
            %the order of the for loops in helper functions...
            tmp=or_dir;
            or_dir=bk_dir;
            bk_dir=tmp;
            fprintf('***Archiving files & folders in:\n');
            display(bk_dir)
            fprintf('\n***That do not exist in :\n');
            display(or_dir)
            fprintf('\n');
        case 'sync'
            flags=['/E /F /Y /D /H'];
            fprintf('***Syncing***Backing up only the most recent files in both directories.\n')
            fprintf('\t Hit enter to continue or ctrl+c to quit.')
            pause
            backup(or_dir,bk_dir,warn,flags,'xcopy')
            backup(bk_dir,or_dir,warn,flags,'xcopy')
            return %exit function from sync mode    
    end


    tic;
    %Call helper functions. Implements recursion until a modified sub-folder is
    %found that does not have any directories inside and manipulates accordingly the files
    folderfind(or_dir,bk_dir,cond);
    t=toc;
    fprintf(['*****Complete in ' num2str(t/60), ' minutes.****\n\n'])

end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Helper function that backs up only folders within a directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function folderfind(or_dir,bk_dir,cond)


%CD into original and back-up directories and get all file names
[or_fnames,or_Nfolders]=getfolders(or_dir);
[bk_fnames,bk_Nfolders]=getfolders(bk_dir);


%End of recursion, leaf of the tree, so delete any files in this folder
%that does not exist in original directory
filefind(or_dir,bk_dir,cond);

if(bk_Nfolders>0)

    %More subfolders inside. Keep going down the tree searching for
    %folder & files non-existent in orginal directory

    % Loop through all folders & files and move only those that do not exist
    for i=1:bk_Nfolders
        match=0;
        for j=1:or_Nfolders
            match=strcmp(or_fnames(j).name,bk_fnames(i).name);
            if(match)
                %Folder exists in original directory
                %move in a directory deeper
                or_folder=[or_dir,'/',or_fnames(j).name];
                bk_folder=[bk_dir,'/',bk_fnames(i).name];
                folderfind(or_folder,bk_folder,cond);
                break %from the original directory search since folder was found
            end
        end %of search through the original directory

        if(~match)
            %No matching folder was found so apply cond
            bk_folder=[bk_dir,'\',bk_fnames(i).name];
            if(strcmp(cond,'del'))
                
                %Prompt before user deleting
                fprintf('\n Delete folder: \n')
                disp(bk_folder)
                fprintf('\n')
                resp=input('(Y/N): ','s');
                if(~strcmpi(resp,'y'))
                    warning('Operation cancelled.')
                    return
                end
                dir_sucess=rmdir(bk_folder,'s'); %remove directory

                if(~dir_sucess)
                    str=['Error deleting folder in: ', bk_folder,' . Check permission status.'];
                    warning(str)
                else
                    fprintf('\t**Folder deleted: \n')
                    disp(bk_folder)
                end

            elseif(strcmp(cond,'arc'))
                fprintf('\t**Unique folder set to archive : \n')
                fileattrib(bk_folder,'+a')%set for archiving
                disp(bk_folder)
            elseif(strcmp(cond,'src'))
                fprintf('\t**Unique folder: \n')
                disp(bk_folder)
            else
                %reserved for later
            end

        end %End of no match



    end  %End of browsing through the backup directory
end %End of recursion conditions


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Helper function that backs up only files within a directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filefind(or_dir,bk_dir,cond)


%CD into original and back-up directories and get all file names
[or_fnames,or_Nfiles]=getfiles(or_dir);
[bk_fnames,bk_Nfiles]=getfiles(bk_dir);

% Loop through all files delete only those that do not exist in original
for i=1:bk_Nfiles
    match=0;
    for j=1:or_Nfiles
        match=strcmp(or_fnames(j).name,bk_fnames(i).name);
        if(match)
            break %file found so exit search
        end
    end %of original directory search

    if(match==0)
        %No file was found son manipulate accordin to cond
        bk_file=[bk_dir,'\',bk_fnames(i).name];
        if(strcmp(cond,'del'))
            
            %Prompt before user deleting
            fprintf('\n Delete file: \n')
            disp(bk_file)
            fprintf('\n')
            resp=input('(Y/N): ','s');
            if(~strcmpi(resp,'y'))
                warning('Operation cancelled.')
                return
            end
            
            
            delete(bk_file);
            disp(['***Backup file deleted: ',bk_file])
        elseif(strcmp(cond,'arc'))
            disp(['***Unique file set to archive: ',bk_file])
            fileattrib(bk_file,'+a')%set for archiving
        elseif(strcmp(cond,'src'))
            disp(['***Unique file: ',bk_file])
        else
            %reserved for later
        end
        fprintf('\n')
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Helper function to get only files with no folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fnames,Nfiles]=getfiles(buf_dir)
home_dir=pwd;
cd(buf_dir)
fnames=dir;
Nfiles=length(fnames);

%Search and delete folder names from compiled list
i=1;
while(i <= Nfiles)
    if(fnames(i).isdir)
        fnames(i)=[]; %delete any directories or folders from search
        Nfiles=Nfiles-1;
    else
        i=i+1;
    end
end

cd(home_dir)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Helper function to get only folders (no files in the comiled list)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fnames,Nfolder]=getfolders(buf_dir)
home_dir=pwd;
cd(buf_dir)
fnames=dir;
Nfolder=length(fnames);

%Search and delete files names from compiled list
i=1;
while(i <= Nfolder)
    if(~fnames(i).isdir || strcmp(fnames(i).name,'.') || strcmp(fnames(i).name,'..'))
        fnames(i)=[]; %delete any files from search
        % . and .. directories
        Nfolder=Nfolder-1;
    else
        i=i+1;
    end
end

cd(home_dir)









