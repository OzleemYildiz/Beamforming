n = 8:64;
m = 2:4; %defective


number_of_test_freq_Hwang_prob = zeros(length(m), length(n),3);
number_of_test_Hwang_prob =zeros(length(m), length(n), 3);
number_of_test_freq_Hwang_2seperate_prob =zeros(length(m), length(n),3);
number_of_test_freq_GT_hwang_nocomingback_prob = zeros(length(m), length(n),3);
trial = 100;

pmd = [0.19, 0.12, 0.39];
pfa = [0.19, 0.4 , 0.05];

blockage_Hwang = zeros(length(m), length(n),3);
md_hwang = zeros(length(m), length(n),3);


for tr = 1:trial
    for k = 1:3
        for j = 1:length(m)        
            for i = 1:length(n)
                location = [ones(1,m(j)), zeros(1,n(i)-m(j))];
                location = location(randperm(length(location))); 

                true_loc = find(location == 1 );
                
%                 [beam_loc, n_steps] = Hwang_gt(n(i), m(j),1:n(i),{}, location, 0, pmd(k), pfa(k));
%                 number_of_test_Hwang_prob(j,i,k) = number_of_test_Hwang_prob(j,i,k) + n_steps;
% 
%                 
%                  [beam_loc, n_steps] = freq_Hwang(n(i),m(j), 1:n(i), {}, location, 0, pmd(k), pfa(k));
%                  number_of_test_freq_Hwang_prob(j,i,k) = number_of_test_freq_Hwang_prob(j,i,k) + n_steps;
                

%                 [beam_loc_1, n_steps_1] = Hwang_gt(ceil(n(i)/2), m(j),1:ceil(n(i)/2),{}, location(1:ceil(n(i)/2)), 0, pmd(k), pfa(k));
%     
%                 [beam_loc_2, n_steps_2] = Hwang_gt(floor(n(i)/2), m(j),1:floor(n(i)/2),{}, location(ceil(n(i)/2)+1:end), 0, pmd(k), pfa(k));
%                 
%                 temp = cell2mat(beam_loc_2) +16;
%                 beam_loc = [beam_loc_1, temp];
%                 n_steps = max(n_steps_1, n_steps_2);
%                 number_of_test_freq_Hwang_2seperate_prob(j,i,k) = number_of_test_freq_Hwang_2seperate_prob(j,i,k) + n_steps;

                 
                 [beam_loc, n_steps] = freq_GT_hwang_nocomingback(n(i),m(j), 1:n(i), {}, location, 0, pmd(k), pfa(k));
                 number_of_test_freq_GT_hwang_nocomingback_prob(j,i,k) = number_of_test_freq_GT_hwang_nocomingback_prob(j,i,k) + n_steps;
                  
                 res_beam = cell2mat(beam_loc);
                 if isempty(res_beam)
                     blockage_Hwang(j,i,k) = blockage_Hwang(j,i,k) +1;
                 else   
                     if sum(true_loc == res_beam', 'all') == 0
                         blockage_Hwang(j,i,k) = blockage_Hwang(j,i,k) +1;
                     end
                     if sum(true_loc == res_beam', 'all') ~= m(j)
                         md_hwang(j,i,k) = md_hwang(j,i,k) + abs(m(j) - sum(true_loc == res_beam', 'all'));
                     end
                 end

            end

        end
    end	    
end

% number_of_test_Hwang_prob = number_of_test_Hwang_prob./trial;
%number_of_test_freq_Hwang_prob =  number_of_test_freq_Hwang_prob./trial;
%number_of_test_freq_Hwang_2seperate_prob = number_of_test_freq_Hwang_2seperate_prob./trial;
number_of_test_freq_GT_hwang_nocomingback_prob = number_of_test_freq_GT_hwang_nocomingback_prob./trial;

blockage_Hwang = blockage_Hwang./trial;
md_hwang = md_hwang./trial;


% save('number_of_test_Hwang_prob', 'number_of_test_Hwang_prob')
%save('number_of_test_freq_Hwang_prob', 'number_of_test_freq_Hwang_prob')
%save('number_of_test_freq_Hwang_2seperate_prob', 'number_of_test_freq_Hwang_2seperate_prob')
save('number_of_test_freq_GT_hwang_nocomingback_prob', 'number_of_test_freq_GT_hwang_nocomingback_prob')


save('blockage_Hwang', 'blockage_Hwang' )
save('md_hwang', 'md_hwang' )