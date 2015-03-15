function [Xbest,fbest,exitflag,output] = gb(fObj,alg,X0,LB,UB,varargin)
%********************************************************************
% Funcion which demand tasks to parametric engine, solver and compute
% fitness
% 
% INPUT  :
% OUTPUT :
%********************************************************************

% global opt

%% Optimizer options
%  *****************
fprintf('\nBuild options...\n')

options = [];

%options = optimset(@fmincon); % set matlab 'fmincon' default options
%options = optimset(options,'Algorithm',opt,'Display','iter','MaxFunEvals',50000,...
%                    'LargeScale','off','MaxIter',2500,'TolFun',1E-6,'TolCon', 1E-6);

options = optimset('Algorithm',alg,'Display','iter','MaxFunEvals',50000,...
                    'LargeScale','off','MaxIter',2500,'TolFun',1E-6,'TolCon', 1E-6);

if nargin < 6
	fconP_flag = 1; % define a flag to activate (1) or disable (0) penalty functions. 
                	% Instead of penalty functions one may set linear and
                	% not-linear constraints in other way (see documetation of "fmincon.m"). 
                	% Default value is 1.
end
                
if fconP_flag
    
    %% Solve
    fprintf('call %s...\n',alg)
    tstart = tic; % start the clock
    
    [Xbest,fbest,exitflag,output] = fmincon(fObj,X0,[],[],[],[],LB,UB,[],[],options); 

    tcomp=toc(tstart); % stop the clock
    fprintf('\n tcomp = %.3f\n',tcomp/60)
    
else 
    %% Define linear-not linear constraints
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    
    c = [];
    ceq = [];
    %% ! define a function to compute not linear constraints instead
    
    %% Solve
    fprintf('call %s...\n',alg)
    tstart = tic; % start the clock

    [Xbest,fbest,exitflag,output] = fmincon(fObj,X0,A,b,Aeq,beq,LB,UB,c,ceq,options); 
    tcomp=toc(tstart); % stop the clock
    fprintf('\n tcomp = %.3f\n',tcomp/60)
    
end
