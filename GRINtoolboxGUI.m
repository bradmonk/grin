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
% clearvars -except varargin

% Change the current folder to the folder of this .m file.
global thisfilepath
thisfile = 'GRINtoolboxGUI.m';
thisfilepath = fileparts(which(thisfile));
cd(thisfilepath);


disp('WELCOME TO THE GRIN LENS IMAGING TOOLBOX')

%% MANUALLY SET PER-SESSION PATH PARAMETERS IF WANTED


%% ESTABLISH GLOBALS AND SET STARTING VALUES


% NEW GLOBALS

global mainguih imgLogo

global IMG xlsN xlsT xlsR

global frame_period framesUncomp CS_type US_type delaytoCS CS_length compressFrms
global total_trials framesPerTrial secPerFrame framesPerSec secondsPerTrial 
global total_frames CS_lengthFrames
global GRINstruct GRINtable

global cropAmount blockSize previewNframes customFunOrder
cropAmount = 18;
blockSize = 20;
previewNframes = 25;
customFunOrder = 1;

global stimtype stimnum CSUSvals
% CSxUS:1  CS:2  US:3
stimnum = 1;
stimtype = 'CS'; 
CSUSvals = {'CS','US'};


global CSonset CSoffset USonset USoffset CSUSonoff
global CSonsetDelay
CSonsetDelay = 10;


global smoothHeight smoothWidth smoothSD smoothRes
smoothHeight = .8;
smoothWidth = 9;
smoothSD = .14;
smoothRes = .1;


global muIMGS
muIMGS = [];



%% MANUALLY SET PATH TO IMG STACK AND EXCEL FILE (OPTIONAL)

global imgfilename imgpathname xlsfilename xlspathname

% imgfilename = 'gc33_032316g.tif';
% imgpathname = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/';
% xlsfilename = 'gc33_032316.xlsx';
% xlspathname = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/';







% -----------------------------------------------------------------
%%     INITIATE GUI HANDLES AND CREATE SUBMENU GUI FIGURE
% -----------------------------------------------------------------
% INITIAL SUBMENU GUI SETUP (GRIN TOOLBOX ~ MOTION CORRECTION)

initmenuh = figure('Units','normalized','OuterPosition',[.25 .4 .4 .2], ...
    'BusyAction', 'cancel','Menubar', 'none',...
    'Name', 'GRIN analysis', 'Tag', 'GRIN analysis');

grinlenstoolboxh = uicontrol('Parent', initmenuh, 'Units','normalized', 'Position', [.03 .05 .47 .9],...
    'String', 'Start GRIN lens toolbox', 'FontSize', 16, 'Tag', 'Start GRIN lens toolbox',...
    'Callback', @grinlenstoolbox);

motioncorrectionh = uicontrol('Parent', initmenuh, 'Units','normalized', 'Position', [.52 .51 .45 .44],...
    'String', 'Perform motion correction', 'FontSize', 14, 'Tag', 'Perform motion correction',...
    'Callback', @motioncorrection);


formatXLSH = uicontrol('Parent', initmenuh, 'Units','normalized', 'Position', [.52 .05 .45 .44],...
    'String', 'Multiformat XLS sheets', 'FontSize', 14, 'Tag', 'Multiformat XLS sheets',...
    'Callback', @formatXLS);



% -----------------------------------------------------------------
%%           MAIN FLIM ANALYSIS GUI WINDOW SETUP 
% -----------------------------------------------------------------

% mainguih.CurrentCharacter = '+';
mainguih = figure('Units', 'normalized','Position', [.1 .1 .8 .6], 'BusyAction',...
    'cancel', 'Name', 'mainguih', 'Tag', 'mainguih','Visible', 'Off'); 
     % 'KeyPressFcn', {@keypresszoom,1}, 'CloseRequestFcn',{@mainGUIclosereq}
     % intimagewhtb = uitoolbar(mainguih);


% -------- MAIN FIGURE WINDOW --------
haxGRIN = axes('Parent', mainguih, 'NextPlot', 'replacechildren',...
    'Position', [0.05 0.05 0.45 0.9], 'PlotBoxAspectRatio', [1 1 1], ...
    'XColor','none','YColor','none','YDir','reverse'); 
    % ,'XDir','reverse',...
    
% -------- IMPORT IMAGE STACK & EXCEL DATA BUTTON --------
importimgstackH = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.51 0.90 0.47 0.08], 'FontSize', 14, ...
    'String', 'Import Image Stack & Excel Data', ...
    'Callback', @importimgstack);











% -------- IMAGE PROCESSING PANEL --------
IPpanelH = uipanel('Title','Image Processing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.51 0.05 0.45 0.8]); % 'Visible', 'Off',


smoothimgH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.90 0.65 0.08], 'FontSize', 14, 'String', 'Smooth Images',...
    'Callback', @smoothimg, 'Enable','off'); 
smoothimgtxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.71 0.96 0.27 0.03], 'FontSize', 11,'String', 'Smooth Amount (stdev)');
smoothimgnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.71 0.91 0.27 0.05], 'FontSize', 14); 



cropimgH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.80 0.65 0.08], 'FontSize', 14, 'String', 'Crop Images',...
    'Callback', @cropimg, 'Enable','off'); 
cropimgtxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.71 0.86 0.27 0.03], 'FontSize', 11,'String', 'Crop Amount (pixels)');
cropimgnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.71 0.81 0.27 0.05], 'FontSize', 14); 



imgblocksH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.70 0.65 0.08], 'FontSize', 14, 'String', 'Block-Segment Images',...
    'Callback', @imgblocks, 'Enable','off'); 
imgblockstxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.71 0.76 0.27 0.03], 'FontSize', 11,'String', 'Tile Size (pixels)');
imgblocksnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.71 0.71 0.27 0.05], 'FontSize', 14); 


dFoverFH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.60 0.65 0.08], 'FontSize', 14, 'String', 'Compute dF / F',...
    'Callback', @dFoverF, 'Enable','off'); 
% dFoverFtxtH = uicontrol('Parent', mainguih, 'Style', 'Text', 'Units', 'normalized',...
%     'Position', [0.71 0.56 0.2 0.03], 'FontSize', 11,'String', 'Block Size (pixels)');
% dFoverFnumH = uicontrol('Parent', mainguih, 'Style', 'Edit', 'Units', 'normalized', ...
%     'Position', [0.73 0.51 0.15 0.05], 'FontSize', 14); 

reshapeDataH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.50 0.65 0.08], 'FontSize', 13, 'String', 'Reshape stack by trial (4D matrix) ',...
    'Callback', @reshapeData, 'Enable','off'); 
unshapeDataH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.71 0.51 0.27 0.06], 'FontSize', 10, 'String', 'Undo reshape (make 3D) ',...
    'Callback', @unshapeData, 'Enable','off'); 


alignCSFramesH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.40 0.65 0.08], 'FontSize', 14, 'String', 'Align frames by CS onset',...
    'Callback', @alignCSframes, 'Enable','off');
alignCSFramestxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.71 0.46 0.27 0.03], 'FontSize', 11,'String', 'Delay to CS onset (sec)');
alignCSFramesnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.71 0.41 0.27 0.05], 'FontSize', 14); 



timepointMeansH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.30 0.55 0.08], 'FontSize', 13, 'String', 'Compute same-timepoint means ',...
    'Callback', @timepointMeans, 'Enable','off');

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
              
CSUSpopupH = uicontrol('Parent', IPpanelH,'Style', 'popup',...
                  'Units', 'normalized', 'String', {'CS','US'},...
                  'Position', [0.65 0.31 0.34 0.05],...
                  'Callback', @CSUSpopup);

              
              
getROIstatsH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.20 0.65 0.08], 'FontSize', 14, 'String', 'Compute ROI statistics ',...
    'Callback', @getROIstats, 'Enable','off');               


openImageJH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.02 0.45 0.08], 'FontSize', 14, 'String', 'Open stack in ImageJ ',...
    'Callback', @openImageJ, 'Enable','off');


runCustomH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.53 0.02 0.45 0.08], 'FontSize', 14, 'String', 'Run Custom Function ',...
    'Callback', @runCustom, 'Enable','off');


% hsl = uicontrol('Style','slider')         




% enableButtons


% -----------------------------------------------------------------
%%                     GUI TOOLBOX FUNCTIONS
% -----------------------------------------------------------------


function grinlenstoolbox(hObject, eventdata)
%Load file triggers uiresume; the initial menu is set to invisible. Prompts
%user for file to load, copies the datastack from the file; sets the image 
%windows to visible, and plots the images.    

    set(initmenuh, 'Visible', 'Off');
    set(mainguih, 'Visible', 'On');
    
    %----------------------------------------------------
    %           SET USER-EDITABLE GUI VALUES
    %----------------------------------------------------
    imgLogo = imread('grinlogo.png');
    set(haxGRIN, 'XLim', [1 size(imgLogo,2)], 'YLim', [1 size(imgLogo,1)]);
    set(smoothimgnumH, 'String', num2str(smoothSD));
    set(cropimgnumH, 'String', num2str(cropAmount));
    set(imgblocksnumH, 'String', num2str(blockSize));
    set(alignCSFramesnumH, 'String', num2str(CSonsetDelay));
    
    
    
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

disp('Ready!')        
end



function enableButtons()
% --- Enable - Disable Buttons ---
% smoothimgH.Enable = 'off';
% cropimgH.Enable = 'off';
% imgblocksH.Enable = 'off';
% dFoverFH.Enable = 'off';
% reshapeDataH.Enable = 'off';
% alignCSFramesH.Enable = 'off';
% timepointMeansH.Enable = 'off';
% getROIstatsH.Enable = 'off';

smoothimgH.Enable = 'on';
cropimgH.Enable = 'on';
imgblocksH.Enable = 'on';
dFoverFH.Enable = 'on';
reshapeDataH.Enable = 'on';
unshapeDataH.Enable = 'on';
alignCSFramesH.Enable = 'on';
timepointMeansH.Enable = 'on';
getROIstatsH.Enable = 'on';
runCustomH.Enable = 'on';

if numel(size(IMG)) > 1 && numel(size(IMG)) < 4;
    openImageJH.Enable = 'on';
else
    openImageJH.Enable = 'off';
end

% --------------------------------- 
end
function disableButtons()
% --- Enable - Disable Buttons ---
smoothimgH.Enable = 'off';
cropimgH.Enable = 'off';
imgblocksH.Enable = 'off';
dFoverFH.Enable = 'off';
reshapeDataH.Enable = 'off';
unshapeDataH.Enable = 'off';
alignCSFramesH.Enable = 'off';
timepointMeansH.Enable = 'off';
getROIstatsH.Enable = 'off';
runCustomH.Enable = 'off';
openImageJH.Enable = 'off';

% smoothimgH.Enable = 'on';
% cropimgH.Enable = 'on';
% imgblocksH.Enable = 'on';
% dFoverFH.Enable = 'on';
% reshapeDataH.Enable = 'on';
% alignCSFramesH.Enable = 'on';
% timepointMeansH.Enable = 'on';
% getROIstatsH.Enable = 'on';
% --------------------------------- 
end



% POPUP MENU CALLBACK
function CSUSpopup(hObject, eventdata)

    if numel(GRINtable) > 0 
        disp('reminder of CS/US combos...')
        GRINtable(1:7,1:2)
        % GRINstruct
    end
        
    stimnum = CSUSpopupH.Value;

    % CSUSvals = unique(GRINstruct.csus);
    % set(CSUSpopupH, 'String', CSUSvals);

end




% RADIO BUTTON CALLBACK
function stimselection(source,callbackdata)
        
    % strcmp(stimtypeh.SelectedObject.String,'CSxUS')
    stimtype = stimtypeh.SelectedObject.String;
    
    display(['Previous Stim: ' callbackdata.OldValue.String]);
    display(['Current Stim: ' callbackdata.NewValue.String]);
    display('------------------');

end










function importimgstack(hObject, eventdata)
    
    if imgfilename
        disp('image stack path was set manually')
    else
        [imgfilename, imgpathname] = uigetfile({'*.tif*'},...
        'Select image stack to import', thisfilepath);        
    end
    
    % keyboard
    
    
    if xlsfilename
        disp('xls data path was set manually')
    else
    
        if numel(imgfilename) == 16

            xlsFiles = dir([imgpathname, imgfilename(1:end-5) '*.xls*']);

        elseif numel(imgfilename) == 15

            xlsFiles = dir([imgpathname, imgfilename(1:end-4) '*.xls*']);

        end

        if numel(xlsFiles) == 1

            choice = questdlg({'Matching xls file found.', 'Would you like to import:',...
                               xlsFiles.name}, ...
                               'Import XLS file', ...
                               'Yes','No (import manually)','Yes');
            switch choice
                case 'Yes'
                    disp([choice ' importing xls data...'])
                    xlsfilename = xlsFiles.name;
                    xlspathname = imgpathname;
                case 'No (import manually)'
                    [xlsfilename, xlspathname] = uigetfile({'*.xls*'},...
                    'Select Excel file associated with the TIF stack', imgpathname);
            end

        end
    
    end
    
    
    
    % ------------- IMG STACK IMPORT CODE -----------
    grinano('import',[imgpathname , imgfilename])

    FileTif=[imgpathname , imgfilename];
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
    disp('Image stack sucessfully imported!') 
    
    axes(haxGRIN)
    colormap(haxGRIN,parula)
    phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);
              pause(1)
    
    
              
              
              
              
    % ------------- XLS IMPORT CODE -----------
    grinano('importxls',[xlspathname , xlsfilename])

    [xlsN,xlsT,xlsR] = xlsread([xlspathname , xlsfilename]);

    disp(xlsR(1:5,1:7))

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

    disp('XLS data successfully imported and processed!')
    grinano('xlsparams',total_trials, framesPerTrial, secPerFrame, framesPerSec, secondsPerTrial)

    % CREATE ID FOR EACH UNIQUE CS+US COMBO AND DETERMINE ROW 
    [GRINstruct, GRINtable] = gettrialtypes(total_trials, CS_type, US_type, framesPerTrial);


    disp('GRINstruct contains the following structural arrays:')
    disp('{  Example usage: GRINstruct.tf(:,1)  }')
    disp(GRINstruct)

    disp('GRINtable includes the following columns:')
    disp(GRINtable(1:10,:))

    
   
        
     CSUSvals = unique(GRINstruct.csus);
     set(CSUSpopupH, 'String', CSUSvals);
    
    
    
enableButtons
disp('Image stack and xls data import completed!')
end




function smoothimg(boxidselecth, eventdata)
disableButtons; pause(.02);

    % PERFORM IMAGE SMOOTHING
    disp('PERFORMING IMAGE SMOOTHING')

    
    smoothSD = str2num(smoothimgnumH.String);
    % smoothHeight = .8;
    % smoothWidth = 9;
    % smoothSD = .16;
    % smoothRes = .1;
    

    % GRINmask([PEAK HEIGHT] [WIDTH] [SLOPE SD] [RESOLUTION] [doPLOT])
    % Mask = GRINkernel(.8, 9, .14, .1, 1);
    Mask = GRINkernel(smoothHeight, smoothWidth, smoothSD, smoothRes, 1);
    pause(.5)
    % IMGmsk = IMG(:,:,1);
    % IMGmsk(1:size(Mask),1:size(Mask)) = Mask;
    % figure; imagesc(IMGmsk);
    
    

    IMGc = convn( IMG, Mask,'same');


        % VISUALIZE AND ANNOTATE
        GRINcompare(IMG, IMGc, previewNframes)
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
    
    IMG = IMGc;

        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);


enableButtons        
disp('Image smoothing completed!')
end







function cropimg(boxidselecth, eventdata)
disableButtons; pause(.02);

    % TRIM EDGES FROM IMAGE
    disp('TRIMMING EDGES FROM IMAGE')
    
    
    cropAmount = str2num(cropimgnumH.String);

    IMGt = IMG((cropAmount+1):(end-cropAmount) , (cropAmount+1):(end-cropAmount) , :);

        % VISUALIZE AND ANNOTATE
        grinano('trim',IMG,IMGt)
        % fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        % fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGt)));
        GRINcompare(IMG, IMGt, previewNframes)
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
    
    IMG = IMGt;
    
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        
enableButtons        
disp('Crop Images completed!')
end






function imgblocks(boxidselecth, eventdata)
disableButtons; pause(.02);

    % CREATE ROBERT BLOCK PROC
    disp('SEGMENTING IMGAGES INTO BLOCKS (blockproc could take a few seconds)')

    blockSize = str2num(imgblocksnumH.String);
    
    
    
    fun = @(block_struct) mean(block_struct.data(:)) * ones(size(block_struct.data)); 

    IMGb = zeros(size(IMG));

    sz = size(IMG,3);
    progresstimer('Segmenting images into blocks...')
    % hwb = waitbar(0,'Segmenting image into tiles...');
    for nn = 1:sz

        IMGb(:,:,nn) = blockproc(IMG(:,:,nn),[blockSize blockSize],fun);
        
        if ~mod(nn,100)
            % waitbar(nn/sz)
            progresstimer(nn/sz)
        end
    
    end
    
        % close(hwb)
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGb)));
        GRINcompare(IMG, IMGb, previewNframes)
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
    
    IMG = IMGb;

        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        
enableButtons        
disp('Block-Segment Images completed!')        
end







function dFoverF(boxidselecth, eventdata)
disableButtons; pause(.02);

    % COMPUTE dF/F FOR ALL FRAMES
    disp('COMPUTING dF/F FOR ALL FRAMES')
    
    % As a shortcut and to retain the original frame number I am using
    % circshift to move the first image to the end of the image matrix

    % im = circshift( IMG , -1 ,3);
    % IMGf = (im - IMG) ./ im;
    % IMGf(:,:,end) = IMGf(:,:,end-1); % this just duplicates the last frame
        
    im = repmat(mean(IMG,3),1,1,size(IMG,3));
    IMGf = (IMG - im) ./ im;
    
    

    
    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGf)));
        GRINcompare(IMG, IMGf, previewNframes, [.98 1.05], [8 2])
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
    
    IMG = IMGf;
    
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        
enableButtons        
disp('dF/F computation completed!')
end





function reshapeData(boxidselecth, eventdata)
disableButtons; pause(.02);

    % RESHAPE IMAGE STACK INTO SIZE: YPIXELS by XPIXELS in NFRAMES per NTRIALS

    
    IMGr = reshape(IMG,size(IMG,1),size(IMG,2),framesPerTrial,[]);
        
    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGr)));
    
    IMG = IMGr;
        
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);


enableButtons
disp('Reshape stack by trial completed!')
end



function unshapeData(boxidselecth, eventdata)
disableButtons; pause(.02);

    % RESHAPE IMAGE STACK INTO SIZE: YPIXELS by XPIXELS in NTOTALFRAMES
    
    IMGr = reshape(IMG,size(IMG,1),size(IMG,2),[]);
        
    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGr)));
    
    IMG = IMGr;
        
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);


enableButtons
disp('Undo reshape (make 3D) completed!')
end










function alignCSframes(boxidselecth, eventdata)
disableButtons; pause(.02);

    % MAKE DELAY TO CS EQUAL TO t SECONDS FOR ALL TRIALS

    % Make all CS onsets this many seconds from trial start
    CSonsetDelay = str2num(alignCSFramesnumH.String);

    EqualizeCSdelay  = round((delaytoCS-CSonsetDelay) .* framesPerSec);

    IMGe = IMG;
    for nn = 1:size(IMG,4)

        IMGe(:,:,:,nn) = circshift( IMGe(:,:,:,nn) , -EqualizeCSdelay(nn) ,3);

    end
    
    
    
    % DETERMINE FIRST AND LAST FRAME FOR CS / US FOR EACH TRIAL
    CSonset  = round(CSonsetDelay .* framesPerSec);                % CS first frame in trial
    CSoffset  = round((CSonsetDelay+CS_length) .* framesPerSec);   % CS last frame in trial
    USonset  = round((CSonsetDelay+CS_length+1) .* framesPerSec);  % US first frame in trial
    USoffset  = round((CSonsetDelay+CS_length+2) .* framesPerSec); % US last frame in trial
    CSUSonoff = [CSonset CSoffset USonset USoffset];
    fprintf(['\n\n (in frames)...\n   CSon: % 6.1d \n   CSoff: % 5.1d ',...
             '\n   USon: % 6.1d \n   USoff: % 5.1d '],CSUSonoff);
    
    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGe)));
    
    IMG = IMGe;
    
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        
enableButtons
disp('Align frames by CS onset completed!')
end




function timepointMeans(boxidselecth, eventdata)
disableButtons; pause(.02);    
    
    
    % AVERAGE ACROSS SAME TIMEPOINTS
    nCSUS = size(GRINstruct.tf,2);
    szIMG = size(IMG);
    
    % Check that input is 4D
    if numel(szIMG) ~= 4
        ms = {'Stack must be 4D to compute timepoint means',...
              ['Stack is currently: ' num2str(szIMG)]};
        msgbox(ms, 'invalid stack size','custom',imgLogo(80:140,60:120,:));
        return
    end
    
    
    
    % Perform averaging for each (nCSUS) unique trial type
    % This will create a matrix 'muIMGS' of size [h,w,f,nCSUS]
    muIMGS = zeros(szIMG(1), szIMG(2), szIMG(3), nCSUS);
    for tt = 1:nCSUS
        im = IMG(:,:,:,GRINstruct.tf(:,tt));
        muIMGS(:,:,:,tt) = squeeze(mean(im,4));
    end


    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix retains size: % s ', num2str(size(IMG)));
        fprintf('\n muIMGS matrix is now size: % s \n\n', num2str(size(muIMGS)));
        GRINcompare(IMG, muIMGS, previewNframes)
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
        disp('Done!')
    
    % IMG = IMGf;
    
        axes(haxGRIN)
        phGRIN = imagesc(muIMGS(:,:,1,1) , 'Parent', haxGRIN);

enableButtons        
disp('Compute same-timepoint means completed!')
end











function getROIstats(boxidselecth, eventdata)
disableButtons; pause(.02);
    
    % PREVIEW AN ROI FOR A SINGLE TRIAL AVERAGED OVER TRIALS

    fh1=figure('Units','normalized','OuterPosition',[.40 .22 .59 .75],'Color','w');
    hax1 = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[]);

    ih1 = imagesc(muIMGS(:,:,1,1));

    disp('Use mouse to trace around a region of interest on the figure.')
    hROI = imfreehand(hax1);   
    ROIpos = hROI.getPosition;
    ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));


    ROImask = hROI.createMask(ih1);
    
    ROI_INTENSITY = muIMGS(:,:,1,1) .* ROImask;
    figure; imagesc(ROI_INTENSITY); colorbar;




    % Here we are computing the average intensity for the selected ROI
    % N.B. here it is assumed that a pixel value (actually dF/F value)
    % has virtually a zero probability of equaling exactly zero; this
    % allows us to multiply the mask T/F matrix by the image matrix
    % and disclude from the average all pixels that equal exactly zero
    
    ROImu = zeros(size(muIMGS,4),size(muIMGS,3));
    for mm = 1:size(muIMGS,4)
        for nn = 1:size(muIMGS,3)
        
        ROI_INTENSITY = muIMGS(:,:,nn,mm) .* ROImask;
        ROImu(mm,nn) = mean(ROI_INTENSITY(ROI_INTENSITY ~= 0));

        end
    end

    CSUSplot(ROImu', GRINstruct);
    % CSUSplot(ROImu', GRINstruct, CSUSonoff);
    % previewstack(squeeze(muIMGS(:,:,:,1)), CSUSonoff, ROImu)
    
    
enableButtons
disp('Compute ROI statistics completed!')
end












function openImageJ(boxidselecth, eventdata)
disableButtons; pause(.02);

    % TRIM EDGES FROM IMAGE
    disp('LAUNCHING ImageJ!')
    
    % tifimg = IMG;
    matfiji(IMG)
        

    
%{    
% ----------------------------------------
    [str,maxsize,endian] = computer;


if strcmp(str,'PCWIN') || strcmp(str,'PCWIN64')
    
    javaaddpath 'C:\Program Files\MATLAB\R2014b\java\jar\mij.jar'
    javaaddpath 'C:\Program Files\MATLAB\R2014b\java\jar\ij.jar'
    MIJ.start('E:\Program Files (x86)\ImageJ')
    MIJ.setupExt('E:\Program Files (x86)\ImageJ');


    % strr1=strcat('open=[Y:\\ShareData\\LABMEETINGS\\Steve\\GRIN lens data\\RM\\*.tif] starting=1 increment=1 scale=100 file=Ch2 or=[] sort');
    % MIJ.run('Image Sequence...', strr1); %works!! will generate tif stack in imageJ

    MIJ.createImage('result', IMG, true);
    
end


if strcmp(str,'MACI64')
    
    javaaddpath '/Applications/MATLAB_R2014b.app/java/jar/mij.jar';
    javaaddpath '/Applications/MATLAB_R2014b.app/java/jar/ij.jar';
    MIJ.start('/Applications/Fiji');
    MIJ.setupExt('/Applications/Fiji');
    
    % strr1=strcat('open=[/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/031016_gc33_green_keep.tif]');
    % MIJ.run('Image Sequence...', strr1); %works!! will generate tif stack in imageJ
    
    MIJ.createImage('result', IMG, true);
    
end
% ----------------------------------------    
%}    
    
    
GRINtoolboxGUI    
return
enableButtons        
disp('ImageJ (FIJI) processes completed!')
end



function runCustom(boxidselecth, eventdata)
disableButtons; pause(.02);

    % TRIM EDGES FROM IMAGE
    disp('RUNNING YOUR CUSTOM FUNCTION!')
    
    
    grincustom(IMG, GRINstruct, GRINtable, customFunOrder)

        
enableButtons        
disp('Run custom function completed!')
end














% --------  FUNCTIONS IM CONSIDERING  ----------

function motioncorrection(hObject, eventdata)
   msgbox('Coming Soon!'); 
   return
   
   %===============================================
%% MOTION Stabilization
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
                        

% Create object to display the original video and the stabilized video.
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
pos.search_border = [10 10];        % max horizontal and vertical displacement

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

    % Add black border for display
    Stabilized(:, BorderCols) = minmin;
    Stabilized(BorderRows, :) = minmin;

    TargetRect = [pos.template_orig-Offset, pos.template_size];
    SearchRegionRect = [SearchRegion, pos.template_size + 2*pos.search_border];

    % Draw rectangles on input to show target and search region
    input = insertShape(input, 'Rectangle', [TargetRect; SearchRegionRect],...
                        'Color', 'white');
    % Display the offset (displacement) values on the input image
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




% function mainGUIclosereq(src,callbackdata)
%{
function mainGUIclosereq(src,callbackdata)

whoIsTryingToClose = callbackdata.Source.Name;
disp(whoIsTryingToClose)

    if strcmp(whoIsTryingToClose,'mainGUIwindow')

       selection = questdlg('Close This Figure?',...
          'Close Request Function',...
          'Yes','No','Yes'); 
       switch selection, 
          case 'Yes',
             delete(gcf)
          case 'No'
          return 
       end
       
    else
        
        return

    end
   
end
%}
% ------------------------------------------












% --------  COMPILE  ~  LOAD  ~  SAVE  ----------

% TBD






% --------  TEMPORARY NOTES AND OTHER GARBAGE  ----------

% FUNCTIONS FROM A SIMILAR GUI
%{
function getROI(boxidselecth, eventdata)

    ROInum = str2num(boxidh.String);

    lftthresholdMIN = str2double(lftthresholdMINh.String);
    lftthresholdMAX = str2double(lftthresholdMAXh.String);
        
    intPminmax = prctile(intensity(:),...
        [str2double(intThreshMin.String) str2double(intThreshMax.String)]);
    
    chimin = str2double(chiminh.String);
    chimax = str2double(chimaxh.String);
    
    
    if strcmp(stimtypeh.SelectedObject.String,'rectangle')
        
        hROI = imrect(haxFLIM);
        
        ROIpos = hROI.getPosition;
        
        ROIarea = ROIpos(3) * ROIpos(4);
        
    elseif strcmp(stimtypeh.SelectedObject.String,'elipse')
        
        hROI = imellipse(haxFLIM);
        
        ROIpos = hROI.getPosition;
        
        ROIarea = pi * (.5*ROIpos(3)) * (.5*ROIpos(4));
        
    elseif strcmp(stimtypeh.SelectedObject.String,'stamp')
        
        % [x,y] = FLIMginput(2,'custom');

        hROI = impoint;
        ROIpos = hROI.getPosition;
        delete(hROI)
        hROI = imellipse(haxFLIM, [ROIpos-round(stampSize/2) stampSize stampSize]);
        
        ROIarea = pi * (stampSize/2)^2;
        
    else % strcmp(stimtypeh.SelectedObject.String,'freehand')
        
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
            haxGRIN.XLim = haxGRIN.XLim+20;
            haxCCDR.XLim = haxCCDR.XLim+20;
            haxFLIM.XLim = haxFLIM.XLim+20;
        end
        
        if strcmp(mainguih.CurrentCharacter,'s')
            haxGRIN.XLim = haxGRIN.XLim-20;
            haxCCDR.XLim = haxCCDR.XLim-20;
            haxFLIM.XLim = haxFLIM.XLim-20;
        end
        
        if strcmp(mainguih.CurrentCharacter,'e')
            haxGRIN.YLim = haxGRIN.YLim+20;
            haxCCDR.YLim = haxCCDR.YLim+20;
            haxFLIM.YLim = haxFLIM.YLim+20;
        end
        
        if strcmp(mainguih.CurrentCharacter,'d')
            haxGRIN.YLim = haxGRIN.YLim-20;
            haxCCDR.YLim = haxCCDR.YLim-20;
            haxFLIM.YLim = haxFLIM.YLim-20;
        end
        
        
        % --- RESET ZOOM & PAN ---
        
        if strcmp(mainguih.CurrentCharacter,'0')
            zoom out
            zoom reset
            haxGRIN.XLim = imXlim;
            haxGRIN.YLim = imYlim;
            haxCCDR.XLim = imXlim;
            haxCCDR.YLim = imYlim;
            haxFLIM.XLim = imXlim;
            haxFLIM.YLim = imYlim;
        end
        
        
end



function boxselection(source,callbackdata)
    
    % callbackdata.OldValue.String
    % stimtypeh.SelectedObject.String
    % stimtype = callbackdata.NewValue.String;
    
    display(['Previous: ' callbackdata.OldValue.String]);
    display(['Current: ' callbackdata.NewValue.String]);
    display('------------------');

end



function getStampSize(boxidselecth, eventdata)
    
    stampSize = stampSizeH.String;

   disp(['Stamp size is now:' num2str(stampSize)])

end

%}
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
%{
function grinlenstoolbox(hObject, eventdata)
%Load file triggers uiresume; the initial menu is set to invisible. Prompts
%user for file to load, copies the datastack from the file; sets the image 
%windows to visible, and plots the images.    

    set(initmenuh, 'Visible', 'Off');
    set(mainguih, 'Visible', 'On');
    
    
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
    set(haxGRIN, 'XLim', [1 size(imgG,2)], 'YLim', [1 size(imgG,1)]);
    % set(haxGRIN, 'YLim', [1 ydim]);
    set(haxCCDR, 'XLim', [1 size(imgR,2)], 'YLim', [1 size(imgR,1)]);
    % set(haxCCDR, 'YLim', [1 ydim]);
    set(haxFLIM, 'XLim', [1 xdim]);
    set(haxFLIM, 'YLim', [1 ydim]);
    
    
    set(stampSizeH, 'String', num2str(stampSize));
    stimtypeh.SelectedObject = stimtypeh4; % Set radiobutton to stamp
    % stimtype = stimtypeh.SelectedObject.String;
    %----------------------------------------------------
    
    
    
    
    %----------------------------------------------------
    %                   DRAW IMAGE
    %----------------------------------------------------
    
    axes(haxGRIN)
    colormap(haxGRIN,hot)
    phGRIN = imagesc(imgG , 'Parent', haxGRIN);
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



%}


end
%% EOF
