%% getoddxls.m
clc; clear; close all;

% ------------- IMG STACK IMPORT CODE -----------


[imgfilename, imgpathname] = uigetfile({'*.tif*'}, 'Select TIF stack');
imgfullpath = [imgpathname , imgfilename];


fprintf('\n Importing tif stack from...\n % s \n', imgfullpath);

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

phGRIN = imagesc(IMG(:,:,1));
          pause(1)

IMGraw = IMG(:,:,1);

szIMG = size(IMG);

RSmx = 1:540*2:540*6*2;
REmx = RSmx+540-1;
Rmx = [RSmx; REmx]';

RCmx = [];
for nn = 1:6
    
    RCmx = [RCmx Rmx(nn,1):Rmx(nn,2)];

end

IMG(:,:,RCmx) = [];

szIMG = size(IMG);

% imwrite(IMG,'myMultipageFile.tif');
% imwrite(im2,'myMultipageFile.tif','WriteMode','append')

imgdata = uint16(IMG);

clear tagstruct t

newtifname = [imgpathname , imgfilename(1:end-4) 'go.tif'];

t = Tiff(newtifname, 'w');

tagstruct.ImageLength = size(imgdata,1)
tagstruct.ImageWidth = size(imgdata,2)
tagstruct.Photometric = Tiff.Photometric.MinIsBlack
tagstruct.BitsPerSample = 16
tagstruct.SamplesPerPixel = szIMG(3)
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky
tagstruct.Software = 'MATLAB'
t.setTag(tagstruct)

t.write(imgdata);

t.close();

IMGT = imread(newtifname);

imagesc(IMGT(:,:,1))



IMG(1:5,1:5,1)
IMGT(1:5,1:5,1)

