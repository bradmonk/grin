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
  
          
          
          
%%          
%----------------------------------------------------
%        CROP IMAGES
%----------------------------------------------------


    % TRIM EDGES FROM IMAGE
    disp(' '); disp('TRIMMING EDGES FROM IMAGE')
    
    
    cropAmount = 18;

    IMGt = IMG((cropAmount+1):(end-cropAmount) , (cropAmount+1):(end-cropAmount) , :);

        % VISUALIZE AND ANNOTATE        
        st1 = {'rows(y)';'cols(x)';'frames'};
        sp1 = sprintf('\n  % 34.10s % s % s  \n', st1{1:3});
        sp2 = sprintf('\n Imported image was size: %6.0f %8.0f %8.0f  \n', size(IMG));
        sp3 = sprintf('\n Trimmed image is size: %8.0f %8.0f %8.0f  \n', size(IMGt));
        disp([sp1 sp2 sp3])
        
    
    IMG = IMGt;
          
    clear IMGt
%%

IMGff = IMG(:,:,1);

disp('Sample of first image:')
disp(IMGff(1:10,1:10))

minIMG = min(min(min(IMG)));
maxIMG = max(max(max(IMG)));
muIMG = mean(IMG(:));



disp('Min value:')
disp(minIMG)
disp('Max value')
disp(maxIMG)
disp('Overall average')
disp(muIMG)
disp('')
disp('')
disp('')



% imwrite(IMG,'myMultipageFile.tif');
% imwrite(im2,'myMultipageFile.tif','WriteMode','append')


% uint16 handles values from 0 - 65535 (2^16)
imgdata = uint16(IMG);

clear tagstruct t

newtifname = [imgpathname , imgfilename(1:end-4) '_new.tif'];

t = Tiff(newtifname, 'w');

tagstruct.ImageLength = size(imgdata,1)
tagstruct.ImageWidth = size(imgdata,2)
tagstruct.Photometric = Tiff.Photometric.MinIsBlack
tagstruct.BitsPerSample = 16
tagstruct.SamplesPerPixel = size(IMG,3)
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky
tagstruct.Software = 'MATLAB'
t.setTag(tagstruct)

t.write(imgdata);

t.close();

clearvars -except 'newtifname' 'IMGff'

IMGnew = imread(newtifname);

imagesc(IMGnew(:,:,1))


IMGff(1:5,1:5,1)
IMGnew(1:5,1:5,1)


