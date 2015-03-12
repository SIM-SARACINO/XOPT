function [Xbest,fbest,exitflag,output] = gb(fobj,alg,X0,LB,UB,varargin)
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
sprintf('\nBuild options...\n')

options = [];

%options = optimset(@fmincon); % set matlab 'fmincon' default options
%options = optimset(options,'Algorithm',opt,'Display','iter','MaxFunEvals',50000,...
%                    'LargeScale','off','MaxIter',2500,'TolFun',1E-6,'TolCon', 1E-6);

options = optimset('Algorithm',alg,'Display','iter','MaxFunEvals',50000,...
                    'LargeScale','off','MaxIter',2500,'TolFun',1E-6,'TolCon', 1E-6);

fconP_flag = 1; % define a flag to activate (1) or disable (0) penalty functions. 
                % Instead of penalty functions one may set linear and
                % not-linear constraints in other way (see documetation of "fmincon.m"). 
                % Default value is 1.
                
if fconP_flag
    
    %% Solve
    sprintf('call %s...\n',alg)
    tstart = tic; % start the clock

    [Xbest,fbest,exitflag,output] = fmincon(fobj,X0,[],[],[],[],[],[],[],options); % run matlab "fmincon.m"

    tcomp=toc(tstart); % stop the clock
    sprintf('\n tcomp = %.3f\n',tcomp)
    
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
    sprintf('call %s...\n',alg)
    tstart = tic; % start the clock

    [Xbest,fbest,exitflag,output] = fmincon(fobj,X0,A,b,Aeq,beq,LB,UB,c,ceq,options); 
    tcomp=toc(tstart); % stop the clock
    sprintf('\n tcomp = %.3f\n',tcomp)
    
end