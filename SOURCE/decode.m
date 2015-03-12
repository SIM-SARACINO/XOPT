function [x,coarse] = decode(gen,vlb,vub,bits);
%DECODE Converts from binary Gray code to variable representation.
%	[X,COARSE] = DECODE(GEN,VLB,VUB,BITS) converts the binary 
%       population GEN to variable representation.  Each individual 
%       of GEN should have SUM(BITS).  Each individual binary string
%       encodes LENGTH(VLB)=LENGTH(VUB)=LENGTH(BITS) variables.
%       COARSE is the coarseness of the binary mapping and is also
%       of length LENGTH(VUB).
%
%  this *.m file created by combining "decode.m" from the MathWorks, Inc.
%  originally created by Andrew Potvin in 1993, with "GDECODE.FOR" written 
%  by William A. Crossley in 1996.
%	
%	William A. Crossley, Assoc. Prof. School of Aero. & Astro.
%  Purdue University, 2001
%
%  gen is an array [population size , string length], each row is one individual's chromosome
%  vlb is a row vector [number of parameters], each entry is the lower bound for a variable
%  vub is a row vector [number of parameters], each entry is the upper bound for a variable
%  bits is a row vector [number of parameters], each entry is number of bits used
%  for a variable
%---------------------------------------------------------------------------------- 

no_para = length(bits); 	% extract number of parameters using number of rows 					in bits vector
npop = size(gen,1);		% extract population size using number of rows in gen 					array
x = zeros(npop, no_para);  	% sets up x as an array [population size, number of 					parameters]
coarse = zeros(1,no_para); 	% sets up coarse as a row vector [number of 					parameters]

for J = 1:no_para,  		% extract the resolution of the parameters
	coarse(J) = (vub(J)-vlb(J))/(2^bits(J)-1); % resolution of parameter J
end

for K = 1:npop, 		% outer loop through each individual 
	sbit = 1;		% initialize starting bit location for a parameter
	ebit = 0;		% initialize ending bit location
   
   for J = 1:no_para,	        % loop through each parameter in the problem
   	ebit = bits(J) + ebit;	% pick the end bit for parameter J
		accum = 0.0;    % initialize the running sum for parameter J
      ADD = 1;                  % add / subtract flag for Gray code; add if(ADD), 					subtract otherwise
      for I = sbit:ebit,        % loop through each bit in parameter J
         pbit = I + 1 - sbit;   % pbit determines value to be added or subtracted for 					Gray code
         if (gen(K,I)) 		% if "1" is at current location
            if (ADD) 		% add if appropriate
               accum = accum + (2.0^(bits(J)-pbit+1) - 1.0);
               ADD = 0; 	% next time subtract
            else
               accum = accum - (2.0^(bits(J)-pbit+1) - 1.0);
               ADD = 1; % next time add
            end
         end
      end 

      x(K,J) = accum*coarse(J) + vlb(J);% decoded parameter J for individual K
      sbit = ebit + 1; % next parameter starting bit location

   end						

end 					




