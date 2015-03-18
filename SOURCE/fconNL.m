function [c,ceq] = fconNL(x)

global N N1 N2
global nu nl
global mod 
global Re Ma
global alpha
global max_iter_xfoil
global cpmin

def = 0;
tag = [1 0];

[xy,xyu,xyl,wu,wl,xyc,xytu,xytl,file] = cst2d(x,tag,N,nu,nl);
[cp,cp_u,cp_l,pol] = xfoil(mod,Re,Ma,alpha,file,tag,def,max_iter_xfoil,cpmin);

%% Define "minimum thickness fuction"
tmin = -0.04.*(xyu(:,1) - 0.5).^2 + 0.01;

%% Maximum Cm

c = xyl(2:end,2) - xyu(:,2) + tmin; % c = yl - yu + tmin < 0 !
%c(2) = Cm_max - pol(5);

ceq = [];

system('rm -f *.pol *.cp *.xy *.run *.log');
