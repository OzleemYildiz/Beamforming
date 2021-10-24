method = 1; %1-5, GBS, GT1(both ack), GT3(seperate), GT2 (One ack), Exhaustive, Jyotish
n = 8:64;
m =2; %defective


pmd = [0, 0.39,0.19, 0.12];
pfa = [0,0.05,0.19, 0.4]; 

if method == 1
    n_test_Hwang =zeros(length(m), length(n),4);   
elseif method ==2
     n_test_f_gt = zeros(length(m), length(n),4);
elseif method ==3
    n_test_fs_gt =zeros(length(m), length(n),4);
elseif method == 4
    n_test_fn_gt = zeros(length(m), length(n),4);
elseif method == 5
    n_test_ex = zeros(length(m), length(n),4);
end


trial = 500000;



blockage_Hwang = zeros(length(m), length(n),4);
md_hwang = zeros(length(m), length(n),4);

rng(1);
for tr = 1:trial
    parfor k = 1:4
        for j = 1:length(m)        
            for i = 1:length(n)
                location = [ones(1,m(j)), zeros(1,n(i)-m(j))];
                location = location(randperm(length(location))); 

                true_loc = find(location == 1 );
                if method == 1    
                    [beam_loc, n_steps, ~] = Hwang_gt(n(i), m(j),1:n(i),{}, location, 0, pmd(k), pfa(k));
                     n_test_Hwang(j,i,k) = n_test_Hwang(j,i,k) + n_steps;
                elseif method ==2
                    [beam_loc, n_steps] = freq_Hwang(n(i),m(j), 1:n(i), {}, location, 0, pmd(k), pfa(k));
                    n_test_f_gt(j,i,k) = n_test_f_gt(j,i,k) + n_steps;
                elseif method ==3
                    [beam_loc, n_steps] = GT_Prob_Seperate(n(i), m(j), location, pmd(k), pfa(k));
                    n_test_fs_gt(j,i,k) = n_test_fs_gt(j,i,k) + n_steps;
                elseif method ==4
                    [beam_loc, n_steps] = freq_GT_hwang_nocomingback(n(i),m(j), 1:n(i), {}, location, 0, pmd(k), pfa(k));
                    n_test_fn_gt(j,i,k) = n_test_fn_gt(j,i,k) + n_steps;
                elseif method ==5
                    [beam_loc, n_steps] = exhaustive_hybrid(n(i), m(j), location, pmd(k), pfa(k));
                    n_test_ex(j,i,k) = n_test_ex(j,i,k) +n_steps;
                end
                
                res_beam = cell2mat(beam_loc);
                res_beam = unique(res_beam);
                if isempty(res_beam)
                     blockage_Hwang(j,i,k) = blockage_Hwang(j,i,k) +1;
                     md_hwang(j,i,k) = md_hwang(j,i,k) + m(j);
                else   
                     if sum(true_loc == res_beam', 'all') == 0
                         blockage_Hwang(j,i,k) = blockage_Hwang(j,i,k) +1;
                         md_hwang(j,i,k) = md_hwang(j,i,k) + m(j);                     
                    elseif sum(true_loc == res_beam', 'all') ~= m(j)
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
    n_test_Hwang = n_test_Hwang./trial;
    save("final_n_test_Hwang_5m" + m+ ".mat", 'n_test_Hwang')
    save("final_blockage_Hwang5m" + m + ".mat", 'blockage_Hwang' )
    save("final_md_hwang5m" + m+ ".mat", 'md_hwang' )
elseif method ==2
    n_test_f_gt =  n_test_f_gt./trial;
    save("final_n_test_f_gt_5m" + m+ ".mat", 'n_test_f_gt')
    save("final_blockage_Hwang_f_5m" + m + ".mat", 'blockage_Hwang' )
    save("final_md_hwang_f_5m" + m+ ".mat", 'md_hwang' )
elseif method ==3
    n_test_fs_gt = n_test_fs_gt./trial;
    save("final_n_test_fs_gt_5m" + m+ ".mat", 'n_test_fs_gt')
    save("final_blockage_Hwang_fs_5m" + m + ".mat", 'blockage_Hwang' )
    save("final_md_hwang_fs_5m" + m+ ".mat", 'md_hwang' )
elseif method ==4
    n_test_fn_gt = n_test_fn_gt./trial;
    save("final_n_test_fn_gt_5m" + m+ ".mat", 'n_test_fn_gt')    
    save("final_blockage_Hwang_fn_5m" + m + ".mat", 'blockage_Hwang' )
    save("final_md_hwang_fn_5m" + m+ ".mat", 'md_hwang' )
elseif method ==5
    n_test_ex = n_test_ex./trial;
    save("final_n_test_ex_5m" + m+ ".mat", 'n_test_ex')    
    save("final_blockage_ex_5m" + m + ".mat", 'blockage_Hwang' )
    save("final_md_ex_5m" + m+ ".mat", 'md_hwang' )
end






