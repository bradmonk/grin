function [] = GRINtoolboxGUI(varargin)
%% FLIMCCD.m USAGE NOTES
%{

Syntax
-----------------------------------------------------
    FLIMCCD()
    FLIMCCD(datfilefdir)


Description
-----------------------------------------------------
    FLIMCCD() can be run with no arguments passed in. In this case user
    will be prompted to select a directory which contains the FLIM dat 
    file along with the corresponding CCD images. Optionally this function can 
    be called using FLIMCCD(datfilefdir) where the full path to the data directory
    is explicitly provided.
    

Useage Definitions
-----------------------------------------------------


    FLIMCCD()
        launches a GUI that will first ask whether you want to compile
        a dataset output from Bh SPC-Image. Specifically it requires
        that...
            - Color Coded VAlue
            - Chi
            - Pixel Intensities
            - Color Coded Image
        ...are exported from the FLIM analysis software. This GUI will also
        ask the user if it wants to load one of these compiled .dat files.
        If this 'Load data file' option is clicked, the user is prompted to
        select a .dat file. After this the main FLIMCCD analysis GUI is
        launched.
 


Example
-----------------------------------------------------

% Create 2D triangulated mesh
    XY = randn(10,2);
    TR2D = delaunayTriangulation(XY);
    vrts = TR2D.Points;
    tets = TR2D.ConnectivityList;

    xmlmesh(vrts,tets,'xmlmesh_2D.xml')



See Also
-----------------------------------------------------
http://bradleymonk.com/xmlmesh
http://fenicsproject.org
>> web(fullfile(docroot, 'matlab/math/triangulation-representations.html'))


Attribution
-----------------------------------------------------
% Created by: Bradley Monk
% email: brad.monk@gmail.com
% website: bradleymonk.com
% 2016.04.19

%}


%% ESTABLISH STARTING PATHS

clc; close all; clearvars -except varargin
disp('clearing matlab workspace');

thisfile = mfilename;
thisfilepath = fileparts(which(thisfile));


global datfilefdir ccdfilegdir ccdfilerdir
global datfilef ccdfileg ccdfiler 
datfilefdir = '';
ccdfilegdir = '';
ccdfilerdir = '';
datfilef    = '';
ccdfileg    = '';
ccdfiler    = '';


%% MANUALLY SET PER-SESSION PATH PARAMETERS IF WANTED


% datfilefdir = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/FLIMCCD/FLIMCCDdata/DATCCD/';
% ccdfilegdir = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/FLIMCCD/FLIMCCDdata/DATCCD/';
% ccdfilerdir = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/FLIMCCD/FLIMCCDdata/DATCCD/';
% datfilef = 'a1p1_n2_i1_flim.dat';
% ccdfileg = 'a1p1_n1_i1_gfp.tif';
% ccdfiler = 'a1p1_n1_i1_rfp.tif';




%% CD TO DATA DIRECTORY

% if numel(datfilefdir) < 1
%     datfilefdir = uigetdir;
% end
% 
% 
% cd(datfilefdir);
% home = cd;
% 
% disp(['HOME PATH: ' datfilefdir])



%% ESTABLISH GLOBALS AND SET STARTING VALUES

global LifeImageFile FLIMcmap
global intenseThreshMIN intenseThreshMAX intenseThreshPMIN intenseThreshPMAX
global lifeThreshMIN lifeThreshMAX chiThreshMIN chiThreshMAX magnification maglevel
global flimdata flimdat flimtab flimd ROInames Datafilename 
global hROI hROIs ROImask ROIpos ROIarea dendritesize dpos
global ChiGood IntensityGood LifeGood AllGood
global ROI_LIFETIME ROI_INTENSITY ROI_CHI
global ROI_LIFETIME_MEAN ROI_INTENSITY_MEAN ROI_CHI_MEAN
global ROI_imgG ROI_imgR ROI_imgG_MEAN ROI_imgR_MEAN
global imXlim imYlim VxD dVOL
global imgG imgR haxes haxnum stampSize
global phFLIM phCCDR phCCDG
global sROI sROIpos sROIarea sROImask flimdats
global tempV1 tempV2 tempV3 tempV4 tempV5 tempV6 tempV7 tempV8

tempV1 = [];
tempV2 = [];
tempV3 = [];
tempV4 = [];
tempV5 = [];
tempV6 = [];
tempV7 = [];
tempV8 = [];

flimdats = {};
sROI = [];
sROIpos = [];
sROIarea = [];
sROImask = [];
LifeImageFile = 0;
FLIMcmap = FLIMcolormap;
intenseThreshMIN = 85.000;
intenseThreshMAX = 99.999;
intenseThreshPMIN = 2;
intenseThreshPMAX = 10;
lifeThreshMIN = 500;
lifeThreshMAX = 2900;
chiThreshMIN = 0.7;
chiThreshMAX = 2.0;
magnification = 6;
maglevel = 6;
dendritesize = maglevel*5;
dpos = [];
flimdata = {};
flimdat = [];
flimtab = [];
flimd = [];
ROInames = '';
Datafilename = '';
hROI = [];
ROImask = [];
ROIpos = [];
ROIarea = [];
ChiGood = [];
IntensityGood = [];
LifeGood = [];
AllGood = [];
ROI_LIFETIME = [];
ROI_INTENSITY = [];
ROI_CHI = [];
ROI_LIFETIME_MEAN = [];
ROI_INTENSITY_MEAN = [];
ROI_CHI_MEAN = [];
ROI_imgG = [];
ROI_imgR = [];
ROI_imgG_MEAN = [];
ROI_imgR_MEAN = [];
VxD = 1;
dVOL = 1;
imgG = [];
imgR = [];
haxes = {};
haxnum = 1:3;
stampSize = 11;
hROIs = {};

global boxtype
boxtype = 'freehand'; % freehand:1  rectangle:2  elipse:3








%% INITIATE GUI HANDLES AND CREATE GUI FIGURE

%Initialization code. Function creates a datastack variable for storing the
%files. It then displays the initial menu options - to compile a file or to
%load a file. Also sets up lifetime image and intensity image windows -
%these are set to invisible unless the 'load file' button is selected.


% ----- INITIAL SUBMENU GUI SETUP (LOAD DATA ~ COMPILE DATA) -----

initmenuh = figure('Position', [100 100 400 150], 'BusyAction', 'cancel','Menubar', 'none',...
    'Name', 'GRIN analysis', 'Tag', 'GRIN analysis');

loadstackh = uicontrol('Parent', initmenuh, 'Position', [20 50 150 50],...
    'String', 'Load tif image stack', 'FontSize', 11, 'Tag', 'Load tif image stack',...
    'Callback', @loadstack);



% ----- MAIN FLIM ANALYSIS GUI WINDOW SETUP -----

% mainguih.CurrentCharacter = '+';
mainguih = figure('Units', 'normalized','Position', [.1 .1 .8 .8], 'BusyAction',...
    'cancel', 'Name', 'Lifetime image', 'Tag', 'lifetime image','Visible', 'Off', ...
    'KeyPressFcn', {@keypresszoom,1});

% intimagewhtb = uitoolbar(mainguih);

haxCCDG = axes('Parent', mainguih, 'NextPlot', 'Add',...
    'Position', [0.05 0.15 0.8 0.8], 'OuterPosition', [-.2 0 1 1],...
    'PlotBoxAspectRatio', [1 1 1],'XColor','none','YColor','none'); 
    % ,'XDir','reverse',...

haxCCDR = axes('Parent', mainguih, 'NextPlot', 'Add',...
    'Position', [0.05 0.15 0.8 0.8], 'OuterPosition', [-.2 0 1 1],...
    'PlotBoxAspectRatio', [1 1 1],'XColor','none','YColor','none'); 
    % ,'XDir','reverse',...

haxFLIM = axes('Parent', mainguih, 'NextPlot', 'Add',...
    'Position', [0.05 0.15 0.8 0.8], 'OuterPosition', [-.2 0 1 1],...
    'PlotBoxAspectRatio', [1 1 1],'XColor','none','YColor','none'); 

linkaxes([haxFLIM,haxCCDG,haxCCDR],'xy')
haxes = {haxFLIM haxCCDG haxCCDR};

% ----- FLIM ANALYSIS GUI PARAMETER BOXES -----

boxidh = uicontrol('Parent', mainguih, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.88 0.92 0.06 0.04], 'FontSize', 11); 
boxidselecth = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.70 0.92 0.12 0.04], 'FontSize', 11, 'String', 'ROI ID',...
    'Callback', @getROI); 


boxtypeh = uibuttongroup('Parent', mainguih, 'Visible','off',...
                  'Units', 'normalized',...
                  'Position',[0.62 0.85 0.28 0.05],...
                  'SelectionChangedFcn',@boxselection);
              
% Create three radio buttons in the button group.
boxtypeh1 = uicontrol(boxtypeh,'Style','radiobutton',...
                  'String','freehand',...
                  'Units', 'normalized',...
                  'Position',[0.05 0.05 0.3 0.9],...
                  'HandleVisibility','off');
              
boxtypeh2 = uicontrol(boxtypeh,'Style','radiobutton',...
                  'String','rectangle',...
                  'Units', 'normalized',...
                  'Position',[0.3 0.05 0.3 0.9],...
                  'HandleVisibility','off');

boxtypeh3 = uicontrol(boxtypeh,'Style','radiobutton',...
                  'String','elipse',...
                  'Units', 'normalized',...
                  'Position',[0.55 0.05 0.3 0.9],...
                  'HandleVisibility','off');

boxtypeh4 = uicontrol(boxtypeh,'Style','radiobutton',...
                  'String','stamp',...
                  'Units', 'normalized',...
                  'Position',[0.77 0.05 0.3 0.9],...
                  'HandleVisibility','off');              
boxtypeh.Visible = 'on';

stampSizeTxt = uicontrol('Parent', mainguih, 'Style', 'Text', 'Units', 'normalized', ...
    'Position', [0.915 0.87 0.05 0.03], 'FontSize', 10, 'String', 'Stamp Size');
stampSizeH = uicontrol('Parent', mainguih, 'Style', 'Edit', 'FontSize', 11, 'Units', 'normalized', ...
    'Position', [0.92 0.85 0.04 0.03],'Callback', @getStampSize);



% deleteROIh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
%     'Position', [0.70 0.79 0.12 0.04], 'String', 'Delete ROI', 'FontSize', 11,...
%     'Callback', @deleteROI);


resetROISh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.70 0.79 0.12 0.04], 'String', 'Reset all ROIs', 'FontSize', 11,...
    'Callback', @resetROIS);



zoomh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.85 0.79 0.12 0.04], 'String', 'Zoom', 'FontSize', 11,...
    'Callback', @zoomlifetime);




setintenh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.70 0.72 0.12 0.04], 'FontSize', 11, 'String', 'Set intensity',...
    'Callback', @setinten);


dftintenh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.85 0.72 0.12 0.04], 'FontSize', 11,...
    'String', 'Default intensities','Callback', @defaultinten);


intThreshMinh = uicontrol('Parent', mainguih, 'Style', 'Text', 'Units', 'normalized', ...
    'Position', [0.70 0.668 0.12 0.04], 'FontSize', 11, 'String', 'Min Intensity');
intThreshMin = uicontrol('Parent', mainguih, 'Style', 'Edit', 'FontSize', 11, 'Units', 'normalized', ...
    'Position', [0.70 0.64 0.12 0.04]);

intThreshMaxh = uicontrol('Parent', mainguih, 'Style', 'Text', 'Units', 'normalized', ...
    'Position', [0.85 0.668 0.12 0.04], 'FontSize', 11, 'String', 'Max Intensity');
intThreshMax = uicontrol('Parent', mainguih, 'Style', 'Edit', 'FontSize', 11, 'Units', 'normalized', ...
    'Position', [0.85 0.64 0.12 0.04]);


lifetimethresholdh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized',...
    'Position', [0.70 0.49 0.12 0.04], 'FontSize', 11, 'String', 'Lifetime Min');
lftthresholdMINh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized',...
    'Position', [0.70 0.46 0.12 0.04], 'FontSize', 11);


lifetimethreshMAXh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized',...
    'Position', [0.85 0.49 0.12 0.04], 'FontSize', 11, 'String', 'Lifetime Max');
lftthresholdMAXh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized',...
    'Position', [0.85 0.46 0.12 0.04], 'FontSize', 11);



chithresholdminh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized',...
    'Position', [0.70 0.33 0.12 0.04], 'FontSize', 11, 'String', 'Chi Min');
chiminh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized', ...
    'Position', [0.70 0.30 0.12 0.04], 'FontSize', 11);


chithresholdmaxh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized', ...
    'Position', [0.85 0.33 0.12 0.04], 'FontSize', 11, 'String', 'Chi Max');
chimaxh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized', ...
    'Position', [0.85 0.30 0.12 0.04], 'FontSize', 11);


magnifh = uicontrol('Parent', mainguih, 'Style', 'Text',  'Units', 'normalized', ...
    'Position', [0.70 0.58 0.12 0.04], 'FontSize', 11, 'String', 'Magnification');
magh = uicontrol('Parent', mainguih, 'Style', 'Edit',  'Units', 'normalized', ...
    'Position', [0.70 0.555 0.12 0.04], 'FontSize', 11);


dendszh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.85 0.56 0.12 0.04], 'String', 'Get Dendrite Size', 'FontSize', 11,...
    'Callback', @getdendsize);



lifetimeviewerh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.70 0.20 0.24 0.04], 'String', 'Explore Image', 'FontSize', 11,...
    'Callback', @lifetimeviewer);


closeimagesh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.70 0.13 0.24 0.04], 'FontSize', 11, 'String', 'Close Windows',...
    'Callback', @closelftintenw);


savefileh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.70 0.06 0.24 0.04], 'String', 'Save File', 'FontSize', 11,...
    'Callback', @saveFile);


changeimgh = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.10 0.03 0.1 0.04], 'String', 'Next Image', 'FontSize', 11,...
    'Callback', @changeimg);



datastack = zeros(1,1,3,'double');
lifetime = zeros(1, 1);
intensity = zeros(1, 1);
chi = zeros(1, 1);
lifetimeimage = zeros(1, 1);
intensityimage = zeros(1, 1);
xdim = 0;
ydim = 0;
saveROI = zeros(200, 17);
saveData = zeros(200, 9);




% -----------------------------------------------------------------
%% GUI TOOLBOX FUNCTIONS


function loadstack(hObject, eventdata)
%Load file triggers uiresume; the initial menu is set to invisible. Prompts
%user for file to load, copies the datastack from the file; sets the image 
%windows to visible, and plots the images.    

    set(initmenuh, 'Visible', 'Off');
    
    
    
    %% IMPORT TIF STACK
clc; close all; clear;

filename = '031016_gc33_green_keep.tif';
pathname = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/';
xlsfilename = '031016 gc33 summary.xlsx';
xlspathname = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/';


% [filename, pathname] = uigetfile({'*.tif*'},'File Selector');
grinano('import',[pathname , filename])


FileTif=[pathname , filename];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
IMGS=zeros(nImage,mImage,NumberImages,'double');
 
TifLink = Tiff(FileTif, 'r');
for i=1:NumberImages
   TifLink.setDirectory(i);
   IMGS(:,:,i)=TifLink.read();
end
TifLink.close();
disp('!done!')




%% TRIM EDGES FROM IMAGE

IMG = IMGS(:,:,1);

IMGS = IMGS(9:end-8,9:end-8,:);

grinano('trim',IMG,IMGS)




%% PREVIEW IMPORTED STACK
close all

fh1=figure('Units','normalized','OuterPosition',[.05 .05 .8 .6],'Color','w');
hax1 = axes('Position',[.05 .05 .45 .9],'Color','none','XTick',[],'YTick',[]);
hax2 = axes('Position',[.55 .05 .45 .9],'Color','none','XTick',[],'YTick',[]);

axes(hax1)
imagesc(IMGS(:,:,1))

mx = max(max(IMGS(:,:,1)));
mn = min(min(IMGS(:,:,1)));

% colormap(customcmap(1))
% for nT = 1:length(IMGS)
for nT = 1:10:1000
    % PLOT MESH SURF
    imagesc(IMGS(:,:,nT))
    mesh(hax2,IMGS(:,:,nT))
    view(hax2,[-40 2])
    zlim(hax2,[mn*.9 mx*1.2])
    
    pause(.1)
end
%----------------------



%% IMPORT ASSOCIATED EXCEL DATA

% [xlsfilename, xlspathname] = uigetfile({'*.xls*'},'File Selector');
grinano('importxls',[xlspathname , xlsfilename])

[xlsN,xlsT,xlsR] = xlsread([xlspathname , xlsfilename]);

xlsR(1:4,14:20)
%{

14              15              16      17      18              19          20
frame period    total frames    CS      US      delay to CS     compressF   CS length
0.03462         2000            tone    us      35              20          10


Every trial contains...

variable delay period (VDP)   >   CS (sound)   >  US (shock/sucrose/nothing) > ITI

VDP ranges from 25 - 35 sec

CS is always 10 sec

there is a short 0.5 sec delay between CS and US

US is short ~< 1 sec

The ITI is > 60 sec? however, frames are only captured through the end of
the "trial" which is made to be 60 sec total. So the frames captured during ITI 
period depend on the 'delay to CS' period.



%}

frame_period    = xlsN(1,14);
framesUncomp    = xlsN(1,15);
CS_type         = xlsT(2:end,16);
US_type         = xlsT(2:end,17);
delaytoCS       = xlsN(:,18);
compressFrms    = xlsN(1,19);
CS_length       = xlsN(1,20);


total_trials    = size(xlsN,1);                 % total number of trials
framesPerTrial  = framesUncomp / compressFrms;  % frames per trial
secPerFrame     = frame_period * compressFrms;  % seconds per frame
framesPerSec    = 1 / secPerFrame;              % frames per second
secondsPerTrial = framesPerTrial * secPerFrame; % seconds per trial
total_frames    = total_trials * framesPerTrial;% total collected frames



grinano('xlsparams',total_trials, framesPerTrial, secPerFrame, framesPerSec, secondsPerTrial)





%% RESHAPE IMAGE STACK INTO SIZE: YPIXELS by XPIXELS in NFRAMES per NTRIALS



IMGS = reshape(IMGS,size(IMGS,1),size(IMGS,2),framesPerTrial,[]);

fprintf('\n\n IMGS matrix is now size: % 5.0d % 5.0d % 5.0d % 5.0d \n\n', size(IMGS));



%% MAKE DELAY TO CS EQUAL TO 10 SECONDS FOR ALL TRIALS


adjustDelay = 10;

EqualizeCSdelay  = (delaytoCS-adjustDelay) .* framesPerSec; % CS first frame in trial
EqualizerCSdelay = round(EqualizeCSdelay);                  % round frame to integer


% IMGS(:,:,1:5,1) = 0;

for nn = 1:size(IMGS,4)
    
    IMGS(:,:,:,nn) = circshift( IMGS(:,:,:,nn) , EqualizerCSdelay(nn) ,3);

end




%% DETERMINE FIRST AND LAST FRAME FOR CS / US FOR EACH TRIAL

CSonset  = round(adjustDelay .* framesPerSec);       % CS first frame in trial

CSoffset  = round((adjustDelay+10) .* framesPerSec);  % CS last frame in trial

USonset  = round((adjustDelay+11) .* framesPerSec);  % US first frame in trial

USoffset  = round((adjustDelay+21) .* framesPerSec);  % US last frame in trial


CSUSoo = [CSonset CSoffset USonset USoffset];


%% CREATE ID FOR EACH UNIQUE CS+US COMBO AND DETERMINE ROW 


[GRINstruct, GRINtable] = gettrialtypes(total_trials, CS_type, US_type, framesPerTrial);

% GRINstruct.csus
% GRINstruct.id
% GRINstruct.tf
% GRINstruct.fr
% GRINstruct.frames

GRINtable.AllFrames


%{

At this point everything is organized. The main image stack 'IMGS' is
organized so that size(IMGS) will be something like: 240 240 100 48

Where 
    240  height of each image in pixels
    240  width of each image in pixels
    100  number of images per trial
    48   number of trials in imaging session

The IMGS matrix has been circshift such that the time delay before each CS 
has been equalized for all trials. The variables...

CSonset
CSoffset
USonset
USoffset

... indicate the first and last frame for the CS/US onset/offset


GRINstruct and GRINtable contain redundant information (just different ways
to visualze same info) about trial types. 

% GRINstruct.csus
% GRINstruct.id
% GRINstruct.tf
% GRINstruct.fr
% GRINstruct.frames



%}



%% AVERAGE ACROSS SAME TRIAL TYPES
close all;

IMG = IMGS(:,:,:,GRINstruct.tf(:,2));
muIMG = squeeze(mean(IMG,4));


mu = mean(IMGS(:,:,:,GRINstruct.tf(:,2)),4);
size(mu)


% previewstack(mu)
previewstack(mu, CSUSoo)



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    if numel(datfilef) < 1
        [datfilef, datfilefdir] = uigetfile('*.dat', 'load a .dat file');
    end
    
    if numel(ccdfileg) < 1
        [ccdfileg, ccdfilegdir] = uigetfile({'*.tif*';'*.bmp';'*.jpg';'*.png'}, 'load green-channel .bmp file');
    end

    if numel(ccdfiler) < 1
        [ccdfiler, ccdfilerdir] = uigetfile({'*.tif*';'*.bmp';'*.jpg';'*.png'}, 'load red-channel .dat file');
    end
    
    
    tempdata = load([datfilefdir datfilef]);
    tempdatadim = size(tempdata);
    totxdim = tempdatadim(1);
    
    
    ydim = tempdatadim(2);
    if mod(totxdim,3)~=0
        disp('This does not appear to be a properly compiled file.');
        return
    end
    xdim = totxdim/3;
    datastack = zeros(xdim,ydim,3,'double');

    
    set(mainguih, 'Visible', 'On');

    datastack(1:xdim,1:ydim,1) = tempdata(1:xdim,1:ydim);
    datastack(1:xdim,1:ydim,2) = tempdata(xdim+1:2*xdim,1:ydim);
    datastack(1:xdim,1:ydim,3) = tempdata(2*xdim+1:3*xdim,1:ydim);

    lifetime = datastack(:,:,1);
    intensity = datastack(:,:,2);
    chi = datastack(:,:,3);
    
    
    imgG = ccdget([ccdfilegdir ccdfileg]);
    imgR = ccdget([ccdfilerdir ccdfiler]);
    
%{
FLIMsets{1} = 'SPCI2/';
basedir = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/FRET_FLIM/FRETdata/ActinProfilin/2016_02_21/';

%---------------
pixdir = FLIMsets{1};
filedir = [basedir pixdir];
regexpStr = '((\S)+(\.tif|\.jpg|\.bmp|\.png+))';
allfileinfo = dir(filedir);
allfilenames = {allfileinfo.name};
filepaths    = fullfile(filedir,allfilenames(~cellfun('isempty',regexp(allfilenames,regexpStr))));
fprintf('%s \r',filepaths{:})
%---------------


% IMGfiles = {IMGfilenames.name};
for nn = 1:numel(filepaths)
    
    IMGs{nn} = imgcon(filepaths{nn});

end

IMG = IMGs{1};
    
%}
    
    

    %----------------------------------------------------
    %           SET USER-EDITABLE GUI VALUES
    %----------------------------------------------------
    set(intThreshMin, 'String', num2str(intenseThreshMIN));
    set(intThreshMax, 'String', num2str(intenseThreshMAX));

    set(intThreshMin, 'String', num2str(intenseThreshMIN));
    set(intThreshMax, 'String', num2str(intenseThreshMAX));

    set(lftthresholdMINh, 'String', num2str(lifeThreshMIN));
    set(lftthresholdMAXh, 'String', num2str(lifeThreshMAX));

    set(chiminh, 'String', num2str(chiThreshMIN));
    set(chimaxh, 'String', num2str(chiThreshMAX));

    set(magh, 'String', num2str(magnification));

    set(mainguih, 'Name', datfilef);
    set(boxidh, 'String', int2str(1));
    set(haxCCDG, 'XLim', [1 size(imgG,2)], 'YLim', [1 size(imgG,1)]);
    % set(haxCCDG, 'YLim', [1 ydim]);
    set(haxCCDR, 'XLim', [1 size(imgR,2)], 'YLim', [1 size(imgR,1)]);
    % set(haxCCDR, 'YLim', [1 ydim]);
    set(haxFLIM, 'XLim', [1 xdim]);
    set(haxFLIM, 'YLim', [1 ydim]);
    
    
    set(stampSizeH, 'String', num2str(stampSize));
    boxtypeh.SelectedObject = boxtypeh4; % Set radiobutton to stamp
    % boxtype = boxtypeh.SelectedObject.String;
    %----------------------------------------------------
    
    
    
    
    %----------------------------------------------------
    %                   DRAW IMAGE
    %----------------------------------------------------
    
    axes(haxCCDG)
    colormap(haxCCDG,hot)
    phCCDG = imagesc(imgG , 'Parent', haxCCDG);
              pause(1)
              
    axes(haxCCDR)
    colormap(haxCCDR,hot)
    phCCDR = imagesc(imgR, 'Parent', haxCCDR);
        pause(1)
        
    axes(haxFLIM)    
    colormap(haxFLIM,hot)
    phFLIM = imagesc(intensity, 'Parent', haxFLIM,...
                  [prctile(intensity(:),intenseThreshMIN) prctile(intensity(:),intenseThreshMAX)]);
        pause(1)
        axes(haxFLIM)
    
    pause(.2)
    imXlim = haxFLIM.XLim;
    imYlim = haxFLIM.YLim;
    


end









function getROI(boxidselecth, eventdata)

    ROInum = str2num(boxidh.String);

    lftthresholdMIN = str2double(lftthresholdMINh.String);
    lftthresholdMAX = str2double(lftthresholdMAXh.String);
        
    intPminmax = prctile(intensity(:),...
        [str2double(intThreshMin.String) str2double(intThreshMax.String)]);
    
    chimin = str2double(chiminh.String);
    chimax = str2double(chimaxh.String);
    
    
    if strcmp(boxtypeh.SelectedObject.String,'rectangle')
        
        hROI = imrect(haxFLIM);
        
        ROIpos = hROI.getPosition;
        
        ROIarea = ROIpos(3) * ROIpos(4);
        
    elseif strcmp(boxtypeh.SelectedObject.String,'elipse')
        
        hROI = imellipse(haxFLIM);
        
        ROIpos = hROI.getPosition;
        
        ROIarea = pi * (.5*ROIpos(3)) * (.5*ROIpos(4));
        
    elseif strcmp(boxtypeh.SelectedObject.String,'stamp')
        
        % [x,y] = FLIMginput(2,'custom');

        hROI = impoint;
        ROIpos = hROI.getPosition;
        delete(hROI)
        hROI = imellipse(haxFLIM, [ROIpos-round(stampSize/2) stampSize stampSize]);
        
        ROIarea = pi * (stampSize/2)^2;
        
    else % strcmp(boxtypeh.SelectedObject.String,'freehand')
        
        hROI = imfreehand(haxFLIM);
        
        ROIpos = hROI.getPosition;
        ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));
    end
    
    
    hROIs{ROInum} = hROI;    
    
    ROImask       = hROI.createMask(phFLIM);

    ChiGood       = (chi >= chimin & chi <= chimax);
    IntensityGood = (intensity >= intPminmax(1) & intensity <= intPminmax(2));
    LifeGood      = (lifetime >= lftthresholdMIN & lifetime <= lftthresholdMAX);
    AllGood       = (ChiGood .* IntensityGood .* LifeGood) > 0;
    
    ROI_LIFETIME  = lifetime .* AllGood .* ROImask;
    ROI_INTENSITY = intensity .* AllGood .* ROImask;
    ROI_CHI       = chi .* AllGood .* ROImask;
    
    ROI_imgG      = imgG .* AllGood .* ROImask;
    ROI_imgR      = imgR .* AllGood .* ROImask;
    
    
    
    ROI_LIFETIME_MEAN  = mean(ROI_LIFETIME(ROI_LIFETIME > 0));
    ROI_INTENSITY_MEAN = mean(ROI_INTENSITY(ROI_INTENSITY > 0));
    ROI_CHI_MEAN       = mean(ROI_CHI(ROI_CHI > 0));
    ROI_imgG_MEAN       = mean(ROI_imgG(ROI_imgG > 0))*1000;
    ROI_imgR_MEAN       = mean(ROI_imgR(ROI_imgR > 0))*1000;
    
    
    flimdata{ROInum} = {ROI_LIFETIME, ROI_INTENSITY, ROI_CHI,...
                        ROI_LIFETIME_MEAN, ROI_INTENSITY_MEAN, ROI_CHI_MEAN, ...
                        ROIarea, ROI_imgG_MEAN, ROI_imgR_MEAN};
                    
                    
                    
    fprintf('\n Life: % 5.5g \n Inte: % 5.5g \n Chi: % 5.5g \n Area: % 5.5g \n GFP: % 5.5g \n RFP: % 5.5g \n\n',...
                ROI_LIFETIME_MEAN, ROI_INTENSITY_MEAN,ROI_CHI_MEAN,ROIarea,...
                ROI_imgG_MEAN, ROI_imgR_MEAN)

            

    doagainROI = questdlg('Select next ROI?', 'Select next ROI?', 'Yes', 'No', 'No');
    switch doagainROI
       case 'Yes'
            set(boxidh,'String',num2str((str2num(boxidh.String)+1)) );
            getROI
       case 'No'
           set(boxidh,'String',num2str((str2num(boxidh.String)+1)) );
           % keyboard
    end

    set(gcf,'Pointer','arrow')

end








function GetMouseLoc(boxidselecth, eventdata)

% set(gcf,'Pointer','hand')

        if(saveROI(str2double(get(boxidh, 'String')),1)==0)
            %[x, y] = ginput(2);
            [x,y] = FLIMginput(2,'custom');
            x1=x(1);
            y1=y(1);
            x2=x(2);
            y2=y(2);
            calcROIcoor(x1, y1, x2, y2, str2double(get(boxidh, 'String')));
        else 
            duplicateROI = questdlg('Box already exists. Overwrite?', 'Duplicate ROI', 'Yes', 'No', 'No');
            switch duplicateROI
                case 'Yes'
                    [x, y] = ginput(2);
                    x1=x(1);
                    y1=y(1);
                    x2=x(2);
                    y2=y(2);
                    calcROIcoor(x1, y1, x2, y2, str2double(get(boxidh, 'String')));
                case 'No'
            end
        end

        doagainROI = questdlg('Select next ROI?', 'Select next ROI?', 'Yes', 'No', 'No');
        switch doagainROI
           case 'Yes'
                set(boxidh,'String',num2str((str2num(boxidh.String)+1)) );
                GetMouseLoc
           case 'No'
        end

set(gcf,'Pointer','arrow')

end











function lifetimeviewer(lifetimeviewerh, eventData)

    set(mainguih, 'Visible', 'Off');
    set(initmenuh, 'Visible', 'Off');

    lftthresholdMIN = str2double(get(lftthresholdMINh, 'String'));
    lftthresholdMAX = str2double(get(lftthresholdMAXh, 'String'));
    
    intenthresholdMIN = str2double(get(intThreshMin, 'String'));
    intenthresholdMAX = str2double(get(intThreshMax, 'String'));
    
    intPminmax = prctile(intensity(:),[intenthresholdMIN intenthresholdMAX]);
    
    chimin = str2double(get(chiminh, 'String'));
    chimax = str2double(get(chimaxh, 'String'));


    ChiG = (chi >= chimin & chi <= chimax);
    IntG = (intensity >= intPminmax(1) & intensity <= intPminmax(2));
    LifG = (lifetime >= lftthresholdMIN & lifetime <= lftthresholdMAX);
    AllG = (ChiG .* IntG .* LifG) > 0;

        
    % close all
    fh3=figure('Units','normalized','OuterPosition',[.05 .27 .9 .7],'Color','w');
    ah1 = axes('Position',[.05 .55 .2 .4],'Color','none','XTick',[],'YTick',[]);
    ah2 = axes('Position',[.30 .55 .2 .4],'Color','none','XTick',[],'YTick',[]);
    ah3 = axes('Position',[.05 .05 .2 .4],'Color','none','XTick',[],'YTick',[]);
    ah4 = axes('Position',[.30 .05 .2 .4],'Color','none','XTick',[],'YTick',[]);
    ah5 = axes('Position',[.55 .15 .40 .7],'Color','none','XTick',[],'YTick',[]);
    
        axes(ah1)
    imagesc(ChiG); title('Pixels within CHI thresholds')
        axes(ah2)
    imagesc(IntG); title('Pixels within INTENSITY thresholds')
        axes(ah3)
    imagesc(LifG); title('Pixels within LIFETIME thresholds')
        axes(ah4)
    imagesc(AllG); title('Pixels within ALL thresholds')
        axes(ah5)
    imagesc(lifetime .* AllG); title('Fluorescent Lifetime of pixels above ALL thresholds')
        colormap(ah5,[0 0 0; flipud(jet(15))])
        caxis([1600 2800])
        colorbar
        set(ah1,'YDir','normal')
        set(ah2,'YDir','normal')
        set(ah3,'YDir','normal')
        set(ah4,'YDir','normal')
        set(ah5,'YDir','normal')

    disp('Close figure to continue')
    uiwait(fh3)
    
    
    set(mainguih, 'Visible', 'On');

end



function setinten(hObject, eventdata)
    
       lowerinten = str2num(intThreshMin.String);
       upperinten = str2num(intThreshMax.String);
       
       lowerintenPCT = prctile(intensity(:),lowerinten);
       upperintenPCT = prctile(intensity(:),upperinten);
              
       set(haxFLIM,'CLim',[lowerintenPCT upperintenPCT])

end



function setcolormap
              
    % set(mainguih, 'Colormap', gray);
    set(mainguih, 'Colormap', hot);
    % colormap([0 0 0; jet(20)])
        
end



function defaultinten(hObject, eventdata)
        
       set(intThreshMin, 'String', num2str(intenseThreshMIN));
       set(intThreshMax, 'String', num2str(intenseThreshMAX));

end



function closelftintenw(hObject, eventdata)
%Closelftintenw sets both lifetime image and intensity image windows to
%invisible. The initial menu becomes visible again for further selection. 
    
       set(mainguih, 'Visible', 'Off');
       set(initmenuh, 'Visible', 'On');
       saveROI = zeros(200, 17);
       saveData = zeros(200, 9);
       datastack = zeros(1,1,3,'double');
       lifetime = zeros(1, 1);
       intensity = zeros(1, 1);
       chi = zeros(1, 1);
       lifetimeimage = zeros(1, 1);
       intensityimage = zeros(1, 1);
       xdim = 0;
       ydim = 0;
end



function zoomlifetime(zoomh, eventData)
        zoom on;
end



function keypresszoom(hObject, eventData, key)
    
    

    
        % --- ZOOM ---
        
        if strcmp(mainguih.CurrentCharacter,'=')
            
            % IN THE FUTURE USE MOUSE LOCATION TO ZOOM
            % INTO A SPECIFIC POINT. TO QUERY MOUSE LOCATION
            % USE THE METHOD: mainguih.CurrentPoint
            
            zoom(1.5)
        end
        
        if strcmp(mainguih.CurrentCharacter,'-')
            zoom(.5)
        end
                
        
        % --- PAN ---
        
        if strcmp(mainguih.CurrentCharacter,'p')

            pan('on')        
            % h = pan;
            % h.ActionPreCallback = @myprecallback;
            % h.ActionPostCallback = @mypostcallback;
            % h.Enable = 'on';
        end
        if strcmp(mainguih.CurrentCharacter,'o')
            pan('off')        
        end
        
        if strcmp(mainguih.CurrentCharacter,'f')
            haxCCDG.XLim = haxCCDG.XLim+20;
            haxCCDR.XLim = haxCCDR.XLim+20;
            haxFLIM.XLim = haxFLIM.XLim+20;
        end
        
        if strcmp(mainguih.CurrentCharacter,'s')
            haxCCDG.XLim = haxCCDG.XLim-20;
            haxCCDR.XLim = haxCCDR.XLim-20;
            haxFLIM.XLim = haxFLIM.XLim-20;
        end
        
        if strcmp(mainguih.CurrentCharacter,'e')
            haxCCDG.YLim = haxCCDG.YLim+20;
            haxCCDR.YLim = haxCCDR.YLim+20;
            haxFLIM.YLim = haxFLIM.YLim+20;
        end
        
        if strcmp(mainguih.CurrentCharacter,'d')
            haxCCDG.YLim = haxCCDG.YLim-20;
            haxCCDR.YLim = haxCCDR.YLim-20;
            haxFLIM.YLim = haxFLIM.YLim-20;
        end
        
        
        % --- RESET ZOOM & PAN ---
        
        if strcmp(mainguih.CurrentCharacter,'0')
            zoom out
            zoom reset
            haxCCDG.XLim = imXlim;
            haxCCDG.YLim = imYlim;
            haxCCDR.XLim = imXlim;
            haxCCDR.YLim = imYlim;
            haxFLIM.XLim = imXlim;
            haxFLIM.YLim = imYlim;
        end
        
        
end










function resetROIS(deleteROIh, eventData)
    
    ROInum = str2double(get(boxidh, 'String'));
        
    % spf1 = sprintf('Delete ROI #%1.2g ?.',ROInum);
    yesno = questdlg('Reset all ROIs and start over?','Warning','Yes','No','Yes');
    
    
    if strcmp(yesno,'Yes')
    
        flimdata(:) = [];
        
        delete(haxFLIM.Children(1:end-2))
        
        set(boxidh, 'String','1')
        
        msgbox('ROI data-container and image has been reset');
        
    else
        msgbox('Phew, nothing was deleted!');
    end
    
end



% THIS STILL NEEDS SOME WORK. USE RESETROIS() FOR NOW
function deleteROI(deleteROIh, eventData)
    
    ROInum = str2double(get(boxidh, 'String'));
        
    spf1 = sprintf('Delete ROI #%1.2g ?.',ROInum);
    yesno = questdlg(spf1,'Warning','Yes','No','Yes');
    
    
    if strcmp(yesno,'Yes')
    
        flimdata(ROInum) = [];
        
        
        set(boxidh, 'String',num2str(length(flimdata)+1))
        
        spf2 = sprintf('ROI %1.2g deleted. Delete the trace by right clicking it with the mouse',ROInum);
        msgbox(spf2);
        
    else
        
        spf3 = sprintf('ROI %1.2g was not deleted.',ROInum);
        msgbox(spf3);
        
    end
    
end



function boxselection(source,callbackdata)
    
    % callbackdata.OldValue.String
    % boxtypeh.SelectedObject.String
    % boxtype = callbackdata.NewValue.String;
    
    display(['Previous: ' callbackdata.OldValue.String]);
    display(['Current: ' callbackdata.NewValue.String]);
    display('------------------');

end



function getdendsize(boxidselecth, eventdata)


   hline = imline;
   dpos = hline.getPosition();
    
   dendritesize = sqrt((dpos(1,1)-dpos(2,1))^2 + (dpos(1,2)-dpos(2,2))^2);

   disp(['dendrite size:' num2str(dendritesize)])

end




function getStampSize(boxidselecth, eventdata)
    
    stampSize = stampSizeH.String;

   disp(['Stamp size is now:' num2str(stampSize)])

end







% --------  COMPILE  ~  LOAD  ~  SAVE  ----------




function compilefile(hObject, eventdata)
%Compile function triggers the user input for three datafiles. (Will return
%error if files are not of the right size, etc.) Compile then writes a new 
%file that is the stacked version of all three files. 

    set(initmenuh, 'Visible', 'Off');

    home = cd;
    compiledir = uigetdir;
    cd(compiledir);

    filelist = dir(compiledir);
    filelistsize = size(filelist);
        

        
    for ii=1:filelistsize

        currentfile = filelist(ii,1).name;

        if(length(currentfile) >=7)

            if (strcmp('Chi of ', currentfile(1:7))==1) ||...
               (strcmp('chi.asc', currentfile(end-6:end))==1)

                chifile = currentfile;
                if (strcmp('Chi of ', chifile(1:7))==1)
                    chifilename = chifile(8:end);
                else
                    chifilename = chifile(1:end-8);
                end


                for jj=1:filelistsize

                    searchcolorfile = filelist(jj,1).name;

                    if(length(searchcolorfile) >=21)


                        if (strcmp('Color coded value of ', searchcolorfile(1:21))==1) ||...
                           (strcmp('color coded value.asc', searchcolorfile(end-20:end))==1)

                            if (strcmp(chifilename, searchcolorfile(22:end))==1) ||...
                               (strcmp(chifilename, searchcolorfile(1:end-22))==1)

                                colorfile = searchcolorfile;
                                if (strcmp(chifilename, colorfile(22:end))==1)
                                    colorfilename = colorfile(22:end);
                                else
                                    colorfilename = colorfile(1:end-22);
                                end


                                for kk=1:filelistsize
                                    searchintenfile = filelist(kk,1).name;

                                    if(length(searchintenfile) >=12)

                                        if (strcmp('Photons of ', searchintenfile(1:11))==1) ||...
                                           (strcmp('photons.asc', searchintenfile(end-10:end))==1)


                                            if (strcmp(chifilename, searchintenfile(12:end))==1) ||...
                                               (strcmp(chifilename, searchintenfile(1:end-12))==1)

                                                intenfile = searchintenfile;
                                                if (strcmp(chifilename, colorfile(22:end))==1)
                                                    intenfilename = intenfile(12:end);
                                                else
                                                    intenfilename = intenfile(1:end-12);
                                                end


                                                if(strcmp(chifilename, colorfilename)==1 && strcmp(chifilename, intenfilename)==1)

                                                    lifetime = load(colorfile);
                                                    lifetimedim = size(lifetime);
                                                    intensity = load(intenfile);
                                                    intensitydim = size(intensity);
                                                    chitemp = load(chifile);
                                                    chidim = size(chitemp);
                                                    chi = zeros(chidim(1), chidim(2));
                                                    chitemp(chitemp>100) = 0;
                                                    chi = chitemp;
                                                    
                                                    if isequal(lifetimedim, intensitydim, chidim)==1    
                                                        savefilename = mat2str(strcat(chifilename, '.dat'));
                                                        savefilename = savefilename(2:end-1);
                                                        save(savefilename, 'lifetime', '-ascii');
                                                        save(savefilename, 'intensity', '-ascii', '-append');
                                                        save(savefilename, 'chi', '-ascii', '-append');

                                                        disp(strcat(savefilename, ' was successfully compiled.'));
                                                    else
                                                        savefilename = mat2str(strcat(chifilename, '.dat'));
                                                        savefilename = savefilename(2:end-1);
                                                        disp('Error compiling ', savefilename, '. One or more of the component files may be incorrect');

                                                    end

                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end                 
        end
    end
    msgbox('All files successfully compiled.');



    cd(home);

    set(initmenuh, 'Visible', 'On');


end
   


function changeimg(hObject, eventdata)

    
    haxnum = circshift(haxnum,[0 -1]);
    
    if haxnum(1) == 1
    
        axes(haxFLIM)
        
    
    elseif haxnum(1) == 2
        
        axes(haxCCDG)
        
    
    else
    
        axes(haxCCDR)
    
    end
    



end















function prepForSave(savefileh, eventData)
    
    % ------
    
    lftthresholdMIN = str2double(lftthresholdMINh.String);
    lftthresholdMAX = str2double(lftthresholdMAXh.String);
        
    intPminmax = prctile(intensity(:),...
        [str2double(intThreshMin.String) str2double(intThreshMax.String)]);
    
    chimin = str2double(chiminh.String);
    chimax = str2double(chimaxh.String);
    
    ChiGood       = (chi >= chimin & chi <= chimax);
    IntensityGood = (intensity >= intPminmax(1) & intensity <= intPminmax(2));
    LifeGood      = (lifetime >= lftthresholdMIN & lifetime <= lftthresholdMAX);
    AllGood       = (ChiGood .* IntensityGood .* LifeGood) > 0;

    
    
    
    
    % ------
    sROI = findobj(haxFLIM,'Type','patch');
    
    for nn = 1:length(sROI)
        
        sROIpos = sROI(nn).Vertices;
        sROIarea = polyarea(sROIpos(:,1),sROIpos(:,2));
        sROImask = poly2mask(sROIpos(:,1),sROIpos(:,2), ...
                             size(intensity,1), size(intensity,2));


        ROI_LIFETIME  = lifetime .* AllGood .* sROImask;
        ROI_INTENSITY = intensity .* AllGood .* sROImask;
        ROI_CHI       = chi .* AllGood .* sROImask;

        ROI_imgG      = imgG .* AllGood .* sROImask;
        ROI_imgR      = imgR .* AllGood .* sROImask;



        ROI_LIFETIME_MEAN  = mean(ROI_LIFETIME(ROI_LIFETIME > 0));
        ROI_INTENSITY_MEAN = mean(ROI_INTENSITY(ROI_INTENSITY > 0));
        ROI_CHI_MEAN       = mean(ROI_CHI(ROI_CHI > 0));
        ROI_imgG_MEAN      = mean(ROI_imgG(ROI_imgG > 0))*1000;
        ROI_imgR_MEAN      = mean(ROI_imgR(ROI_imgR > 0))*1000;



        flimdats{nn} = {ROI_LIFETIME_MEAN, ...
                        ROI_INTENSITY_MEAN, ...
                        ROI_CHI_MEAN, ...
                        sROIarea, ...
                        ROI_imgG_MEAN, ...
                        ROI_imgR_MEAN};
    
    
    end
    % ------
        
end








function saveFile(savefileh, eventData)
    
    
    prepForSave(savefileh, eventData)
    

    cd(datfilefdir);

    saveDatafilename = inputdlg('Enter a filename to save data','file name',1,...
                                {datfilef(1:end-4)});

    Datafilename = char(strcat(saveDatafilename));

    maglevel = str2double(magh.String);
    
    if numel(dpos) < 1; % If dendrite size was manually selected, numel(dpos) > 1
        dendritesize = maglevel*5;
    end
    
    
    
    for nn = 1:size(flimdats,2)
        
        VxD = flimdats{1,nn}{4} ./ (.5 .* dendritesize).^2;
        
        flimdat(nn,:) = [flimdats{1,nn}{1:6} maglevel dendritesize VxD];        
        ROInames{nn} = num2str(nn);        
    end
    
    
    
    flimtab = array2table(flimdat);
    flimtab.Properties.VariableNames = {'LIFETIME' 'INTENSITY' 'CHISQR' 'VOLUME' ...
                                        'GFP' 'RFP' 'MAG' 'DSIZE' 'VxD'};
    flimtab.Properties.RowNames = ROInames;
    
    
    
    writetable(flimtab,[Datafilename '.csv'],'WriteRowNames',true)
    disp('Data saved successfully!')
    % msgbox('Data saved successfully');

    cd(home);


end




%{
function saveFile(savefileh, eventData)
    
    
    prepForSave(savefileh, eventData)
    

    cd(datfilefdir);

    saveDatafilename = inputdlg('Enter a filename to save data','file name',1,...
                                {datfilef(1:end-4)});

    Datafilename = char(strcat(saveDatafilename));

    maglevel = str2double(magh.String);
    
    if numel(dpos) < 1; % If dendrite size was manually selected, numel(dpos) > 1
        dendritesize = maglevel*5;
    end
    
    
    
    for nn = 1:size(flimdata,2)
        
        VxD = flimdata{1,nn}{7} ./ (.5 .* dendritesize).^2;
        
        dVOL = VxD .* 0;
        
        flimdat(nn,:) = [flimdata{1,nn}{4:end} maglevel dendritesize VxD dVOL];        
        ROInames{nn} = num2str(nn);        
    end
    
    
    
    flimtab = array2table(flimdat);
    flimtab.Properties.VariableNames = {'LIFETIME' 'INTENSITY' 'CHISQR' 'VOLUME' ...
                                        'GFP' 'RFP' 'MAG' 'DSIZE' 'VxD' 'dVOL'};
    flimtab.Properties.RowNames = ROInames;
    
    
    
    writetable(flimtab,[Datafilename '.csv'],'WriteRowNames',true)
    disp('Data saved successfully!')
    % msgbox('Data saved successfully');


%     OpenFLIMdataTool = questdlg('Open FLIMX plots?',...
%                                 'Open FLIMX plots?',...
%                                 'Yes', 'No', 'No');
%                             
%     switch OpenFLIMdataTool
%        case 'Yes'
%             assignin('base','FXdata',flimdata)
%             assignin('base','FXdat',flimdat)
%             assignin('base','FXcsv',flimtab)
%             disp('Welcome to the FLIMXplots toolbox')
%             %edit FLIMXplots.m
%             FLIMXplots(flimdata,flimdat,flimtab,Datafilename)
%             close all
%        case 'No'
%     end

    cd(home);


end
%}


end
%% EOF
