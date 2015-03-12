function [wu,wl,Au,bu,Al,bl,xu,yu,xl,yl] = cstW(X,nu,nl,solv,N1,N2)
%*************************************************************
% Funcion to calculate weigth  coeff. scaling Shape components
% airfoils
% INPUT  :
% OUTPUT :
%*************************************************************

if nargin < 4

    solv = 'custom';
    N1 = 0.5;
    N2 = 1.0;

elseif nargin < 5
    
    N1 = 0.5;
    N2 = 1.0;
    
end

%% INPUT DESIGN VARIABLES
%  **********************
ru =X(1);
rl =X(2);
bu =X(3);
bl =X(4);

xu = zeros(nu,1); xl = zeros(nl,1); 
yu = zeros(nu,1); yl = zeros(nl,1);

for i=1:nu
	xu(i) =X(5+(i-1));
	yu(i) =X(5+nu+(i-1));
end

for i=1:nl
	xl(i) =X(2*nu+5+(i-1));
	yl(i) =X(2*nu+nl+5+(i-1));
end

dzu =X(end-1);
dzl =X(end);

%% INITIALIZE A
%--------------
dim1Au =nu; dim2Au =dim1Au;
dim1Al =nl; dim2Al =dim1Al;

BPN_u =dim2Au+1; 
BPN_l =dim2Al+1;

Au =zeros(dim1Au,dim2Au);
Al =zeros(dim1Al,dim2Al);

[Sku,CSku] = cstK(BPN_u,xu);
[Skl,CSkl] = cstK(BPN_l,xl);

CSku = CSku';
CSkl = CSkl';

for i=1:nu
	Au(i,:) =CSku(i,2:end-1);
end

for i=1:nl
	Al(i,:) =CSkl(i,2:end-1);
end

%% INITIALIZE weigth coeff.
%--------------------------
wu =zeros(1,BPN_u+1);
wl =zeros(1,BPN_l+1);

wu(1) = sqrt(2*ru);
wu(end) = tan(bu)+dzu;

wl(1) = -sqrt(2*rl);
wl(end) = tan(bl)+dzl;

%% INITIALIZE b
%--------------
bu =zeros(dim1Au,1);
bl =zeros(dim1Al,1);

for i=1:nu
	bu(i) =yu(i)-wu(1)*CSku(i,1)-wu(end)*CSku(i,end)-xu(i)*dzu;
end

for i=1:nl
	bl(i) =yl(i)-wl(1)*CSkl(i,1)-wl(end)*CSkl(i,end)-xl(i)*dzl;
end

if strcmp(solv,'custom')
	
	%% Call Matlab Routine : A\b
	%  *************************
	sol_u = Au \ bu;
	sol_l = Al \ bl;

elseif strcmp(solv,'gauss') % old
    %% Call GAUSS ROUTINE
	%  ******************
	itermax =1E05;
	tol =1E-06;

	w0_u =rand(dim1Au,1);
	flag_u =0;
	k_u =1;

	while (flag_u == 0)
	
		itermax = itermax*k_u;
		[sol_u,iter_u,err_u,flag_u] = gauss(Au,bu,w0_u,itermax,tol);
		k_u = k_u+1;
	
	end	

	w0_l = rand(dim1Al,1);
	flag_l = 0;
	k_l = 1;

	while (flag_l == 0)
	
		itermax = itermax*k_l;
		[sol_l,iter_l,err_l,flag_l] = gauss(Al,bl,w0_l,itermax,tol);
		k_l = k_l+1;
    
    end	

end

%% OUTPUT
%  ******
wu(2:end-1) = sol_u;
wl(2:end-1) = sol_l;
