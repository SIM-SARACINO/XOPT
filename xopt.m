function [Xbest,fbest] = xopt
% 1 configure xopt.m
% 2 configure genetic.m (for EXPERIMENTAL purposes you can set on of 'simplex','sqp','active-set',('interior-point')
			% then fill in the option list (look at the last section of this configuration file))
% 1 $matlab -nojvm -nodisplay   (call matlab without java virtual machine and doesn't open the workspace)
% 2 >> xopt; (call xopt)
% 2' >> [x,f] = xopt; (call xopt and pull output data (best_configuration and best fitness value) out)
%%****************************************************************************
%   XOPT v.1.2.0
%                              input  >>> xopt
%                                      /   |   \
%                                     |    |    |
%                                   geom  fobj solver 
%                                      \   |   /
%                        constraint --> optimizer >> output 
%                                         
%   DESCRIPTION :
%
%   XOPT is an optimization code which embodies the power of genetic
%   algorithms and gradient-based methods to find optimal efficiency
%   of wing sections in subsonic conditions.
%   (Remark: gradient-based approach is only experimental; hybrid
%   schemes will be available in XOPT v.1.3.0.)
%
%   See README in DOC and the SOURCE documentation 
%
%   STRUCTURE   :
%   
%   - xopt.m.....: it's the main airfoil design routine that call the 
%     appropriate functions to set up the optimization problem, call 
%     the optimizer, and export data to text files.
%   - run.m........:
%   - genetic.m....:
%   - goptions.m...:
%   - sga.m........:
%   - gb.m.........:
%   - cst2d.m......:
%   - xfoil.m......:
%   - fobj.m.......:
%   - fconNL.m.....:
%
%   Draft
%   The configuration file here and the genetic one in genetic.m ,  	
%   represent only a 'bit taste' of the dimension and the complexity of the 
%   entire optimization process.    	
%   
%   Contact the Author for any comment, suggestion and issue.
%   Now You can find us on GitHub at https://github.com/SIM-SARACINO/XOPT 
%%****************************************************************************

clc
clear all
close all

%% Arch controll
%  *************
if ispc
    error('**ERROR : system not compatible')
end

%% Preamble
%  ********
fprintf(['***************************\n',...
         '           XOPT            \n',...
         '          v.1.2.0          \n',...
         ' Airfoil Optimization Tool \n',...
         '***************************\n'])

fprintf(['UNIVERSITY of ROMA TRE\n',...
         'Department of Mechanical and Industrial Engineering\n',...
         'Supervisors :    Umberto Iemma.         (Associate Professor)\n',...
         '                 Lorenzo Burghignoli.   (Researcher)\n',...
         '                 Francesco Centracchio. (Researcher)\n',... 
         'Author:  Simone Saracino\n\n']) 

%% Include XOPT in matlab directory path
%  *************************************
addpath('SOURCE') 

%% Set global variables
%  ********************
global N N1 N2
global nu nl
global mis mod 
global solv opt 
global pm par
global Re Ma
global alpha
global max_iter_xfoil
global cpmin

%% Start 
%  *****
fprintf(['Init problem configuration\n',...
         '**************************\n'])

%% Parametric model
%  ****************
pm = 'cst';
fprintf('Parametric model = %s\n',pm)

%% Mach range 
%  **********
mis = 'LowSubsonic'; % Low-Subsonic aerodynamic application 
fprintf('\nMission = %s\n',mis)

%% Viscous-Inviscid analysis
%  *************************
mod = 'visc'; 
fprintf('Potential-Viscous = %s\n',mod)

%% Solver
%  ******
solv = 'xfoil'; % Linear Vortex Panel Method + two integral equations for the BL (*) 
fprintf('Fluid solver = %s\n',solv) 

%% Optimizer
%  *********
opt = 'sga';
% INPUT METHOD :............'sga'
% EXPERIMENTAL METHODs :....'simplex','sqp','active-set',('interior-point')
fprintf('Optimizer algorithm  = %s\n',opt)

%% Distributed computation service
%  *******************************
par = 'work'; % 0 not available
              % 1 available
fprintf('Workstation or cluster  = %s\n',par)

%% Start configuration
%  *******************
fprintf(['\nStart airfoil configuration parameters\n',...
         '**************************************\n'])
fprintf('\nInitialize the chord\n')
%          default value : c = 1 
c = 1 

fprintf(['\nInitialize normalized coordinates of starting airfoil\n',... 
         ' u : upper surface\n',... 
         ' l : lower surface\n',... 
         ' Pu = [xu_1 , zu_1 ; xu_2 , zu_2 ; ......; xu_n , zu_n]\n',...
         ' Pl = [xl_1 , zl_1 ; xl_2 , zl_2 ; ......; xl_m , zl_m]\n'])

% =====================================================================
% Remark
%          - Normalize the airfoil coordinates respect with the chord ;
%          - One-entry configuration is managed (1*) ;
%          - "n" and "m" should be equal (2*) ;
%          - the number of points is arbitrary but two or three-point
%            selection is reasonable for both upper and lower surfaces
% =====================================================================

Pu = [ 0.00932  0.01214 ; 0.21624  0.05810 ; 0.64723  0.04612 ; 0.95248  0.00865 ] # RG15
Pl = [ 0.94748  0.00101 ; 0.66244 -0.01366 ; 0.30221 -0.02762 ; 0.02670 -0.01436 ]

% ==========================================================================================
% Link
%          http://brendakulfan.com/docs/CST5.pdf -> An overview of CST
%          geometric model
%
%          http://aerospace.illinois.edu/m-selig/ads/coord_database.html -> Airfoil database   
% ==========================================================================================

% Compute the number of points placed in [Pu] and [Pl] (3*)
nu = size(Pu,1);
nl = size(Pl,1);

fprintf(['\nInitialize airfoil configuration parameters\n',...
         ' X0 = [Ru,Rl,bu,bl,[Pu],[Pl],dzu,dzl]\n',... 
         ' Ru, Rl	: normalized leading edge radius of curvature\n',... 
         ' bu, bl	: boat-tail angle (rad)\n',...
         ' Pu, Pl	: normalized coordinate matrix\n',...
         ' dzu,dzl	: normalized trailing edge thickness\n'])

X0 = [0.00495,0.00495,0.089,0.0,Pu(:,1)',Pu(:,2)',Pl(:,1)',Pl(:,2)',0.001,-0.001]
%% Use small dz instead of zero thickness ! 

fprintf(['\nInitialize upper and lower bounds\n',...
         ' UB_u  : upper bound-upper surface points ;\n',...
         ' UB_l	 : upper bound-lower ... ;\n',...
         ' LB_u  : lower bound-upper surface poins ;\n',...
         ' LB_l  : lower bound-lower ... ;\n',...
         ' UB    : upper bound (all parameters) ;\n',...
         ' LB    : lower bound (all parameters)\n'])

%% Extended entry data example for upper and lower coordinate bounds         
%UB_u = [ 0.25,0.15 ; 0.55,0.15 ; 0.75,0.10 ];
%LB_u = [ 0.15,0.05 ; 0.45,0.05 ; 0.65,0.02 ];

%UB_l = [ 0.25,-0.05 ; 0.55,-0.04 ; 0.75,-0.01 ];
%LB_l = [ 0.15,-0.10 ; 0.45,-0.08 ; 0.65,-0.02 ];

%% +- 15% 
varP_u = 0.20;
UB_u = Pu+Pu.*varP_u;
LB_u = Pu-Pu.*varP_u;

varP_l = 0.20;
UB_l = Pl+abs(Pl.*varP_l);
LB_l = Pl-abs(Pl.*varP_l);

UB = [ 0.008,0.008,0.15,0.02,UB_u(:,1)',UB_u(:,2)',UB_l(:,1)',UB_l(:,2)',0.0015,-0.0005 ]
LB = [ 0.004,0.004,0.0,-0.10,LB_u(:,1)',LB_u(:,2)',LB_l(:,1)',LB_l(:,2)',0.0005,-0.0015 ]

fprintf(['\nInitialize physical parameters of the flux\n',...
         'dry air\n',...  
         ' - T     : temperature..................K\n',...
         ' - p     : pressure.....................atm\n',...
         ' - rho   : density......................kg*m^(-3)\n',... 
         ' - ni    : cinematic viscosity..........m^2*s^(-1)\n',... 
         ' - R     : specific gas costant.........J*Kg^(-1)*K^(-1)\n',...
         ' - gamma : isoentropic coefficient\n'])

T = 288
p = 1
rho = 1.22 
ni = 1.41*10^(-5)
gamma = 1.4
R = 287.05

fprintf(['\nInitialize XFoil parameters\n',...
         ' N                 : number of panel nodes ;\n',... % max N = 330 (4*)
         ' N1 N2             : cst parameters ;\n',... 
         ' Re                : chord Reynolds number......U*c*nu^(-1) ;\n',...
         ' Ma                : Mach number U*(gamma*R*T)^(-0.5) ;\n',...
         ' alpha             : angle of attack ;\n',...
         ' max_iter_xfoil    : maximum number of viscous iteration* ;\n',...
         ' cpmin             : minimum value of cp axis \n'])
     
N = 80  % Sometimes the starting configuration could be too 'coarse',
	% even though a great number of panel nodes ('80-100' panels), 
	% so the standard procedure provide a second discretization of the 
	% wing section with '160' panels. One could set this value in the xfoil 
	% default file (*.def). We provide you a template file in 'DEF' folder 
	% so it will be simple for you to make a change : infact the 'Npane' component
	% of the array, is just the first. 
	% Now, you make Xfoil read the default file moving that in the workspace
	% ~/../XOPT/ and turning on 'def' parameter (see SOURCE/run.m).

N1 = 0.5
N2 = 1.0

%if c == 1
Re = 0.5E06
%U = Re*ni*c^(-1);
%else    % see XFoil handbook
if c ~= 1
	Rec = Re*c
	Re = Rec;
	%U = Re*ni*c^(-1);
end

U = Re*ni*c^(-1);

Ma = U*(gamma*R*T)^(-0.5)
alpha = 1
max_iter_xfoil = 50
cpmin = -10.0

% ========================================================================================================
% Remark
%          - One can modify the default xfoil-configuration file (.def) in ~/path_to_XOPT/XOPT/def/
%          - Refer to the handbook.txt and the comments of every m-file in ~/path_to_XOPT/XOPT/SourceCode/
%            for more advanced topics.\n'
%          - Look at the XFoil handbook at http://web.mit.edu/drela/Public/web/xfoil/
% ========================================================================================================

%% Call optimizer
%  **************
switch opt
    case {'sga'}
        fprintf('\nlaunch %s configuration...\n',opt)        
        [Xbest,fbest,gen_best,k_best,stats,nfit,fgen,lgen,lfit] = genetic(@run,opt,X0,LB,UB,nu,nl);
        
        
    case {'simplex','sqp','active-set','interior-point'} % experimental !
        
        fprintf('\nlaunch %s configuration...\n',opt)
	fprintf('\nBuild options...\n')

	options = [];
	options = optimset('Algorithm',opt,'Display','iter','MaxFunEvals',1500,...
                    'LargeScale','off','MaxIter',1500,'TolFun',1E-2,'TolCon', 1E-2);

	Cm_max = 0.1;

	%fconP_flag = 1; % turn on the penalty function approach
	
	%% linear constraints Aeqx = beq, Ax < b
	%A = []; b = [];
	%Aeq = []; beq = [];

	%% not linear constraints ceq(x) = 0, c(x) < 0	
	%c = [];
	%ceq = [];
	%% define a function to evaluate the constraint 
	
	%mkdir('X');
	%cod1 = 0; cod2 = 0;

	%fid1=fopen('history.dat', 'w');
	%	fprintf(fid1,['\n\t','XOPT v.1.2.0\n\n',...
        %        	      '\t\tDatabase\n\n',...
	%	              'Re %.3e\tMach %.2f\tAlpha %.3f\t%s\n\n',...
	%	              'x0\t\t Cl\t\tCd\t\tCm\t\tE\t      fitness\n',...
	%	              '--\t     ----------\t    ----------\t    ----------\t    ----------\t    ----------\n'],...
        %                       Re,Ma,alpha,mod);
	%	fclose(fid1);

	%% Solve
	%fprintf('call %s...\n',opt)
    	tstart = tic; % start the clock
    	
    	[Xbest,fbest,exitflag,output] = fmincon(@(x) fobjGb(x,Cm_max),X0,[],[],[],[],[],[],@fconNL,options) 
	%[Xbest,fbest,exitflag,output] = fminsearch(@(x) fobjGb(x,Cm_max),X0)
	%[Xbest,fbest,exitflag,output] = fminunc(@(x) fobjGb(x,Cm_max),X0)	

    	tcomp=toc(tstart); % stop the clock
    	fprintf('\n tcomp = %.3f\n',tcomp/60)	
        
    case {'testGEN','testGB'} % 'testGEN' and 'testGB' integrated routines in next release !
        fprintf('\n%s...launch test ...\n',opt)
        
        if strcmp(opt,'testGEN')
        %    [Xbest,fbest,stats,nfit,fgen,lgen,lfit,BSA] = genetic(@?,opt,X0,LB,UB);
        
        elseif strcmp(opt,'testGB')
        %    [Xbest,fbest,exitflag,output] = gb(@?,opt,X0,LB,UB);
        end
        
    otherwise
        error('**ERROR : opt : optimizer or test not available')
end

fprintf('\n**END**\n')
%% end program

%% Post-processing
%  ***************
%  Process data with gnuplot 
%  ~/XOPT/plot4.sh 
%  ...

%% Notes
%          (1*) :   
%          (2*) :   

%% Release v.1.3.1 (?)
%  ***************
%   - Wing analysis extension
%   - integration of much more operator
%   - real code 
%   - hybrid-scheme
%   - Parallel implementation (for distributed environments)
