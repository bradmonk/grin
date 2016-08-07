function [varargout] = grincustomD(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, muIMGS, LICK)

%% EXPORT VARIABLES TO WORKSPACE


%         checkLabels = {'Save IMG to variable named:' ...
%                    'Save GRINstruct to variable named:' ...
%                    'Save GRINtable to variable named:' ...
%                    'Save XLSdata to variable named:' ...
%                    'Save IMGraw to variable named:'...
%                    'Save muIMGS to variable named:'...
%                    'Save LICK to variable named:'}; 
%                
%         varNames = {'IMG','GRINstruct','GRINtable','XLSdata','IMGraw','muIMGS','LICK'}; 
%         
%         items = {IMG,GRINstruct,GRINtable,XLSdata,IMGraw,muIMGS,LICK};
%         
%         export2wsdlg(checkLabels,varNames,items,'Save Variables to Workspace');


         
%% CALL YOUR CUSTOM FUNCTIONS BELOW

% mycustomfunctioncalls(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, LICK);



blocks = squeeze(reshape(muIMGS,size(muIMGS,1),size(muIMGS,2),[],1));

tiles = blocks(1:XLSdata.blockSize:end,1:XLSdata.blockSize:end,:);

pixels = squeeze(reshape(tiles,numel(tiles(:,:,1)),[],XLSdata.sizeIMG(3),size(XLSdata.CSUSvals,1)));

size(muIMGS)
size(blocks)
size(tiles)
size(pixels)


save('gc33mat.mat','tiles','pixels')


varargout = {'tiles'};
return
%%


IMGff = blocks(:,:,5);

disp('Sample of first image:')
disp(IMGff(1:10,1:10))

minIMG = min(min(min(blocks)));
maxIMG = max(max(max(blocks)));
muIMG = mean(blocks(:));



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
imgdata = uint16(blocks);

clear tagstruct t

newtifname = [imgpathname , imgfilename(1:end-4) '_new.tif'];

t = Tiff(newtifname, 'w');

tagstruct.ImageLength = size(imgdata,1)
tagstruct.ImageWidth = size(imgdata,2)
tagstruct.Photometric = Tiff.Photometric.MinIsBlack
tagstruct.BitsPerSample = 16
tagstruct.SamplesPerPixel = size(blocks,3)
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





varargout = {'IMG'};
end
%% EOF