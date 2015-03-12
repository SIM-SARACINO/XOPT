function [Sk,CSk,dSk,dCSk,S,C,K,CS,y] = cstK(BPN,x,w,dz,N1,N2)
%**************************************************************
% Funcion to calculate shape components of Bernstein polynomial
% 
% INPUT  :
% OUTPUT :
%**************************************************************

if nargin < 5
    N1 = 0.5;
    N2 = 1.0;
end

% Class function
% **************
for i = 1:size(x,1)
    	C(i,1) = x(i)^N1*((1-x(i))^N2);
        dC(i,1)=N1*x(i)^(N1-1)*(1-x(i))^N2-N2*x(i)^N1*(1-x(i))^(N2-1);
end

%% Shape function; using Bernstein Polynomials
%  *******************************************
for i = 1:BPN+1
     	K(i) = factorial(BPN)/(factorial(i-1)*factorial(BPN-(i-1)));
end
	
for i = 1:BPN+1
	for j=1:size(x,1)
    	Sk(i,j) = K(i)*x(j)^(i-1)*(1-x(j))^(BPN-(i-1));
		dSk(i,j) = K(i)*( (i-1)*x(j)^(i-2)*(1-x(j))^(BPN-(i-1))-...
		(BPN-(i-1))*x(j)^(i-1)*(1-x(j))^(BPN-i) );
		CSk(i,j) = C(j)*Sk(i,j);
		dCSk(i,j) = dC(j)*Sk(i,j)+C(j)*dSk(i,j);
	end
end

if nargin > 2 

	for i = 1:size(x,1)
    		S(i,1) = w*Sk(:,i);
	end

	for i = 1:size(x,1)
        	CS(i,1) = w*CSk(:,i);
		y(i,1) = CS(i,1)+x(i)*dz;
	end

end



