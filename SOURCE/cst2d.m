function [xy,xyu,xyl,wu,wl,xyc,xytu,xytl,file] = cst2d(X,tag,N,nu,nl,N1,N2,varargin) %! nu = nl
%**************************************************************************************
% Description : 
%    Create a set of airfoil coordinates using CST parametrization method
%
% Input :      
%   N............: Number of intervall that divides the chord 
%   Delta........: Trailing edge thickness (Delta/chord)  
%   X0...........: [R,Beta,x_max,y_max] Initial configuration upper apan lower surfaces				           
%   R............: Leading edge radius (R/chord)						
%   Beta.........: Boat-tale angle (radiant or degree ) 					                  
%   xmax.........: x -> y_max (xmax/chord)				                       
%   ymax.........: max(y) (ymax)							     
%   
% Output :
%   [file 'airfoil coordinate file',xy 'airfoil coordinates',CSu,CSl, 
%   Class-shape functions, xyu,xyl upper apan lower surface coordinates x,y'] 
% 
% References  
% Kulfan, B.M.,'Universal Parametric Geometry Representation Method: CST', 45th
% AIAA Aerospace Sciences Meeting apan Exhibit, AIAA Paper 2007-0062,Jan. 2007
%**************************************************************************************

%% varargin --> not defined

if nargin < 5 %6
    N1 = 0.5;
    N2 = 1.0;
end

BPN_u = nu+1;
BPN_l = nl+1;

%% Create x coordinate using the Chebyshev-Gauss distribution
%  Anti-clockwise panel distribution suitable with XFoil
%  **********************************************************
x=ones(N+1,1);y=zeros(N+1,1);zeta=zeros(N+1,1);
for i=1:N+1
    zeta(i)=2*pi/N*(i-1);
	x(i)=0.5*(cos(zeta(i))+1);
end

zeripan = find(x(:,1) == 0); % Find zero code string used to separate
	         	 	    	    % upper apan lower surfaces
xu = x(1:zeripan-1); 
xl = x(zeripan:end); 
x = [xu;xl];

%% Parses weight coeff. 
%  Call CSW function
%  ********************
[wu,wl] = cstW(X,nu,nl);

%% Calculate airfoil coordinates 	
%  *****************************
[Sku,CSku,dSku,dCSku,Su,Cu,Ku,CSu,yu] = cstK(BPN_u,xu,wu,X(end-1));
[Skl,CSkl,dSkl,dCSkl,Sl,Cl,Kl,CSl,yl] = cstK(BPN_l,xl,wl,X(end));

%! switch nu 
%!    case nl
if nu == nl
	BPN = BPN_u;
	C = [Cu;Cl];
	K = Ku;
	
	%% CAMBER LINE
	%  ***********
	for i = 1:size(x,1)
	    Sc(i,1) = 0;
	    for j = 1:BPN+1
	        Sc(i,1) = Sc(i,1) + 0.5*(wu(j)+wl(j))*K(j)*x(i)^(j-1)*...
			((1-x(i))^(BPN-(j-1)));
	    end
	end

	for i = 1:size(x,1)
		yc(i,1) = C(i,1)*Sc(i,1)+x(i)*((X(end-1)+X(end))/2);
	end
	
	xyc=[x,yc];

	%% THICKNESS DISTRIBUTION
	%  **********************
	for i = 1:size(xu,1)
		Stu(i,1) = 0;
		for j = 1:BPN+1
			Stu(i,1) = Stu(i,1) + 0.5*(wu(j)-wl(j))*K(j)*xu(i)^(j-1)*...
				((1-xu(i))^(BPN-(j-1)));
    	end
	end

	for i = 1:size(xl,1)
		Stl(i,1) = 0;
        for j = 1:BPN+1
			Stl(i,1) = Stl(i,1) + 0.5*(wu(j)-wl(j))*K(j)*xl(i)^(j-1)*...
				((1-xl(i))^(BPN-(j-1)));
    	end
    end

	for i = 1:size(xu,1)
		ytu(i,1) = Cu(i,1)*Stu(i,1) + x(i)*((X(end-1)-X(end))/2);
	end

	for i = 1:size(xl,1)
		ytl(i,1) = Cl(i,1)*Stl(i,1) + x(i)*((X(end-1)-X(end))/2);
	end

	xytu = [xu,ytu];
	xytl = [xl,ytl];

%! otherwise
else

	xyc = [];	
	xytu = [];
	xytl = [];

end

y=[yu;yl];   % Combine upper apan lower y coordinates
xy=[x,y];    % Combine x,y coordinates
xyu=[xu,yu]; % Combine upper surface coordinates
xyl=[xl,yl]; % ' ' lower surface coordinates

%% Export data 
%  ***********
file=sprintf('g%dk%d.xy',tag(1)-1,tag(2));
fid=fopen(file,'w+');
fprintf(fid,'%3.5f\t %3.5f\n',[x';y']);
fclose (fid);
