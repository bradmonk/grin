%% GRINregready
% 
% GRINregready is the second step in the grin big data pipeline.
% 
% 1. GRINcompress
% 2. >> GRINregready <<
% 3. GRINdaypicker
% 4. GRINalign
% 5. GRINbiganalysis
% 
% 
%{
% 
% 
% GRINregready imports mat files created by 'GRINcompress' and packages
% them into a single mat file that can be used by 'GRINdaypicker'.
% 
% This script also performs several checks to make sure information and
% content from each mat file is standardized. It will check that each
% mat file calls variables by the same name, and makes sure all image
% stacks are the same hight and width.
% 
% 
%}
%----------------------------------------------------



%% CLEAR RAM AND CHANGE WORKING DIRECTORIES
clc; close all; clear;
% system('sudo purge')
g=what('grin'); m=what('grin-master');
try cd(g.path); catch;end; try cd(m.path); catch;end
try cd([g.path filesep 'grindata' filesep 'grin_compressed']); catch;end
try cd([m.path filesep 'grindata' filesep 'grin_compressed']); catch;end
% addpath([g.path filesep 'grindata' filesep 'grin_compressed'])



%% GET PATHS TO GRIN DATA MAT FILES
clc; close all; clear

datafilepath = uigetdir;
regexpStr = '((\S)+(\.mat+))';
allfileinfo = dir(datafilepath);
allfilenames = {allfileinfo.name};
r = regexp(allfilenames,regexpStr);                        
datafiles = allfilenames(~cellfun('isempty',r));      
datafiles = reshape(datafiles,size(datafiles,2),[]);
datapaths = fullfile(datafilepath,datafiles);
disp(' '); fprintf('   %s \r',  datafiles{:} ); disp(' ')
disp(' '); fprintf('   %s \r',  datapaths{:} ); disp(' ')
clearvars -except datapaths datafiles




%% IMPORT DATASETS INTO CELL STRUCT

% IMPORT DATASETS
DATA = cell(size(datapaths));

for nn = 1:size(datapaths,1)

    disp(datapaths{nn})

    DATA{nn} = load(datapaths{nn});

    f = isfield(DATA{nn}, {'IMGS', 'IMGC', 'IMRC', 'LICK', 'INFO', 'XLSD'});
    g = isfield(DATA{nn}, {'GRINstruct', 'XLSdata', 'blockSize'});



    % MAKE SURE 'IMGC' CONTAINS IMAGES (IM) FOR THE GREEN CHANNEL (GC)
    if f(1)
    IMGC = DATA{nn}.IMGS;
    DATA{nn} = rmfield(DATA{nn},'IMGS');
    DATA{nn}.IMGC = IMGC;
    end


    % MAKE SURE 'IMRC' VARIABLE EXISTS, EVEN IF EMPTY
    if ~f(3)
    DATA{nn}.IMRC = [];
    end


    % MAKE SURE 'LICK' VARIABLE EXISTS, EVEN IF EMPTY
    if ~f(4)
    DATA{nn}.LICK = [];
    end


    % IF STILL NAMED 'GRINstruct' CHANGE TO 'INFO'
    if ~f(5)
    INFO = DATA{nn}.GRINstruct;
    DATA{nn} = rmfield(DATA{nn},'GRINstruct');
    DATA{nn}.INFO = INFO;
    end

    % IF STILL NAMED 'XLSdata' CHANGE TO 'XLSD'
    if ~f(6)
    XLSD = DATA{nn}.XLSdata;
    DATA{nn} = rmfield(DATA{nn},'XLSdata');
    DATA{nn}.XLSD = XLSD;
    end


    % MAKE SURE XLSD CONTAINS BLOCKSIZE
    if g(3)
        DATA{nn}.XLSD.blocksize = DATA{nn}.blockSize;
        DATA{nn} = rmfield(DATA{nn},'blockSize');
    end


end

clearvars -except datapaths datafiles DATA


%% PREVIEW IMAGE STACK FROM FIRST STACK

I = DATA{1}.IMGC;
I = mean(I,4);

figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
axes('Position',[.05 .05 .9 .9],'Color','none');

ph1 = imagesc(I(:,:,1)); pause(1)

for nn = 1:size(I,3)
    fprintf('Stack: % .0f \n',nn)
    ph1.CData = I(:,:,nn);
    pause(.04)
end

close all
clearvars -except datapaths datafiles DATA









%% MAKE EVERY DAY 40 X 40 IMAGE


for mm = 1:size(DATA,1)

    szG = size(DATA{1}.IMGC , 1);

    szR = size(DATA{1}.IMRC , 1);

    fprintf('IMPORTED STACK SIZE FOR [[%s]]: %.0f x %.0f \n' ,...
        DATA{mm}.INFO.file,szG,szG)

    if szG ~= 40 
        disp('...resizing IMGC to 40x40')
        I = DATA{mm}.IMGC;
        B = imresize(I,[40 40]);
        DATA{mm}.IMGC = B;
        disp('resize successful.')
    end

    if (szR ~= 40) && (szR > 1)
        disp('...resizing IMRC to 40x40')
        I = DATA{mm}.IMRC;
        B = imresize(I,[40 40]);
        DATA{mm}.IMRC = B;
        disp('resize successful.')
    end

end




clearvars -except datapaths datafiles DATA





%% EXPORT ALIGNMENT-READY STACK

clc; clearvars -except DATA


disp(' ')
disp('DATA{1}.XLSD contains...')
disp(DATA{1}.XLSD)

disp(' ')
disp('DATA{1}.INFO contains...')
disp(DATA{1}.INFO)

disp('DATA{1} contains...')
disp(DATA{1})

disp(' ')
disp('DATA{end} contains...')
disp(DATA{end})


disp('Saving file...')

filename = [DATA{1}.INFO.file(1:4) '_REGREADY.mat'];



% ATTEMPT TO SAVE 'gc00_REGREADY.mat' INTO FOLDER...
% 
%     ~/grin/grindata/grin_regready/gc00/
% ELSE
%     ~/grin/grindata/grin_regready/
% ELSE
%     ~/grin/
% ELSE
%     uisave()
%

g=what('grin'); m=what('grin-master');
try cd(g.path); catch; try cd(m.path); catch;end;end
p=[pwd filesep 'grindata' filesep 'grin_regready'];
try cd(p);catch;try mkdir(p); cd(p); catch;end;end
p=[pwd filesep filename(1:4)];
try cd(p);catch;try mkdir(p); cd(p); catch;end;end


s = regexpi(pwd,'grin');
if isempty(s)
    uisave('DATA',filename)
else
    save(filename,'DATA')
    disp(filename)
    disp('Saved in this folder: ')
    disp(pwd)
end


disp(' ')
disp('GRINregready FINISHED! PROCEED TO GRINdaypicker.')



