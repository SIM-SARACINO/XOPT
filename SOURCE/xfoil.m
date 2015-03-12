function [cp,cp_u,cp_l,pol] = xfoil(mod,Re,Ma,alpha,file,tag,varargin)
%*****************************************************************************
%
% Description : 
%
%   Make and import data with Xfoil.
%   This  script make a command file to get passed to Xfoil, then calls xfoil 
%   and import data.
% 
% Input :
%
%   file...............:
%   Reynolds...........:
%   alpha..............:
%   max_iter_xfoil:....: 
%   cpmin..............:
%   def................:
%   ...
%   ...
%*******************************************************************************

optional = cell2mat(varargin);

if nargin < 7
    def = 0;
    max_iter_xfoil = 30;
    cpmin = -15;
elseif nargin < 8
    def = optional(1);
    max_iter_xfoil = 30;
    cpmin = -15;
elseif nargin < 9
    def = optional(1);
    max_iter_xfoil = optional(2);
    cpmin = -15;
elseif nargin < 10
    def = optional(1);
    max_iter_xfoil = optional(2);
    cpmin = optional(3);
%elseif ..
end

cod = sprintf('g%dk%d',tag(1)-1,tag(2)); % basename of airfoil coordinates file
file = strcat(cod,'.xy');

%% Generate Xfoil commands
%  ***********************
comandi = {
    'PLOP'      %
    'G F'       %
    ''    
    'LOAD'      % Load coordinate file 
    file    
    cod
    'PANE'
    sprintf(['SAVE ' file]) 
    'Y'  
    'OPER'  
    sprintf('%s',mod)       % Viscid analisis
    sprintf('%e',Re)
    'MACH'
    sprintf('%.3f',Ma)
    'ITER'       % Change max iter to make solution converge 
    sprintf('%d',max_iter_xfoil)
    'CPMI'       % Change cpmin for large analises
    sprintf('%.2f',cpmin)
    'PACC'       % Polar point accumulation enabled
    strcat(cod,'.pol')'% Define save polar file
    ''           % Dump polar file
    'ALFA' 
    sprintf('%.3f',alpha)
    'PACC'  
    'CPWR'  
    strcat(cod,'.cp')	
    ''
    'QUIT'
};

%% Write XFoil commands
%  ********************
fid = fopen(strcat(cod,'.run'),'w+');
if def
    fprintf(fid,'%s\n','Y');
    fprintf(fid,'%s\n',comandi{:});
else
    fprintf(fid,'%s\n', comandi{:});
end

fclose(fid);

%% Run xfoil
%  *********
fid = fopen(strcat(cod,'.log'),'w+');

setenv('GFORTRAN_STDIN_UNIT', '5')  % These statements resolve some 
setenv('GFORTRAN_STDOUT_UNIT', '6') % MCC (matlab compiler) troubles
setenv('GFORTRAN_STDERR_UNIT', '0') % with fortran routine compiled 
                                    % with gfortran. (my spec...
                                    % ..Matlab R2012a, gfortran 4.8.2)
%!xfoil < *.run >> *.log
status = system('xfoil < *.run >> *.log');

while status ~= 0
    pause(1)
end

setenv('GFORTRAN_STDIN_UNIT', '-1')
setenv('GFORTRAN_STDOUT_UNIT', '-1')
setenv('GFORTRAN_STDERR_UNIT', '-1')

fclose(fid);

% %% Read polar data file --> Compute fitnessness function 
% %  Open in sequence all XFoil generated data files and put them in a cell array
% %  *****************************************************************************
[cp,cp_u,cp_l] = read('cp',cod);
pol = read('pol',cod);
