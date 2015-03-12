function [new_gen,nselected] = tourney(old_gen,fitness)
%TOURNEY Creates NEW_GEN from OLD_GEN, based on tournament selection.
%	 [NEW_GEN,NSELECTED] = TOURNEY(OLD_GEN,FITNESS) selects
%        individuals from OLD_GEN by competing consecutive individuals
%	 after random shuffling.  NEW_GEN will have the same number of
%	 individuals as OLD_GEN.
%        NSELECTED contains the number of copies of each individual
%	 that survived.  This vector corresponds to the original order
%	 of OLD_GEN.
%
%	 Created on 1/21/96 by Joel Grasmeyer

fitness=fitness';

% Initialize nselected vector and indices of old_gen
new_gen = [];
nselected = zeros(size(old_gen,1),1);
i_old_gen = 1:size(old_gen,1);

% Perform two "tournaments" to generate size(old_gen,1) new individuals
for j = 1:2,
  
  % Shuffle the old generation and the corresponding fitness values
  [old_gen,i_shuffled] = shuffle(old_gen);
  fitness = fitness(i_shuffled);
  i_old_gen = i_old_gen(i_shuffled);

  % Keep the best of each pair of individuals
  i_odd = 1:2:(size(old_gen,1)-1);
  i_even = i_odd +1;
  [min_fit,i_min] = min([fitness(i_odd),fitness(i_even)],[],2);
  selected = [i_odd(find(i_min == 1)),i_even(find(i_min == 2))];
  new_gen = [new_gen; old_gen(selected,:)];

  % Increment counters in nselected for each individual that survived
  temp = zeros(size(old_gen,1),1);
  temp(i_old_gen(selected)) = ones(length(selected),1);
  nselected = nselected + temp;

end

% end tourney


