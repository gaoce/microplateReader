function [OD GFP] = importFun(dataPath,fileName,nWells,nTime)
% importFun import OD, GFP values from data file

% Authors: Ce Gao
% Created: 2013-05-30
% Revised:
% Toolbox: microplate_parser v1

%% Translate '\' to '/', add a trailing '/' in case these is none
dataPath = regexprep(dataPath, '\\', '\/');
dataPath = regexprep(dataPath, '([^\/])$', '$1\/');
% -------------------------------------------------------------------------

%% determine OD or GFP, call readBlock to import data individually
fileID = fopen([dataPath,'/',fileName]);%shared with nested function
tline = fgetl(fileID);

while ischar(tline)
    if isempty(tline)
        tline = fgetl(fileID);
    elseif regexp(tline,'^Read \d:600')     %read OD for Yeast
        OD  = readBlock(2);
    elseif regexp(tline,'^Read \d:590')     %read OD for E.coli
        OD  = readBlock(2);
    elseif regexp(tline,'^Read \d:485')     %read GFP
        GFP = readBlock(2);
    else
        tline = fgetl(fileID);              % skip the rest of the file
    end
end

fclose(fileID);
%% ------------------------------------------------------------------------
% read data
    function block = readBlock(nHeaderLines)
        
        while nHeaderLines > 0 %n is the num of lines skipped
            fgetl(fileID); %skip a line
            nHeaderLines = nHeaderLines - 1;
        end
        
        readings = zeros(nTime, nWells);
        tline = fgetl(fileID);
        i = 1; %line number
%         while ischar(tline) && ~isempty(tline)
        while i <= nTime
            tlineSplit = regexp(tline,'\t','split');
            
            % return if the number block followed by a empty line filled with tabs
            if all(strcmp(tlineSplit,'')); return;end 
            
            nCol = length(tlineSplit);
            switch nCol
                case nWells + 2 % 2 more condition columns in the beginning
                    [~,pos] = textscan(tline,'%s\t%s\t',1);
                    numCell = textscan(tline(pos+1:end),'%f',nWells);
                    readings(i,:)  = cell2mat(numCell)';
                case nWells + 1 % 1 more condition column in the beginning
                    [~,pos] = textscan(tline,'%s\t',1);
                    numCell = textscan(tline(pos+1:end),'%f',nWells);
                    readings(i,:)  = cell2mat(numCell)';
                otherwise
                    error(['Unknown Plate Layout! Check ',fileName]);
            end
            tline = fgetl(fileID);
            i = i + 1;
        end
        block = readings';

    end % end of readBlock
% -------------------------------------------------------------------------
end% end of primary function
