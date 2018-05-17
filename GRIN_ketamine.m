%% GRIN ketamine
%{

we want to see if bursting changes with ketamine treatment, and if this
is specific to the ?reward sensitive? (RS) cells. Steve will be sending
us mouse IDs, session IDs and pics of his ROI, which I think we could
match up to our aligned stacks.

We could look for the bursting in the baseline periods of each trial.

We?d like to know a) if bursting is specific to RS cells; b) if this is
affected by introduction of shock trials; and c) if ketamine has an
effect on this.

For now, the data in the paper are from animals: 33 65 74 93. So we should
focus getting these formatted the same, and analyze these.

Yes, Chenyu, we need to get the Long sessions with injections aligned. We
will look at bursting before and after injections.


%}


clc; close all; clear;
% system('sudo purge')
g=what('grin'); m=what('grin-master');
try cd(g.path); catch;end; try cd(m.path); catch;end
try cd([g.path filesep 'grindata' filesep 'grin_raw']); catch;end
try cd([m.path filesep 'grindata' filesep 'grin_raw']); catch;end
% addpath([g.path filesep 'grindata' filesep 'grin_compressed'])



%% GET PATHS TO GRIN DATA MAT FILES

clc; close all; clear

datafilepath = uigetdir;
regexpStr = '((\S)+(\.tif+))';
allfileinfo = dir(datafilepath);
allfilenames = {allfileinfo.name};
r = regexp(allfilenames,regexpStr);                        
datafiles = allfilenames(~cellfun('isempty',r));
datafiles = reshape(datafiles,size(datafiles,2),[]);
datapaths = fullfile(datafilepath,datafiles);
disp(' '); fprintf('   %s \r',  datafiles{:} ); disp(' ')
disp(' '); fprintf('   %s \r',  datapaths{:} ); disp(' ')
clearvars -except datapaths datafiles



%% IMPORT IMAGE STACK


jj = 2;


FileTif=datapaths{jj};
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);


IMG = zeros(nImage,mImage,NumberImages,'double');

TifLink = Tiff(FileTif, 'r');
for i=1:NumberImages
    TifLink.setDirectory(i);
    IMG(:,:,i)=TifLink.read();
end
TifLink.close();

clear InfoImage


clearvars -except IMG XLSdata datafiles datapaths









%% IMPORT EXCEL DATA


jj = 2;


% sum(T(t) - T(t-4):(t+4))^2

xlspath = [datapaths{jj}(1:end-6)  '.xls'];

    [xlsN,xlsT,xlsR] = xlsread(xlspath);
    
    if size(xlsN,1) == size(xlsR,1)
        xlsN(1,:) = [];
    end

    frame_period    = xlsN(1,1);
    framesUncomp    = xlsN(1,2);
    CS_type         = xlsT(2:end,3);
    US_type         = xlsT(2:end,4);
    delaytoCS       = xlsN(:,5);
    CS_length       = xlsN(1,6);
    compressFrms    = xlsN(1,7);

    total_trials    = size(xlsN,1);                     % total number of trials
    framesPerTrial  = framesUncomp / compressFrms;      % frames per trial
    secPerFrame     = frame_period * compressFrms;      % seconds per frame
    framesPerSec    = 1 / secPerFrame;                  % frames per second
    secondsPerTrial = framesPerTrial * secPerFrame;     % seconds per trial
    total_frames    = total_trials * framesPerTrial;    % total collected frames
    CS_lengthFrames = round(CS_length .* framesPerSec); % CS length in frames

    
    
    fprintf('\n\n In this dataset there are...')
    fprintf('\n    total trials: %10.1f  ', total_trials)
    fprintf('\n    frames per trial: %7.1f  ', framesPerTrial)
    fprintf('\n    seconds per frame: %8.5f  ', secPerFrame)
    fprintf('\n    frames per second: %8.5f  ', framesPerSec)
    fprintf('\n    seconds per trial: %8.4f  \n\n', secondsPerTrial)  
    
    
    % CREATE ID FOR EACH UNIQUE CS+US COMBO AND DETERMINE ROW 
    [GRINstruct, GRINtable] = gettrialtypes(total_trials, CS_type, US_type, framesPerTrial);

    GRINstruct.file  = datafiles{jj};
    GRINstruct.path  = datapaths{jj};

    CSonsetDelay = min(delaytoCS);
    baselineTime = CSonsetDelay;
    
        
     CSUSvals = unique(GRINstruct.csus);
     % set(CSUSpopupH, 'String', CSUSvals);
     
     CSonsetFrame = round(CSonsetDelay .* framesPerSec);
     CSoffsetFrame = round((CSonsetDelay+CS_length) .* framesPerSec);
     
    XLSdata.frame_period    = frame_period;
    XLSdata.framesUncomp    = framesUncomp;
    XLSdata.CS_type         = CS_type;
    XLSdata.US_type         = US_type;
    XLSdata.delaytoCS       = delaytoCS;
    XLSdata.CS_length       = CS_length;
    XLSdata.compressFrms    = compressFrms;
    XLSdata.total_trials    = total_trials;
    XLSdata.framesPerTrial  = framesPerTrial;
    XLSdata.secPerFrame     = secPerFrame;
    XLSdata.framesPerSec    = framesPerSec;
    XLSdata.secondsPerTrial = secondsPerTrial;
    XLSdata.total_frames    = total_frames;
    XLSdata.CS_lengthFrames = CS_lengthFrames;
    XLSdata.CSonsetDelay    = CSonsetDelay;
    XLSdata.CSonsetFrame    = CSonsetFrame;
    XLSdata.CSoffsetFrame   = CSoffsetFrame;
    XLSdata.baselineTime    = baselineTime;
    XLSdata.CSUSvals        = CSUSvals;
    XLSdata.blockSize       = 5;
    XLSdata.cropAmount      = 5;
    XLSdata.sizeIMG         = size(IMG);
    
    
    % GET TREATMENT GROUP STRINGS
    fid=[];
    for nn = 1:size(GRINstruct.tf,2)
        fid(nn) = find(GRINstruct.id==nn,1); 
    end
    GRINstruct.TreatmentGroups = GRINstruct.csus(fid);
     
    
    if XLSdata.total_frames == size(IMG,3)
        disp('GOOD: XLSdata.total_frames == size(IMG,3)')
    else
        disp('WARNING: XLSdata.total_frames ~= size(IMG,3)')
        disp(['for: ' imgfilename])
    end
    


    if numel(xlsT{2,8}) > 5
        fprintf('XLSdata reports 2 channels: %s \n\n',xlsT{2,8})
        
        Isz = size(reshape(IMG,size(IMG,1),size(IMG,2),[],XLSdata.total_trials));
                
    end


clearvars -except IMG XLSdata datafiles datapaths

%% SMOOTH DATASET

smoothHeight = .8;
smoothWidth = 9;
smoothSD = .11;
smoothRes = .1;

% GRINmask([PEAK HEIGHT] [WIDTH] [SLOPE SD] [RESOLUTION] [doPLOT])
% Mask = GRINmask(.8, 9, .14, .1, 1);



% -- MASK SETUP
GNpk  = smoothHeight; 	% HIGHT OF PEAK
GNnum = smoothWidth;     % SIZE OF MASK
GNsd = smoothSD;      % STDEV OF SLOPE
GNres = smoothRes;     % RESOLUTION
GNx0 = 0;       % x-axis peak locations
GNy0 = 0;   	% y-axis peak locations
GNspr = ((GNnum-1)*GNres)/2;
a = .5/GNsd^2;
c = .5/GNsd^2;
[X, Y] = meshgrid((-GNspr):(GNres):(GNspr), (-GNspr):(GNres):(GNspr));
Z = GNpk*exp( - (a*(X-GNx0).^2 + c*(Y-GNy0).^2)) ;
Mask=Z;

%Mask = GRINmask(smoothHeight, smoothWidth, smoothSD, smoothRes);

IMGc = convn( IMG, Mask,'same');

size(IMGc)


clearvars -except IMG XLSdata datafiles datapaths IMGc



%% PREVIEW STACK
close all;    
fh1 = figure('Units','normalized','Position',[.1 .1 .5 .6],'Color','w','MenuBar','none');
haxGRIN = axes('Position',[.1 .1 .8 .8],'Color','none');

%---------  RESET AXES COLOR RANGE  -----------
IMGi = mean(IMGc,3);
phGRIN = imagesc(IMGi,'Parent',haxGRIN,'CDataMapping','scaled');
axis tight
Imax = max(max(max(IMGi)));
Imin = min(min(min(IMGi)));
cmax = Imax - (Imax-Imin)/25;
cmin = Imin + (Imax-Imin)/25;
if cmax > cmin; haxGRIN.CLim=[cmin cmax]; end


% haxGRIN.CLim = [(haxGRIN.CLim(1)+haxGRIN.CLim(1)/2)...
%                 (haxGRIN.CLim(2)-haxGRIN.CLim(2)/2)];
pause(.3)


for ii = 1:size(IMGc,3)

    phGRIN.CData = IMGc(:,:,ii);
    pause(.03)
end




























%% RESHAPE DATA AND ALIGN CS FRAMES

%-------  reshapeData

IMGrs = reshape(IMGc,size(IMGc,1),size(IMGc,2),XLSdata.framesPerTrial,[]);

size(IMGrs)


%------- alignCSframes
framesPerSec = XLSdata.framesPerSec;
delaytoCS = XLSdata.delaytoCS;
CS_length = XLSdata.CS_length;

CSonsetDelay = delaytoCS;
CSonsetFrame = round(CSonsetDelay .* framesPerSec);
CSoffsetFrame = round((CSonsetDelay+CS_length) .* framesPerSec);

EqualizeCSdelay  = round((delaytoCS-CSonsetDelay) .* framesPerSec);

IMGe = IMGrs;
for nn = 1:size(IMGrs,4)

IMGe(:,:,:,nn) = circshift( IMGe(:,:,:,nn) , -EqualizeCSdelay(nn) ,3);

end



% DETERMINE FIRST AND LAST FRAME FOR CS / US FOR EACH TRIAL
CSonset   = round(CSonsetDelay .* framesPerSec);               % CS first frame in trial
CSoffset  = round((CSonsetDelay+CS_length) .* framesPerSec);   % CS last frame in trial
USonset   = round((CSonsetDelay+CS_length+1) .* framesPerSec); % US first frame in trial
USoffset  = round((CSonsetDelay+CS_length+2) .* framesPerSec); % US last frame in trial
CSUSonoff = [CSonset CSoffset USonset USoffset];

GRINstruct.CSUSonoff = CSUSonoff;

size(IMGe)

close all;    
fh1 = figure('Units','normalized','Position',[.1 .1 .5 .6],'Color','w','MenuBar','none');
haxGRIN = axes('Position',[.1 .1 .8 .8],'Color','none');

phGRIN = imagesc(IMGe(:,:,1) , 'Parent', haxGRIN);

XLSdata.CSonsetFrame = CSonsetFrame;
XLSdata.CSoffsetFrame = CSoffsetFrame;

size(IMGe)




clearvars -except IMG XLSdata datafiles datapaths IMGc IMGe





%% PREVIEW STACK
close all;    
fh1 = figure('Units','normalized','Position',[.1 .1 .5 .6],'Color','w','MenuBar','none');
haxGRIN = axes('Position',[.1 .1 .8 .8],'Color','none');

%---------  RESET AXES COLOR RANGE  -----------
IMGi = mean(IMGc,3);
phGRIN = imagesc(IMGi,'Parent',haxGRIN,'CDataMapping','scaled');
axis tight
Imax = max(max(max(IMGi)));
Imin = min(min(min(IMGi)));
cmax = Imax - (Imax-Imin)/25;
cmin = Imin + (Imax-Imin)/25;
if cmax > cmin; haxGRIN.CLim=[cmin cmax]; end


% haxGRIN.CLim = [(haxGRIN.CLim(1)+haxGRIN.CLim(1)/2)...
%                 (haxGRIN.CLim(2)-haxGRIN.CLim(2)/2)];
pause(.3)


for ii = 1:size(IMGc,3)
    phGRIN.CData = IMGc(:,:,ii);
    pause(.03)
end
%%










%%


jj = 1;


% sum(T(t) - T(t-4):(t+4))^2

xlspath = [datapaths{jj}(1:end-6)  '.xls'];

    [xlsN,xlsT,xlsR] = xlsread(xlspath);
    
    if size(xlsN,1) == size(xlsR,1)
        xlsN(1,:) = [];
    end

    frame_period    = xlsN(1,1);
    framesUncomp    = xlsN(1,2);
    CS_type         = xlsT(2:end,3);
    US_type         = xlsT(2:end,4);
    delaytoCS       = xlsN(:,5);
    CS_length       = xlsN(1,6);
    compressFrms    = xlsN(1,7);

    total_trials    = size(xlsN,1);                     % total number of trials
    framesPerTrial  = framesUncomp / compressFrms;      % frames per trial
    secPerFrame     = frame_period * compressFrms;      % seconds per frame
    framesPerSec    = 1 / secPerFrame;                  % frames per second
    secondsPerTrial = framesPerTrial * secPerFrame;     % seconds per trial
    total_frames    = total_trials * framesPerTrial;    % total collected frames
    CS_lengthFrames = round(CS_length .* framesPerSec); % CS length in frames

    
    
    fprintf('\n\n In this dataset there are...')
    fprintf('\n    total trials: %10.1f  ', total_trials)
    fprintf('\n    frames per trial: %7.1f  ', framesPerTrial)
    fprintf('\n    seconds per frame: %8.5f  ', secPerFrame)
    fprintf('\n    frames per second: %8.5f  ', framesPerSec)
    fprintf('\n    seconds per trial: %8.4f  \n\n', secondsPerTrial)  
    
    
    % CREATE ID FOR EACH UNIQUE CS+US COMBO AND DETERMINE ROW 
    [GRINstruct, GRINtable] = gettrialtypes(total_trials, CS_type, US_type, framesPerTrial);

    GRINstruct.file  = datafiles{jj};
    GRINstruct.path  = datapaths{jj};

    CSonsetDelay = min(delaytoCS);
    baselineTime = CSonsetDelay;
    
        
     CSUSvals = unique(GRINstruct.csus);
     % set(CSUSpopupH, 'String', CSUSvals);
     
     CSonsetFrame = round(CSonsetDelay .* framesPerSec);
     CSoffsetFrame = round((CSonsetDelay+CS_length) .* framesPerSec);
     
    XLSdata.frame_period    = frame_period;
    XLSdata.framesUncomp    = framesUncomp;
    XLSdata.CS_type         = CS_type;
    XLSdata.US_type         = US_type;
    XLSdata.delaytoCS       = delaytoCS;
    XLSdata.CS_length       = CS_length;
    XLSdata.compressFrms    = compressFrms;
    XLSdata.total_trials    = total_trials;
    XLSdata.framesPerTrial  = framesPerTrial;
    XLSdata.secPerFrame     = secPerFrame;
    XLSdata.framesPerSec    = framesPerSec;
    XLSdata.secondsPerTrial = secondsPerTrial;
    XLSdata.total_frames    = total_frames;
    XLSdata.CS_lengthFrames = CS_lengthFrames;
    XLSdata.CSonsetDelay    = CSonsetDelay;
    XLSdata.CSonsetFrame    = CSonsetFrame;
    XLSdata.CSoffsetFrame   = CSoffsetFrame;
    XLSdata.baselineTime    = baselineTime;
    XLSdata.CSUSvals        = CSUSvals;
    XLSdata.blockSize       = 5;
    XLSdata.cropAmount      = 5;
    XLSdata.sizeIMG         = size(IMG);
    
    
    % GET TREATMENT GROUP STRINGS
    fid=[];
    for nn = 1:size(GRINstruct.tf,2)
        fid(nn) = find(GRINstruct.id==nn,1); 
    end
    GRINstruct.TreatmentGroups = GRINstruct.csus(fid);
     
    
    if XLSdata.total_frames == size(IMG,3)
        disp('GOOD: XLSdata.total_frames == size(IMG,3)')
    else
        disp('WARNING: XLSdata.total_frames ~= size(IMG,3)')
        disp(['for: ' imgfilename])
    end
    


    if numel(xlsT{2,8}) > 5
        fprintf('XLSdata reports 2 channels: %s \n\n',xlsT{2,8})
        
        Isz = size(reshape(IMG,size(IMG,1),size(IMG,2),[],XLSdata.total_trials));
                
    end

%%





























