method = 4;
n = 8:64;
m = 2; %defective


pmd = [0, 0.39,0.19, 0.12];
pfa = [0,0.05,0.19, 0.4]; 

if method == 1
    number_of_test_Hwang_prob =zeros(length(m), length(n),4);   
elseif method ==2
     number_of_test_freq_Hwang_prob = zeros(length(m), length(n),4);
elseif method ==3
    number_of_test_freq_Hwang_2seperate_prob =zeros(length(m), length(n),4);
else
    number_of_test_freq_GT_hwang_nocomingback_prob = zeros(length(m), length(n),4);
end


trial = 50;



blockage_Hwang = zeros(length(m), length(n),4);
md_hwang = zeros(length(m), length(n),4);

rng(1);
for tr = 1:trial
    for k = 1:4
        for j = 1:length(m)        
            for i = 1:length(n)
                location = [ones(1,m(j)), zeros(1,n(i)-m(j))];
                location = location(randperm(length(location))); 

                true_loc = find(location == 1 );
                if method == 1    
                    [beam_loc, n_steps, ~] = Hwang_gt(n(i), m(j),1:n(i),{}, location, 0, pmd(k), pfa(k));
                     number_of_test_Hwang_prob(j,i,k) = number_of_test_Hwang_prob(j,i,k) + n_steps;
                elseif method ==2
                    [beam_loc, n_steps] = freq_Hwang(n(i),m(j), 1:n(i), {}, location, 0, pmd(k), pfa(k));
                    number_of_test_freq_Hwang_prob(j,i,k) = number_of_test_freq_Hwang_prob(j,i,k) + n_steps;
                elseif method ==3
                    [beam_loc, n_steps] = GT_Prob_Seperate(n(i), m(j), location, pmd(k), pfa(k));
                    number_of_test_freq_Hwang_2seperate_prob(j,i,k) = number_of_test_freq_Hwang_2seperate_prob(j,i,k) + n_steps;
                else
                    [beam_loc, n_steps] = freq_GT_hwang_nocomingback(n(i),m(j), 1:n(i), {}, location, 0, pmd(k), pfa(k));
                    number_of_test_freq_GT_hwang_nocomingback_prob(j,i,k) = number_of_test_freq_GT_hwang_nocomingback_prob(j,i,k) + n_steps;
                end
                
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

blockage_Hwang = blockage_Hwang./trial;
md_hwang = md_hwang./trial;

if method ==1
    number_of_test_Hwang_prob = number_of_test_Hwang_prob./trial;
    save("number_of_test_Hwang_prob5m" + m+ ".mat", 'number_of_test_Hwang_prob')
    save("blockage_Hwang5m" + m + ".mat", 'blockage_Hwang' )
    save("md_hwang5m" + m+ ".mat", 'md_hwang' )
elseif method ==2
    number_of_test_freq_Hwang_prob =  number_of_test_freq_Hwang_prob./trial;
    save("number_of_test_freq_Hwang_prob5m" + m+ ".mat", 'number_of_test_freq_Hwang_prob')
    save("blockage_Hwang_f_5m" + m + ".mat", 'blockage_Hwang' )
    save("md_hwang_f_5m" + m+ ".mat", 'md_hwang' )
elseif method ==3
    number_of_test_freq_Hwang_2seperate_prob = number_of_test_freq_Hwang_2seperate_prob./trial;
    save("number_of_test_freq_Hwang_2seperate_prob5m" + m+ ".mat", 'number_of_test_freq_Hwang_2seperate_prob')
    save("blockage_Hwang_fs_5m" + m + ".mat", 'blockage_Hwang' )
    save("md_hwang_fs_5m" + m+ ".mat", 'md_hwang' )
else
    number_of_test_freq_GT_hwang_nocomingback_prob = number_of_test_freq_GT_hwang_nocomingback_prob./trial;
    save("number_of_test_freq_GT_hwang_nocomingback_prob5m" + m+ ".mat", 'number_of_test_freq_GT_hwang_nocomingback_prob')    
    save("blockage_Hwang_fn_5m" + m + ".mat", 'blockage_Hwang' )
    save("md_hwang_fn_5m" + m+ ".mat", 'md_hwang' )

end






