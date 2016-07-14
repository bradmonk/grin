function [] = matfiji()

javaaddpath 'C:\Program Files\MATLAB\R2014b\java\jar\mij.jar'
javaaddpath 'C:\Program Files\MATLAB\R2014b\java\jar\ij.jar'
MIJ.start('E:\Program Files (x86)\ImageJ')
MIJ.setupExt('E:\Program Files (x86)\ImageJ');

strr1=strcat('open=[Y:\\ShareData\\LABMEETINGS\\Steve\\GRIN lens data\\RM\\*.tif] starting=1 increment=1 scale=100 file=Ch2 or=[] sort');
MIJ.run('Image Sequence...', strr1); %works!! will generate tif stack in imageJ


javaaddpath '/Applications/MATLAB_R2014b.app/java/jar/mij.jar';
javaaddpath '/Applications/MATLAB_R2014b.app/java/jar/ij.jar';
MIJ.start('/Applications/Fiji');
MIJ.setupExt('/Applications/Fiji');





strr1=strcat('open=[/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/031016_gc33_green_keep.tif]');
MIJ.run('Image Sequence...', strr1); %works!! will generate tif stack in imageJ


end





%%



















