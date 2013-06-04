function wca = normalizeData(wca)
% NORMALIZEASSAYDATA calls OD and GFP normalization function to adjust the
%   background influence of *growth media*. It creates a field in original 
%   input structure array called normalizedData

% Authors: Ce Gao
% Created: 2013-05-30
% Revised:
% Toolbox: microplate_parser v1

%% Initialization
nPlates  = wca.featureData.metaData.nPlates;
concs = unique(wca.featureData.conc);
switch sum(concs < 0)
    case 1
        nConc = length(concs)-1;
    case 0
        nConc = length(concs);
    otherwise
        error('The format of concentration in Plateconf file is wrong!');
end
% copy-on-write below, so there is no memory cost here, for the sake of 
% convenience
assayOD  = wca.assayData.OD; 
assayGFP = wca.assayData.GFP;

wca.normalizedData.OD  = zeros(size(assayOD));
wca.normalizedData.GFP = zeros(size(assayGFP));
%% substract media OD and GFP from sample OD and GFP
display('Start normalizing data!');
for i = 1:nPlates
    for j = 0:nConc-1 % concentration
        ind_sample = getIndex(wca.featureData,'plate',i,'conc',j,'control',{'sample','housekeeping','gfpminus'});
        ind_media  = getIndex(wca.featureData,'plate',i,'conc',j,'control','media');
          
        % OD normalization
        OD_bg = assayOD(ind_media,:);
        OD_bg(OD_bg >= 0.1) = 0.1;
        wca.normalizedData.OD(ind_sample,:) = bsxfun(@minus,assayOD(ind_sample,:),mean(OD_bg));
        
        % GFP
        GFP_bg = assayGFP(ind_media,:);
        wca.normalizedData.GFP(ind_sample,:) = bsxfun(@minus,assayGFP(ind_sample,:),mean(GFP_bg));
    end
end

wca.featureData.metaData.lastModified = clock;
wca.featureData.metaData.lastAccessedBy = 'normalizedAssayData';
