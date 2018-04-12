%% GRINdaypicker
%{
GRINalign is the third step in the grinbigdata pipeline.

1. GRINcompress
2. GRINregready
3. [[ GRINdaypicker ]]
4. GRINalign
5. GRINbiganalysis

GRINdaypicker imports a single mat file created by GRINregready which 
contains image stacks and info for all days of experiments performed
on a single subject. Here you will pick a subset of days to group for
image alignment performed in the next script, GRINalign.


%}


%% CLEAR RAM AND CHANGE WORKING DIRECTORIES
clc; close all; clear;
% system('sudo purge')
g=what('grin'); m=what('grin-master');
try cd(g.path); catch;end; try cd(m.path); catch;end
try cd([g.path filesep 'grindata' filesep 'grin_regready']); catch;end
try cd([m.path filesep 'grindata' filesep 'grin_regready']); catch;end
% addpath([g.path filesep 'grindata' filesep 'grin_compressed'])




%% GET PATHS TO REGREADY MAT FILE
clc; close all; clear

disp('Choose a regready mat file.')

[filename , filepath] = uigetfile;
fullpath = [filepath, filename];

clearvars -except filename filepath fullpath


% LOAD ALIGNMENT-READY STACK
disp('Loading REGREADY.mat file (please wait)...')
load(fullpath)
disp('Finished loading REGREADY.mat')








%#############################################################
%%        DETERMINE SUBJECT'S DAILY STIM SCHEDULE
%#############################################################



i=1;

DATA{i}


%% GET ALL STIM TRIAL TYPES FOR ALL DAYS

% It could be (and probably will be) the case that not all stim
% trial types are given each day. For example on day-1 of the
% experiment for a given animal, it may recieve stim trial types:
% tone-sucrose and white-noise-no-sucrose; however the final day
% of experiments pn this animal may include tone-sucrose and
% tone-no-sucrose probe trials.
%
% Here we are identifying all the different stim trial types that
% have ever been given to this particular subject, and saving those
% to a struct variable called 'STIM'



STYPE = DATA{1}.INFO.TreatmentGroups;

for nn = 1:size(DATA,1)

    STYPE = [STYPE ; setdiff( DATA{nn}.INFO.TreatmentGroups , STYPE) ];
    % setdiff(A,B) returns the data in A that is not in B

end

STYPE = sort(STYPE);
% disp(STYPE)

TGi = (1:numel(STYPE))';

STIM = table();

STIM.ID   = TGi;
STIM.STYPE   = STYPE;

disp(STIM)





S = string(STYPE);
T = zeros(numel(TGi),size(DATA,1));

for nn = 1:size(DATA,1)

    m = ismember( S , string(DATA{nn}.INFO.TreatmentGroups) );

    T(m,nn) = 1;

end

for nn = 1:size(T,1)

    T(nn,:) = T(nn,:) .* (nn+1);

end



%#############################################################
%%          CHOOSE DAYS TO INCLUDE GRAPHICALLY
%#############################################################

close all
fh1 = figure('Units','normalized','Position',[.05 .08 .9 .5],'Color','w');
ax1 = axes('Position',[.13 .07 .85 .9],'Color','none');

[y,x,z] = find(T);
ph1 = scatter(x,y,50,z,'filled');
colormap([(jet).*.9])
ax1.YLim = [.5 size(T,1)+.5];

grid on
ax1.XMinorGrid='on';
ax1.XTick = 0:5:size(T,2)+1;
ax1.YTickLabel = S;

% SELECT TWO ROI POINTS
hAP1 = impoint;
hAP2 = impoint;

day1 = hAP1.getPosition;
day2 = hAP2.getPosition;

imline(ax1, [day1; day2]);

d1 = round(day1(1,1));
d2 = round(day2(1,1));
if d1 < 1; d1=1; end
if d2 > size(T,2); d2=size(T,2); end

pause(.4);
close(fh1)
 
fprintf('\nFIRST DAY: %.0f \n',d1)
fprintf('\nLAST DAY: %.0f \n',d2)



%% ONLY KEEP CHOSEN DAYS

DATA = DATA(d1:d2);




%#############################################################
%%        CHOOSE DAYS TO INCLUDE USING EXCEL FILE
%#############################################################
%{
clc

answer = questdlg('DO YOU HAVE AN EXCEL SHEET WITH DAYS?', ...
	'DO YOU HAVE AN EXCEL SHEET WITH DAYS?', ...
	'YES','NO','NO');
% Handle response
switch answer
    case 'YES'
        disp('SELECT EXCEL SHEET WITH DAYS TO ALIGN')
        [filename,filepath] = uigetfile('*.xls*');
        [xlsN, xlsT, xlsR] = xlsread([filepath filename]);
        F=[];
        for i = 1:size(DATA,1)
            F(i) = any(strcmp(DATA{i}.GRINstruct.file,xlsT));
        end
        DATA(~F) = [];
    case 'NO'
        disp('NO EXCEL FILE IT IS. PREPARE TO ALIGN ALL DAYS...')
end
%}







%#############################################################
%%          PREVIEW CHOSEN DAYS AND SAVE
%#############################################################


%% SAVE GREEN CHANNEL PROJECTION IMAGE FOR EACH DAY INTO 'IM'
clc;

IM = zeros(size(DATA{1}.IMGC,1),size(DATA{1}.IMGC,2),size(DATA,1));

for mm = 1:size(DATA,1)

    I = DATA{mm}.IMGC;

    IM(:,:,mm) = mean(mean(I,4),3);

end


clearvars -except datapaths datafiles DATA IM









%% PREVIEW PROJECTION 'IM' STACK

fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');

ph1 = imagesc(IM(:,:,1)); pause(1)

for nn = 1:size(IM,3)
    fprintf('Stack: % .0f \n',nn)
    ph1.CData = IM(:,:,nn);
    pause(.5)
end


clearvars -except datapaths datafiles DATA IM



%% SHOW MONTAGE OF EACH DAY'S PROJECTION IMAGE

close all
fh1=figure('Units','normalized','OuterPosition',[.05 .06 .9 .9],'Color','w','MenuBar','none');
hax1 = axes('Position',[.01 .04 .97 .95],'Color','none'); %hold on;

clc
disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
disp('CLOSE WINDOW WHEN READY TO CONTINUE')
disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
disp(' ')

I = mat2gray(reshape(IM,40,40,1,[]));

hm = montage(I,'Parent',hax1, 'Size', [NaN 9]);

colormap(jet)

uiwait
close all;






% ################################################################
%%                  SAVE DATASET
% ################################################################

clc; clearvars -except DATA

filename = [DATA{1}.INFO.file(1:4) '_DAYPICKS_.mat'];

uisave('DATA',filename)

disp('Finished.')

