function index = getIndex(featureData,varargin)
% GETINDEX takes featureData and key+value pairs, return valid index for
%    microplate wells. The key must be a string, the value can be single number, a 
%    string, a numeric vector, or a cell array of strings, depending on the data
%    type stored in the specific field of featureData
%    Example:
%        ind = getIndex(fea,'plate',1,'control','sample');
%        ind = getIndex(fea,'plate',1,'conc',[1 2],'control',{'sample','media'});

% Authors: Ce Gao
% Created: 2013-05-30
% Revised:
% Toolbox: microplate_parser v1


%% input check
n = length(varargin);
assert( mod(n,2) == 0, 'Incomplete key/value pairs in getIndex!');

%% iterate all conditions
m = featureData.metaData.nTotalWells;
index = true(m,1);
for i  = 1:2:n
    index = index & compValue(varargin{i},varargin{i+1}); 
    % note short circuit && doesn't work on arrays
end

%%
    function ind = compValue(key,value)
        % nested function using global variable condition and nTotalWells
        if isfield(featureData,key)
            if isnumeric(value)
                inds = bsxfun(@eq,featureData.(key),value(:)');
                ind = any(inds,2);
            elseif iscell(value) % cellstr array
                % note the getIndex(fea, 'control', {'sample', 'media'}) could
                % be coded in 2 ways below, the 1st is faster. if the value is a
                % single string, it is almost the same
                % 1
                inds = true(m,length(value));
                for k = 1:length(value)
                    inds(:,k) = strncmp(featureData.(key),value(k),4);
                end
                ind = any(inds,2);
                % 2
                % ind = ismember(featureData.(key),value);
            else %character
                ind = strncmp(featureData.(key),value,4);
            end
        else
            error('Invalid field for featureData');
        end
    end % end of nested function

end % end of primary function getIndex
