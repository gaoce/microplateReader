function wca = scoreData(wca)
% SCORENORMALIZEDDATA calculates direct scores: P, Q, IP, IQ based on 
% normalized data

% Authors: Ce Gao
% Created: 2013-05-30
% Revised:
% Toolbox: microplate_parser v1

% Get P = GFP./OD, Q = P./P_housekeeping
% IP = P_sample[>0] / P_sample0, IQ = Q_sample[>0] / Q_sample0
display('Start scoring data!');

wca.scoreData.P  = wca.normalizedData.GFP ./ wca.normalizedData.OD;
wca.scoreData.Q  = zeros(size(wca.assayData.GFP));
wca.scoreData.IP = zeros(size(wca.assayData.GFP));
wca.scoreData.IQ = zeros(size(wca.assayData.GFP));

nPlates = wca.featureData.metaData.nPlates;
nConc   = length(unique(wca.featureData.conc)) - 1; % doesn't count "-1", which is cells around the plate edges

for i = 1:nPlates
    ind_sample0 = getIndex(wca.featureData,'plate',i,'conc',0,'control',{'sample','housekeeping','gfpminus'});
    
    for j = 0:nConc-1 % concentration
        ind_sample = getIndex(wca.featureData,'plate',i,'conc',j,'control',{'sample','housekeeping','gfpminus'});
        ind_hk     = getIndex(wca.featureData,'plate',i,'conc',j,'control','housekeeping');

        wca.scoreData.Q(ind_sample,:)  = bsxfun(@rdivide, wca.scoreData.P(ind_sample,:),mean(wca.scoreData.P(ind_hk,:)));    
        wca.scoreData.IP(ind_sample,:) = wca.scoreData.P(ind_sample,:) ./ wca.scoreData.P(ind_sample0,:);
        wca.scoreData.IQ(ind_sample,:) = wca.scoreData.Q(ind_sample,:) ./ wca.scoreData.Q(ind_sample0,:);
    end
end

wca.featureData.metaData.lastModified = clock;
wca.featureData.metaData.lastAccessedBy = 'scoreNormalizedData';
