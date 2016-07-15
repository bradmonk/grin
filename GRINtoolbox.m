%% GRINtoolbox.m - GRIN LENS IMAGING TOOLBOX
clc; close all; clear;
% Change the current folder to the folder of this .m file.
cd(fileparts(which('GRINtoolbox.m')));
disp('WELCOME TO THE GRIN LENS IMAGING TOOLBOX')




%% IMPORT TIF STACK
clc; close all; clear;

filename = 'gc33_032316g.tif';
pathname = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/';
xlsfilename = 'gc33_032316.xlsx';
xlspathname = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/';


% [filename, pathname] = uigetfile({'*.tif*'},'File Selector');
grinano('import',[pathname , filename])


FileTif=[pathname , filename];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
IMG=zeros(nImage,mImage,NumberImages,'double');
 
TifLink = Tiff(FileTif, 'r');
for i=1:NumberImages
   TifLink.setDirectory(i);
   IMG(:,:,i)=TifLink.read();
end
TifLink.close();
disp('!done!')




%% PREVIEW IMPORTED STACK
close all

% IMGg = mat2gray(IMG);
% implay(IMGg);


%% PERFORM IMAGE SMOOTHING
disp('PERFORMING IMAGE SMOOTHING')


% GRINmask([PEAK HEIGHT] [WIDTH] [SLOPE SD] [RESOLUTION] [doPLOT])
Mask = GRINkernel(.8, 9, .14, .1, 1);

IMGc = convn( IMG, Mask,'same');

close all
GRINcompare(IMG, IMGc, 100)




%% TRIM EDGES FROM IMAGE
disp('TRIMMING EDGES FROM IMAGE')

trimAmount = 18;

IMGt = IMGc((trimAmount+1):(end-trimAmount) , (trimAmount+1):(end-trimAmount) , :);

grinano('trim',IMG,IMGt)

close all
GRINcompare(IMG, IMGt, 100)





%% CREATE ROBERT BLOCK PROC
disp('CREATING ROBERT BLOCK PROC (could take a few seconds)')

% CLEAR FROM MEMORY IMAGE STACKS NOT BEING USED
IMG = IMGt;
clear IMGc
clear IMGt


fun = @(block_struct) mean(block_struct.data(:)) * ones(size(block_struct.data)); 

IMGb = zeros(size(IMG));

for nn = 1:size(IMG,3)

    IMGb(:,:,nn) = blockproc(IMG(:,:,nn),[20 20],fun); 

end

close all
GRINcompare(IMG, IMGb, 100)


%{
% % This version is a few seconds faster but less flexible 
% f = @(x) ones(400,1)*mean(x);
% IMGb = zeros(size(IMG));
% for nn = 1:size(IMG,3)
%     IMGb(:,:,nn) = colfilt(IMG(:,:,nn),[20 20],'distinct',f);
% end
%}



% CLEAR FROM MEMORY IMAGE STACKS NOT BEING USED
IMG = IMGb;
clear IMGb


%% COMPUTE dF/F FOR ALL FRAMES
disp('COMPUTING dF/F FOR ALL FRAMES')

% As a shortcut and to retain the original frame number I am using
% circshift to move the first image to the end of the image matrix

im = circshift( IMG , -1 ,3);

IMGf = (im - IMG) ./ im;
IMGf(:,:,end) = IMGf(:,:,end-1);

clear im


close all
GRINcompare(IMG, IMGf, 99, [.98 1.05], [8 2])

% CLEAR FROM MEMORY IMAGE STACKS NOT BEING USED
IMG = IMGf;
clear IMGf


%% IMPORT ASSOCIATED EXCEL DATA

% [xlsfilename, xlspathname] = uigetfile({'*.xls*'},'File Selector');
grinano('importxls',[xlspathname , xlsfilename])

[xlsN,xlsT,xlsR] = xlsread([xlspathname , xlsfilename]);

xlsR(1:5,1:7)
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


grinano('xlsparams',total_trials, framesPerTrial, secPerFrame, framesPerSec, secondsPerTrial)





%% RESHAPE IMAGE STACK INTO SIZE: YPIXELS by XPIXELS in NFRAMES per NTRIALS



IMG = reshape(IMG,size(IMG,1),size(IMG,2),framesPerTrial,[]);

fprintf('\n\n IMG matrix is now size: % 5.0d % 5.0d % 5.0d % 5.0d \n\n', size(IMG));



%% MAKE DELAY TO CS EQUAL TO 10 SECONDS FOR ALL TRIALS

% Here we are going to use circshift() to shift frames for each trial
% from right to left as if they were on a circular timeline. For example...
%
% t = [1 2 3 4 5 6 7 8 9]
%
% circshift(t, -3, 2) 
%
% t = [4 5 6 7 8 9 1 2 3]
%
% except we will be shifting the 3rd dimension because images are 2D, and
% time is the 3rd dim. To do this, set 'adjustDelay' to the number of
% seconds you want to make all CS onsets from the beginning of the trial.
% Basically we will use the known 'delay to CS' from the excel sheet 
% to shift all CS onsets to zero seconds, then add the number of seconds
% specified in 'adjustDelay' to each trial. These time values are converted
% to frames for shifting purposes.


adjustDelay = 10;   % Make all CS onsets this many seconds from trial start

EqualizeCSdelay  = round((delaytoCS-adjustDelay) .* framesPerSec);


for nn = 1:size(IMG,4)
    
    IMG(:,:,:,nn) = circshift( IMG(:,:,:,nn) , -EqualizeCSdelay(nn) ,3);

end




%% DETERMINE FIRST AND LAST FRAME FOR CS / US FOR EACH TRIAL

CSonset  = round(adjustDelay .* framesPerSec);                % CS first frame in trial

CSoffset  = round((adjustDelay+CS_length) .* framesPerSec);   % CS last frame in trial

USonset  = round((adjustDelay+CS_length+1) .* framesPerSec);  % US first frame in trial

USoffset  = round((adjustDelay+CS_length+2) .* framesPerSec); % US last frame in trial


CSUSonoff = [CSonset CSoffset USonset USoffset];


%% CREATE ID FOR EACH UNIQUE CS+US COMBO AND DETERMINE ROW 

% Here we are creating the main CS+US identifiers to use with the image stacks
% that are now in a 4D matrix 'IMG'
%
%     {for example...
%
%     size(IMG)    % 240   240   100    30 
%
%     where each of 30 trials includes 100 of 240x240 images}
%
% with all CS onsets aligned. This identifier will allow us to pull out
% trials from the stack that correspond to a particular CS+US combo.
% Essentially we want the identifier to be a logical array of values for
% each unique CS+US combo to use on the 4th dim of IMG.



[GRINstruct, GRINtable] = gettrialtypes(total_trials, CS_type, US_type, framesPerTrial);




% GRINstruct and GRINtable contain redundant information (just different ways
% to visualze same info) about trial types.
%     GRINstruct.csus:   {30x1 cell}
%     GRINstruct.id:     [30x1 double]
%     GRINstruct.tf:     [30x2 logical]
%     GRINstruct.fr:     [30x2 double]
%     GRINstruct.frames: [30x100 double]


disp('GRINstruct contains the following structural arrays:')
disp('{  Example usage: GRINstruct.tf(:,1)  }')
disp(GRINstruct)

disp('GRINtable includes the following columns:')
disp(GRINtable(1:10,:))







%% AVERAGE ACROSS SAME TRIAL TYPES


nCSUS = size(GRINstruct.tf,2);

muIMGS = zeros(size(IMG,1), size(IMG,2), size(IMG,3), nCSUS);

for tt = 1:nCSUS
        
    im = IMG(:,:,:,GRINstruct.tf(:,tt));
    muIMGS(:,:,:,tt) = squeeze(mean(im,4));

    
end
size(muIMGS)
size(IMG)

% previewstack(mu)
previewstack(squeeze(muIMGS(:,:,:,1)), CSUSonoff)

close all
GRINcompare(IMG, muIMGS, 99)

% CLEAR FROM MEMORY IMAGE STACKS NOT BEING USED
clear im









%% CREATE AN IMAGE MONTAGE

muIMGS(1,1,:) = 0;

IM = squeeze(muIMGS(:,:,1:100));
IM = reshape(IM,size(IM,1),size(IM,2),1,size(IM,3));

close all
fh1=figure('Units','normalized','OuterPosition',[.2 .05 .55 .90],'Color','w');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');

mh = montage(IM,'Size',[10 10]);
colormap(parula)
colorbar

hax1.CLim = [-0.1  0.1];
% hax1.CLimMode = 'auto';

hax2 = axes('Position',[.05 .06 .82 .88],'Color','none');
grid on

% min(min(IMG(:,:,1)))
% max(max(IMG(:,:,1)))

disp('Reminder, frames for CSonset CSoffset USonset USoffset are...')
disp(CSUSonoff)































%% --------------------  CURRENT STOPPING POINT  ------------------- %

                               keyboard

% ------------------------------------------------------------------ % 



%% PREVIEW AN ROI FOR A SINGLE TRIAL AVERAGED OVER TRIALS

fh1=figure('Units','normalized','OuterPosition',[.40 .22 .59 .75],'Color','w');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[]);

ih1 = imagesc(muIMGS(:,:,1,1));


hROI = imfreehand(hax1);   
ROIpos = hROI.getPosition;
ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));

    
ROImask = hROI.createMask(ih1);



for nn = 1:size(muIMGS,3)


    ROI_INTENSITY = muIMGS(:,:,nn,1) .* ROImask;
    ROImu(nn) = mean(ROI_INTENSITY(ROI_INTENSITY > 0));


end


close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .8 .7],'Color','w');
hax1 = axes('Position',[.05 .05 .45 .9],'Color','none','XTick',[]);
hax2 = axes('Position',[.52 .05 .45 .9],'Color','none','NextPlot','replacechildren');

    axes(hax1)
ih1 = imagesc(muIMGS(:,:,1,1));

    axes(hax2)
ph2 = plot(ROImu);
    hax2.YLim = [100 300];
    text(CSUSonoff(1),150,'\uparrow','FontSize',50)
    text(CSUSonoff(1),110,'CS on','FontSize',18,'HorizontalAlignment','center')
    text(CSUSonoff(2),150,'\uparrow','FontSize',50)
    text(CSUSonoff(2),110,'CS off','FontSize',18,'HorizontalAlignment','center')








%% --------------------  CURRENT STOPPING POINT  ------------------- %

                               keyboard

% ------------------------------------------------------------------ % 
%%










%{
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .5 .2],'Color','w');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[],'YTick',[]);

annotation(fh1,'textbox',...
    [0.1 0.1 0.8 0.6],...
    'String','Close this window to continue',...
    'FontSize',36,...
    'FontName','Helvetica',...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);

implay(IMGSG);
uiwait






fh1=figure('Units','normalized','OuterPosition',[.05 .05 .8 .6],'Color','w');
hax1 = axes('Position',[.05 .05 .45 .9],'Color','none','XTick',[],'YTick',[]);
hax2 = axes('Position',[.55 .05 .45 .9],'Color','none','XTick',[],'YTick',[]);


% I = squeeze(IMG(:,:,:,1));


% I = IMGSG(:,:,1);
% J = imadjust(I,stretchlim(I),[]);
% imshow(I), figure, imshow(J)


axes(hax1)
imagesc(IMG(:,:,1))

mx = max(max(IMG(:,:,1)));
mn = min(min(IMG(:,:,1)));

% colormap(customcmap(1))
% for nT = 1:length(IMG)
for nT = 1:20:1000
    % PLOT MESH SURF
    imagesc(IMG(:,:,nT))
    mesh(hax2,IMG(:,:,nT))
    view(hax2,[-40 2])
    zlim(hax2,[mn*.9 mx*1.2])
    
    pause(.1)
end
%----------------------
%}












%% --- PERFORM CONVOLUTION WITH GAUSSIAN FILTER (gGRINs) ---



  % MaskMaker([PEAK HEIGHT] [MASK SIZE] [SLOPE SD] [RESOLUTION] [doPLOT])
  Mask = GRINmask(2, 8, .1, .1, 1);
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