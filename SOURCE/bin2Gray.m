function g2 = bin2Gray(b2,bits);
%% Binary --> Gray code 
%-----------------------

bit_count = 0;
b2_index = [];
bits_index = 1:length(bits);

for i=bits_index
	bit_count = bit_count + bits(i);
	b2_index = [b2_index bit_count];
end
	
g2=b2;
for k=1:size(b2,1)
	for j=length(bits):-1:1
		sbit=b2_index(j);
		ebit=sbit-bits(j)+1;
		for i=sbit:-1:ebit+1
			g2(k,ebit)=b2(k,ebit);
			g2(k,i)=xor(b2(k,i),b2(k,i-1));
		end
	end
end

	
