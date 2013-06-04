function wca = importAssayData(para)
% importData is a wrapper funciton incorporating other funcitons to import
%   and annotate data.

% importData is the main funcitons which calls
%       readPlateList: import plate file list
%       readPlateConf: import plate configuration
%       readPlateFile: import intensity readings

% Authors: Ce Gao
% Created: 2013-05-30
% Revised:
% Toolbox: microplate_parser v1

%% primary func: read data and create data struct
display('Start importing data!');
plateSpec   = readPlateList(para);            % read PlateList file
featureData = readPlateConf(plateSpec,para);  % read Plateconf file
assayData   = readPlateFile(featureData);     % assayData, OD and GFP
wca         = struct('assayData',assayData,'featureData',featureData);

end % end of primary func
% ------------------------------------------------------------------------------

%% readPlateList
function plateSpec = readPlateList(para)
% readPlateList reads from Platelist file, return the specifications of 
%   plates in plateSpec, including 
%         file:       file list;
%         plate:      plate type (different due to different layout);
%         replicate:  plate replicate;
%         chemical:   chemical types(so far as number,will be string later).

plateListFileName = para.plateListFileName;
dataPath = parseDataPath(para.dataPath);

% read files, note there is a HeaderLines by def
fid = fopen([dataPath,plateListFileName]);
C = textscan(fid,'%s\t%f\t%f\t%f','HeaderLines',1,'CommentStyle','%');
plateSpec.file      = C{1};
plateSpec.layout    = C{2};
plateSpec.replicate = C{3};
plateSpec.chemical  = C{4}; % chemicals, historically called batch
fclose(fid);

end % end of readPlateList
% ------------------------------------------------------------------------------

%% readPlateConf
function featureData = readPlateConf(plateSpec,para)
% readPlateConf read Plateconf file, create featureData
%   Currently only Well allows regexp

% read Plateconf file
dataPath = parseDataPath(para.dataPath);
fid = fopen([dataPath,para.plateConfFileName]);
C = textscan(fid,'%s%d',1,'delimiter',':','CommentStyle',{'%'});
D = textscan(fid,'%s%d',1,'delimiter',':','CommentStyle',{'%'});
E = textscan(fid,'%s%d',1,'delimiter',':','CommentStyle',{'%'});
nWells      = C{2}; % number of wells on each plate
nLayouts = D{2}; % types of plate
nTimePoints = E{2};

textscan(fid,'%s%s%s%s%s%s',1,'delimiter','\t','CommentStyle',{'%'});
LIST = textscan(fid,'%f%s%s%s%s%f','delimiter','\t','CommentStyle',{'%'});
fclose(fid);

% extract the content in each columns
LAYOUT  = LIST{:,1};
% WELL    = LIST{:,2}; % currently regexp is disabled
CTRL    = LIST{:,3};
GENE    = LIST{:,4};  
PATH    = LIST{:,5};
CONC    = LIST{:,6};

% file, plate, plate-wise replicate, chemical
layout   = repmat(plateSpec.layout,1,nWells)';
repPlate = repmat(plateSpec.replicate,1,nWells)';
chemical = repmat(plateSpec.chemical,1,nWells)';% assume only one chem per plate

featureData.layout   = layout(:);
featureData.repPlate = repPlate(:);
featureData.chemical = chemical(:);

% controlStatus, replicate status for all wells
nPlates = length(plateSpec.file);
nTotalWells = nWells*nPlates;
plates = bsxfun(@plus,zeros(nWells,1),1:nPlates);
featureData.plate = plates(:);
featureData.control   = cell(nTotalWells,1);
featureData.gene      = cell(nTotalWells,1);
featureData.pathway   = cell(nTotalWells,1);
featureData.conc      = zeros(nTotalWells,1); 
% repWell   = zeros(nPlateTypes,nWells);
for i = 1:nPlates
    indWell   = (i-1)*nWells+1:i*nWells;
    indLayout = LAYOUT == plateSpec.layout(i);
    featureData.control(indWell) = CTRL(indLayout);
    featureData.gene(indWell)    = GENE(indLayout);
    featureData.pathway(indWell) = PATH(indLayout);
    featureData.conc(indWell)    = CONC(indLayout);
end


featureData.metaData.dataPath    = dataPath;
featureData.metaData.plateConf   = para.plateConfFileName;
featureData.metaData.plateList   = para.plateListFileName;
featureData.metaData.dataFiles   = plateSpec.file;

featureData.metaData.nPlates     = nPlates;
featureData.metaData.nLayouts    = nLayouts;
featureData.metaData.nWells      = nWells;
featureData.metaData.nTotalWells = nTotalWells;
featureData.metaData.nTimePoints = nTimePoints;
featureData.metaData.timeCreated = clock;
end % end of readPlateConf
% ------------------------------------------------------------------------------

%% readPlateFile
function assayData = readPlateFile(featureData)
% readDataList reads from data from data file, return assayData. 
%   note: importFun is outside the main wrapper function, in case of
%   different input data format 

% Call importFun to read data, revise it if file format is changed
metaData    = featureData.metaData;

nPlates     = metaData.nPlates;
nWells      = metaData.nWells;
nTotalWells = metaData.nTotalWells;
nTimePoints = metaData.nTimePoints;
file        = metaData.dataFiles;
dataPath    = metaData.dataPath;

%
assayData.OD  = zeros(nTotalWells,nTimePoints);
assayData.GFP = zeros(nTotalWells,nTimePoints);

for i = 1:nPlates
    ind = (i*nWells-nWells+1):i*nWells;
    [assayData.OD(ind,:),assayData.GFP(ind,:)] = importFun(dataPath,file{i},nWells,nTimePoints);
end

end % end of readPlateFile
% ------------------------------------------------------------------------------

%% helper function
function dataPath = parseDataPath(dataPath)
% Translate '\' to '/', add a trailing '/' in case these is none

dataPath = regexprep(dataPath, '\\', '\/');
dataPath = regexprep(dataPath, '([^\/])$', '$1\/');
end %end of parseDataPath
