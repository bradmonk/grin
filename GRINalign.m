function [] = GRINtoolboxGUI(varargin)
%% GRINtoolboxGUI.m - GRIN LENS IMAGING TOOLBOX
%{
% 
% Syntax
% -----------------------------------------------------
%     GRINtoolboxGUI()
% 
% 
% Description
% -----------------------------------------------------
% 
%     GRINtoolboxGUI() is run with no arguments passed in. The user
%     will be prompted to select a directory which contains the image data
%     tif stack along with the corresponding xls file.
%     
% 
% Useage Definitions
% -----------------------------------------------------
% 
%     GRINtoolboxGUI()
%         launches a GUI to process image stack data from GRIN lens
%         experiments
%  
% 
% 
% Example
% -----------------------------------------------------
% 
%     TBD
% 
% 
% See Also
% -----------------------------------------------------
% >> web('http://bradleymonk.com/grintoolbox')
% >> web('http://imagej.net/Miji')
% >> web('http://bigwww.epfl.ch/sage/soft/mij/')
% 
% 
% Attribution
% -----------------------------------------------------
% % Created by: Bradley Monk
% % email: brad.monk@gmail.com
% % website: bradleymonk.com
% % 2016.07.04
%}
%----------------------------------------------------
clc; close all; clear all; clear java;
disp('WELCOME TO THE GRIN LENS IMAGING TOOLBOX')

% clearvars -except varargin
% set(0,'HideUndocumented','off')
[str,maxsize] = computer;
if strcmp(str,'MACI64')
    disp(' '); disp('Purging RAM'); 
    system('sudo purge'); 
end


global thisfilepath
thisfile = 'GRINtoolboxGUI.m';
thisfilepath = fileparts(which(thisfile));
cd(thisfilepath);

fprintf('\n\n Current working path set to: \n % s \n', thisfilepath)

    
    pathdir0 = thisfilepath;
    pathdir1 = [thisfilepath filesep 'grinsubfunctions'];
    pathdir2 = [thisfilepath filesep 'grincustomfunctions'];
    
    gpath = [pathdir0 pathsep pathdir1 pathsep pathdir2];
    
    addpath(gpath)

fprintf('\n\n Added folders to path: \n % s \n % s \n % s \n % s \n\n',...
        pathdir0,pathdir1,pathdir2)
    
    
%% MANUALLY SET PER-SESSION PATH PARAMETERS IF WANTED (OPTIONAL)

global imgfilename imgpathname xlsfilename xlspathname lickfilename lickpathname
global imgfullpath xlsfullpath lickfullpath

%% ESTABLISH GLOBALS AND SET STARTING VALUES

global mainguih imgLogo

global IMG GRINstruct GRINtable XLSdata LICK IMGred IMGr IMGR RIMG
global xlsN xlsT xlsR DATA
global lickN LICKraw
global IMGraw IMGSraw IM
global memes conboxH
global NormType

global frame_period framesUncomp CS_type US_type delaytoCS CS_length compressFrms
global total_trials framesPerTrial secPerFrame framesPerSec secondsPerTrial 
global total_frames CS_lengthFrames IMhist tiledatX tiledatY RHposCheck

IMhist.smoothed   = 0;
IMhist.cropped    = 0;
IMhist.tiled      = 0;
IMhist.reshaped   = 0;
IMhist.aligned    = 0;
IMhist.normalized = 0;
IMhist.rawIM      = [];
IMhist.minIM      = [];
IMhist.maxIM      = [];
IMhist.aveIM      = [];

IMGred = [];
IMGr   = [];

NormType = 'dF';



global cropAmount IMGfactors blockSize previewNframes customFunOrder 
cropAmount = 18;
IMGfactors = 1;
blockSize = 22;
previewNframes = 25;
customFunOrder = 1;

global stimtype stimnum CSUSvals
% CSxUS:1  CS:2  US:3
stimnum = 1;
stimtype = 'CS'; 
CSUSvals = {'CS','US'};


global CSonset CSoffset USonset USoffset CSUSonoff
global CSonsetDelay baselineTime CSonsetFrame CSoffsetFrame
CSonsetDelay = 10;
baselineTime = 10;
CSonsetFrame = 25;
CSoffsetFrame = 35;


global smoothHeight smoothWidth smoothSD smoothRes
smoothHeight = .8;
smoothWidth = 9;
smoothSD = .14;
smoothRes = .1;


global AlignVals
AlignVals.P1x = [];
AlignVals.P1y = [];
AlignVals.P2x = [];
AlignVals.P2y = [];
AlignVals.P3x = [];
AlignVals.P3y = [];
AlignVals.P4x = [];
AlignVals.P4y = [];


 
global muIMGS phGRIN previewStacknum toggrid axGRID
global IMGcMax IMGcMaxInd IMGcMin IMGcMinInd
muIMGS = [];
previewStacknum = 25;
toggrid = 0;

global confile confilefullpath
confile = 'gcconsole.txt';
% diary(confile)
disp('GRIN CONSOLE LOGGING ON.')
% diary off
confilefullpath = which(confile,'-all');
% delete(confile)


% -----------------------------------------------------------------
%%     INITIATE GUI HANDLES AND CREATE SUBMENU GUI FIGURE
% -----------------------------------------------------------------
% INITIAL SUBMENU GUI SETUP (GRIN TOOLBOX ~ MOTION CORRECTION)
%{
% initmenuh = figure('Units','normalized','OuterPosition',[.25 .4 .4 .2], ...
%     'BusyAction', 'cancel','Menubar', 'none',...
%     'Name', 'GRIN analysis', 'Tag', 'GRIN analysis');
% 
% grinlenstoolboxh = uicontrol('Parent', initmenuh, 'Units','normalized', 'Position', [.03 .05 .47 .9],...
%     'String', 'Start GRIN lens toolbox', 'FontSize', 16, 'Tag', 'Start GRIN lens toolbox',...
%     'Callback', @grinlenstoolbox);
% 
% motioncorrectionh = uicontrol('Parent', initmenuh, 'Units','normalized', 'Position', [.52 .51 .45 .44],...
%     'String', 'Perform motion correction', 'FontSize', 14, 'Tag', 'Perform motion correction',...
%     'Callback', @motioncorrection);
% 
% 
% formatXLSH = uicontrol('Parent', initmenuh, 'Units','normalized', 'Position', [.52 .05 .45 .44],...
%     'String', 'Multiformat XLS sheets', 'FontSize', 14, 'Tag', 'Multiformat XLS sheets',...
%     'Callback', @formatXLS);
%}


%########################################################################
%%              MAIN GRIN ANALYSIS GUI WINDOW SETUP 
%########################################################################

% mainguih.CurrentCharacter = '+';
mainguih = figure('Units', 'normalized','Position', [.05 .08 .90 .78], 'BusyAction',...
    'cancel', 'Name', 'GRIN TOOLBOX', 'Tag', 'mainguih','Visible', 'Off'); 
     % 'KeyPressFcn', {@keypresszoom,1}, 'CloseRequestFcn',{@mainGUIclosereq}
     % intimagewhtb = uitoolbar(mainguih);


% -------- MAIN FIGURE WINDOW --------
haxGRIN = axes('Parent', mainguih, 'NextPlot', 'replacechildren',...
    'Position', [0.01 0.01 0.40 0.85], 'PlotBoxAspectRatio', [1 1 1], ...
    'XColor','none','YColor','none','YDir','reverse'); 
    % ,'XDir','reverse',...
    
% -------- IMPORT IMAGE STACK & EXCEL DATA BUTTON --------
importimgstackH = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.01 0.90 0.40 0.08], 'FontSize', 14, ...
    'String', 'Import Image Stack & Excel Data', ...
    'Callback', @importimgstack);



imgsliderH = uicontrol('Parent', mainguih, 'Units', 'normalized','Style','slider',...
	'Max',100,'Min',1,'Value',1,'SliderStep',[0.01 0.10],...
	'Position', [0.01 0.86 0.40 0.02], 'Callback', @imgslider);








%----------------------------------------------------
%           MEMO CONSOLE GUI WINDOW
%----------------------------------------------------

memopanelH = uipanel('Parent', mainguih,'Title','Memo Log ','FontSize',10,...
    'BackgroundColor',[1 1 1],...
    'Position', [0.43 0.76 0.55 0.23]); % 'Visible', 'Off',


memes = {' ',' ',' ', ' ',' ',' ',' ', ...
         'Welcome to the GRIN TOOLBOX', 'GUI is loading...'};

conboxH = uicontrol('Parent',memopanelH,'Style','listbox','Units','normalized',...
        'Max',9,'Min',0,'Value',9,'FontSize', 13,'FontName', 'FixedWidth',...
        'String',memes,'FontWeight', 'bold',...
        'Position',[.0 .0 1 1]);  
    

% memocon(['Factor set to: ' callbackdata.NewValue.String])


%----------------------------------------------------
%           IMAGE PROCESSING PANEL
%----------------------------------------------------
IPpanelH = uipanel('Title','Image Processing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.43 0.23 0.35 0.52]); % 'Visible', 'Off',


%----------------------------------------------------
%           DATA GRAPHS AND FIGURES PANEL
%----------------------------------------------------
graphspanelH = uipanel('Title','Graphs and Figures','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.43 0.01 0.35 0.20]); % 'Visible', 'Off',
              

plotTileStatsH = uicontrol('Parent', graphspanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.66 0.31 0.28], 'FontSize', 12, 'String', 'Plot Tile Data',...
    'Callback', @plotTileStats, 'Enable','off'); 




%----------------------------------------------------
%    ALIGN & NORMALIZE PANEL
%----------------------------------------------------
alignfunpanelH = uipanel('Title','Align & Normalize','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.80 0.49 0.18 0.26]); % 'Visible', 'Off',


getAlignH = uicontrol('Parent', alignfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.80 0.45 0.17], 'FontSize', 13, 'String', 'Get Align',...
    'Callback', @getAlign, 'Enable','off');

setAlignH = uicontrol('Parent', alignfunpanelH, 'Units', 'normalized', ...
    'Position', [0.53 0.80 0.45 0.17], 'FontSize', 13, 'String', 'Set Align',...
    'Callback', @setAlign, 'Enable','off');


imgAlignXTxtH = uicontrol('Parent', alignfunpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.12 0.70 0.35 0.09], 'FontSize', 10,'String', 'X');

imgAlignYTxtH = uicontrol('Parent', alignfunpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.57 0.70 0.35 0.09], 'FontSize', 10,'String', 'Y');


imgAlignP1TxtH = uicontrol('Parent', alignfunpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.59 0.13 0.10], 'FontSize', 10,'String', 'P1: ');

imgAlignP2TxtH = uicontrol('Parent', alignfunpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.46 0.13 0.10], 'FontSize', 10,'String', 'P2: ');

imgAlignP3TxtH = uicontrol('Parent', alignfunpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.33 0.13 0.10], 'FontSize', 10,'String', 'P3: ');

imgAlignP4TxtH = uicontrol('Parent', alignfunpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.20 0.13 0.10], 'FontSize', 10,'String', 'P4: ');




imgAlignP1Xh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.18 0.59 0.28 0.11], 'FontSize', 10);

imgAlignP1Yh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.62 0.59 0.28 0.11], 'FontSize', 10);


imgAlignP2Xh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.18 0.46 0.28 0.11], 'FontSize', 10);

imgAlignP2Yh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.62 0.46 0.28 0.11], 'FontSize', 10);


imgAlignP3Xh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.18 0.33 0.28 0.11], 'FontSize', 10);

imgAlignP3Yh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.62 0.33 0.28 0.11], 'FontSize', 10);


imgAlignP4Xh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.18 0.20 0.28 0.11], 'FontSize', 10);

imgAlignP4Yh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.62 0.20 0.28 0.11], 'FontSize', 10);







redChImportH = uicontrol('Parent', alignfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.02 0.45 0.17], 'FontSize', 11, 'String', 'Import Red Ch.',...
    'Callback', @redChImport, 'Enable','off');

redChanNormalizeH = uicontrol('Parent', alignfunpanelH, 'Units', 'normalized', ...
    'Position', [0.53 0.02 0.45 0.17], 'FontSize', 11, 'String', 'Red Ch. Norm.',...
    'Callback', @redChanNormalize, 'Enable','off');


pause(.1)

grinlenstoolbox()

% memocon('Ready!')



% -----------------------------------------------------------------------------
%%                     GUI TOOLBOX FUNCTIONS
% -----------------------------------------------------------------------------



%----------------------------------------------------
%   INITIAL GRIN TOOLBOX FUNCTION TO POPULATE GUI
%----------------------------------------------------
function grinlenstoolbox(hObject, eventdata)

    % set(initmenuh, 'Visible', 'Off');
    % set(mainguih, 'Visible', 'On');
    
    %----------------------------------------------------
    %           SET USER-EDITABLE GUI VALUES
    %----------------------------------------------------
    imgLogo = imread('grinlogo.png');
    set(haxGRIN, 'XLim', [1 size(imgLogo,2)], 'YLim', [1 size(imgLogo,1)]);
    
    % set(imgblocksnumH, 'String', num2str(blockSize));
    % Set radiobuttons
    % stimtypeh.SelectedObject = stimtypeh1; 
    % stimtype = stimtypeh.SelectedObject.String;
    %----------------------------------------------------
    
    
    
    
    %----------------------------------------------------
    %                   DRAW IMAGE
    %----------------------------------------------------

        axes(haxGRIN)
        colormap(haxGRIN,parula)
    phGRIN = imagesc(imgLogo , 'Parent', haxGRIN);
        pause(.1)

memocon('Ready to Import Image Stack!')
end



%----------------------------------------------------
%        IMPORT IMAGE STACK MAIN FUNCTION
%----------------------------------------------------
function importimgstack(hObject, eventdata)
% diary on
memocon('GRIN LENS IMAGING TOOLBOX - ACQUIRING DATASET')



% GET FULL PATHS TO ALL MAT FILES IN A FILE
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




% IMPORT DATASETS
DATA = {};

for nn = 1:size(datapaths,1)

    DATA{nn} = load(datapaths{nn});

end



figure
imagesc(DATA{1}.IMGS(:,:,1,1));



moving_reg = imregister(moving,fixed,transformType,optimizer,metric)

%[moving_reg,R_reg] = imregister(moving,Rmoving,fixed,Rfixed,transformType,optimizer,metric)


keyboard


IMG = {};
RIMG = {};
INFO = GRINstruct;
XLS = XLSdata;

for nn = 1:size(datapaths,1)

    LOADS{nn} = load(datapaths{nn});

    IMG{nn,1} = IMGS;
    RIMG{nn,1} = IMGR;
    INFO(nn,1) = GRINstruct;
    XLS(nn,1) = XLSdata;

end

clearvars -except...
datapaths datafiles IMG INFO XLS RIMG










enableButtons
memocon('Image stack and xls data import completed!')
end




%----------------------------------------------------
%        GET ALIGN
%----------------------------------------------------
function getAlign(hObject, eventdata)
% disableButtons; 
getAlignH.FontWeight = 'bold';
pause(.02);

%{
xlsA = [];
AlignSheetExists = 0;
try
    
   xlsA = xlsread([xlspathname , xlsfilename],'ALIGN');
   
   AlignSheetExists = 1;
   
   memocon('Imported pre-existing aligment values fomr ALIGN excel sheet');
   
catch ME
    
    memocon(ME.message)
    
end 





if isempty(xlsA)

    if AlignSheetExists && isempty(xlsA)
        memocon('ALIGN excel sheet exists, but is empty');
    end
    if ~AlignSheetExists
        memocon('ALIGN excel sheet does not exist');
    end


%     memocon(' ');
%     memocon('SMOOTHING AND CROPPING IMAGES...');
%     if checkbox1H.Value
%         smoothimg
%     end
%     if checkbox2H.Value
%         cropimg
%     end

    memocon('OPENING IMG ALIGNMENT POPOUT...');
    memocon('SELECT TWO (2) ALIGNMENT POINTS');


    % CREATE IMG WINDOW POPOUT

    IMGi = IMG(:,:,1:previewStacknum);

    fhIMA=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
    haxIMA = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[],'YTick',[]);
    % hold on;

    axes(haxIMA)
    phG = imagesc(IMGi(:,:,1),'Parent',haxIMA,'CDataMapping','scaled');
    [cmax, cmaxi] = max(IMGi(:));
    [cmin, cmini] = min(IMGi(:));
    cmax = cmax - abs(cmax/4);
    cmin = cmin + abs(cmin/4);
    haxIMA.CLim = [cmin cmax];
    axes(haxIMA)
    pause(.01)



    % SELECT TWO ROI POINTS
    hAP1 = impoint;
    hAP2 = impoint;

    AP1pos = hAP1.getPosition;
    AP2pos = hAP2.getPosition;

    imellipse(haxIMA, [AP1pos-5 10 10]); pause(.1);
    imellipse(haxIMA, [AP2pos-5 10 10]); pause(.1);

    pause(.5);
    close(fhIMA)

    memocon('  ');
    memocon('ALIGNMENT POINTS');
    memocon(sprintf('P1(X,Y): \t    %.2f \t    %.2f',AP1pos));
    memocon(sprintf('P2(X,Y): \t    %.2f \t    %.2f',AP2pos));

end
%}




    memocon('OPENING IMG ALIGNMENT POPOUT...');
    memocon('SELECT TWO (2) ALIGNMENT POINTS');


    % CREATE IMG WINDOW POPOUT

    IMGi = IMG(:,:,1:previewStacknum);

    fhIMA=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
    haxIMA = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[],'YTick',[]);
    % hold on;

    axes(haxIMA)
    phG = imagesc(IMGi(:,:,1),'Parent',haxIMA,'CDataMapping','scaled');
    [cmax, cmaxi] = max(IMGi(:));
    [cmin, cmini] = min(IMGi(:));
    cmax = cmax - abs(cmax/4);
    cmin = cmin + abs(cmin/4);
    haxIMA.CLim = [cmin cmax];
    axes(haxIMA)
    pause(.01)



    % SELECT TWO ROI POINTS
    hAP1 = impoint;
    hAP2 = impoint;

    AP1pos = hAP1.getPosition;
    AP2pos = hAP2.getPosition;

    imellipse(haxIMA, [AP1pos-5 10 10]); pause(.1);
    imellipse(haxIMA, [AP2pos-5 10 10]); pause(.1);

    pause(.5);
    close(fhIMA)

    memocon('  ');
    memocon('ALIGNMENT POINTS');
    memocon(sprintf('P1(X,Y): \t    %.2f \t    %.2f',AP1pos));
    memocon(sprintf('P2(X,Y): \t    %.2f \t    %.2f',AP2pos));




AlignVals.P1x = AP1pos(1);
AlignVals.P1y = AP1pos(2);
AlignVals.P2x = AP2pos(1);
AlignVals.P2y = AP2pos(2);

imgAlignP1Xh.String = num2str(AlignVals.P1x);
imgAlignP1Yh.String = num2str(AlignVals.P1y);
imgAlignP2Xh.String = num2str(AlignVals.P2x);
imgAlignP2Yh.String = num2str(AlignVals.P2y);        
% imgAlignP3Xh.String = num2str(AlignVals.P3x);
% imgAlignP3Yh.String = num2str(AlignVals.P3y);
% imgAlignP4Xh.String = num2str(AlignVals.P4x);
% imgAlignP4Yh.String = num2str(AlignVals.P4y);



getAlignH.FontWeight = 'normal';
pause(.02);
enableButtons; pause(.02);
memocon('GET alignment completed.')
end





%----------------------------------------------------
%        SET ALIGN
%----------------------------------------------------
function setAlign(hObject, eventdata)
% disableButtons; 
setAlignH.FontWeight = 'bold';
pause(.02);



AlignVals.P1x = str2num(imgAlignP1Xh.String);
AlignVals.P1y = str2num(imgAlignP1Yh.String);
AlignVals.P2x = str2num(imgAlignP2Xh.String);
AlignVals.P2y = str2num(imgAlignP2Yh.String);
AlignVals.P3x = str2num(imgAlignP3Xh.String);
AlignVals.P3y = str2num(imgAlignP3Yh.String);
AlignVals.P4x = str2num(imgAlignP4Xh.String);
AlignVals.P4y = str2num(imgAlignP4Yh.String);



P1x = AlignVals.P1x;
P1y = AlignVals.P1y;
P2x = AlignVals.P2x;
P2y = AlignVals.P2y;
P3x = AlignVals.P3x;
P3y = AlignVals.P3y;
P4x = AlignVals.P4x;
P4y = AlignVals.P4y;


tX = P3x - P1x;
tY = P3y - P1y;

[IM,~] = imtranslate(IMG,[tX, tY],'FillValues',mean(IMG(:)),'OutputView','same');

IMG = IM;
previewStack



% P1x = P1x + tX;    % after translation P1x moves to P3x
% P1y = P1y + tY;    % after translation P1y moves to P3y
% P2x = P2x + tX;    % after translation P2x does not move to P4x
% P2y = P2y + tY;    % after translation P2y does not move to P4y
% 
% 
% % Make X and Y origins equal zero
% 
% Xa = P2x - P1x; 
% Ya = P2y - P1y; 
% 
% RotA = rad2deg(atan2(Ya,Xa));
% 
% 
% Xb = P4x - P3x;
% Yb = P4y - P3y;
% 
% RotB = rad2deg(atan2(Yb,Xb));
% 
% RotAng = RotB - RotA;
% 
% IM = imrotate(IMG,RotAng,'bilinear','crop'); % Make output image B the same size as the input image A, cropping the rotated image to fit
% 
% IMG = IM;
% previewStack




% fixed = IMG(:,:,1);
% moving = IMG(:,:,500);
% imshowpair(fixed, moving,'Scaling','joint')
% [optimizer, metric] = imregconfig('multimodal');
% optimizer.InitialRadius = 0.009;
% optimizer.Epsilon = 1.5e-4;
% optimizer.GrowthFactor = 1.01;
% optimizer.MaximumIterations = 300;
% movingRegistered = imregister(moving, fixed, 'affine', optimizer, metric);
% imshowpair(fixed, movingRegistered,'Scaling','joint')




setAlignH.FontWeight = 'normal';
pause(.02);
enableButtons; pause(.02);
memocon('SET alignment completed.')
end














%----------------------------------------------------
%        red Channel IMPORT
%----------------------------------------------------
function redChImport(hObject, eventdata)
pause(.02);

    pathfull = [GRINstruct.path(1:end-5) 'r.tif'];
    [VpPath,VpFile,VpExt] = fileparts(pathfull);
    rcFile = dir(pathfull);

    if numel(rcFile.name) > 1
        
        memocon(' ');
        memocon('Red channel stack found; attempting to import...');
                
    else
        
        memocon(' ');
        memocon('No red channel stack found named:');
        memocon(['  ' VpFile VpExt]);
        memocon(' '); memocon('Select a red channel tif stack...')

        [pathfile, pathdir, ~] = uigetfile({'*.tif*; *.TIF*'}, 'Select file.');
        pathfull = [pathdir pathfile];

    end



    % IMPORT RED CHANNEL IMAGE 
    InfoImage=imfinfo(pathfull);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
        
    IMGred = zeros(nImage,mImage,NumberImages,'double');

    TifLink = Tiff(pathfull, 'r');
    for i=1:NumberImages
       TifLink.setDirectory(i);
       IMGred(:,:,i)=TifLink.read();
    end
    TifLink.close();
    

    if (size(IMG,3) * size(IMG,4)) == size(IMGred,3)
        memocon('GOOD: size(greenStack) == size(redStack)')
    else
        memocon(' ');memocon(' ');memocon(' ');memocon(' ');
        memocon('******  WARNING: size(greenStack) ~= size(redStack)  *****')
        warning('WARNING: size(greenStack) ~= size(redStack)')
        memocon('******    ABORTING RED CHANNEL STACK IMPORT    ******')
        memocon(' ');memocon(' ');memocon(' ');
        return
    end

      
        % VISUALIZE AND ANNOTATE

        SPF1 = sprintf('Green Channel dims: % s ', num2str(size(IMG))  );
        SPF2 = sprintf('Red   Channel dims: % s ', num2str(size(IMGred)) );
       
        memocon(' '); memocon(SPF1); memocon(SPF2);
        
        % GRINcompare(IMG, IMGf, previewNframes, [.98 1.05], [8 2])
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
    
        
        memocon(' ');
        pause(.5)
        memocon('red Stack Preview'); previewIMGSTACK(IMGred)
        pause(.5)
        memocon('green Stack Preview'); previewStack
        pause(.5)
        memocon('red Stack Preview'); previewIMGSTACK(IMGred)
        pause(.5)
        memocon('green Stack Preview'); previewStack
        pause(.5)
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);


pause(.02);
redChanNormalizeH.Enable = 'on';
enableButtons
memocon('Red channel import completed!')
end


%----------------------------------------------------
%        red Channel NORMALIZATION
%----------------------------------------------------
function redChanNormalize(hObject, eventdata)
% disableButtons;
pause(.02);




RHposCheck.A  = [.02  .76  .05  .05];
RHposCheck.B  = [.02  .64  .05  .05];
RHposCheck.C  = [.02  .52  .05  .05];
RHposCheck.D  = [.02  .40  .05  .05];
RHposCheck.E  = [.02  .28  .05  .05];
RHposCheck.F  = [.02  .16  .05  .05];
RHposCheck.G  = [.02  .04  .05  .05];
RHposTexts.A  = [.12  .72  .45  .08];
RHposTexts.B  = [.12  .60  .45  .08];
RHposTexts.C  = [.12  .48  .45  .08];
RHposTexts.D  = [.12  .36  .45  .08];
RHposTexts.E  = [.12  .24  .45  .08];
RHposTexts.F  = [.12  .12  .45  .08];
RHposTexts.G  = [.22  .85  .65  .08];



REDpopupH = figure('Units', 'normalized','Position', [.25 .12 .30 .80], 'BusyAction',...
    'cancel', 'Name', 'GRIN TOOLBOX', 'Tag', 'REDpopupH','Visible', 'On'); 

REDpanelH = uipanel('Title','Process Red Channel Stack','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],'Position', [0.08 0.20 0.90 0.77]);

Rcheckbox1H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.A ,'String','', 'Value',1);
Rcheckbox2H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.B ,'String','', 'Value',1);
Rcheckbox3H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.C ,'String','', 'Value',1);
Rcheckbox4H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.D ,'String','', 'Value',1);
Rcheckbox5H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.E ,'String','', 'Value',1);
Rcheckbox6H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.F ,'String','', 'Value',1);

uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.A, 'FontSize', 14,'String', 'Smooth');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.B, 'FontSize', 14,'String', 'Crop');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.C, 'FontSize', 14,'String', 'Tile');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.D, 'FontSize', 14,'String', 'Reshape');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.E, 'FontSize', 14,'String', 'Align to CS');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.F, 'FontSize', 14,'String', 'Normalize');
% uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
%     'Position', RHposTexts.G, 'FontSize', 14,'String', 'CLOSE THIS WINDOW TO CONTINUE');


REDcontinueH = uicontrol('Parent', REDpopupH, 'Units', 'normalized', ...
    'Position', [.1 .05 .8 .12], 'FontSize', 12, 'String', 'Continue',...
    'Callback', @REDcontinue, 'Enable','on');

uiwait
REDpopupH.Visible = 'Off';

    
    %----------------------------------------------------
    %        SMOOTH RED CHAN IMAGES
    %----------------------------------------------------  
    if Rcheckbox1H.Value
        memocon(' '); memocon('PERFORMING RED CH IMAGE SMOOTHING')
        IMGr = [];

        smoothSD = str2num(smoothimgnumH.String);
        Mask = GRINkernel(smoothHeight, smoothWidth, smoothSD, smoothRes, 1);
        pause(.2)
        mbh = waitbar(.5,'Performing convolution smoothing, please wait...');

        IMGr = convn( IMGred, Mask,'same');

        waitbar(.8); close(mbh);

        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Image smoothing completed!')    
    end
    
    
    %----------------------------------------------------
    %        CROP RED CHANNEL IMAGES
    %----------------------------------------------------
    if Rcheckbox2H.Value
        memocon(' '); memocon('TRIMMING EDGES FROM IMAGE')
        IMGr = [];

        cropAmount = str2num(cropimgnumH.String);

        IMGr = IMGred((cropAmount+1):(end-cropAmount) , (cropAmount+1):(end-cropAmount) , :);

        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Crop Images completed!')
    end

    
    %----------------------------------------------------
    %        CREATE IMAGE TILES BLOCKS
    %----------------------------------------------------
    if Rcheckbox3H.Value
        memocon('SEGMENTING IMGAGES INTO TILES')
        IMGr = [];

        blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));

        IMGr = zeros(size(IMGred));
        sz = size(IMGred,3);

        %-------------------------
        tv1 = 1:blockSize:size(IMGred,1);
        tv2 = 0:blockSize:size(IMGred,1);
        tv2(1) = [];

        progresstimer('Segmenting images into blocks...')
        for nn = 1:sz
          for cc = 1:numel(tv1)
            for rr = 1:numel(tv1)

              mbloc = IMGred( tv1(rr):tv2(rr), tv1(cc):tv2(cc) , nn );
              mu = mean(mbloc(:));

              IMGr( tv1(rr):tv2(rr), tv1(cc):tv2(cc) , nn ) = mu;

            end
          end
        if ~mod(nn,100); progresstimer(nn/sz); end    
        end
        %-------------------------


        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Block-Segment Images completed!')        
    end

    
    
    %----------------------------------------------------
    %        RESHAPE DATA BY TRIALS
    %----------------------------------------------------
    if Rcheckbox4H.Value
        memocon(' '); memocon('Reshaping dataset to 4D');
        IMGr = [];

        IMGr = reshape(IMGred,size(IMGred,1),size(IMGred,2),framesPerTrial,[]);

        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Reshape stack by trial completed!')
    end

    
    
    %----------------------------------------------------
    %        ALIGN CS FRAMES BY CS ONSET
    %----------------------------------------------------
    if Rcheckbox5H.Value
        memocon(sprintf('Setting CS delay to %s seconds for all trials',alignCSFramesnumH.String));
        IMGr = [];

        % Make all CS onsets this many seconds from trial start
        CSonsetDelay = str2num(alignCSFramesnumH.String);
        CSonsetFrame = round(CSonsetDelay .* framesPerSec);
        CSoffsetFrame = round((CSonsetDelay+CS_length) .* framesPerSec);


        EqualizeCSdelay  = round((delaytoCS-CSonsetDelay) .* framesPerSec);

        IMGr = IMGred;
        for nn = 1:size(IMGr,4)

            IMGr(:,:,:,nn) = circshift( IMGr(:,:,:,nn) , -EqualizeCSdelay(nn) ,3);

        end

        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Align frames by CS onset completed!')
    end
    
    
    %----------------------------------------------------
    %        deltaF OVER F
    %----------------------------------------------------
    if Rcheckbox6H.Value
        memocon(' '); memocon('Computing dF/F for all frames...')
        IMGr = [];

        IMGr = mean(IMGred(:,:,1:round(baselineTime*framesPerSec),:),3);

        im = repmat(IMGr,1,1,size(IMGred,3),1);

        IMGf = (IMGred - im) ./ im;

        IMGred = IMGf;

        previewIMGSTACK(IMGred)
        memocon('dF/F computation completed!')
    end
    
    
    %----------------------------------------------------
    %        RED CHANNEL SUBTRACTION NORMALIZATION
    %----------------------------------------------------
    
    szGimg = size(IMG);
    szRimg = size(IMGred);
    
    disp('Green Stack Dims:')
    disp(szGimg)
    disp('Red Stack Dims:')
    disp(szRimg)
    
    
    if all(szGimg == szRimg)
    
        prompt = {'Enter normalization equation:'};
        dlgout = inputdlg(prompt,'Equation Input',1,{'IMG = IMG - IMGred;'});    

        eval(char(dlgout));

        previewIMGSTACK(IMG)

    else
       
        warning('Green and Red IMG stacks are not the same size.')
        warning('Cannot perform normalization.')
        
    end





        
pause(.02);
enableButtons        
memocon('RED CHANNEL NORMALIZATION COMPLETED')
end


%----------------------------------------------------
%        RED CHANNEL CONTINUE BUTTON CALLBACK
%----------------------------------------------------
function REDcontinue(hObject, eventdata)    

    uiresume
    
end


%----------------------------------------------------
%        EXPORT DATA TO BASE WORKSPACE
%----------------------------------------------------
function exportvars(hObject, eventdata)
% disableButtons; pause(.02);

    if size(GRINtable,1) > 1
        checkLabels = {'Save IMG to variable named:' ...
                   'Save GRINstruct to variable named:' ...
                   'Save GRINtable to variable named:' ...
                   'Save XLSdata to variable named:' ...
                   'Save IMGraw to variable named:'...
                   'Save IMGSraw to variable named:'...
                   'Save muIMGS to variable named:'...
                   'Save LICK to variable named:'}; 
        varNames = {'IMG','GRINstruct','GRINtable','XLSdata','IMGraw','IMGSraw','muIMGS','LICK'}; 
        items = {IMG,GRINstruct,GRINtable,XLSdata,IMGraw,IMGSraw,muIMGS,LICK};
        export2wsdlg(checkLabels,varNames,items,...
                     'Save Variables to Workspace');

        memocon('Main VARS exported to base workspace')
    else
        memocon('no variables available to export')
    end
    
enableButtons        
end

%----------------------------------------------------
%        LOAD .mat DATA
%----------------------------------------------------
function loadmatdata(hObject, eventdata)
% disableButtons; pause(.02);


    [filename, pathname] = uigetfile( ...
    {'*.mat'}, ...
   'Select a .mat datafile');
    
    IMG = [];
    IMGSraw = [];
    muIMGS = [];

memocon('Loading data from .mat file, please wait...')
disableButtons; pause(.02);    

    LODIN = load([pathname, filename]);
    
    
    [IMG] = deal(LODIN.IMG);
    [GRINstruct] = deal(LODIN.GRINstruct);
    [GRINtable] = deal(LODIN.GRINtable);
    [XLSdata] = deal(LODIN.XLSdata);
    [muIMGS] = deal(LODIN.muIMGS);
    [IMGSraw] = deal(LODIN.IMGSraw);
    [LICK] = deal(LODIN.LICK);
    [IMhist] = deal(LODIN.IMhist);
    
    
    if isa(IMG, 'single')

        memocon('loading single precision dataset...')
        IM = IMG;
        IMG = double(IM);
        
    else
        
        memocon('loading uint16-compressed dataset...')
        IM = IMG;
        IMG = double(IM);
        lintrans = @(x,a,b,c,d) (c.*(1-(x-a)./(b-a)) + d.*((x-a)./(b-a)));
        IMG = lintrans(IMG,min(min(min(min(IMG)))),max(max(max(max(IMG)))),IMhist.minIM,IMhist.maxIM);
        
    end
    
    LODIN = [];
    IM = [];
    
    previewStack

    clc;
    memocon('Dataset loaded with the following history...')
    memocon(IMhist)
    memocon('Experimental parameters...')
    memocon(XLSdata.CSUSvals)
    memocon('Image stack sizes...')
    memocon(['size(IMG) :  ' num2str(size(IMG))])
    memocon(['size(muIMGS) :  ' num2str(size(muIMGS))])
    memocon(['size(IMGSraw) :  ' num2str(size(IMGSraw))])

memocon('Dataset fully loaded, GRIN Toolbox is Ready!')
enableButtons        
end


%----------------------------------------------------
%        PREVIEW IMAGE STACK
%----------------------------------------------------
function previewStack(hObject, eventdata)
disableButtons; pause(.02);

    % memocon('PREVIEWING IMAGE STACK')
    
    totframes = size(IMG,3);
    
    previewStacknum = str2num(previewStacknumH.String);

    
    if totframes >= previewStacknum
    
        IMGi = IMG(:,:,1:previewStacknum);
    
    
        [IMGcMax, IMGcMaxInd] = max(IMG(:));
        [IMGcMin, IMGcMinInd] = min(IMG(:));    
        % [I,J,tmp1] = ind2sub(size(IMG),cb1)
        % IMG(I,J,tmp1)
        
        axes(haxGRIN)
        phGRIN = imagesc(IMGi(:,:,1),'Parent',haxGRIN,'CDataMapping','scaled');
        Imax = max(max(max(IMGi)));
        Imin = min(min(min(IMGi)));

        cmax = Imax - (Imax-Imin)/12;
        cmin = Imin + (Imax-Imin)/12;
        
        if cmax > cmin
            haxGRIN.CLim = [cmin cmax];
        end

        for nn = 1:previewStacknum

            phGRIN.CData = IMGi(:,:,nn);

            pause(.04)
        end
    
    

        % VISUALIZE AND ANNOTATE
        % fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        % fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGt)));
        % GRINcompare(IMG, IMGt, previewNframes)
        % mainguih.HandleVisibility = 'off';
        % close all;
        % mainguih.HandleVisibility = 'on';
    
    
    else
        
       memocon('Not enough images in 3rd dim to preview that many frames') 
        
    end

        
enableButtons        
% memocon('Preview completed!')
end


function previewIMGSTACK(IMGSTACK)
disableButtons; pause(.02);

    % memocon('PREVIEWING IMAGE STACK')
    
    totframes = size(IMGSTACK,3);
    
    previewStacknum = str2num(previewStacknumH.String);

    
    if totframes >= previewStacknum
    
        IMGi = IMGSTACK(:,:,1:previewStacknum);
    
    
        [IMGcMax, IMGcMaxInd] = max(IMGSTACK(:));
        [IMGcMin, IMGcMinInd] = min(IMGSTACK(:));    
        % [I,J,tmp1] = ind2sub(size(IMG),cb1)
        % IMG(I,J,tmp1)

        axes(haxGRIN)
        phGRIN = imagesc(IMGi(:,:,1),'Parent',haxGRIN,'CDataMapping','scaled');

        Imax = max(max(max(IMGi)));
        Imin = min(min(min(IMGi)));

        cmax = Imax - (Imax-Imin)/5;
        cmin = Imin + (Imax-Imin)/5;

        haxGRIN.CLim = [cmin cmax];

        for nn = 1:previewStacknum

            phGRIN.CData = IMGi(:,:,nn);

            pause(.04)
        end

%     phGRIN.CData = mean(squeeze(muIMGS(:,:,XLSdata.CSoffsetFrame,:)),3);
% 
%     phGRIN.CData = IMGraw;
%     haxGRIN.CLim = [min(IMGraw(:)) + (max(IMGraw(:))-min(IMGraw(:)))/15 , ...
%                     max(IMGraw(:)) - (max(IMGraw(:))-min(IMGraw(:)))/15];
% 
%     IM = zscore(mean(squeeze(muIMGS(:,:,XLSdata.CSoffsetFrame,:)),3));
% 
%     IM = IMGraw.*(IM + 7);
% 
%     phGRIN.CData = IM;
%     haxGRIN.CLim = [min(IM(:)) + (max(IM(:))-min(IM(:)))/15 , ...
%                     max(IM(:)) - (max(IM(:))-min(IM(:)))/15];

    
    else
        
       memocon('Not enough images in 3rd dim to preview that many frames') 
        
    end

        
enableButtons        
% memocon('Preview completed!')
end





%----------------------------------------------------
%        ENABLE AND DISABLE GUI BUTTONS
%----------------------------------------------------
function enableButtons()

    plotTileStatsH.Enable = 'on';
    getAlignH.Enable = 'on';
    setAlignH.Enable = 'on';
    redChImportH.Enable = 'on';

end
function disableButtons()
    
    plotTileStatsH.Enable = 'off';
    getAlignH.Enable = 'off';
    setAlignH.Enable = 'off';
    redChImportH.Enable = 'off';

end



%----------------------------------------------------
%        MEMO LOG UPDATE
%----------------------------------------------------
function memocon(spf,varargin)
    
  
    if iscellstr(spf)
        spf = [spf{:}];
    end
    
    if iscell(spf)
        return
        keyboard
        spf = [spf{:}];
    end
    
    if ~ischar(spf)
        return
        keyboard
        spf = [spf{:}];
    end
    
    

    memes(1:end-1) = memes(2:end);
    memes{end} = spf;
    conboxH.String = memes;
    pause(.02)
    
    if nargin == 3
        
        vrs = deal(varargin);
                
        memi = memes;
                 
        memes(1:end) = {' '};
        memes{end-1} = vrs{1};
        memes{end} = spf;
        conboxH.String = memes;
        
        conboxH.FontAngle = 'italic';
        conboxH.ForegroundColor = [.9 .4 .01];
        pause(vrs{2})
        
        conboxH.FontAngle = 'normal';
        conboxH.ForegroundColor = [0 0 0];
        conboxH.String = memi;
        pause(.02)
        
    elseif nargin == 2
        vrs = deal(varargin);
        pause(vrs{1})
    end
    
    
    

end




end
%% EOF



%% ------------------------- OUT OF USE ------------------------------
%{

%----------------------------------------------------
%   MAIN GUI CLOSE REQUEST FUNCTION
%----------------------------------------------------
function mainGUIclosereq(src,callbackdata)
   selection = questdlg('Clear globals from memory?',...
      'Close Request Function',...
      'Yes','No','Yes'); 
   switch selection, 
      case 'Yes',
         clc
         initialVars = who;
         memocon('Clearing globals...')
         memocon(initialVars)
         clearvars -global
         % clearvars IMG;
         memocon('Global variables cleared from memory.')
         memocon('GRIN toolbox closed.')
         delete(gcf)
      case 'No'
      delete(gcf)
      memocon('GRIN toolbox closed.')
   end
end




%----------------------------------------------------
%        COMING SOON NOTIFICATION
%----------------------------------------------------
function comingsoon(hObject, eventdata)
   msgbox('Coming Soon!'); 
end





%----------------------------------------------------
%        MOTION CORRECTION
%----------------------------------------------------
function motioncorrection(hObject, eventdata)
   msgbox('Coming Soon!'); 
   return
   
    % clc; clear all; close all;

    % Input video file which needs to be stabilized.
    % filename = 'shaky_car.avi';
    filename = 'GRIN_zstack.avi';

    hVideoSource = vision.VideoFileReader(filename, ...
              'ImageColorSpace', 'Intensity','VideoOutputDataType', 'double');


    % Create geometric translator object used to compensate for movement.
    hTranslate = vision.GeometricTranslator( ...
           'OutputSize', 'Same as input image', 'OffsetSource', 'Input port');


    % Create template matcher object to compute location of best target match
    % in frame. Use location to find translation between successive frames.
    hTM = vision.TemplateMatcher('ROIInputPort', true, ...
                                'BestMatchNeighborhoodOutputPort', true);


    % Create object to memoconlay the original video and the stabilized video.
    hVideoOut = vision.VideoPlayer('Name', 'Video Stabilization');
    hVideoOut.Position(1) = round(0.4*hVideoOut.Position(1));
    hVideoOut.Position(2) = round(1.5*(hVideoOut.Position(2)));
    hVideoOut.Position(3:4) = [900 550];


        imgA = step(hVideoSource); % Read first frame into imgA
        figure
        imagesc(imgA);
        title('USE MOUSE TO DRAW BOX AROUND BEST STABILIZATION OBJECT')
        h1 = imrect;
        pos1 = round(getPosition(h1)); % [xmin ymin width height]


    % Here we initialize some variables used in the processing loop.

    pos.template_orig = [pos1(1) pos1(2)]; % [x y] upper left corner
    pos.template_size = [pos1(3:4)];    % [width height]
    pos.search_border = [10 10];        % max horizontal and vertical memoconlacement

    pos.template_center = floor((pos.template_size-1)/2);
    pos.template_center_pos = (pos.template_orig + pos.template_center - 1);
    fileInfo = info(hVideoSource);
    W = fileInfo.VideoSize(1); % Width in pixels
    H = fileInfo.VideoSize(2); % Height in pixels
    BorderCols = [1:pos.search_border(1)+4 W-pos.search_border(1)+4:W];
    BorderRows = [1:pos.search_border(2)+4 H-pos.search_border(2)+4:H];
    sz = fileInfo.VideoSize;
    TargetRowIndices = ...
      pos.template_orig(2)-1:pos.template_orig(2)+pos.template_size(2)-2;
    TargetColIndices = ...
      pos.template_orig(1)-1:pos.template_orig(1)+pos.template_size(1)-2;
    SearchRegion = pos.template_orig - pos.search_border - 1;
    Offset = [0 0];
    Target = zeros(20,20);
    % Target = zeros(18,22);
    firstTime = true;



    % Stream Processing Loop

    % Processing loop using objects created above to perform stabilization
    nn = 0;
    while ~isDone(hVideoSource)
    nn = nn+1;

        input = step(hVideoSource);

        % Find location of Target in the input video frame
        if firstTime
          Idx = int32(pos.template_center_pos);
          MotionVector = [0 0];
          firstTime = false;
        else
          IdxPrev = Idx;

          ROI = [SearchRegion, pos.template_size+2*pos.search_border];
          Idx = step(hTM, input, Target, ROI);

          MotionVector = double(Idx-IdxPrev);
        end

        [Offset, SearchRegion] = updatesearch(sz, MotionVector, ...
            SearchRegion, Offset, pos);

        % Translate video frame to offset the camera motion
        Stabilized = step(hTranslate, input, fliplr(Offset));

        Target = Stabilized(TargetRowIndices, TargetColIndices);

        % Add black border for memoconlay
        Stabilized(:, BorderCols) = minmin;
        Stabilized(BorderRows, :) = minmin;

        TargetRect = [pos.template_orig-Offset, pos.template_size];
        SearchRegionRect = [SearchRegion, pos.template_size + 2*pos.search_border];

        % Draw rectangles on input to show target and search region
        input = insertShape(input, 'Rectangle', [TargetRect; SearchRegionRect],...
                            'Color', 'white');
        % Display the offset (memoconlacement) values on the input image
        txt = sprintf('(%+05.1f,%+05.1f)', Offset);
        input = insertText(input(:,:,1),[191 215],txt,'FontSize',16, ...
                        'TextColor', 'white', 'BoxOpacity', 0);
        % Display video
        step(hVideoOut, [input(:,:,1) Stabilized]);


        sGRINs{nn} = Stabilized;
    end

    % Release hVideoSource
    release(hVideoSource);
    % ===============================================
   
end



%----------------------------------------------------
%        RADIO BUTTON CALLBACK
%----------------------------------------------------
function stimselection(source,callbackdata)
        
    % strcmp(stimtypeh.SelectedObject.String,'CSxUS')
    stimtype = stimtypeh.SelectedObject.String;
    
    memoconlay(['Previous Stim: ' callbackdata.OldValue.String]);
    memoconlay(['Current Stim: ' callbackdata.NewValue.String]);
    memoconlay('------------------');
    
    
    % % RADIO BUTTON GROUP FOR TIMEPOINT MEANS
    % stimtypeh = uibuttongroup('Parent', IPpanelH, 'Visible','on',...
    %                   'Units', 'normalized',...
    %                   'Position',[0.63 0.31 0.35 0.06],...
    %                   'SelectionChangedFcn',@stimselection);              
    % stimtypeh1 = uicontrol(stimtypeh,'Style','radiobutton',...
    %                   'String','CSxUS',...
    %                   'Units', 'normalized',...
    %                   'Position',[0.04 0.05 0.38 0.9],...
    %                   'HandleVisibility','off');
    % stimtypeh2 = uicontrol(stimtypeh,'Style','radiobutton',...
    %                   'String','CS',...
    %                   'Units', 'normalized',...
    %                   'Position',[0.42 0.05 0.3 0.9],...
    %                   'HandleVisibility','off');
    % stimtypeh3 = uicontrol(stimtypeh,'Style','radiobutton',...
    %                   'String','US',...
    %                   'Units', 'normalized',...
    %                   'Position',[0.68 0.05 0.3 0.9],...
    %                   'HandleVisibility','off');

end




%----------------------------------------------------
%        FORMAT XLS DATASHEETS
%----------------------------------------------------
function formatXLS()
    
    msgbox('Coming Soon!'); 
   return
   
   xlsdata = formatXLS(varargin);
     
end


%}