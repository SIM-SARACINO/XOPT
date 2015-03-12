function fit = fobj(tag1,tag2,cp,cp_u,cp_l,pol,xy,xyu,xyl,xyc,xyt,fconP_flag,varargin)
%********************************************************************
% Funcion which compute fitness 
% 
% INPUT  :
% OUTPUT :
%********************************************************************

global Re Ma alpha
global nu nl
global mod

%% varargin not defined

%% Initialize penalty coeff.
%  REMARK : 
%  *************************
p = [];
Fp = [];

p(1) = 0.05;     % thickness penalty coeff.
%p(2) = 0.2;      % p. c. for NOT RELIABLE SHAPE
p(2) = 0.1;      % p. c. for NOT-CONVERGED SOLUTION
p(3) = 0.1;      % p. c. for NEGATIVE FIT VALUE
p(4) = 0.1;      % p. c. for MAXIMUM Cm

Cm_max = -0.7;

%% Define "minimum thickness fuction"
tmin = -0.04.*(xyu(:,1) - 0.5).^2 + 0.01;

c = xyl(2:end,2) - xyu(:,2) + tmin; % c = yl - yu + tmin < 0 !

[ix iy val] = find(max(c,0));   
if ~isempty(val);
    Fp(1) = max(val);
else
    Fp(1) = 0;
end

%[ix ix val] = find(xyu(:,2) < -0.001);
%Fp(2) = max(val)^2
Fp(2) = sum(isnan(pol));

%% Compute fitness
%  ***************
if isnan(pol)
    fit = p(2)*Fp(2);
else
    fit=pol(3)./pol(2)+p(1)*Fp(1);
    
    Fp(3) = (fit < 0)*(abs(fit)+0.1);
    Fp(4) = (pol(5) < Cm_max)*(Cm_max - pol(5))^2;
    
    fit = fit + p(3:4)*Fp(3:4)';
    
end

data = [pol(2:3),pol(5),pol(2)./pol(3),fit];

%% Print data
%  **********
if tag2 == 1
	fid1=fopen(sprintf('%d.gen',tag1-1), 'w');
	fprintf(fid1,['\n\t','XOPT v.1.2.0\n\n',...
                    '\t\tDatabase\n\nGen %d\n',...
		     'Re %.3e\tMach %.2f\tAlpha %.3f\t%s\n\n',...
		     'x0\t\t Cl\t\tCd\t\tCm\t\tE\t      fitness\n',...
		     '--\t     ----------\t    ----------\t    ----------\t    ----------\t    ----------\n',...
		     '%d\t      %3.4f\t      %3.4f\t      %3.4f\t      %3.4f\t      %3.4f\t\n'],...
                    tag1-1,Re,Ma,alpha,mod,tag2,data);
                
else
    fid1=fopen(sprintf('%d.gen',tag1-1), 'a+');
	fprintf(fid1,['%d\t      %3.4f\t      %3.4f\t      %3.4f\t      %3.4f\t      %3.4f\t\n'],tag2,data);
    
end

fclose(fid1);
