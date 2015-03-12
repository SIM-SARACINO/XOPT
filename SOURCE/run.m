function fit = run(x,tag1,tag2,varargin)
%********************************************************************
% Funcion which demand tasks to parametric engine, solver and compute
% fitness
% 
% INPUT  :
% OUTPUT :
%********************************************************************

if nargin < 4
    fconP_flag = 1;
%elseif ...
end

%% Global parameter
%  ****************
global N N1 N2
global nu nl
global mis mod 
global solv 
global pm par
global Re Ma
global alpha
global max_iter_xfoil
global cpmin

%% Call parametric engine
%  Build airfoil
%  **********************
switch pm
    case 'cst'
    [xy,xyu,xyl,wu,wl,xyc,xytu,xytl,file] = cst2d(x,[tag1 tag2],N,nu,nl,N1,N2);

%!  case ...
    otherwise
        error('**ERROR : pm : parametric model not available')
end

%% Call aerodynamic solver
%  Evaluate aerodynamic loads
%  **************************
switch solv 
    case 'xfoil'
    
    def = 0; % .def file not available in work space (enter '1' to get xfoil read '.def'
             % in current work space)
    [cp,cp_u,cp_l,pol] = xfoil(mod,Re,Ma,alpha,file,[tag1 tag2],def,max_iter_xfoil,cpmin);

%!  case ... 
    otherwise 
        error('**ERROR : solv : solver not available')
end

%% Compute Fitness
%  ***************
fit = fobj(tag1,tag2,cp,cp_u,cp_l,pol,xy,xyu,xyl,xyc,xytu,xytl,fconP_flag);