function [xopt,fopt,gen_best,k_best,stats,nfit,fgen,lgen,lfit] = sga(fObj, ...
                    x0,options,vlb,vub,bits,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10)
%*********************************************************************
%SGA minimizes a fit function using a simple genetic algorithm.
%	
%	New Features : 
%       (by Simone Saracino)
%		-CST parametric representation model interface  
%		-XFoil interface for airfoil analysis 
%		-binary encoding and decoding improvements
%       	
%   Description :
%       (Authors list below)
%	X=SGA('FUN',X0,OPTIONS,VLB,VUB) uses a simple (haploid) 
%       genetic algorithm to find a minimum of the fit function 
%       FUN.  FUN can be a user-defined M-file: FUN.M, or it can be a 
%	string containing the function itself.  The user may define all
%       or part of an initial population X0. Any undefined individuals 
%	will be randomly generated between the lower and upper bounds
%	(VLB and VUB).  If X0 is an empty matrix, the entire initial
%	population will be randomly generated.  Use OPTIONS to specify 
%	flags, tolerances, and input parameters.  Type HELP GOPTIONS
%       for more information and default values.
%
%	X=SGA('FUN',X0,OPTIONS,VLB,VUB,BITS) allows the user to 
%	define the number of BITS used to code non-binary parameters
%	as binary strings.  Note: length(BITS) must equal length(VLB)
%	and length(VUB).  If BITS is not specified, as in the previous 
%	call, the algorithm assumes that the fit function is 
%	operating on a binary population.
%
%	X=SGA('FUN',X0,OPTIONS,VLB,VUB,BITS,P1,P2,...) allows up 
%	to ten arguments, P1,P2,... to be passed directly to FUN.
%	F=FUN(X,P1,P2,...). If P1,P2,... are not defined, F=FUN(X).
%
%	[X,FOPT,STATS,NFIT,FGEN,LGEN,LFIT,ONLINE,OFFLINE]=SGA(<ARGS>)
%          X       - design variables of best ever individual
%          FOPT    - fit value of best ever individual
%          STATS   - [min mean max] fit values for each gen
%          NFIT	 - number of fit function evalations
%          FGEN    - first gen population
%          LGEN    - last gen population
%          LFIT    - last gen fit
%
%       The algorithm implemented here is based on the book: Genetic
%       Algorithms in Search, Optimization, and Machine Learning,
%       David E. Goldberg, Addison-Wiley Publishing Company, Inc.,
%       1989.
%
%   
%	Originally created on 1/10/93 by Andrew Potvin, Mathworks, Inc. 
%	Modified on 2/3/96 by Joel Grasmeyer.
%   Modified on 11/12/02 by Bill Crossley.
%   Modified again on 7/20/04 by Bill Crossley.
%*********************************************************************

%% Load input arguments and check for errors
%  *****************************************
fprintf('Parse input arguments...\n')
if nargin < 4,
    error('No population bounds given.')
elseif (size(vlb,1) ~= 1) || (size(vub,1) ~= 1),
    % Remark: this will change if algorithm accomodates matrix variables
    error('VLB and VUB must be row vectors')
elseif (size(vlb,2) ~= size(vub,2)),
    error('VLB and VUB must have the same number of columns.')
elseif (size(vub,2) ~= size(x0,2)) && (size(x0,1) > 0),
    error('X0 must all have the same number of columns as VLB and VUB.')
elseif any(vlb>vub),
    error('Some lower bounds greater than upper bounds')
else
    x0_row = size(x0,1);
    for i=1:x0_row,
        if any(x0(x0_row,:) < vlb) || any(x0(x0_row,:) > vub),
            error('Some initial population not within bounds.')
        end % if initial pop not within bounds
    end % for initial pop
end % if nargin<4   

if nargin < 6,
    bits = [];
elseif (size(bits,1) ~= 1) || (size(bits,2) ~= size(vlb,2)),
    % Remark: this will change if algorithm accomodates matrix variables
    error('BITS must have one row and length(VLB) columns')
elseif any(bits ~= round(bits)) || any(bits < 1),
    error('BITS must be a vector of integers >0')
end % if nargin<6

%% Read option variables
%  *********************
fprintf('Read option arguments...\n')
PRINTING = options(1);
BSA = options(2);
fit_tol = options(3);
nsame = options(4)-1;
elite = options(5);

% =========================================================================
% Remark
% Since operators are tournament selection and uniform crossover and
% default coding is Gray / binary, set crossover rate to 0.50 and use
% population size and mutation rate based on Williams, E. A., and Crossley,
% W. A., 'Empirically-derived population size and mutation rate guidelines
% for a genetic algorithm with uniform crossover,' Soft Computing in
% Engineering Design and Manufacturing, 1998.  If user has entered values
% for these options, then user input values are used.
% =========================================================================

if options(11) == 0,
    pop_size = sum(bits) * 4;
else
    pop_size = options(11);
end
if options(12) == 0,
    Pc = 0.5;
else
    Pc = options(12);
end
if options(13) == 0,
    Pm = (sum(bits) + 1) / (2 * pop_size * sum(bits));
else
    Pm = options(13);
end
max_gen = options(14);

%% Ensure valid options: e.q. Pc,Pm,pop_size,max_gen>0, Pc,Pm<1
% *************************************************************
fprintf('Check...\n')
if any([Pc Pm pop_size max_gen] < 0) || any([Pc Pm] > 1),
    error('Some Pc,Pm,pop_size,max_gen<0 or Pc,Pm>1')
end

%% Display warning if initial population size is odd
%  *************************************************
if rem(pop_size,2)==1,
    fprintf('Warning: Population size should be even.  Adding 1 to population.\n')
    pop_size = pop_size +1;
end

%% Encode fgen if necessary
%  ************************
temp_mat = [vlb; vub; x0];
ENCODED = any(any((temp_mat ~= 0) & (temp_mat ~= 1))) |...
    ~isempty(bits);
if ENCODED,
    fprintf('Encode x0 -> fgen...\n')
    [fgen,lchrom] = encode(x0,vlb,vub,bits);
else
    fgen = x0;
    lchrom = size(vlb,2);
end

%% Form random initial population if not enough supplied by user
%  *************************************************************
fprintf('Build random population of encoded configuration...\n')
if size(fgen,1) < pop_size,
    fgen = [fgen; (rand(pop_size-size(fgen,1),lchrom) < 0.5)];
end

%% Initialize loop variables & statistics
%  **************************************
fprintf('Initialize loop variable...')
xopt = vlb;
nfit = 0;
new_gen = fgen;
isame = 0;
fopt = Inf;

%% Decode 
%  ******
if ENCODED,
    fgen = decode(fgen,vlb,vub,bits);
end

fprintf('Run main loop...')
%% Output stats table
%stats = []; % dynamical allocation !
stats = zeros(max_gen,4);

if PRINTING >= 1
fprintf(['                    fit statistics                     \n',...
         '-------------------------------------------------------\n',...
         '|  Gen  |    Minimum    |     Mean     |    Maximum   |\n',...
         '-------------------------------------------------------\n'])
end
     
%% Optimize
%  ********

% Build data folder
mkdir('GEN');

% fit, BSA history
BSA_out = zeros(max_gen,2); BSA_out(1,:) = [0 0];
fit_out = zeros(max_gen*size(pop_size,1),2);

for gen = 1:max_gen,
    old_gen = new_gen;
    mkdir('GEN',sprintf('%d',gen-1));
    
    % Decode binary strings if necessary
    if ENCODED,
        x_pop = decode(old_gen,vlb,vub,bits);
    else
        x_pop = old_gen;
    end
    
    % Get fit of each string in population
    for k = 1:pop_size,
        x = x_pop(k,:);
        mkdir(sprintf('GEN/%d',gen-1),sprintf('%d',k));
        fit(k) = fObj(x,gen,k);      
        nfit = nfit + 1;
        pause(1)
        system('./system.sh mv');
    end
    
    ix0 = 1+pop_size*(gen-1);
    ix1 = pop_size+pop_size*(gen-1);
    ind = (ix0:ix1)';
    fit_out(ix0:ix1,:) = [ind fit']; 
    
    % Store minimum fit value from previous gen (except for
    % initial gen)
    if gen > 1,
        min_fit_prev = min_fit;
        min_gen_prev = min_gen;
        min_x_prev = min_x;
    end
    
    % identify worst (maximum) fit individual in current gen
    [max_fit,max_index] = max(fit);
   
    % impose elitism - currently only one individual; this replaces worst
    % individual of current gen with best of previous gen
    if ((gen > 1) && (elite > 0)),   
        old_gen(max_index,:) = min_gen_prev;
        x_pop(max_index,:) = min_x_prev;
        fit(max_index) = min_fit_prev;
    end
     
    % identify best (minimum) fit individual in current gen and
    % store bit string and x values
    [min_fit,min_index] = min(fit);
    min_gen = old_gen(min_index,:);
    min_x = x_pop(min_index,:);
    
    % store best fit and x values
    if min_fit < fopt,
        fopt = min_fit;
        xopt = min_x;
    end

    % Calculate gen statistics
    stats(gen,:) = [gen-1,min(fit),mean(fit),max(fit)];

    % Display stats 
    if PRINTING >= 1,
        fprintf('    %d\t  %1.5e\t  %1.5e\t  %1.5e\n',stats(gen,:))
    end

%     if PRINTING > 2	% old octave version, the routine is deprecated 
%         cod = 
%      	[xy xy_u xy_l] = pull('xy',cod,'foil');
%       [Cp Cp_u Cp_l] = pull('cp',cod,'Cp');
%      	 
%         nfitXgen=size(stats(:,1),1);
%         nfitXgen=0:nfitXgen-1;
%         
%         subplot(1,2,1)
%         plotyy(xy(:,1),xy(:,2),'-k',Cp_u(:,1),Cpx_u(:,2),'-r',...
%         Cp_l(:,1),Cp_l(:,2),'-b'),axis([-0.05,1.05,min(Cp_u(:,2)-0.1),Cpmax],'ij'),grid on
%         xlabel('x/c')
%         ylabel('Cp')
%         title(sprintf('\t xopt(gen %d): %3.4f %3.4f %3.4f %3.4f %3.2f\t...
%         fopt= %3.4f',[gen-1;xopt';fopt]))
%         legend(sprintf('xopt(gen %d)',gen-1),'Cpx U','Cpx L')
% 
%         subplot(1,2,2)	
%         plot(nfitXgen,stats(:,2)','-^',nfitXgen,stats(:,3)','-+',...
%                 nfitXgen,stats(:,4),'-*'),...
%         axis([stats(1,1),stats(end,1)+1,min(stats(:,2))-0.1,...
% 	    abs(10*min(stats(:,2)))]),grid on
%         xlabel('gen')
%         ylabel('Fit')
%         legend('Fit_min','Fit_avg','Fit_max')
%         
%          drawnow;
%      end
    
    % ================================================================
    % Check for termination
    % The default termination criterion is bit string affinity (BSA).
    % Also available are fit tolerance across five gens and
    % number of consecutive gens with the same best fit.  
    % These can be used concurrently.
    % ================================================================
    
    if fit_tol > 0, % fit tolerance criterion
        if gen > 5,
            % Check for normalized difference in fit minimums
            if stats(gen,1) ~= 0,
                if abs(stats(gen-5,1)-stats(gen,1))/ ...
                        stats(gen,1) < fit_tol
                    if PRINTING >= 1
                        fprintf('\n')
                        disp('GA converged based on difference in fit minimums.')
                    end
                    lfit = fit;
                    if ENCODED,
                        lgen = x_pop;
                    else
                        lgen = old_gen;
                    end
                    
      	            fit_out = fit_out(1:gen*pop_size,:);
		    [best_val,ind_val] = min(fit_out(:,2));
		    gen_best = floor(ind_val/pop_size) - (rem(ind_val,pop_size) < 1); % first gen is '0' !
		    k_best = ind_val - gen_best*pop_size;
                    stats = stats(1:gen,:);
                    
                    save('FIT.out','fit_out','-ascii')
                    save('STATs.out','stats','-ascii')
                    system('./system.sh mvG');
                    
                    return
                end
            else
                if abs(stats(gen-5,1)-stats(gen,1)) < fit_tol
                    if PRINTING >= 1
                        fprintf('\n')
                        disp('GA converged based on difference in fit minimums.')
                    end
                    lfit = fit;
                    if ENCODED,
                        lgen = x_pop;
                    else
                        lgen = old_gen;
                    end
                    
      		    fit_out = fit_out(1:gen*pop_size,:);
                    [best_val,ind_val] = min(fit_out(:,2));
		    gen_best = floor(ind_val/pop_size) - (rem(ind_val,pop_size) < 1); % first gen is '0' !
		    k_best = ind_val - gen_best*pop_size;
		    stats = stats(1:gen,:);
                    
                    save('FIT.out','fit_out','-ascii')
                    save('STATs.out','stats','-ascii')
                    system('./system.sh mvG');
                    
                    return
                end
            end
        end
    elseif nsame > 0,    % consecutive minimum fit value criterion
        if gen > 1
            if min_fit_prev == min_fit
                isame = isame + 1;
            else
                isame = 0;
            end
            if isame == nsame
                if PRINTING >= 1
                    fprintf('\n')
                    disp('GA stopped based on consecutive minimum fit values.')
                end
                lfit = fit;
                if ENCODED,
                    lgen = x_pop;
                else
                    lgen = old_gen;
                end
                
                
       		fit_out = fit_out(1:gen*pop_size,:);
		[best_val,ind_val] = min(fit_out(:,2));
		gen_best = floor(ind_val/pop_size) - (rem(ind_val,pop_size) < 1); % first gen is '0' !
		k_best = ind_val - gen_best*pop_size;
		stats = stats(1:gen,:);
                
                save('FIT.out','fit_out','-ascii')
                save('STATs.out','stats','-ascii')
                system('./system.sh mvG');
                
                return
            end
        end
    elseif BSA > 0,  % bit string affinity criterion
        if gen > 1
            bitlocavg = mean(old_gen,1);
            BSA_pop = 2 * mean(abs(bitlocavg - 0.5));
	    BSA_out(gen,:) = [gen-1 BSA_pop];
            if BSA_pop >= BSA,
                if PRINTING >=1
                    fprintf('\n')
                    disp('GA stopped based on bit string affinity value.')
                end
                lfit = fit;
                if ENCODED,
                    lgen = x_pop;
                else
                    lgen = old_gen;
                end
                 
      		BSA_out = BSA_out(1:gen,:);
       		fit_out = fit_out(1:gen*pop_size,:);
		[best_val,ind_val] = min(fit_out(:,2));
		gen_best = floor(ind_val/pop_size) - (rem(ind_val,pop_size) < 1); % first gen is '0' !
		k_best = ind_val - gen_best*pop_size;
	        stats = stats(1:gen,:);
                
                save('BSA.out','BSA_out','-ascii')
                save('FIT.out','fit_out','-ascii')
                save('STATs.out','stats','-ascii')
                system('./system.sh mvG');
                   
                return
            end
        end
    end
    
    % Tournament selection
    new_gen = tourney(old_gen,fit);
    
    % Crossover
    new_gen = uniformx(new_gen,Pc);
    
    % Mutation
    new_gen = mutate(new_gen,Pm);
    
    % Always save last gen.  This allows user to cancel and
    % restart with x0 = lgen
    if ENCODED,
        lgen = x_pop;
    else
        lgen = old_gen;
    end
    
    system('./system.sh mvG');

end % for max_gen


% Maximum number of gens reached without termination
lfit = fit;

if BSA > 0 % print BSA history
     BSA_out = BSA_out(1:gen,:);
     save('BSA.out','BSA_out','-ascii')
end

[best_val,ind_val] = min(fit_out(:,2));	
gen_best = floor(ind_val/pop_size) - (rem(ind_val,pop_size) < 1); % first gen is '0' !
k_best = ind_val - gen_best*pop_size;

save('FIT.out','fit_out','-ascii') % print fit history
save('STATs.out','stats','-ascii') % print stats history

if PRINTING >= 1,
   fprintf(['\nWARNING\n',...
            'Maximum number of generation reached without termination\n',...
            'criterion met.  Either increase maximum generation \n',...
            'or ease termination criterion.\n\n'])
end

%% end genetic
