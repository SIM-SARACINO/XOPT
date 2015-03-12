function [Xbest,fbest,stats,nfit,fgen,lgen,lfit] = genetic(fObj,alg,X0,LB,UB,varargin)
%********************************************************************
% Funcion which 
% fitness
% 
% INPUT  :
% OUTPUT :
%********************************************************************

%% varargin not defined

fprintf(['\n[Initialize genetic algorithm \n',...
        '  N_pop : number of chromosomes ;\n',...
        '  P_cross : cross-over probability (default value = 0.5) ;\n',...
        '  P_mut : mutation probability	(default value = 0.01) ;\n',...
        '  Maxgen : maximum number of generations ;\n',...
        '  elite : No. of best individuals exported in new generations from the older ones \n']) 
%          The option list below is not complete so we suggest you to see "goptions.m"  and  "genetic.m"
%          in ~/.../XOPT/SourceCode for more detailed information.

N_pop = 4
P_cross = 0.5
P_mut = 0.03
Maxgen = 2
elite = 1

fprintf(['\nInitialize bit-number for every configuration variables\n',...
        '  bits_u   :  vector of bit numbers for upper surface points ;\n',...
        '  bits_l	:  vector of bit numbers for lower surface points ;\n',...
        '  bits		:  bit string (all parameters)\n'])
%          Note that the space dimension of the i-th variable is equal to 2^i 

bits_u = [ 8,8 ; 8,8 ; 8,8 ];
bits_l = [ 8,8 ; 8,8 ; 8,8 ];
bits = [ 6,6,4,4,bits_u(:,1)',bits_u(:,2)',bits_l(:,1)',bits_l(:,2)',4,4 ]

% =============================================================================================================
% Remark
%          - The script "goptions.m" sets the default values of the genetic variables (except for those which 
%          have just been assigned), however one can fill the option vector by commentig the line number "197". 
%          
%          - The default stop-criterion is 'bit string affinity' ("BSA") : the default value is 0.9
%          Refer to "goptions.m" and "genetic.m" for more detailed information.
%  ============================================================================================================

fprintf('\nBuild options...\n')
options = goptions([1,0.9,0,0,elite,0,0,0,0,0,N_pop,P_cross,P_mut,Maxgen])
%options=[1,0.9,0,0,elite,0,0,0,0,0,N_pop,P_cross,P_mut,Maxgen];

%% Solve
%  *****
fprintf('call %s...\n',alg)
tstart = tic; % start the clock

switch alg
    case 'sga'
        [Xbest,fbest,stats,nfit,fgen,lgen,lfit] = sga(fObj,X0,options,LB,UB,bits) % run "sga.m"

    %case ...
    %otherwise
    
end

tcomp=toc(tstart); % stop the clock
fprintf('\n tcomp = %.3f\n',tcomp)
