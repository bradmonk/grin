function [varargout] = grincustomB(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, muIMGS, LICK)

%% EXPORT VARIABLES TO WORKSPACE


        checkLabels = {'Save IMG to variable named:' ...
                   'Save GRINstruct to variable named:' ...
                   'Save GRINtable to variable named:' ...
                   'Save XLSdata to variable named:' ...
                   'Save IMGraw to variable named:'...
                   'Save muIMGS to variable named:'...
                   'Save LICK to variable named:'}; 
               
        varNames = {'IMG','GRINstruct','GRINtable','XLSdata','IMGraw','muIMGS','LICK'}; 
        
        items = {IMG,GRINstruct,GRINtable,XLSdata,IMGraw,muIMGS,LICK};
        
        export2wsdlg(checkLabels,varNames,items,'Save Variables to Workspace');


         
%% CALL YOUR CUSTOM FUNCTIONS BELOW

% mycustomfunctioncalls(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, LICK);









varargout = {'IMG'};
end
%% EOF