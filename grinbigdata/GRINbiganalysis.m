clc; close all; clear all;
% system('sudo purge')

cd(fileparts(which('GRINbiganalysis.m')));
fprintf('\n\n Working DIR set to: \n % s \n', ...
fileparts(which('GRINbiganalysis.m')))



%% IMPORT DATASETS AND (OPTIONALLY) NORMALIZE GREEN - RED CHANNEL STACKS

[filename,filepath] = uigetfile;

cd(filepath)

load([filepath,filename])

clearvars -except filepath filename DATA


IMG  = {};
INFO = DATA{1}.GRINstruct;
XLS  = DATA{1}.XLSdata;



for nn = 1:size(DATA,1)

    G = DATA{nn};
    
    IMG{nn,1}  = G.IMAL;
    INFO(nn,1) = G.GRINstruct;
    XLS(nn,1)  = G.XLSdata;

end

clearvars -except filepath filename DATA IMG INFO XLS




close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');
ph1 = imagesc(mean(mean(IMG{1},4),3));
for nn = 1:size(IMG,1)
    ph1.CData = mean(mean(IMG{nn},4),3);
    pause(.2)
end



disp('EACH IMAGE STACK IS SIZE: ')
disp( size(IMG{1}) )
pause(2)



%#############################################################
%%               WHAT DAYS TO ANALYZE??
%#############################################################
clc

answer = questdlg('DO YOU HAVE AN EXCEL SHEET WITH DAYS?', ...
	'DO YOU HAVE AN EXCEL SHEET WITH DAYS?', ...
	'YES','NO','NO');
% Handle response
switch answer
    case 'YES'
        disp('SELECT EXCEL SHEET WITH DAYS TO ANALYZE')
        [filename,filepath] = uigetfile('*.xls*');
        [xlsN, xlsT, xlsR] = xlsread([filepath filename]);
        F=[];
        for i = 1:size(INFO,1)
            F(i) = any(strcmp(INFO(i).file,xlsT));
        end
        IMG(~F) = [];
        INFO(~F) = [];
        XLS(~F) = [];
    case 'NO'
        disp('YOU SUCK!')
end





clearvars -except filepath filename DATA IMG INFO XLS
























%% CONVERT RAW IMAGES TO dF/F IMAGES


IMF = IMG;


for nn=1:size(IMG,1)

    IM = double(IMG{nn});

    baselineMean = mean(  IM(:,:,1:INFO(nn).CSUSonoff(1),:)  ,3);

    basemu = repmat(baselineMean,1,1,size(IM,3),1);

    IMF{nn} = (IM - basemu) ./ basemu;

end


clc; clearvars -except IMG IMF INFO XLS





%% SHOW MEAN RAW IMAGE AND DF/F IMAGE FROM EACH DAY
close all

N = size(IMG,1);

fh1=figure('Units','normalized','OuterPosition',[.05 .07 .9 .9],'Color','w','MenuBar','none');
for nn = 1:N

    IM = IMG{nn};

    subplot(5,ceil(N/5),nn);
    imagesc( mean(mean(IM,4),3) );
    axis image
    title(INFO(nn).file(11:14),'Interpreter','none')

end


N = size(IMF,1);

fh2=figure('Units','normalized','OuterPosition',[.04 .04 .9 .9],'Color','w','MenuBar','none');
for nn = 1:N

    IM = IMF{nn};

    subplot(5,ceil(N/5),nn);
    imagesc( mean(mean(IM,4),3) );
    axis image
    title(INFO(nn).file(11:14),'Interpreter','none')

end






clc; clearvars -except IMG IMF INFO XLS





%% CULL INCOMPATIBLE TRIALS FROM KNOWN SUBJECTS

% CURRENTLY APPLIES ONLY TO GC33
%{
if strcmp(datafiles{1}(6:9),'gc33')
    datapaths(1:7) = [];
    datafiles(1:7) = [];
    IMG(1:7)       = [];
    INFO(1:7)      = [];
    XLS(1:7)       = [];



    IM = IMG(1:17);


    for nn=1:size(IM,1)

        IM{nn} = imresize(IM{nn}, [40 40] , 'bilinear');

    end


    IX = zeros(size(IM,1),size(IM,2),100,size(IM,4));
    for nn=1:size(IM,1)
        I = IM{nn};
        J = IM{nn};

        sz=(size(I,3)-100)*2;

        (I(:,:,mm,:) + I(:,:,mm+1,:)) ./ 2

        ( I(:,:, 1:2:end ,:) + I(:,:, 2:2:end ,:) ) ./ 2


    for mm=1:(size(I,3)-100)*2

        mu = (I(:,:,mm,:) + I(:,:,mm+1,:))./2;
        I(:,:,mm,:) = mu;

    end
    end

end



%% CULL INCOMPATIBLE TRIALS FROM KNOWN SUBJECTS


% gc33 is standard size only after 2016_0305
if strcmp(datafiles{1}(6:9),'gc33')
    datapaths(1:24) = [];
    datafiles(1:24) = [];
    IMG(1:24)       = [];
    INFO(1:24)      = [];
    XLS(1:24)       = [];
end

%}







%% GET NUMBER OF FRAMES & IMAGE SIZES
%{
N = size(IMG,1);

FRAMES=[];
PIXELS=[];
for nn = 1:N

    FRAMES = [FRAMES INFO(nn).frames(1,end)];
    PIXELS = [PIXELS XLS(nn).sizeIMGS(1)];

end


if all(PIXELS(1) == PIXELS)
    PIX = PIXELS(1);
else
    disp('Images not all same size')
    return
end

if all(FRAMES(1) == FRAMES)
    FRM = FRAMES(1);
else
    disp('Not all IMG stacks have same N frames')
    return
end

fprintf('\n These image stacks have %.0f pixels and %.0f frames \n',PIX,FRM);




clearvars -except IMG IMF INFO XLS FRM PIX
%}










%% GET AVERAGE FOR EACH STIM TYPE  (FOR DF/F STACK)
clc; close all

N = size(IMF,1);


IMX = {};
for i = 1:N

    I = IMF{i};

    Vn = size(INFO(i).tf,2);

    IM=zeros(size(I,1),size(I,2),size(I,3),Vn);
    for j = 1:Vn

        IMu = I(:,:,:,INFO(i).tf(:,j));

        IM(:,:,:,j) =  mean(IMu,4);
    end

	IMX{i} = IM;
end

size(IMX{1})

imagesc(  mean(mean(IMX{1},4),3)    )




%
% By this point in the script we now have a cell array (IMX),
% with one cell for each day...
%
% >> size( IMX )
%
%    1 x nDays
% 
%
% where each cell has a size of around...
% 
% >> size( IMX{1} )
%
%    40 x 40 x 100 x nStimTypes
% 
%
% Where nStimTypes is the number of different experimental conditions,
% with regard to stimulus presentation types for that daily imaging 
% session. For example if that day the subject was given 36 trials 
% that included (9) tone-shock, (9) tone-no-shock, (18) tone-sucrose, 
% then the size of IMX{1} would be...
%
%    40 x 40 x 100 x 3
% 
% The stack has been collapsed to 3 because trials of the same
% type, on the same day, have been averaged. More specifically, an
% average was computed based on: 
%
%    same pixel, same frame, same stim, same day.
%
% Also note the data processing to create IMX was done on a dF/F image
% stack, not a raw pixel-value image stack. The reason being is that
% it's not wise to average across trials unless the data has been 
% normalized to a baseline at the beginning of each trial. If there 
% were any GCaMP signal-strength drift throughout the course of the 
% daily imaging session, averaging raw pixel values from trials during
% the beginning of each session with trials from the end of each session
% will mask any trial-level effects.


clearvars -except IMG INFO XLS FRM PIX IMX

% Next we need to create a way to identify each of the different
% stim types present in the dataset, so if IMX has a size like
% [40 x 40 x 100 x 3] we actually know which 3 stim trial types
% were presented that day.





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



STYPE = INFO(1).TreatmentGroups;

for nn = 1:size(INFO,1)

    STYPE = [STYPE ; setdiff( INFO(nn).TreatmentGroups , STYPE) ];
    % setdiff(A,B) returns the data in A that is not in B

end

STYPE = sort(STYPE);
% disp(STYPE)

TGi = (1:numel(STYPE))';

STIM = table();

STIM.ID   = TGi;
STIM.STYPE   = STYPE;

disp(STIM)





clearvars -except IMG INFO XLS FRM PIX IMX STIM





%% STIM TRIAL TYPE LIST FOR EACH GC SUBJECT

%{
% gc52
%     ID                  STYPE              
%     __    ______________________________
%     1     'tone no sucrose'             
%     2     'tone shock'                  
%     3     'white noise no sucrose'      
%     4     'white noise sucrose'         
%     5     'white noise sucrose omission'


% gc74
%     ID                 STYPE             
%     __    ____________________________
%     1     'tone no sucrose'           
%     2     'tone sucrose'              
%     3     'tone sucrose omission'     
%     4     'white noise no sucrose'    
%     5     'white noise shock'         
%     6     'white noise shock omission'


% gc75
%     ID                  STYPE              
%     __    ______________________________
%     1     'tone no sucrose'             
%     2     'white noise no sucrose'      
%     3     'white noise sucrose'         
%     4     'white noise sucrose omission'


% gc80
%     ID               STYPE           
%     __    ________________________
%     1     'tone no sucrose'       
%     2     'tone sucrose'          
%     3     'white noise no sucrose'


% gc90
%     ID               STYPE           
%     __    ________________________
%     1     'tone no sucrose'       
%     2     'white noise no sucrose'
%     3     'white noise sucrose'  

%}



%% ADD THOSE TREATMENT INDICATORS TO INFO STRUCT

% It could be (and probably will be) the case that not all stim
% trial types are given each day. For example on day-1 of the
% experiment for a given animal, it may recieve stim trial types:
% tone-sucrose and white-noise-no-sucrose; however the final day
% of experiments pn this animal may include tone-sucrose and
% tone-no-sucrose probe trials.
%
% Above we identified all the different stim trial types that
% have ever been given to this particular subject, and saved those
% to a struct variable called 'STIM'.
%
% Here we are going to give each type of stim trial a unique ID number.
% Using this ID we will be able to determine which trial types are being
% performed on a given day, and will also let us compare the same
% stim trial types from different days. These ID numbers will be appended
% onto the INFO struct container in two formats:
% 
%     INFO(day).STIMd
%
%     INFO(day).STIMg
%
% 
% STIMd will be nTrials-by-nStimTypesThatDay
% STIMg will be nTrials-by-nGlobalStimTypes
% 
% STIMd will contain integers that indicate the stim type ID.
% STIMg will contain logicals in the respective trial-type column
% 
% To clarify, if tone-sucrose is assigned the ID=1 and tone-shock is 
% assigned the ID=4, and those are the only two types of stim trials 
% given on the 8th day of testing, then STIMd and STIMg might look like:
%
% 
%     INFO(8).STIMd
%          1     0
%          1     0
%          0     4
%          1     0
%          0     4
%          0     4
%          1     0
%          0     4
%          ...   ...
%
%     INFO(8).STIMg
%          1     0     0     0     0     0
%          1     0     0     0     0     0
%          0     0     0     1     0     0
%          1     0     0     0     0     0
%          0     0     0     1     0     0
%          ...   ...   ...   ...   ...   ...
% 



N = size(IMG,1);

INFO(1).STIMd = [];
INFO(1).STIMg = [];

for nn = 1:N

    Groups = INFO(nn).TreatmentGroups;

    [a,b,c] = intersect(Groups,STIM.STYPE);

    INFO(nn).STIMd = INFO(nn).tf .* 1.0;

for i = 1:size(Groups,1)

    INFO(nn).STIMd(:,i) = INFO(nn).tf(:,i) .* c(i);

end
end



% INFO(nn).STIMg = zeros(  TGi(end)  )

for nn = 1:N

    Groups = INFO(nn).TreatmentGroups;

    [a,b,c] = intersect(Groups,STIM.STYPE);

    INFO(nn).STIMg = zeros( size(INFO(nn).tf,1), STIM.ID(end) );

for i = 1:size(c,1)

    INFO(nn).STIMg(:,c(i)) = INFO(nn).tf(:,i);

end
end

% INFO = rmfield(INFO,'STIMS')
% INFO = rmfield(INFO,'STIMd')
% INFO = rmfield(INFO,'STIMg')




clc; clearvars -except IMG INFO XLS FRM PIX IMX STIM

disp('STIM'); disp(STIM)
disp('INFO(i).STIMd(1:j,:)'); disp( INFO(1).STIMd(1:4:end,:) )
disp('INFO(i).STIMg(1:j,:)'); disp( INFO(1).STIMg(1:4:end,:) )






%% PUT STACKS INTO CONTAINER WITH OTHERS OF SAME STYPE

% N = length(IMG);
% N = length(IMX);
% 
% size(IMG{i})
% size(IMX{i})

IMS = cell([size(STIM.STYPE,1) length(IMX)]);
% Tx  = cell(size(STIM.STYPE));



for i = 1:length(IMX)

    IMXi = IMX{i};


    [r,c,v] = find(INFO(i).STIMd);
    u = unique(INFO(i).STIMd);
    u = u(u>0);


    for j = 1:size(u,1)

        IMS{u(j),i} = IMXi(:,:,:,j);

    end


end



clc; clearvars -except IMG INFO XLS FRM PIX IMX STIM IMS





















%% PUT STACKS INTO CONTAINER WITH OTHERS OF SAME STYPE

%{
%     STIM
%     INFO(1).tf
%     INFO(1).csus
%     INFO(1).id
%     INFO(1).TreatmentGroups
%     INFO(1).STIMd
%     INFO(1).STIMg

N = length(IMG);
N = length(IMX);

size(IMG{N})
size(IMX{N})



IMS = cell(size(STIM.STYPE));
Tx  = cell(size(STIM.STYPE));

for nn = 1:N

    id = INFO(nn).STIMd > 0;
    gd = INFO(nn).STIMg > 0;

for i = 1:size(gd,2)

    fprintf('\nNow getting: %s \n\n',char(STIM.STYPE(i)))

    %any(STYPE(:,i))

    IM = IMG{nn}(:,:,:,gd(:,i));

    r = find(gd(:,i));
    sub = repmat(str2num(INFO(nn).file([3 4])),numel(r),1);
    d = repmat(str2num(INFO(nn).file([6 7 8 9 11 12 13 14])),numel(r),1);
    subr = [sub , d, r];

    if size(IM,4) > 0

        Tx{i}(end+1 : end+size(subr,1) , :) = subr;

        mu = squeeze(mean(mean(mean( IM(:,:,1:10,:) , 3),2),1));

        IMS{i}(:,:,:, end+1 : end+size(IM,4) ) = double(IM);

        %if (size(subr,1) ~= size(IM,4)); keyboard; end
        %IMS{i}(:,:,:, end+1 : end+size(IM,4) ) = double(IM);
        %for j = 1:size(mu,1)
        %    IMS{i}(:,:,:, end-j+1 ) = IMS{i}(:,:,:, end-j+1 ) ./ mu(j);
        %end

    end

end
end

for nn = 1:size(IMS,1)
    IMS{nn}(:,:,:,1) = [];
end


clc;
for nn = 1:size(IMS,1)
    STIM.STYPE(nn)
    IMS(nn)
end



clc; clearvars -except IMG INFO XLS FRM PIX IMX STIM IMS Tx

size(IMS)
size(IMS{1})




%}


%#############################################################
%%                GET ROI TILES      (STIM TYPE RESTART-POINT)
%#############################################################

%---- SELECT WHICH STIMULATION TRIAL TYPE TO FOCUS ON

clc; close all;
d = dialog('Units','normalized','Position',[.4 .5 .2 .2],'Name','Select One');
t=sprintf(['       SELECT STIM TYPE\n'...
           'click popup menu even if desired\n'...
           '  stim is showing by default']);
txt = uicontrol('Parent',d,...
       'Style','text',...
       'Units','normalized',...
       'Position',[.1 .6 .8 .3],...
       'String',t);
popup = uicontrol('Parent',d,...
       'Style','popup',...
       'Units','normalized',...
       'Position',[.1 .4 .8 .2],...
       'String',STIM.STYPE,...
       'Callback','IDX=popup.Value');
btn = uicontrol('Parent',d,...
       'Units','normalized',...
       'Position',[.1 .1 .8 .3],...
       'String','Continue',...
       'Callback','close all');
       
uiwait

TrialType = STIM.STYPE{IDX};

INFO(1).PopupPick = TrialType;





%---- PULL-OUT TRIAL TYPE THAT WAS SELECTED FROM POPUP MENU

TNS   = IMS((strcmp(STIM.STYPE,TrialType)),:);

noT = zeros(size(TNS));
for i=1:length(TNS)
    noT(i) = isempty(TNS{i});
end

TNS(noT==1) = [];

IMT = zeros([size(TNS{1}) size(TNS,2)]);

for nn=1:size(TNS,2)

    IMT(:,:,:,nn) = TNS{nn};

end






clc;
fprintf('trial type: %s \n\n',TrialType)
disp(' rows  cols  frames  days')
disp(size(IMT))

clearvars -except IMG INFO XLS FRM PIX IMX STIM IMS IMT








%% SELECT ROI FROM IMAGES OF STIM TYPE SELECTED ABOVE



% -----------  DRAW ROI  ----------- 

clc; close all;
figure('Units','normalized','OuterPosition',[.1 .05 .7 .92],'Color','w','MenuBar','none');
axes('Position',[.06 .06 .9 .9],'Color','none');

imagesc(mean(mean(IMT,4),3))

title(['(1) Draw a square around ROI. '... 
       '(2) Double-click inside the square to continue.'])
h = imrect; 
position = wait(h); 
close all

pos = [ceil(position(1:2) - .5) ceil(position(3:4))];
cols = pos(1):(pos(1)+pos(3)-1);
rows = pos(2):(pos(2)+pos(4)-1);

disp('ROI cols')
disp(cols)
disp('ROI rows')
disp(rows)


clearvars -except IMG INFO XLS FRM PIX IMX STIM IMS IMT rows cols






%% GET DATA FROM ROI TILES

Nframes = size(IMT,3);
Ndays = size(IMT,4);

IMD = zeros(Nframes,Ndays);


for nn = 1:Ndays

    I = squeeze(mean(mean(mean(IMT(rows,cols,:,nn),4),2),1));

    IMD(:,nn) = I - I(1);

end



size(IMD)

plot(IMD)


clearvars -except IMG INFO XLS FRM PIX IMX STIM IMS IMT rows cols IMD




























%% SELECT ROI FROM IMAGES OF STIM TYPE SELECTED ABOVE


%{
% Index events happening on the same day
[ua,ub,uc] = unique(TxTNS(:,2));



% Get mean of trials from day-1 to display in ROI selector
I = mean(mean(TNS(:,:,:,uc==1),4),3);



% -----------  DRAW ROI  ----------- 

clc; close all;
figure('Units','normalized','OuterPosition',[.1 .05 .7 .92],'Color','w','MenuBar','none');
axes('Position',[.06 .06 .9 .9],'Color','none');

imagesc(I)

title(['(1) Draw a square around ROI. '... 
       '(2) Double-click inside the square to continue.'])
h = imrect; 
position = wait(h); 
close all

pos = [ceil(position(1:2) - .5) ceil(position(3:4))];
cols = pos(1):(pos(1)+pos(3)-1);
rows = pos(2):(pos(2)+pos(4)-1);

disp('ROI cols')
disp(cols)
disp('ROI rows')
disp(rows)






% ------------ GET DATA FROM ROI TILES -----------

Nframes = size(TNS,3);
Ndays = numel(ua);

TTActivityPerDay = zeros(Nframes,Ndays);


for nn = 1:Ndays

    I = squeeze(mean(mean(mean(TNS(rows,cols,:,uc==nn),4),2),1));

    TTActivityPerDay(:,nn) = I - I(1);

end



size(TTActivityPerDay)

plot(TTActivityPerDay)





clearvars -except datapaths datafiles IMG INFO XLS FRM PIX IMX ...
STIM STYPE TGi IMS Tx TrialType TNS TxTNS TTActivityPerDay

%}




% %% SURFACE PLOT SMOOTHED
% % cftool
% 
% 
% % ACT = IMD(:,1:9);
% ACT = IMD;
% 
% StimType = INFO(1).PopupPick;
% 
% 
% [xD,yD,zD] = prepareSurfaceData(1:size(ACT,1),1:size(ACT,2),ACT);
% ft = 'biharmonicinterp';
% [fitresult, gof] = fit( [xD, yD], zD, ft, 'Normalize', 'on' );
% 
% 
% close all
% fh31 = figure('Units','normalized','OuterPosition',[.1 .04 .81 .93],'Color','w');
% ax31 = axes('Position',[.1 .40 .83 .55],'Color','none');
% ax32 = axes('Position',[.1 .05 .83 .26],'Color','none');
% 
% 
% axes(ax31)
% h1 = plot( fitresult, [xD, yD], zD );
% xlabel('SECONDS'); ylabel('DAY'); zlabel('NEURAL ACTIVITY')
% title([INFO(1).file(1:4) '  ' StimType]); grid on; view(-9,12)
% L1 = light('Position',[1 .3 .8],'Style','local');
% L2 = light('Position',[1 .5 1],'Style','local');
% lighting gouraud;
% % shading interp
% hold on
% 
% % axes(ax31)
% x = 30:2:55;
% y = 1:1:8;
% z = -.1:.05:.15;
% [x,y,z] = meshgrid(x,y,z);
% v = x.*exp(-x.^2-y.^2-z.^2);
% xslice = [XLS(1).CSonsetFrame(1) , XLS(1).CSoffsetFrame(1)]; 
% yslice = 0; 
% zslice = [0,0];
% 
% 
% % hx = slice(x,y,z,v,xslice,yslice,zslice);
% hx = slice(x,y,z,v,xslice,[],[]);
% for i=1:length(hx)
% hx(i).FaceColor = 'interp';
% hx(i).EdgeColor = 'none';
% hx(i).FaceAlpha = .2;
% % colormap hsv
% end
% 
% 
% % Make contour plot.
% axes(ax32)
% h2 = plot( fitresult, [xD, yD], zD, 'Style', 'Contour' );
% xlabel('SECONDS'); ylabel('DAY'); grid on; hold on
% line([XLS(1).CSonsetFrame(1) XLS(1).CSonsetFrame(1)],ax32.YLim,...
% 'Color','red','LineStyle','--')
% line([XLS(1).CSoffsetFrame(1) XLS(1).CSoffsetFrame(1)],ax32.YLim,...
% 'Color','red','LineStyle','--')
% 
% 
% 
% 
% h1(2).Marker = 'none';
% h2(2).Marker = 'none';
% 
% 
% 
% 
% clc;
% clearvars -except IMG INFO XLS FRM PIX IMX STIM IMS IMT rows cols IMD
% 
% 
% saveas(gcf,[INFO(1).file(1:4) '  ' INFO(1).PopupPick '.png'])
% saveas(gcf,[INFO(1).file(1:4) '  ' INFO(1).PopupPick '.svg'])
% saveas(gcf,[INFO(1).file(1:4) '  ' INFO(1).PopupPick],'epsc')
% disp('figure saved')







%% SURFACE PLOT SMOOTHED

clc;
clearvars -except IMG INFO XLS FRM PIX IMX STIM IMS IMT rows cols IMD


StimType = INFO(1).PopupPick;

ACT = IMD;
% ACT(:,[6,8]) = [];
% ACT(:,[6,9]) = [];
% ACT(:,[8,9]) = [];
% ACT = ACT(:,1:9);
% [i,j] = sort(mean(ACT(52:65,:)),'descend');
% ACT = ACT(:,j);


% ACT(1:40,:) = zscore(ACT(1:40,:));
% ACT(1:40,:) = ACT(1:40,:) - mean(ACT(1:40,:));

%--------------------- SMOOTH DATA ---------------------
szA = size(ACT,2);

ACT = ACT - mean(mean(ACT(1:40,:)));
ACT(1:40,:) = reshape(smooth(ACT(1:40,:),15,'rlowess'),size(ACT(1:40,:)));
ACT(80:end,:) = reshape(smooth(ACT(80:end,:),10,'rlowess'),size(ACT(80:end,:)));
ACT(80:end,:) = reshape(smooth(ACT(80:end,:),10,'rlowess'),size(ACT(80:end,:)));
ACT = reshape(smooth(ACT,9,'lowess'),size(ACT));



% %--------------------- PLOT 2D SIGNAL ---------------------
% clc; close all
% fh1 = figure('Units','normalized','OuterPosition',[.01 .06 .95 .8],'Color','w','MenuBar','none');
% ax1 = axes('Position',[.05 .06 .9 .9],'Color','none'); hold on;
% ax2 = axes('Position',[.05 .06 .9 .9],'Color','none'); hold on;
% 
% axes(ax1)
% plot(ACT)
% axes(ax2)
% plot(ACT,'.','LineStyle','none')
% ax1.YLim = ax2.YLim;




%--------------------- PREPARE 3D SURFACE DATA ---------------------
[xD,yD,zD] = prepareSurfaceData(1:size(ACT,1),1:size(ACT,2),ACT);
% cftool(xD,yD,zD)

%---- INTERPOLATION TYPE
ft = 'biharmonicinterp';
% ft = 'smoothingspline';
% ft = 'lowess'
% ft = 'poly11'
[fitresult, gof] = fit( [xD, yD], zD, ft, 'Normalize', 'on');





%-----------------   GENERATE FIGURE AND AXES   ---------------------
close all;
fh31 = figure('Units','normalized','OuterPosition',[.1 .04 .81 .93],'Color','w');
ax31 = axes('Position',[.08 .40 .85 .55],'Color','none');
ax32 = axes('Position',[.06 .05 .43 .26],'Color','none'); hold on;
ax33 = axes('Position',[.06 .05 .43 .26],'Color','none'); hold on;
ax34 = axes('Position',[.54 .05 .43 .26],'Color','none');


    axes(ax31)
h1 = plot( fitresult, [xD, yD], zD );

xlabel('SECONDS'); ylabel('DAY'); zlabel('NEURAL ACTIVITY')
title([INFO(1).file(1:4) '  ' StimType]); 
grid on; view(77,31)
% L1 = light('Position',[20 1  .12],'Style','local');
% L2 = light('Position',[90 5 -.12],'Style','local');
h1(1).FaceAlpha = .9;
h1(1).FaceColor = 'interp';
h1(1).FaceLighting = 'gouraud';
h1(1).BackFaceLighting = 'unlit';
h1(1).EdgeAlpha = 1;
h1(1).EdgeLighting = 'gouraud';
% h1(1).Marker = '.';
% h1(1).MarkerSize = 20;
h1(1).AmbientStrength = .8;
h1(1).SpecularStrength = .5;
h1(1).SpecularExponent = 15;
h1(1).SpecularColorReflectance = .2;

h1(2).Marker = 'none';
% h1(2).Marker = '.';
% h1(2).MarkerEdgeColor = 'k';
% camproj('perspective')
hold on



%------ DRAW STIM WINDOWS

% axes(ax31)
x = 30:2:55;
y = 1:1:size(ACT,2);
% z = -.1:.05:.15;
z = (min(zD)-.02):.05:max(zD)*1.2;
[x,y,z] = meshgrid(x,y,z);
v = x.*exp(-x.^2-y.^2-z.^2);
xslice = [XLS(1).CSonsetFrame(1) , XLS(1).CSoffsetFrame(1)]; 
yslice = 0; 
zslice = [0,0];

% hx = slice(x,y,z,v,xslice,yslice,zslice);
hx = slice(x,y,z,v,xslice,[],[]);
for i=1:length(hx)
% hx(i).FaceColor = 'interp';
hx(i).FaceColor = 'r';
hx(i).EdgeColor = 'none';
hx(i).FaceAlpha = .4;
% colormap hsv
end





%-----------  MAKE BOTTOM PLOT 2D SIGNAL  ---------------------
    axes(ax32)
ph1 = plot(ACT);

    axes(ax33)
ph2 = plot(ACT,'.','LineStyle','none');
    ax33.YLim = ax32.YLim;
ni = numel(ph1);
c = flipud(cool(ni));
% c = cool(ni);
for nn=1:numel(ph1)
    ph1(nn).Color = c(nn,:);
    ph2(nn).Color = c(nn,:);
end




line([XLS(1).CSonsetFrame(1) XLS(1).CSonsetFrame(1)],ax33.YLim,...
'Color','red','LineStyle','--','LineWidth',2)
line([XLS(1).CSoffsetFrame(1) XLS(1).CSoffsetFrame(1)],ax33.YLim,...
'Color','red','LineStyle','--','LineWidth',2)







%-----------  MAKE BOTTOM GRID SURF PLOT  ---------------------

    axes(ax34)
h1 = plot( fitresult, [xD, yD], zD );

xlabel('SECONDS'); ylabel('DAY'); zlabel('NEURAL ACTIVITY')
title([INFO(1).file(1:4) '  ' StimType]); 
grid on; view(0,90); hold on;
h1(1).FaceAlpha = .9;
h1(1).FaceColor = 'interp';
h1(1).FaceLighting = 'gouraud';
h1(1).BackFaceLighting = 'unlit';
h1(1).EdgeAlpha = 1;
h1(1).EdgeLighting = 'gouraud';
h1(1).AmbientStrength = .8;
h1(1).SpecularStrength = .5;
h1(1).SpecularExponent = 15;
h1(1).SpecularColorReflectance = .2;
h1(2).Marker = 'none';

line([XLS(1).CSonsetFrame(1) XLS(1).CSonsetFrame(1)],ax34.YLim,[50 50],...
'Color','red','LineStyle','-','LineWidth',3)
line([XLS(1).CSoffsetFrame(1) XLS(1).CSoffsetFrame(1)],ax34.YLim,[50 50],...
'Color','red','LineStyle','-','LineWidth',3)


% %------ MAKE BOTTOM CONTOUR PLOT
% axes(ax32)
% h4 = plot( fitresult, [xD, yD], zD, 'Style', 'Contour');
% h4(2).Marker = 'none';
% 
% h4(1).LineWidth = .1;
% h4(1).LineColor = [.2 .3 .8];
% % h4(1).LevelStep = .02;
% 
% xlabel('SECONDS'); ylabel('DAY'); grid on; hold on
% line([XLS(1).CSonsetFrame(1) XLS(1).CSonsetFrame(1)],ax32.YLim,...
% 'Color','red','LineStyle','--')
% line([XLS(1).CSoffsetFrame(1) XLS(1).CSoffsetFrame(1)],ax32.YLim,...
% 'Color','red','LineStyle','--')






% saveas(gcf,[INFO(1).file(1:4) '  ' INFO(1).PopupPick '.png'])
% saveas(gcf,[INFO(1).file(1:4) '  ' INFO(1).PopupPick '.svg'])
% saveas(gcf,[INFO(1).file(1:4) '  ' INFO(1).PopupPick],'epsc')

clc;
disp('figure saved')
clearvars -except IMG INFO XLS FRM PIX IMX STIM IMS IMT rows cols IMD






