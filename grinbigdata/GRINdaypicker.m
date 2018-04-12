%% GRINimregister

%% PURGE RAM
clc; close all; clear;
% system('sudo purge')
F = what('grindata');
cd(F.path);



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


















%#############################################################
%%               WHAT DAYS TO ALIGN??
%#############################################################
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





%% NORMALIZE TO RED CHANNEL THEN DISCARD RED CHANNEL
% TBD

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



%% GET ALIGNMENT VALUES
clc; disp('CHOOSE TWO ALIGNMENT LANDMARKS'); disp(' ')


AlignVals.P1x = zeros(size(IM,3),1);
AlignVals.P1y = zeros(size(IM,3),1);
AlignVals.P2x = zeros(size(IM,3),1);
AlignVals.P2y = zeros(size(IM,3),1);


for nn = 1:size(IM,3)

I = IM(:,:,nn);

close all;

fhIMA=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
haxIMA = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[],'YTick',[]);


% axes(haxIMA)
phG = imagesc(I,'Parent',haxIMA,'CDataMapping','scaled');
% phG = imshowpair(IM(:,:,1), I,'Scaling','independent');

% [cmax, cmaxi] = max(I(:));
% [cmin, cmini] = min(I(:));
% cmax = cmax - abs(cmax/12);
% cmin = cmin + abs(cmin/12);
% haxIMA.CLim = [cmin cmax];


% SELECT TWO ROI POINTS
hAP1 = impoint;
hAP2 = impoint;

AP1pos = hAP1.getPosition;
AP2pos = hAP2.getPosition;

imellipse(haxIMA, [AP1pos-2 4 4]); pause(.1);
imellipse(haxIMA, [AP2pos-2 4 4]); pause(.1);

pause(.5);
close(fhIMA)


fprintf('ALIGNMENT POINTS \n');
fprintf('P1(X,Y): \t    %.2f \t    %.2f \n',AP1pos);
fprintf('P2(X,Y): \t    %.2f \t    %.2f \n',AP2pos);


AlignVals.P1x(nn) = AP1pos(1);
AlignVals.P1y(nn) = AP1pos(2);
AlignVals.P2x(nn) = AP2pos(1);
AlignVals.P2y(nn) = AP2pos(2);

end


clearvars -except datapaths datafiles DATA IM AlignVals





%% USE ALIGNMENT VALUES FOR TRANSLATION
clc;

n = round(numel(AlignVals.P1x) / 2);

MASTER1x = AlignVals.P1x(n);
MASTER1y = AlignVals.P1y(n);
MASTER2x = AlignVals.P2x(n);
MASTER2y = AlignVals.P2y(n);

IMx = AlignVals.P1x;
IMy = AlignVals.P1y;

% tX = IMx - MASTER1x;
% tY = IMy - MASTER1y;

tX = MASTER1x - IMx;
tY = MASTER1y - IMy;



IMGC={};
for mm = 1:size(DATA,1)
    IMGC{mm} = DATA{mm}.IMGC;
end


IMGA={};
for i = 1:size(IMGC,2)

    G = IMGC{i};

    IMGA{i} = imtranslate(G,[tX(i), tY(i)],'FillValues',mean(G(:)),'OutputView','same');

end


clearvars -except datapaths datafiles DATA IM AlignVals IMGA






%% PREVIEW ALIGNMENT
clc; close all;


IG = zeros(size(IMGA{1},1) , size(IMGA{1},2) , size(IMGA,2));


for nn = 1:size(IG,3)

    IG(:,:,nn) = mean(mean(IMGA{nn},4),3);

end



%---------  PREVIEW ALIGNMENT AND CAPTURE GIF FRAMES  -----------

close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');

ph1 = imagesc(IG(:,:,1)); pause(.2)

for nn = 1:size(IG,3)

    ph1.CData = IG(:,:,nn);
    title(DATA{nn}.GRINstruct.file,'Interpreter','none')
    pause(.4)

    frame = getframe(fh1);
    figframe{nn} = frame2im(frame);

end



% --- JUST WAIT TO SAVE A GIF OF THE CROPPED DATA BELOW ---
%
% clearvars -except datapaths datafiles DATA IM AlignVals IMGA IMRA IG IR...
% isred figframe
% 
% 
% %---------  SAVE ANIMATED GIF OF ALIGNMENT  -----------
% 
% filename = [DATA{1}.GRINstruct.file(1:4) '_aligned.gif'];
% 
% for i = 1:size(figframe,2)
% 
%     [A,map] = rgb2ind(figframe{i},256);
% 
%     if i == 1
%         imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',.5);
%     else
%         imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',.5);
%     end
% end
% 
% close all;


clearvars -except datapaths datafiles DATA IM AlignVals IMGA IG













%% GET CROPBOX COORDINATES FOR ALIGNED (REGISTERED) STACKS
clc; close all;

I = mean(IG,3);

disp(' '); 
disp('DRAG RECTANGLE TO DESIRED POSITION')
disp('THEN DOUBLE CLICK INSIDE RECTANGLE TO CONTINUE')

%---------  CREATE IMAGE CROPPING FIGURE  -----------
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none'); % ,'YDir','reverse'
phTRIM = imagesc(I,'Parent',hax1,'CDataMapping','scaled');
axis tight; colormap(hot(40))
pause(.07);


%---------  CREATE ROI RECTANGLE ON CROPPING FIGURE  -----------
cropAmount = 4;

[Iw,Ih,In] = size(I);

h = imrect(hax1, [cropAmount cropAmount Iw-cropAmount*2 Ih-cropAmount*2]);
setFixedAspectRatioMode(h,true)
setResizable(h,false)

CropPosition = wait(h);
close all;

% CropPosition = round(CropPosition);

pos = [ceil(CropPosition(1:2) - .5) ceil(CropPosition(3:4))];
cols = pos(1):(pos(1)+pos(3)-1);
rows = pos(2):(pos(2)+pos(4)-1);



clearvars -except datapaths datafiles DATA IM AlignVals IMGA IG...
CropPosition pos cols rows



%% CROP AND TILE ALIGNED IMAGE STACK FOR EACH DAY

%---- CROP IMAGES

IMGAC={}; 

for i = 1:size(IMGA,2)

    G = IMGA{i};
    IMGAC{i} = G(rows , cols , :, :);

end




%---------  PREVIEW ALIGNED & CROPPED STACK  -----------

close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');

IMU = mean(mean(IMGAC{1},4),3);

ph1 = imagesc(IMU); pause(.2)

for nn = 1:size(IG,3)

    IMU = mean(mean(IMGAC{nn},4),3);

    ph1.CData = IMU;
    title(DATA{nn}.GRINstruct.file,'Interpreter','none')
    pause(.2)

    frame = getframe(fh1);
    figframe{nn} = frame2im(frame);

end


%---------  SAVE ANIMATED GIF OF ALIGNMENT  -----------

filename = [DATA{1}.GRINstruct.file(1:4) '_aligned_cropped.gif'];
for i = 1:size(figframe,2)
    [A,map] = rgb2ind(figframe{i},256);
    if i == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',.5);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',.5);
    end
end
close all;



clearvars -except datapaths datafiles DATA IM AlignVals IMGA IG IMGAC





% ################################################################
%%                      SAVE ALIGNED DATASET
% ################################################################

%---- SAVE STACK BACK INTO MAIN DATA CONTAINER
for i = 1:size(IMGAC,2)

    DATA{i}.IMAL = IMGAC{i};

end



for nn = 1:size(DATA,1)

    if isfield(DATA{nn}, 'blockSize')
        DATA{nn} = rmfield(DATA{nn},'blockSize');
    end

%     if isfield(DATA{nn}, 'IMGC')
%     DATA{nn} = rmfield(DATA{nn},'IMGC');
%     end
% 
%     if isfield(DATA{nn}, 'IMGR')
%     DATA{nn} = rmfield(DATA{nn},'IMGR');
%     end

end


clc; clearvars -except datapaths datafiles DATA IM AlignVals IMGA IG IMGAC


filename = [DATA{1}.GRINstruct.file(1:4) '_ALIGNED_.mat'];

% save(filename,'DATA')
uisave('DATA',filename)

disp('Finished.')



return
open GRINbiganalysis.m
