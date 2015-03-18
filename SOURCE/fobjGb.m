function f = fobjGb(x,Cm_max)

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

f = pol(3)./pol(2);

fp1 = Cm_max - pol(5);
p1 = 1;

%% Define "minimum thickness fuction"
tmin = -0.04.*(xyu(:,1) - 0.5).^2 + 0.01;
fp2 = xyl(2:end,2) - xyu(:,2) + tmin; % c = yl - yu + tmin < 0 !

p2 = 1;

if isnan(f) % check for NOT-CONVERGED SOLUTIONs 
	
	f = 0.5;

elseif (f < 0) % check fot NEGATIVE-FIT-VALUE
	
	f = 0.5;

end

if (fp1 > 0) & ~isnan(fp1)

	f = f + p1*fp1;

end


if fp2 > 0

	f = f + p2*max(fp2);		

end

system('rm -f *.pol *.cp *.xy *.run *.log');
