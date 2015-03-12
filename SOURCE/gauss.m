function [sol,iter,err,flag] = Gauss(A,b,u0,kmax,tol);
% Funzione che implementa il metodo iterativo
% di Gauss
%-----------------------------------------------
% Inputs
% A, b: matrice e termine noto, rispettivamente
% u0 : guess iniziale
% tol : tolleranza calcoli
%
% Outputs
% sol : vettore soluzione
% iter: numero delle iterazionil
% err: vettore errori relativi in norma infinito
% flag: booleano convergenza o meno
%-----------------------------------------------
n=length(u0); flag=1;
D=diag(diag(A));
L=tril(A)-D; U=triu(A)-D;
DI=inv(D); C=-DI*(U+L);
%disp('raggio spettrale matrice iterazione di Gauss');
%ro=max(abs(eig(C)));
b1=DI*b; 
u1=b1+C*u0;
k=1;
err(k)=norm(u1-u0,inf);

%% 
while ( (err(k) > tol) && (k <= kmax) )
u0=u1;
u1=b1+C*u0;
k=k+1;
err(k)=norm(u1-u0,inf);
end
if err > tol
%disp('! WARNING: Gauss non converge nel numero di iterazioni fissato');
flag=0;
end

sol=u1;
iter=k;



