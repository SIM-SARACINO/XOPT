function xopt % set input-output data to use in combination with other programs
%%*******************************************************************
%   XOPT v.1.2.0_SGA(s)
%                              input  >>> xopt
%                                      /   |   \
%                                     |    |    |
%                                   geom  fobj solver 
%                                      \   |   /
%                        constraint --> optimizer >> output 
%                                         
%   DESCRIPTION :
%
%   XOPT is an optimization code which has..    
%
%   STRUCTURE   :
%   
%   - xopt.m.....: served as the main airfoil design routine. 
%     It called the appropriate functions to set up the optimization 
%     problem, called the optimizer, processed the results, and saved
%     results to text files (gen%*k%**.xy .cp .pol .run .log, %*.gen,
%     "stats.out", "bsa.out").
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
%%*******************************************************************

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

fprintf(['UNIVERSITY of ROMA TRE',...
         'Department of Mechanical and Industrial Engineering\n',...
         'Supervisors : ','Umberto Iemma.         (Associate Professor)\n',...
         '                 Lorenzo Burghignoli.   (Researcher)\n',...
         '                 Francesco Centracchio. (Researcher)\n',... 
         'Author: ','Simone Saracino\n\n']) 

%% Include XOPT in matlab directory path
%  *************************************
addpath('SOURCE') % trouble with MCC compiler ! 
                   % Fill in manually in the workspace

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
sprintf('\nMission = %s\n',mis)

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
fprintf('Optimizer algorithm  = %s\n',opt)

%% Distributed computation service
%  *******************************

par = 0; % 0 not available
         % 1 available
fprintf('Distributed workstation or cluster  = %s\n',par)

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

Pu = [ 0.20,0.15 ; 0.50,0.10; 0.70,0.05 ]
Pl = [ 0.20,-0.10 ; 0.50,-0.08; 0.70,-0.02 ]

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
         ' X0 = [Ru,Rl,bu,bl,[Pu],[Pl],dzu,dzl\n',... 
         ' Ru, Rl	: normalized leading edge radius of curvature\n',... 
         ' bu, bl	: boat-tail angle (rad)\n',...
         ' Pu, Pl	: normalized coordinate matrix\n',...
         ' dzu,dzl	: normalized trailing edge thickness\n'])

X0 = [0.10,0.10,pi/10,pi/12,Pu(:,1)',Pu(:,2)',Pl(:,1)',Pl(:,2)',0.005,-0.005]

fprintf(['\nInitialize upper and lower bounds\n',...
         ' UB_u  : upper bound-upper surface points ;\n',...
         ' UB_l	 : upper bound-lower ... ;\n',...
         ' LB_u  : lower bound-upper surface poins ;\n',...
         ' LB_l  : lower bound-lower ... ;\n',...
         ' UB    : upper bound (all parameters) ;\n',...
         ' LB    : lower bound (all parameters)\n'])
         
UB_u = [ 0.25,0.15 ; 0.55,0.15 ; 0.75,0.10 ];
LB_u = [ 0.15,0.05 ; 0.45,0.05 ; 0.65,0.02 ];

UB_l = [ 0.25,-0.05 ; 0.55,-0.04 ; 0.75,-0.01 ];
LB_l = [ 0.15,-0.10 ; 0.45,-0.08 ; 0.65,-0.02 ];

UB = [ 0.10,0.10,pi/8,pi/10,UB_u(:,1)',UB_u(:,2)',UB_l(:,1)',UB_l(:,2)',0.005,-0.004 ]
LB = [ 0.06,0.06,pi/12,-pi/10,LB_u(:,1)',LB_u(:,2)',LB_l(:,1)',LB_l(:,2)',0.004,-0.005 ]

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
     
N = 100
N1 = 0.5
N2 = 1.0

if c == 1
Re = 0.5E06
U = Re*ni*c^(-1);
else
	Rec = Re*c
	Re = Rec;
	U = Re*ni*c^(-1);
end

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
        fprintf('\n...launch %s configuration...\n',opt)        
        [Xbest,fbest,stats,nfit,fgen,lgen,lfit] = genetic(@run,opt,X0,LB,UB);
        
        
    case {'active-set','sqp','trust-region-reflective','trust-region-dogleg',...
            'interior-point','interior-point-convex','levenberg-marquardt','lm-line-search'} % new !
        
        fprintf('\n...launch %s configuration...\n',opt)
        [Xbest,fbest,exitflag,output] = gb(@run,opt,X0,LB,UB);
        
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
%  ~/XOPT/plot.sh $1 $2 $3 $4 $5 $6 $7
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
