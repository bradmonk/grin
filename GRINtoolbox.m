%% GRINtoolbox.m - GRIN LENS IMAGING TOOLBOX
clc; close all; clear;
% Change the current folder to the folder of this .m file.
cd(fileparts(which('GRINtoolbox.m')));
disp('WELCOME TO THE GRIN LENS IMAGING TOOLBOX')




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




for nn = 1:size(IMGS,4)
    
    IMGS(:,:,:,nn) = circshift( IMGS(:,:,:,nn) , EqualizerCSdelay(nn) ,3);

end




%% DETERMINE FIRST AND LAST FRAME FOR CS / US FOR EACH TRIAL

CSonset  = round(adjustDelay .* framesPerSec);       % CS first frame in trial

CSoffset  = round((adjustDelay+10) .* framesPerSec);  % CS last frame in trial

USonset  = round((adjustDelay+11) .* framesPerSec);  % US first frame in trial

USoffset  = round((adjustDelay+21) .* framesPerSec);  % US last frame in trial





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


IMG = IMGS(:,:,:,GRINstruct.tf(:,2));
muIMG = squeeze(mean(IMG,4));

size(muIMG)




fh1=figure('Units','normalized','OuterPosition',[.40 .22 .59 .75],'Color','w');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[]);

ih1 = imagesc(muIMG(:,:,1));


hROI = imfreehand(hax1);   
ROIpos = hROI.getPosition;
ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));

    
ROImask = hROI.createMask(ih1);



for nn = 1:size(muIMG,3)


    ROI_INTENSITY = muIMG(:,:,nn) .* ROImask;
    ROImu(nn) = mean(ROI_INTENSITY(ROI_INTENSITY > 0));


end


ph1 = plot(ROImu);
hax1.YLim = [200 400];









%% --------------------  CURRENT STOPPING POINT  ------------------- %

                               keyboard

% ------------------------------------------------------------------ % 
%%




%% -- REMOVE BACKGROUND PIXELS
keyboard

hax2.ZLim
hax1.XLim
hax1.YLim

hist(IMGS{1}(:),20)
hax1.CameraUpVector = [1 0 0];








%% -- RECORD ANIMATION OF IMAGE Z-STACK (SAVES .avi FILE); REPLAY ANIMATION






%% --- PERFORM CONVOLUTION WITH GAUSSIAN FILTER (gGRINs) ---

doConvnFilter = 0;
if doConvnFilter

  % MaskMaker([PEAK HEIGHT] [MASK SIZE] [SLOPE SD] [RESOLUTION] [doPLOT])
  Mask = MaskMaker(2, 8, .1, .1, 1);
  figure
    for nn = 1:numel(GRINs)
        
        gGRINs{nn} = convn(GRINs{nn},Mask,'same');

        imagesc(gGRINs{nn})
            title('smoothed image')
            colormap(bone)
            drawnow
    end
    
    GRINs = gGRINs;
    %---- VIEW RESULTS ----
    figure(fh1); axes(hax1);
    imagesc(GRINs{1})
    colormap(customcmap(1))
    for nT = 1:numel(GRINs)
        imagesc(GRINs{nT});     % PLOT COLORMAP
        mesh(hax2,GRINs{nT});   % PLOT MESH SURF
        view(hax2,[-40 2])
        zlim(hax2,[0 .05])
        title(GRINfils{nT},'Interpreter','none')
        drawnow
        disp(strcat('GRINs{',num2str(nT),'}  :: ' ,GRINfils{nT}))
        pause(.02)
    end
    %----------------------
end




%% -- NORMALIZE DATA TO RANGE: [0 <= DATA <= 1] (nGRINs)

doNormalize = 1;

if doNormalize
    lintrans = @(x,a,b,c,d) (c*(1-(x-a)/(b-a)) + d*((x-a)/(b-a)));

    maxmax=0; minmin=1;
    for mm = 1:numel(GRINs)

        IMGs = GRINs{mm};
        maxIMG = max(max(IMGs));
        minIMG = min(min(IMGs));

        if maxIMG > maxmax
            maxmax = maxIMG;
        end

        if minIMG < minmin
            minmin = minIMG;
        end

    end
    disp(maxmax);
    disp(minmin);


    for mm = 1:numel(GRINs)

        IMGs = GRINs{mm};
        maxIMG = max(max(IMGs));
        minIMG = min(min(IMGs));

        maxsplit = (maxmax + maxIMG) /2;
        minsplit = (minmin + minIMG) /2;

        for nn = 1:numel(IMGs)
            x = IMGs(nn);
            IMGs(nn) = lintrans(x,minsplit,maxsplit,0,1);
        end

        nGRINs{mm} = IMGs;
    end

    GRINs = nGRINs;
    %---- VIEW RESULTS ----
    figure(fh1); axes(hax1);
    imagesc(GRINs{1})
    for nT = 1:numel(GRINs)
        imagesc(GRINs{nT})
        title(GRINfils{nT},'Interpreter','none')
        drawnow
        disp(strcat('GRINs{',num2str(nT),'}  :: ' ,GRINfils{nT}))
        pause(.01)
    end
    %----------------------
end







%% -- PAD GRIN IMAGES USING PADARRAY (pGRINs)

doPADARRAY = 1;
if doPADARRAY

padPx = 10;

for nT = 1:numel(GRINs)

        padra = GRINs{nT};
        pGRINs{nT} = padarray(padra,[padPx padPx],'both');

end

    GRINs = pGRINs;
    %---- VIEW RESULTS ----
    %figure(fh1); axes(hax2);
    imagesc(GRINs{1})
    colormap(customcmap(1))
    for nT = 1:numel(GRINs)
        imagesc(GRINs{nT})
        title(GRINfils{nT},'Interpreter','none')
        drawnow
        disp(strcat('GRINs{',num2str(nT),'}  :: ' ,GRINfils{nT}))
        pause(.01)
    end
    %----------------------
end




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
%% ===============================================





%% TRIM BOARDERS  (tGRINs)

trimPix = 15;

if doPADARRAY
trimPix = trimPix + padPx;
end


for nn = 1:numel(sGRINs)
    qGRIN = sGRINs{nn};
    qGRIN(:,[1:trimPix end-trimPix:end]) = [];
    qGRIN([1:trimPix end-trimPix:end], :) = [];
    qGRINs{nn} = qGRIN;
end

    GRINs = qGRINs;
    %---- VIEW RESULTS ----
    figure(fh1); axes(hax1);
    imagesc(GRINs{1})
    colormap(customcmap(1))
    for nT = 1:numel(GRINs)
        imagesc(GRINs{nT})
        title(GRINfils{nT},'Interpreter','none')
        drawnow
        disp(strcat('GRINs{',num2str(nT),'}  :: ' ,GRINfils{nT}))
        pause(.01)
    end
    %----------------------




%% ESTABLISH ESTIMATE FOR BACKGROUND PIXEL VALUES (GRINs)
close all

%iDUB = dGRINs{1};
doBGsubtraction = 1;
if doBGsubtraction

    doDrawBG = 1;
    % USE MOUSE TO DRAW BOX AROUND BACKGROUND AREA
    if doDrawBG

            fh99 = figure(99);
            set(fh99,'OuterPosition',[400 400 700 700])
            ax1 = axes('Position',[.1 .1 .8 .8]);
        imagesc(GRINs{1});
            colormap(customcmap(1))
            title('USE MOUSE TO DRAW BOX AROUND BACKGROUND AREA')
            % colormap(bone)

            disp('DRAW BOX AROUND A BACKGROUND AREA')
        h1 = imrect;
        pos1 = round(getPosition(h1)); % [xmin ymin width height]

    else
        szBG = size(GRINs{1});
        BGrows = szBG(1);
        BGcols = szBG(2);
        BGr10 = floor(BGrows/10);
        BGc10 = floor(BGcols/10);
        pos1 = [BGrows-BGr10 BGcols-BGc10 BGr10-1 BGc10-1];
    end

    % GET FRAME COORDINATES AND CREATE XY MASK
    MASKTBLR = [pos1(2) (pos1(2)+pos1(4)) pos1(1) (pos1(1)+pos1(3))];

    % Background
    mask{1} = zeros(size(GRINs{1}));
    mask{1}(MASKTBLR(1):MASKTBLR(2), MASKTBLR(3):MASKTBLR(4)) = 1;
    mask1 = mask{1};

  % -- GET MEAN OF BACKGROUND PIXELS & SUBTRACT FROM IMAGE
  for mm = 1:numel(GRINs)

    iDUB = GRINs{mm};
    % GET MEAN OF BACKGROUND PIXELS
    f1BACKGROUND = iDUB .* mask1;
    meanBG = mean(f1BACKGROUND(f1BACKGROUND > 0));
    meanALL = mean(iDUB(:));
    iDUB = iDUB - meanBG;
    iDUB(iDUB <= 0) = 0;
  
    % REMOVE PIXELS BELOW THRESHOLD
    threshPix = iDUB > threshmask;  % logical Mx of pixels > thresh
    bgGRINs{mm} = iDUB .* threshPix;		% raw value Mx of pixels > thresh
    BGmeans(mm) = meanBG;
  end
    GRINs = bgGRINs;
end



%% RECORD ANIMATION OF GRINs_zstack


    writerObj = VideoWriter('GRINst_zstack');
    writerObj.FrameRate = 10;
    open(writerObj);

    figure(50)
    set(gcf,'Renderer','zbuffer');
    imagesc(GRINs{1})
    colormap(customcmap(1))
    axis tight manual
    ax = gca;
    ax.NextPlot = 'replaceChildren';

    for nT = 1:numel(GRINs)

        figure(60)
        imagesc(GRINs{nT})
        colormap(customcmap(1))
        title(GRINfils{nT},'Interpreter','none')
        drawnow

        if createMovie
        MovieFrames(nT) = getframe;
        writeVideo(writerObj,MovieFrames(nT));
        end

        disp(strcat('GRINs{',num2str(nT),'}  :: ' ,GRINfils{nT}))
        pause(.01)

    end
    close(writerObj);


%% DELTA_F / F      (fdGRINs)

doDeltaF = 0;
if doDeltaF

    fdGRIN = {zeros(size(GRINs{1}))};
    for nn = 1:numel(GRINs)-1
        GRINdiff = GRINs{nn+1} - GRINs{nn};
        GRINdf = sqrt(GRINs{nn+1})+(GRINdiff ./ ((GRINs{nn+1} + GRINs{nn})./2)).^2;
        fdGRIN{nn+1} = GRINdf;
    end


    GRINs = fdGRINs;
    %---- VIEW RESULTS ----
    figure(fh1); axes(hax1);
    imagesc(GRINs{1})
    colormap(customcmap(1))
    for nT = 1:numel(GRINs)
        imagesc(GRINs{nT})
        title(GRINfils{nT},'Interpreter','none')
        drawnow
        disp(strcat('GRINs{',num2str(nT),'}  :: ' ,GRINfils{nT}))
        pause(.01)
    end
    %----------------------

end
%%
keyboard





%%