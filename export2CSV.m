function export2CSV(wca,fileName)
% Export the IP result in CSV file and featureData in tabular txt file.

% Authors:  Ce Gao
% Created:  08-09-2012
% Revised:  04-28-2013 => rename
%           05-28-2013 => output OD, GFP as well
% Toolbox:  wca v4

assert(ischar(fileName),'File name must be a string');

% trim the trailing '.csv' if exist
if ( length(fileName) > 4 ) && strcmpi(fileName(end-3:end),'.csv');
    fileName = fileName(1:end-4);
end

disp('Start exporting data!');

%% write numeric data
fRawOd   = [fileName,'_raw_OD',  '.csv'];
fRawGfp  = [fileName,'_raw_GFP', '.csv'];
fNormOd  = [fileName,'_norm_OD', '.csv'];
fNormGfp = [fileName,'_norm_GFP','.csv'];
fIp      = [fileName,'_IP',      '.csv'];
fFeat    = [fileName,'_features','.csv'];

dlmwrite(fRawOd, wca.assayData.OD);
dlmwrite(fRawGfp,wca.assayData.GFP);
dlmwrite(fNormOd,wca.normalizedData.OD);
dlmwrite(fNormGfp,wca.normalizedData.GFP);
dlmwrite(fIp,    wca.scoreData.IP)

%% write feature data (string )
fid = fopen(fFeat,'w');
header = {'plate','repPlate','layout','chemical','conc','control',...
    'gene','pathway'};
fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s\n',header{:});

for i = 1:wca.featureData.metaData.nTotalWells
   fprintf(fid,'%d,%d,%d,%d,%d,%s,%s,%s\n',...
        wca.featureData.plate(i),...
        wca.featureData.repPlate(i),...
        wca.featureData.layout(i),...
        wca.featureData.chemical(i),...
        wca.featureData.conc(i),...
        wca.featureData.control{i},...
        wca.featureData.gene{i},...
        wca.featureData.pathway{i});
end
fclose(fid);

end
