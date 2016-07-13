function [TRIALTYPE] = gettrialtypes(total_trials, CS_type, US_type)



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

disp('the unique CS US combinations are:')
disp(TblA)

TRIALTYPE.csus = csus;
TRIALTYPE.id = zeros(total_trials,1);

id = zeros(sz_uni_csus,total_trials);
for mm = 1:sz_uni_csus
    for nn = 1:total_trials
    
        id(mm,nn) = strcmp( TRIALTYPE.csus{nn} , uni_csus{mm} );

    end
end
id = id';

TRIALTYPE.tf = id>0;

for mm = 1:sz_uni_csus
    
    ids = id(:, mm);
    
    ids(ids == 1) = mm;
    
    
    id(:, mm) = ids;

end

sid = sum(id,2);
TRIALTYPE.id = sid;

disp('TRIALTYPE.csus'); disp(TRIALTYPE.csus(1:5))
disp('TRIALTYPE.id'); disp(TRIALTYPE.id(1:5))
disp('TRIALTYPE.tf'); disp(TRIALTYPE.tf(1:5,:))


Tb = table(TRIALTYPE.csus,TRIALTYPE.id,TRIALTYPE.tf,...
    'VariableNames',{'TT_csus' 'TT_id' 'TT_tf'});
disp(Tb(1:7,:))








end


















