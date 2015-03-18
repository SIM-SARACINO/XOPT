function fit = fobj(tag1,tag2,cp,cp_u,cp_l,pol,xy,xyu,xyl,xyc,xyt,fconP_flag,varargin)
%********************************************************************
% Funcion which compute fitness 
% 
% INPUT  :
% OUTPUT :
%********************************************************************

global Re Ma alpha
global nu nl opt
global mod

%% varargin not defined

%% Initialize penalty coeff.
%  REMARK : 
%  *************************
p = [];
Fp = [];

p(1) = 0.05;    % penalty coeff. for maximum thickness
p(2) = 0.1;     % penalty coeff. for maximum Cm
p(3) = 1;	% penalty coeff. for maximum Cd

Cm_max = -0.15;
Cd_max = 0.01;
% Cl_max  ?

Fp(1) = sum(isnan(pol));

if isnan(pol) % check for NOT-CONVERGED SOLUTIONs 
	
	fit = 0.5;

else 
	fit=pol(3)./pol(2);
	
	if fit < 0 % check for NEGATIVE FIT VALUEs

		fit = 0.5;
	
	else
		%% Define "minimum thickness fuction"
		tmin = -0.04.*(xyu(:,1) - 0.5).^2 + 0.01;
		c = xyl(2:end,2) - xyu(:,2) + tmin; % c = yl - yu + tmin < 0 !

		[ix iy val] = find(max(c,0));   
	
		if ~isempty(val);
			Fp(1) = max(val);
		else
        		Fp(1) = 0;
		end
		
		Fp(2) = (pol(5) < Cm_max)*(Cm_max - pol(5))^2;
		Fp(3) = (pol(3) > Cd_max)*(Cd_max - pol(3))^2;
	
		fit = fit + p*Fp';

	end    
end
  
data = [pol(2:3),pol(5),pol(2)./pol(3),fit];

%% Print data
%  **********
if strcmp(opt,'sga')
	if tag2 == 1
		fid1=fopen(sprintf('%d.gen',tag1-1), 'w');
		fprintf(fid1,['\n\t','XOPT v.1.2.0\n\n',...
                	      '\t\tDatabase\n\nGen %d\n',...
		              'Re %.3e\tMach %.2f\tAlpha %.3f\t%s\n\n',...
		              'x0\t\t Cl\t\tCd\t\tCm\t\tE\t      fitness\n',...
		              '--\t     ----------\t    ----------\t    ----------\t    ----------\t    ----------\n',...
		              '%d\t      %3.5f\t      %3.5f\t      %3.5f\t      %3.5f\t      %3.5f\t\n'],...
                               tag1-1,Re,Ma,alpha,mod,tag2,data);
                
	else
    		fid1=fopen(sprintf('%d.gen',tag1-1), 'a+');
		fprintf(fid1,['%d\t      %3.5f\t      %3.5f\t      %3.5f\t      %3.5f\t      %3.5f\t\n'],tag2,data);
	end
	
	fclose(fid1);
    
else %! experimental 
	fid1=fopen('history.dat', 'a+');
	fprintf(fid1,['%d\t      %3.4f\t      %3.4f\t      %3.4f\t      %3.4f\t      %3.4f\t\n'],tag1,data);

	fclose(fid1);

end
