function [GRINstruct, GRINtable] = gettrialtypes(total_trials, CS_type, US_type, framesPerTrial)



% concatinate strings in CS and US columns
csus = cell(total_trials,1);
for nn = 1:total_trials
    
    
csus{nn} = [CS_type{nn} ' ' US_type{nn}];
    
    
end

% find unique CS+US combos
uni_csus = unique(csus);

sz_uni_csus = size(uni_csus,1);
uni_csus_id = [1:sz_uni_csus]';

TblA = table(uni_csus_id,uni_csus);


% disp('    ')
% disp('   Unique CS US combinations')
% disp('     --------------------')
disp(TblA)

GRINstruct.csus = csus;
GRINstruct.id = zeros(total_trials,1);

id = zeros(sz_uni_csus,total_trials);
for mm = 1:sz_uni_csus
    for nn = 1:total_trials
    
        id(mm,nn) = strcmp( GRINstruct.csus{nn} , uni_csus{mm} );

    end
end
id = id';

GRINstruct.tf = id>0;

for mm = 1:sz_uni_csus
    
    ids = id(:, mm);
    
    ids(ids == 1) = mm;
    
    
    id(:, mm) = ids;

end

sid = sum(id,2);
GRINstruct.id = sid;


Fend = framesPerTrial .* [1:total_trials];
Fstart = Fend - framesPerTrial + 1;
FrameRange = [Fstart' Fend'];
GRINstruct.fr = FrameRange;


frm = zeros(size(GRINstruct.fr,1),GRINstruct.fr(1,2))';
for nn = 1:numel(frm)
    
    frm(nn) = nn;
    
end
frm = frm';

GRINstruct.frames = frm;

GRINtable = table(GRINstruct.csus,GRINstruct.id,GRINstruct.tf,GRINstruct.fr,GRINstruct.frames,...
    'VariableNames',{'CSUS' 'ID' 'TF' 'FrameRange' 'AllFrames'});


% disp('TRIALTYPE.csus'); disp(GRINstruct.csus(1:5))
% disp('TRIALTYPE.id'); disp(GRINstruct.id(1:5))
% disp('TRIALTYPE.tf'); disp(GRINstruct.tf(1:5,:))
% disp('TRIALTYPE.fr'); disp(GRINstruct.fr(1:5,:))
% disp('TRIALTYPE.frames'); disp(GRINstruct.frames(1:5,:))

% disp(GRINtable(1:7,:))


end


















