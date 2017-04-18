
clc; close all; clear;

[X, Y] = meshgrid(-.5:.1:.5, -.5:.1:.5);
Z = exp( - (15*X.^2 + 15*Y.^2)) .* 100 + 1;

IMGa = padarray(Z,[10 10],1);

IMGb = circshift(IMGa,[0 2]);

IMGdf = (IMGb - IMGa) ./ IMGa;

imagesc(IMGa)
pause(1.5)
caxis manual
hold on
imagesc(IMGb)
pause(1.5)
hold off
imagesc(IMGdf)



%%
clc; close all;

IMGc = IMGa .* 2 - 1;

IMGcdf = (IMGc - IMGa) ./ IMGa;

imagesc(IMGa)
pause(1.5)
caxis manual
hold on
imagesc(IMGc)
pause(1.5)
hold off;
imagesc(IMGcdf)



%%
clc; close all;

imagesc(IMGdf)
pause(1.5)
caxis manual
hold on
imagesc(IMGcdf)
pause(1.5)







