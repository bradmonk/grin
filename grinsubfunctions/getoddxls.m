
clc; clear




% [xlsfilename, xlspathname] = uigetfile({'*.xls*'},...
%                     'Select Excel file associated with the TIF stack');


xlsfilename = 'gc33_110215.xlsx';
xlspathname = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/xlsfiles/old uncorrected excel files/';
xlsfullpath = [xlspathname xlsfilename];








































%%

frame_period = 0.465;

Frames = 540;

TenSecInF = 10 ./ frame_period;
% TenSecInF = [10:20] ./ frame_period

CSonT = [30, 60, 100, 125, 165, 185];
CSonF = CSonT ./ frame_period;

ExtraFrames = Frames - CSonF(end);

CSonDF = CSonF(1);
CSoffDF = [];
for nn = 1:length(CSonT)-1
    
    
    CSonDF(nn+1) = CSonF(nn+1) - CSonF(nn);
    CSoffDF(nn) = CSonDF(nn) + TenSecInF;
    
    
end
CSoffDF(end+1) = CSoffDF(end) + TenSecInF;

floor(CSonDF)



CSbaseDF = CSonDF - TenSecInF;
UStenDF = CSoffDF + TenSecInF;


[CSbaseDF' CSonDF' CSoffDF' UStenDF']



%%



clc; clear

frame_period = 0.465;

Frames = 540;

TenSecInF = 10 ./ frame_period;
% TenSecInF = [10:20] ./ frame_period

CSonT = [30, 60, 100, 125, 165, 185];
CSonF = CSonT ./ frame_period;

ExtraFrames = Frames - CSonF(end);

CSonDF = CSonF(1);
CSoffDF = [];
for nn = 1:length(CSonT)-1
    
    
    CSonDF(nn+1) = CSonF(nn+1) - CSonF(nn);
    CSoffDF(nn) = CSonDF(nn) + TenSecInF;
    
    
end
CSoffDF(end+1) = CSoffDF(end) + TenSecInF;

floor(CSonDF)



CSbaseDF = CSonDF - TenSecInF;
UStenDF = CSoffDF + TenSecInF;


[CSbaseDF' CSonDF' CSoffDF' UStenDF']



CS_base = CSonF-TenSecInF;
CS_on = CSonF;
CS_off = CSonF+TenSecInF;
US_ten = CSonF+TenSecInF+TenSecInF;

EXPmx = [CS_base' CS_on' CS_off' US_ten'];

EXPmx(5,4)





%%



clc; clear

frame_period = 0.465;

Frames = 540;

TenSecInF = 10 ./ frame_period;
% TenSecInF = [10:20] ./ frame_period

CSonT = [30, 60, 100, 125, 165, 185];
CSonF = CSonT ./ frame_period;

ExtraFrames = Frames - CSonF(end);

CSonDF = CSonF(1);
CSoffDF = [];
for nn = 1:length(CSonT)-1
    
    
    CSonDF(nn+1) = CSonF(nn+1) - CSonF(nn);
    CSoffDF(nn) = CSonDF(nn) + TenSecInF;
    
    
end
CSoffDF(end+1) = CSoffDF(end) + TenSecInF;

floor(CSonDF)



CSbaseDF = CSonDF - TenSecInF;
UStenDF = CSoffDF + TenSecInF;


[CSbaseDF' CSonDF' CSoffDF' UStenDF']



CS_base = CSonF-TenSecInF;
CS_on = CSonF;
CS_off = CSonF+TenSecInF;
US_ten = CSonF+TenSecInF+TenSecInF;

EXPmx = [CS_base' CS_on' CS_off' US_ten'];

EXPmx(5,4)






