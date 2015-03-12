function [data,data_u,data_l] = read(ext,cod,path)
%********************************************************************
% Funcion which read data files 
% 
% INPUT  :
% OUTPUT :
%********************************************************************

if (nargin > 3) || (nargin < 1)
    error('ERROR : read : invalid number of parameters')
end

if nargin < 3
    file = strcat(cod,'.',ext);
else
    file = strcat(path,'/',cod,'.',ext);
end

fid = -1;
tstart = tic;

while fid == -1
    fid = fopen(file,'r');
    t = toc(tstart);
    if t > 20
        error('ERROR : read : can''t find data or invalid name')
    end
end

data = {};
switch ext
    case {'cp','xy','dat','txt','nfo'}
        
        col = 2;
        data_temp = textscan(fid,repmat('%s ',1,col));
        data_temp = cellfun(@str2double,data_temp,'UniformOutput',false);
        data_temp = cell2mat(data_temp);
        head = sum(isnan(data_temp),1);
        data = data_temp(head+1:end,:);
        d = floor(size(data,1)/2); %!
	data_u = data(1:d,:);
     	data_l = data(d+1:end,:);
     
    case 'pol'
        
        col = 7;
        data_temp = textscan(fid,repmat('%s ',1,col));
        data_temp = cellfun(@str2double,data_temp,'UniformOutput',false);
        data_temp = cell2mat(data_temp); 
        data = data_temp(end,:);
        
    case 'gen'
        
        col = 7;
        data_temp = textscan(fid,repmat('%s ',1,col));
        data_temp = cellfun(@str2double,data_temp,'UniformOutput',false);
        data_temp = cell2mat(data_temp); 
        data = data_temp(6:end,1:6);
        
    otherwise
        error('ERROR : read : invalid file extention')
end
        
fclose(fid);
