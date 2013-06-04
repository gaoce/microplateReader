%% Main
% demo is the wrapper script to conduct the total workflow

% Authors: Ce Gao
% Created: 2013-05-30
% Revised:
% Toolbox: microplate_parser v1

%% 0. Cleaning up
clear;
clc; 
display('Please watch out "OVRFLW" in your files!');
display('It may cause error!');
pause(1);

%% 1. Setup parameters
para.dataPath = './demo/data';
para.plateListFileName = 'Platelist.txt';
para.plateConfFileName = 'Plateconf.txt';

%% 2. Import data
data = importAssayData(para);

%% 3. Analysis
data = normalizeData(data);
data = scoreData(data);

%% 4. Export to CSV
export2CSV(data,'./demo/results/demo');

%%
save('demo.mat','data');
display('done!');
