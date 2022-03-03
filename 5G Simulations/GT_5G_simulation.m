method =1;
N = 64;
m = 2; %defective, %clusters
threshold= [3, 6.5, 13, 20];



trial = 200;


n_test_fs_gt = zeros(length(m),length(N), length(threshold));
number_of_test_hwang =zeros(length(m),length(N), length(threshold));
number_of_test_hex =zeros(length(m),length(N), length(threshold));
n_test_f_ack_gt = zeros(length(m),length(N), length(threshold));
n_test_f_gt = zeros(length(m),length(N), length(threshold));

blockage = zeros(length(m),length(N),  length(threshold));
md = zeros(length(m), length(N), length(threshold));

for k = 1:length(N)
    resolution = (2*pi/N(k));
    N_antenna=  round(2*0.89/resolution);
    beam_locs = 0:2*0.89/N_antenna:pi;
    
    total_codebook = N(k)/4; %search over pi/2
    
    for j = 1:length(m)        
        for i = 1:length(threshold)
            for tr = 1:trial  
                location = zeros(1, N(k)/2);
                %Because of ULA antenna array, angles of user is limited to be
                %in [0, pi]. I should decide allocations and make changes to
                %search only in this region. 
                [gain_gaussian, angle_ue] = channel(m(j));


                %Where are the locations of the angles
                %I compare with the beams ending locations and sum to find the
                %index

                true_loc = sum(angle_ue' > beam_locs,2)';

                %2*0.89/N is the beamwidth of [0,2*pi],thats why N/2 is the
                %codebook for[0, pi]    
                % Again create a location array for indeces in beamforming 
                location(true_loc)=1;
                
                 if method == 1    
                    [beam_loc, n_steps] = exhaustive_hybrid_5g(total_codebook, m(j), location, gain_gaussian, angle_ue, threshold(i));
                    number_of_test_hex(j,k,i) = number_of_test_hex(j,k,i) + n_steps;
                 elseif method ==2
                    [beam_loc, n_steps, valid_loc] = hwang_5g(total_codebook,m(j), 1:total_codebook,{}, location, 0, 1, gain_gaussian, angle_ue, threshold(i));
                     number_of_test_hwang(j,k,i) = number_of_test_hwang(j,k,i) + n_steps;
                 elseif method==3
                      [beam_loc, n_steps] = gt_seperate_5g(total_codebook,m(j), location, gain_gaussian, angle_ue, threshold);
                      n_test_fs_gt(j,k,i) = n_test_fs_gt(j,k,i) + n_steps;
                 elseif method==4
                      [beam_loc, n_steps] = parallel_gt_ack_5g(total_codebook,m(j),1:total_codebook,{}, location,0, gain_gaussian, angle_ue, threshold(i));
                      n_test_f_ack_gt(j,k,i) = n_test_f_ack_gt(j,k,i) + n_steps;
                 elseif method==5
                      [beam_loc, n_steps] = parallel_gt_5g(total_codebook,m(j),1:total_codebook,{}, location,0, gain_gaussian, angle_ue, threshold(i));
                      n_test_f_gt(j,k,i) = n_test_f_gt(j,k,i) + n_steps;
                 end


                res_hex = cell2mat(beam_loc);
                res_hex = unique(res_hex); 
                
                if length(res_hex) > m(j)
                     %fprintf('error\n')
                end
                
                if isempty(res_hex)
                     blockage(j,k,i) = blockage(j,k,i) +1;
                     md(j,k,i) = md(j,k,i) + m(j);
                else   
                     if sum(true_loc == res_hex', 'all') == 0
                         blockage(j,k,i) = blockage(j,k,i) +1;
                         md(j,k,i) = md(j,k,i) + m(j);                     
                    elseif sum(true_loc == res_hex', 'all') ~= length(true_loc)
                         md(j,k,i) = md(j,k,i) + abs(length(true_loc) - sum(true_loc == res_hex', 'all'));

                     end
                end

            end

        end

    end
end

number_of_test_hex = number_of_test_hex./trial;
number_of_test_hwang= number_of_test_hwang./trial;
n_test_fs_gt = n_test_fs_gt./trial;
n_test_f_ack_gt = n_test_f_ack_gt./trial;
n_test_f_gt = n_test_f_gt./trial;
blockage = blockage./trial;
md = md./trial;

if method == 1
    save('5gsimulation_ntest_hex_03_01_threshold', 'number_of_test_hex')
    save('5gsimulation_blockage_hex_03_01_threshold', 'blockage')
    save('5gsimulation_md_hex_03_01_threshold', 'md')
elseif method ==2
    save('5gsimulation_ntest_hwang_03_01_threshold', 'number_of_test_hwang')
    save('5gsimulation_blockage_hwang_03_01_threshold', 'blockage')
    save('5gsimulation_md_hwang_03_01_threshold', 'md')
elseif method ==3
    save('5gsimulation_ntest_fs_gt_03_01_threshold', 'n_test_fs_gt')
    save('5gsimulation_blockage_fs_gt_03_01_threshold', 'blockage')
    save('5gsimulation_md_fs_gt_03_01_threshold', 'md')
elseif method ==4
    save('5gsimulation_ntest_f_ack_gt_03_01_threshold', 'n_test_f_ack_gt')
    save('5gsimulation_blockage_f_ack_gt_03_01_threshold', 'blockage')
    save('5gsimulation_md_f_ack_gt_03_01_threshold', 'md')
elseif method ==5
    save('5gsimulation_ntest_f_gt_03_01_threshold', 'n_test_f_gt')
    save('5gsimulation_blockage_f_gt_03_01_threshold', 'blockage')
    save('5gsimulation_md_f_gt_03_01_threshold', 'md')
end
