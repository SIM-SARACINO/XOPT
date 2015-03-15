function fit = runGB(x,cod1,cod2)

global N N1 N2
global nu nl
global mis mod 
global solv 
global pm par
global Re Ma
global alpha
global max_iter_xfoil
global cpmin

status = system('rm -f *.run *.log');

cod1 = cod1 + 2; cod2 = cod2 + 1;

[xy,xyu,xyl,wu,wl,xyc,xytu,xytl,file] = cst2d(x,[cod1 cod2],N,nu,nl,N1,N2);

def = 0; % .def file not available in work space (enter '1' to get xfoil read '.def'
             % in current work space)
[cp,cp_u,cp_l,pol] = xfoil(mod,Re,Ma,alpha,file,[cod1 cod2],def,max_iter_xfoil,cpmin);

pause(1)	

fit = fobj(cod1,cod2,cp,cp_u,cp_l,pol,xy,xyu,xyl,xyc,xytu,xytl);

