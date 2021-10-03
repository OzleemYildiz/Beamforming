n = 8:64;
m = 2:4; %defective

number_of_test_freq_Hwang = zeros(length(m), length(n));
number_of_test_freq_GT_update =zeros(length(m), length(n));
number_of_test_Hwang =zeros(length(m), length(n));
number_of_test_freq_GT  =zeros(length(m), length(n));
trial = 10000000;

for tr = 1:trial
    for j = 1:length(m)        
        for i = 1:length(n)
            location = [ones(1,m(j)), zeros(1,n(i)-m(j))];
            location = location(randperm(length(location))); 
            
            [beam_loc, n_steps] = Hwang_gt(n(i), m(j),1:n(i),{}, location, 0);
            number_of_test_Hwang(j,i) = number_of_test_Hwang(j,i) + n_steps;
            
            [beam_loc, n_steps] = freq_GT(n(i),m(j), 1:n(i), {}, location,0, ceil(n(i)/2));
            number_of_test_freq_GT(j,i) = number_of_test_freq_GT(j,i) + n_steps;
            
            [beam_loc, n_steps, ~] = freq_GT_update(n(i),m(j), 1:n(i), {}, location,0, ceil(n(i)/2));
            number_of_test_freq_GT_update(j,i) = number_of_test_freq_GT_update(j,i) + n_steps;
            
            [beam_loc, n_steps] = freq_Hwang(n(i),m(j), 1:n(i), {}, location, 0);
            number_of_test_freq_Hwang(j,i) = number_of_test_freq_Hwang(j,i) + n_steps;
      
        end
        
    end
end

number_of_test_freq_Hwang =  number_of_test_freq_Hwang./trial;
number_of_test_freq_GT_update = number_of_test_freq_GT_update./trial;
number_of_test_freq_GT =number_of_test_freq_GT./trial;
number_of_test_Hwang = number_of_test_Hwang./trial;

save('number_of_test_freq_Hwang', 'number_of_test_freq_Hwang')
save('number_of_test_freq_GT', 'number_of_test_freq_GT')
save('number_of_test_freq_GT_update', 'number_of_test_freq_GT_update')
save('number_of_test_Hwang', 'number_of_test_Hwang')


