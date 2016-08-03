%% makecsv.m
clc; clear; close all;


%% ------------- GET PATH INFO FOR TIF STACK AND XLS DATA -----------
disp('Select newly converted TIF stack and badly formatted XLS sheet...')

[imgfilename, imgpathname] = uigetfile({'*.tif*'}, 'Select TIF stack');

[xlsfilename, xlspathname] = uigetfile({'*.xls*'},'Select Excel file');

imgfullpath = [imgpathname , imgfilename];

xlsfullpath = [xlspathname xlsfilename];


% imgfilename = 'gc33_110215go.tif';
% imgpathname = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/oddstacks/';
% xlsfilename = 'gc33_110215.xlsx';
% xlspathname = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/oddstacks/';


%% ------------- XLS DATA IMPORT CODE -----------

[xlsN,xlsT,xlsR] = xlsread([xlspathname , xlsfilename]);


CSdelayCell = {xlsR{2:end,5}}';

tv1 = size(CSdelayCell,1);
tv2 = [str2num(CSdelayCell{1})];

CSdelayMx = repmat(tv2,tv1,1);


for nn = 1:tv1
    
    CSdelayMx(nn,:) = [str2num(CSdelayCell{nn})];
    
end


frame_period    = xlsN(1,1);
framesUncomp    = xlsN(1,2);
CS_type         = xlsT(2:end,3);
US_type         = xlsT(2:end,4);
CS_length       = xlsN(1,6);
compressFrms    = xlsN(1,7);

framesPerTrial  = framesUncomp / compressFrms;      % frames per trial
secPerFrame     = frame_period * compressFrms;      % seconds per frame
framesPerSec    = 1 / secPerFrame;                  % frames per second
secondsPerTrial = framesPerTrial * secPerFrame;     % seconds per trial
CS_lengthFrames = round(CS_length .* framesPerSec); % CS length in frames



TimeBetCS = zeros(size(CSdelayMx));
TimeBetCS(:,1) = CSdelayMx(:,1);

for nn = 2:size(CSdelayMx,2)
    
    TimeBetCS(:,nn) = CSdelayMx(:,nn) - CSdelayMx(:,nn-1);
    
end

TimeBetCSoffCSon = TimeBetCS - CS_length;

minTBT = min(TimeBetCSoffCSon(:));
halfminTBT = round(minTBT/2);



TrialStartTimes = CSdelayMx - halfminTBT;

TrialEndTimes = CSdelayMx + CS_length + halfminTBT;

tv3 = [secondsPerTrial:secondsPerTrial:size(TrialStartTimes,2)*secondsPerTrial]';
tv4 = circshift(tv3,[1 0]);
tv4(1) = 0;

TsT = TrialStartTimes + repmat(tv4,1,size(TrialStartTimes,2));
TeT = TrialEndTimes + repmat(tv4,1,size(TrialEndTimes,2));

TsF = round(TsT .* framesPerSec);
TeF = round(TeT .* framesPerSec);








%% ------------- IMG STACK IMPORT CODE -----------

% THIS IS DONE AT TOP OF FILE
% [imgfilename, imgpathname] = uigetfile({'*.tif*'}, 'Select TIF stack');
% % imgfilename = 'gc33_110215go.tif';
% % imgpathname = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/oddstacks/';
% imgfullpath = [imgpathname , imgfilename];


fprintf('\n Importing tif stack from...\n % s \n', imgfullpath);

FileTif=[imgpathname , imgfilename];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);


if NumberImages < 2

IMG = imread(imgfullpath);

IMG = double(IMG);

else

IMG = zeros(nImage,mImage,NumberImages,'double');

TifLink = Tiff(FileTif, 'r');
for i=1:NumberImages
   TifLink.setDirectory(i);
   IMG(:,:,i)=TifLink.read();
end
TifLink.close();

end

disp('Image stack sucessfully imported!') 



%% ------------- EDIT IMG STACK AND SAVE -----------

TSEF = []; nn = 1;
for rr = 1:size(TsF,1)
for cc = 1:size(TsF,2)

    TSEF(nn,:) = [TsF(rr,cc):TeF(rr,cc)];

    nn = nn+1;
end
end




IMG = IMG(:,:,TSEF(:));






%% ------------- CREATE UPDATED EXCEL SHEET -----------

total_frames_xls = size(TSEF,2);


[xlsN,xlsT,xlsR] = xlsread([xlspathname , xlsfilename]);


XLSframe_period = xlsN(1,1);
XLStotal_frames = [];
XLScs_stim      = xlsT(2:end,3);
XLSus_stim      = xlsT(2:end,4);
XLSCS_delay     = [];
XLSCS_length    = xlsN(1,6);
XLScompressFrms = xlsN(1,7);
XLSchannel      = [];
XLSkeepFrames   = [];


NumTrials = numel(TsF);
FramesPerTrial = size(TSEF,2);
TrialsPerStim = size(TsF,2);
CSonsetFrame = halfminTBT;

frame_period = ones(NumTrials,1);
total_frames = ones(NumTrials,1);
cs_stim      = cell(NumTrials,1);
us_stim      = cell(NumTrials,1);
CS_delay     = ones(NumTrials,1);
CS_length    = ones(NumTrials,1);
compressFrms = ones(NumTrials,1);
channel      = cell(NumTrials,1);
keepFrames   = cell(NumTrials,1);


% --- MAKE4XLS: frame_period
frame_period = frame_period .* XLSframe_period;


% --- MAKE4XLS: total_frames
total_frames = total_frames .* FramesPerTrial;


% --- MAKE4XLS: cs_stim & us_stim
numCSstim = length(cs_stim);
numUSstim = length(us_stim);



    tt = 1;
for ss = 1:numCSstim

    cs_stim{ss}      = XLScs_stim{tt};
    us_stim{ss}      = XLSus_stim{tt};
    
    if ~mod(ss,TrialsPerStim)
        tt = tt+1;
    end
    
end


% --- MAKE4XLS: CS_delay
CS_delay = CS_delay .* CSonsetFrame;


% --- MAKE4XLS: CS_length
CS_length = CS_length .* XLSCS_length;


% --- MAKE4XLS: compressFrms
compressFrms = compressFrms .* XLScompressFrms;


% --- MAKE4XLS: channel
channel = repmat({['g' num2str(FramesPerTrial)]},NumTrials,1);


% --- MAKE4XLS: keepFrames
keepFrames = repmat({['"1:' num2str(FramesPerTrial) '"']},NumTrials,1);


% ---------- CREATE TABLE FOR XLS EXPORT

XLStable = table(frame_period,total_frames,cs_stim,us_stim,CS_delay,CS_length,...
                 compressFrms,channel,keepFrames);
disp(XLStable)

[FILEpathstr,FILEname,FILEext] = fileparts(xlsfilename);

CSVfullfile = [xlspathname FILEname '_go.csv'];

writetable(XLStable,CSVfullfile,'Delimiter',',','QuoteStrings',false)


XLScell = table2cell(XLStable);

% XLSXfilename = [xlspathname FILEname '_go.xlsx'];
% xlswrite(XLSXfilename,XLScell)

disp('DONE! New .CSV file saved in:')
disp(CSVfullfile)
