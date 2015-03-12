function [new_gen,sites] = uniformx(old_gen,Pc)
%UNIFORMX Creates a NEW_GEN from OLD_GEN using uniform crossover.
%	  [NEW_GEN,SITES] = UNIFORMX(OLD_GEN,Pc) performs uniform crossover
%         on consecutive pairs of OLD_GEN with probability Pc.
%	  SITES shows which bits experienced crossover.  1 indicates
%	  allele exchange, 0 indicates no allele exchange.  SITES has
%	  size(old_gen,1)/2 rows.
%
%  	  Created 1/20/96 by Joel Grasmeyer

new_gen = old_gen;
sites = rand(size(old_gen,1)/2,size(old_gen,2)) < Pc;
for i = 1:size(sites,1),
  new_gen([2*i-1 2*i],find(sites(i,:))) = old_gen([2*i 
2*i-1],find(sites(i,:)));
end

% end uniformx


