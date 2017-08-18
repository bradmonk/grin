clc; close all; clear all;
% system('sudo purge')

disp('WELCOME TO THE GRIN LENS IMAGING TOOLBOX')

global thisfilefun
global thisfilepath
thisfilefun = 'GRINbigsaveGUI';
thisfile = 'GRINbigsaveGUI.m';
thisfilepath = fileparts(which(thisfile));
cd(thisfilepath);

fprintf('\n\n Current working path set to: \n % s \n', thisfilepath)

global PATHgrindata

    PATHgrinsubfunctions = [thisfilepath filesep 'grinsubfunctions'];
    PATHgrincustomfunctions = [thisfilepath filesep 'grincustomfunctions'];
    PATHgrindata = [thisfilepath filesep 'grindata'];
    
    gpath = [thisfilepath pathsep PATHgrinsubfunctions pathsep ...
            PATHgrincustomfunctions pathsep PATHgrindata];
    
    addpath(gpath)

fprintf('\n\n Added folders to path: \n % s \n % s \n % s \n % s \n\n',...
        thisfilepath,PATHgrinsubfunctions,PATHgrincustomfunctions,PATHgrindata)


%% GET FULL PATHS TO ALL MAT FILES IN A FILE

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


%% IMPORT DATASETS

load(datapaths{1})

IMG = {};
INFO = GRINstruct;
XLS = XLSdata;

for nn = 1:size(datapaths,1)

    load(datapaths{nn})

    IMG{nn,1} = IMGS;
    INFO(nn,1) = GRINstruct;
    XLS(nn,1) = XLSdata;

end

clearvars -except...
datapaths datafiles IMG INFO XLS




%% EXAMINE IMPORTED DATA

size(IMG{1})

% INFO(1).csus
% INFO(1).id
% INFO(1).tf
% INFO(1).fr
% INFO(1).frames(1,:)
% INFO(1).file
% INFO(1).path
% INFO(1).TreatmentGroups
% INFO(1).CSUSonoff
% 
% XLS(1).frame_period
% XLS(1).framesUncomp
% XLS(1).CS_type
% XLS(1).US_type
% XLS(1).delaytoCS
% XLS(1).CS_length
% XLS(1).compressFrms
% XLS(1).total_trials
% XLS(1).framesPerTrial
% XLS(1).secPerFrame
% XLS(1).framesPerSec
% XLS(1).secondsPerTrial
% XLS(1).total_frames
% XLS(1).CS_lengthFrames
% XLS(1).CSonsetDelay
% XLS(1).CSonsetFrame
% XLS(1).CSoffsetFrame
% XLS(1).baselineTime
% XLS(1).CSUSvals
% XLS(1).blockSize
% XLS(1).cropAmount
% XLS(1).sizeIMG
% XLS(1).sizeIMGS



%% SHOW MEAN IMAGE FROM EACH DAY
close all

N = size(IMG,1);

fh1=figure('Units','normalized','OuterPosition',[.05 .07 .9 .9],'Color','w','MenuBar','none');
for nn = 1:N

    IM = IMG{nn};

    subplot(5,ceil(N/5),nn);
    imagesc( mean(mean(IM,4),3) );
    title(INFO(nn).file(11:14),'Interpreter','none')

end



%% CULL INCOMPATIBLE TRIALS FROM KNOWN SUBJECTS

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


return
%% CULL INCOMPATIBLE TRIALS FROM KNOWN SUBJECTS


% gc33 is standard size only after 2016_0305
if strcmp(datafiles{1}(6:9),'gc33')
    datapaths(1:24) = [];
    datafiles(1:24) = [];
    IMG(1:24)       = [];
    INFO(1:24)      = [];
    XLS(1:24)       = [];
end

%% GET NUMBER OF FRAMES & IMAGE SIZES

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


clearvars -except...
datapaths datafiles IMG INFO XLS...
FRM PIX



%% GET AVERAGE OF TRIALS FOR EACH STIM TYPE
clc; close all

N = size(IMG,1);


IMX = {};
for i = 1:N

    I = IMG{i};

    Vn = size(INFO(i).tf,2);

    IM=zeros(size(I,1),size(I,2),size(I,3),Vn);
    for j = 1:Vn

        IMu = I(:,:,:,INFO(i).tf(:,j));

        IM(:,:,:,j) =  mean(IMu,4);
    end

	IMX{i} = IM;
end

size(IMX{i})

imagesc(  mean(mean(IMX{1},4),3)    )
imagesc( IMX{1}(:,:,1,1)    )

clearvars -except...
datapaths datafiles IMG INFO XLS...
FRM PIX IMX







%% GET ALL TREATMENT STIM TYPES
clc

% XLS.CS_type
% XLS.US_type

TG = INFO(1).TreatmentGroups;

for nn = 1:size(INFO,1)

    TG = [TG ; setdiff( INFO(nn).TreatmentGroups , TG) ];
    % setdiff(A,B) returns the data in A that is not in B

end

TG = sort(TG);
% disp(TG)

TGi = (1:numel(TG))';

STIMGROUPS = table();

STIMGROUPS.ID   = TGi;
STIMGROUPS.TG   = TG;

STIMGROUPS

clearvars -except...
datapaths datafiles IMG INFO XLS...
FRM PIX IMX STIMGROUPS TG TGi





%%


% gc74
%     ID                 TG             
%     __    ____________________________
%     1     'tone no sucrose'           
%     2     'tone sucrose'              
%     3     'tone sucrose omission'     
%     4     'white noise no sucrose'    
%     5     'white noise shock'         
%     6     'white noise shock omission'


% gc75
%     ID                  TG              
%     __    ______________________________
%     1     'tone no sucrose'             
%     2     'white noise no sucrose'      
%     3     'white noise sucrose'         
%     4     'white noise sucrose omission'


% gc80
%     ID               TG           
%     __    ________________________
%     1     'tone no sucrose'       
%     2     'tone sucrose'          
%     3     'white noise no sucrose'


% gc90
%     ID               TG           
%     __    ________________________
%     1     'tone no sucrose'       
%     2     'white noise no sucrose'
%     3     'white noise sucrose'  





%% ADD THOSE TREATMENT INDICATORS TO INFO STRUCT

N = size(IMG,1);

%     STIMGROUPS
%     INFO(nn).tf
%     INFO(nn).csus
%     INFO(nn).id
%     INFO(nn).TreatmentGroups

INFO(1).STIMid = [];
INFO(1).STIMtg = [];

for nn = 1:N

    Groups = INFO(nn).TreatmentGroups;

    [a,b,c] = intersect(Groups,STIMGROUPS.TG);

    INFO(nn).STIMid = INFO(nn).tf .* 1.0;

for i = 1:size(Groups,1)

    INFO(nn).STIMid(:,i) = INFO(nn).tf(:,i) .* c(i);

end
end



% INFO(nn).STIMtg = zeros(  TGi(end)  )

for nn = 1:N

    Groups = INFO(nn).TreatmentGroups;

    [a,b,c] = intersect(Groups,STIMGROUPS.TG);

    INFO(nn).STIMtg = zeros( size(INFO(nn).tf,1), TGi(end) );

for i = 1:size(c,1)

    INFO(nn).STIMtg(:,c(i)) = INFO(nn).tf(:,i);

end
end


clearvars -except...
datapaths datafiles IMG INFO XLS...
FRM PIX IMX STIMGROUPS TG TGi

% INFO = rmfield(INFO,'STIMS')
% INFO = rmfield(INFO,'STIMid')
% INFO = rmfield(INFO,'STIMtg')

INFO(1).STIMid

INFO(1).STIMtg


%% PUT STACKS INTO CONTAINER WITH OTHERS OF SAME TG

%     STIMGROUPS
%     INFO(1).tf
%     INFO(1).csus
%     INFO(1).id
%     INFO(1).TreatmentGroups
%     INFO(1).STIMid
%     INFO(1).STIMtg

N = size(IMG,1);
nn=1;

IMS = cell(size(TG));
Tx  = cell(size(TG));

for nn = 1:N

    id = INFO(nn).STIMid > 0;
    tg = INFO(nn).STIMtg > 0;

for i = 1:size(tg,2)

    fprintf('\nNow getting: %s \n\n',char(STIMGROUPS.TG(i)))

    %any(tg(:,i))

    IM = IMG{nn}(:,:,:,tg(:,i));

    r = find(tg(:,i));
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
    STIMGROUPS.TG(nn)
    IMS(nn)
end


clearvars -except...
datapaths datafiles IMG INFO XLS...
FRM PIX IMX STIMGROUPS TG TGi IMS Tx




%% PREVIEW IMAGE STACK
clc; close all;

doPreviewStack = 1;

if doPreviewStack == 1

STIMGROUPS

size(IMS{1})
size(Tx{1})

strcmp(TG,'tone no sucrose')
pause(2); clc;

TNS   = IMS{find(strcmp(TG,'tone no sucrose'))};   % 'tone no sucrose'
TxTNS =  Tx{find(strcmp(TG,'tone no sucrose'))}    % 'tone no sucrose'
pause(2); clc;

[ua,ub,uc] = unique(TxTNS(:,2));

close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');
ph1 = imagesc(TNS(:,:,1,1));
title(num2str(TxTNS(1,1)));
t = text(20,20,{ num2str(TxTNS(1,2)), num2str(TxTNS(1,3))...
},'Color','white','FontSize',18,'HorizontalAlignment','center');


for mm = 1:size(ub,1)

    t.String = { num2str( ua(mm) )  ,  num2str(TxTNS(ub(mm),3) )   };

    for nn = 1:size(TNS,3)
        ph1.CData = TNS(:,:,nn,ub(mm));
        pause(.02)
    end
end




% for mm = 1:size(TNS,4)
% t.String ={num2str(TxTNS(mm,2)),num2str(TxTNS(mm,3))}
% for nn = 1:size(TNS,3)
%     ph1.CData = TNS(:,:,nn,mm);
%     pause(.015)
% end
% end
end

%%

N = size(IMG,1);

% INFO = rmfield(INFO,'TGa')
% INFO = rmfield(INFO,'TGb')
INFO(1).STIMS = [];
INFO(1).TGa = [];
INFO(1).TGb = [];

for nn = 1:N
    INFO(nn).STIMS = INFO(nn).id;
end


for nn = 1:N
    for mm = 1:size(INFO(nn).csus,1)
        [a,b,c] = intersect(INFO(nn).csus(mm),TG);
        INFO(nn).STIMS(mm) = c;
    end
end

for nn = 1:N
    for mm = 1:size(INFO(nn).TreatmentGroups,1)
        [a,b,c] = intersect(INFO(nn).TreatmentGroups(mm),TG);
        INFO(nn).TGa(mm) = c;
    end
end

for nn = 1:N
    for mm = 1:size(TG,1)
        [a,b,c] = intersect(TG(mm),INFO(nn).TreatmentGroups);
        if ~isempty(c)
            INFO(nn).TGb(end+1) = c;
        end
    end
end


INFO(5).STIMS
INFO(5).TGa
INFO(5).TGb

disp([cellstr(num2str(TGi)) TG])

clearvars -except...
datapaths datafiles IMG INFO XLS...
FRM PIX IMX STIMGROUPS TG TGi IMS Tx

%{
INFO = rmfield(INFO,'TG')
INFO = rmfield(INFO,'TGa')
INFO = rmfield(INFO,'TGb')

TG              % string of all treatment groups found across datasets
TGi             % number id assigned to those strings

INFO(5).STIMS   % stim type id for each trial
INFO(5).TGa     % stim type id for each trial for IMGmu stack
INFO(5).TGb     % stim type id for each trial for IMGmu stack

%}






%% SEGMENT IMAGES INTO ROIs

% size(IMS{1})
% Tx{1}

ROIM = IMS;


for i=1:size(IMS,1) % for each TG


    [ui, uj, uk] = unique(Tx{i}(:,2));  % get unique day


    % get mask for each day
    MASKS = {};
	for nn = 1:numel(ui)

    
        I = mean(mean(IMS{i}(:,:,:,uk==nn),3),4);
        %size(I)

        MASK = zeros(size(I,1),size(I,2),numel(ui));
        %size(MASK)

        Imin = min(I(:));
        Imax = max(I(:));
        if isequal(Imax,Imin)
            I = 0*I;
        else
            I = (I - Imin) ./ (Imax - Imin);
        end

        % Threshold image - global threshold
        BW = imbinarize(I,'adaptive','Sensitivity',0.7);

        % Active contour using Chan-Vese over 100 iterations
        BW = activecontour(I, BW, 100, 'Chan-Vese');

        % BW = imclearborder(BW);   % Clear borders

        % Fill holes
        BW = imfill(BW, 'holes');

        MASK(:,:,nn) = BW;

        % % Create masked image.

        ROIM{i}(:,:,:,uk==nn) = ROIM{i}(:,:,:,uk==nn) .* BW;
        
	end

end

clearvars -except...
datapaths datafiles IMG INFO XLS...
FRM PIX IMX STIMGROUPS TG TGi IMS Tx...
ROIM



%% PREVIEW ROI STACK
clc; close all;

doPreviewStack = 0;

if doPreviewStack == 1

STIMGROUPS

TNS   = IMS{find(strcmp(TG,'tone no sucrose'))};   % 'tone no sucrose'
TxTNS =  Tx{find(strcmp(TG,'tone no sucrose'))}    % 'tone no sucrose'

close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');
ph1 = imagesc(TNS(:,:,1,1))
title(num2str(TxTNS(1,1)))
t = text(20,20,{...
num2str(TxTNS(1,2)), ...
num2str(TxTNS(1,3))...
},...
'Color','white','FontSize',18,'HorizontalAlignment','center');

for mm = 1:size(TNS,4)
t.String ={num2str(TxTNS(mm,2)),num2str(TxTNS(mm,3))}
for nn = 1:size(TNS,3)
    ph1.CData = TNS(:,:,nn,mm);
    pause(.01)
end
end


clearvars -except...
datapaths datafiles IMG INFO XLS...
FRM PIX IMX STIMGROUPS TG TGi IMS Tx...
ROIM

end


%% GET TRIAL MEANS FOR EACH STIM TYPE
close all

STIMGROUPS

% TS  = ROIM{2};    % 'tone sucrose'
% TNS = ROIM{3};    % 'tone no sucrose'
% 
% TxTS  = Tx{2};   % 'tone sucrose'
% TxTNS = Tx{3};   % 'tone no sucrose'

% ROIM
ROI = cell(size(ROIM));

for nn = 1:size(ROIM,1)

    MX  = ROIM{nn};
    TGa = INFO(nn).TGa;

    
    p = size(MX,1);
    f = size(MX,3);
    t = size(MX,4);

    MI = reshape(MX,p*p,f,t);

    %size(MI)

    Y = zeros(size(MI,2),size(MI,3));
    for mm = 1:size(MI,2)
    for kk = 1:size(MI,3)

        X = MI(:,mm,kk);
        Y(mm,kk) = mean(X(X>0));

        %size(X)
        %size(Y)
    end
    end

ROI{nn} = Y;
end


clearvars -except...
datapaths datafiles IMG INFO XLS...
FRM PIX IMX STIMGROUPS TG TGi IMS Tx...
ROIM ROI


%% COMPUTE DF/F


FF = ROI;

for i = 1:size(ROI,1)

    R = ROI{i};
    
    base = mean(R(1:30,:),1);

    FF{i} = (R - base) ./ base;

end


plot(mean(FF{2},2))


clearvars -except...
datapaths datafiles IMG INFO XLS...
FRM PIX IMX STIMGROUPS TG TGi IMS Tx...
ROIM ROI FF






return
%%

IMu = mean(mean(IMG{1},4),3);

volumeViewer(mean(IMu,4))

imageSegmenter

imagesc(IM)


