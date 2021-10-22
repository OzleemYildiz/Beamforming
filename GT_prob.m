n = 8:64;
m = 2; %defective

number_of_test_freq_Hwang_prob = zeros(length(m), length(n));
number_of_test_Hwang_prob =zeros(length(m), length(n));
number_of_test_freq_Hwang_2seperate_prob =zeros(length(m), length(n));
number_of_test_freq_GT_hwang_nocomingback_prob = zeros(length(m), length(n));
trial = 1000000;

% pmd = 0;
% pfa = 0;
% 
% pmd = 0.19;
% pfa = 0.19;
% 
% pmd = 0.12;
% pfa = 0.4;

pmd =0.39;
pfa = 0.05;

blockage_Hwang = zeros(length(m), length(n));
md_hwang = zeros(length(m), length(n));

rng(1);
for tr = 1:trial
    for k = 1:1
        for j = 1:length(m)        
            for i = 1:length(n)
                location = [ones(1,m(j)), zeros(1,n(i)-m(j))];
                location = location(randperm(length(location))); 

                true_loc = find(location == 1 );
                
%                 [beam_loc, n_steps, ~] = Hwang_gt(n(i), m(j),1:n(i),{}, location, 0, pmd(k), pfa(k));
%                 number_of_test_Hwang_prob(j,i,k) = number_of_test_Hwang_prob(j,i,k) + n_steps;
% 
%                 
%                  [beam_loc, n_steps] = freq_Hwang(n(i),m(j), 1:n(i), {}, location, 0, pmd(k), pfa(k));
%                  number_of_test_freq_Hwang_prob(j,i,k) = number_of_test_freq_Hwang_prob(j,i,k) + n_steps;
                

                [beam_loc_1, n_steps_1, valid_loc1] = Hwang_gt(ceil(n(i)/2), ceil(m(j)/2),1:ceil(n(i)/2),{}, location, 0, pmd(k), pfa(k));
    
                [beam_loc_2, n_steps_2, valid_loc2] = Hwang_gt(floor(n(i)/2), floor(m(j)/2),ceil(n(i)/2) + 1:n(i),{}, location, 0, pmd(k), pfa(k));
                
                beam_loc_3 = {};
                n_steps_3 = 0; 
                
                %temp = cell2mat(beam_loc_2) + ceil(n(i)/2); /no need
                tot_beam = size(cell2mat(beam_loc_1),2) + size(cell2mat(beam_loc_2),2);
                if tot_beam ~= m(j)
                    rest = m(j) - tot_beam;
                    if ceil(m(j)/2) == size(cell2mat(beam_loc_1),2)
                        [beam_loc_3, n_steps_3, ~] = Hwang_gt(size(valid_loc1,2), rest,valid_loc1,{}, location, 0, pmd(k), pfa(k));
                    elseif floor(m(j)/2) == size(cell2mat(beam_loc_2),2)
                        [beam_loc_3, n_steps_3, ~] = Hwang_gt(size(valid_loc2,2), rest,valid_loc2,{}, location, 0, pmd(k), pfa(k));
                    end
                end
                beam_loc = [beam_loc_1, beam_loc_2, beam_loc_3];
                
                
                n_steps = max(n_steps_1, n_steps_2) + n_steps_3;
                
                number_of_test_freq_Hwang_2seperate_prob(j,i,k) = number_of_test_freq_Hwang_2seperate_prob(j,i,k) + n_steps;

                 
%                  [beam_loc, n_steps] = freq_GT_hwang_nocomingback(n(i),m(j), 1:n(i), {}, location, 0, pmd(k), pfa(k));
%                  number_of_test_freq_GT_hwang_nocomingback_prob(j,i,k) = number_of_test_freq_GT_hwang_nocomingback_prob(j,i,k) + n_steps;
                  
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

%number_of_test_Hwang_prob = number_of_test_Hwang_prob./trial;
%number_of_test_freq_Hwang_prob =  number_of_test_freq_Hwang_prob./trial;
number_of_test_freq_Hwang_2seperate_prob = number_of_test_freq_Hwang_2seperate_prob./trial;
%number_of_test_freq_GT_hwang_nocomingback_prob = number_of_test_freq_GT_hwang_nocomingback_prob./trial;

blockage_Hwang = blockage_Hwang./trial;
md_hwang = md_hwang./trial;


% save("number_of_test_Hwang_prob11pmd" + pmd+ "pfa" + pfa + "m" + m+ ".mat", 'number_of_test_Hwang_prob')
% save("number_of_test_freq_Hwang_prob11pmd" + pmd+ "pfa" + pfa + "m" + m+ ".mat", 'number_of_test_freq_Hwang_prob')
save("number_of_test_freq_Hwang_2seperate_prob1pmd" + pmd+ "pfa" + pfa + "m" + m+ ".mat", 'number_of_test_freq_Hwang_2seperate_prob')
% save("number_of_test_freq_GT_hwang_nocomingback_prob11pmd" + pmd+ "pfa" + pfa + "m" + m+ ".mat", 'number_of_test_freq_GT_hwang_nocomingback_prob')
% 
% 
save("blockage_Hwangpmd" + pmd+ "pfa" + pfa + "m" + m + ".mat", 'blockage_Hwang' )
save("md_hwangpmd" + pmd+ "pfa" + pfa + "m" + m+ ".mat", 'md_hwang' )
