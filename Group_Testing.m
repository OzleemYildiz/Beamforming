n = 8:64;
m = 2:4; %defective
% 
% number_of_test_freq_Hwang = zeros(length(m), length(n));
% number_of_test_freq_GT_update =zeros(length(m), length(n));
%number_of_test_Hwang =zeros(length(m), length(n));
% number_of_test_freq_GT  =zeros(length(m), length(n));

number_of_test_freq_Hwang_2seperate =zeros(length(m), length(n));
trial = 1000000;


for tr = 1:trial
    for j = 1:length(m)        
        for i = 1:length(n)
            location = [ones(1,m(j)), zeros(1,n(i)-m(j))];
            location = location(randperm(length(location))); 
            
%             [beam_loc, n_steps] = Hwang_gt(n(i), m(j),1:n(i),{}, location, 0);
%             number_of_test_Hwang(j,i) = number_of_test_Hwang(j,i) + n_steps;
%             
%             [beam_loc, n_steps] = freq_GT(n(i),m(j), 1:n(i), {}, location,0, ceil(n(i)/2));
%             number_of_test_freq_GT(j,i) = number_of_test_freq_GT(j,i) + n_steps;
%             
%             [beam_loc, n_steps, ~] = freq_GT_update(n(i),m(j), 1:n(i), {}, location,0, ceil(n(i)/2));
%             number_of_test_freq_GT_update(j,i) = number_of_test_freq_GT_update(j,i) + n_steps;
%             
%             [beam_loc, n_steps] = freq_Hwang(n(i),m(j), 1:n(i), {}, location, 0);
%             number_of_test_freq_Hwang(j,i) = number_of_test_freq_Hwang(j,i) + n_steps;
            
              [beam_loc_1, n_steps_1] = Hwang_gt(ceil(n(i)/2), m(j),1:ceil(n(i)/2),{}, location(1:ceil(n(i)/2)), 0);
              [beam_loc_2, n_steps_2] = Hwang_gt(floor(n(i)/2), m(j),1:floor(n(i)/2),{}, location(ceil(n(i)/2)+1:end), 0);
              %Dont forget beam_loc_2 +16 is the actual result
              n_steps = max(n_steps_1, n_steps_2);
	      number_of_test_freq_Hwang_2seperate(j,i) = number_of_test_freq_Hwang_2seperate(j,i) + n_steps;
             
        end
        
    end
    	    
end

% number_of_test_freq_GT_update = number_of_test_freq_GT_update./trial;
% number_of_test_freq_Hwang =  number_of_test_freq_Hwang./trial;
number_of_test_freq_Hwang_2seperate = number_of_test_freq_Hwang_2seperate./trial;
% number_of_test_freq_GT =number_of_test_freq_GT./trial;
%number_of_test_Hwang = number_of_test_Hwang./trial;

% save('number_of_test_freq_Hwang', 'number_of_test_freq_Hwang')
% save('number_of_test_freq_GT', 'number_of_test_freq_GT')
% save('number_of_test_freq_GT_update', 'number_of_test_freq_GT_update')
% save('number_of_test_Hwang', 'number_of_test_Hwang')
save('number_of_test_freq_Hwang_2seperate', 'number_of_test_freq_Hwang_2seperate')


