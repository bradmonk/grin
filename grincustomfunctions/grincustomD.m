function [varargout] = grincustomD(IMG, GRINstruct, GRINtable)

%% EXPORT VARIABLES TO WORKSPACE

checkLabels = {'Save IMG to variable named:' ...
               'Save GRINstruct to variable named:' ...
               'Save GRINtable to variable named:'}; 
varNames = {'IMG','GRINstruct','GRINtable'}; 
items = {IMG,GRINstruct,GRINtable};
export2wsdlg(checkLabels,varNames,items,...
             'Save Variables to Workspace');


         
%% CALL YOUR CUSTOM FUNCTIONS BELOW

% mycustomfunctioncalls(IMG,GRINstruct,GRINtable);


end
%% EOF