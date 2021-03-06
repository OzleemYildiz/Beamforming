%method =1 (exhaustive), 2 (AGTBA), 3 (HGTBA_1),  4 (HGTBA_3), 5 (HGTBA_2)
method =3;
N = 2.^(3:6); %Number of angular intervals
m = 3; %defective, %clusters
threshold=-10:30; %SNR

tic
trial = 10000;

beam_type =1; %sectored, 2 hierarchical, 3 dft

n_rf = 4; %method 1 and 3 have the option

%I am not measuring multilevel
multilevel= 0;

n_test_fs_gt = zeros(length(m),length(N), length(threshold));
number_of_test_hwang =zeros(length(m),length(N), length(threshold));
number_of_test_hex =zeros(length(m),length(N), length(threshold));
n_test_f_ack_gt = zeros(length(m),length(N), length(threshold));
n_test_f_gt = zeros(length(m),length(N), length(threshold));

blockage = zeros(length(m),length(N),  length(threshold));
md = zeros(length(m), length(N), length(threshold));
for k = 1:length(N)
%     resolution = (2*pi/N(k));
%     N_antenna=  round(2*0.89/resolution);
%     beam_locs = 0:resolution:pi;
    
    %total_codebook = N(k)/4; %search over pi/2

    
    for j = 1:length(m)        
        for i = 1:length(threshold)
            for tr = 1:trial  
                total_codebook = N(k);
                location = zeros(1, N(k));
                
%  
                %Because of ULA antenna array, angles of user is limited to be
                %in [0, pi]. I should decide allocations and make changes to
                %search only in this region. 
               
                [gain_gaussian, angle_ue] = channel(m(j), multilevel); 


                %Where are the locations of the angles
                %I compare with the beams ending locations and sum to find the
                %index

                %true_loc = sum(angle_ue' > beam_locs,2)';
                %true_loc = locate_AoA_index(angle_ue, N);
                %true_loc = sum(angle_ue' > linspace(0, 2*pi, N(k)+1), 2)';

                %Locating for Hierarchical Codebook
                if beam_type ==1 %Sectored
                    true_loc = sum(angle_ue' > linspace(0, 2*pi, N(k)+1), 2)';
                    if true_loc >32
                        fprintf('error\n');
                    end
                elseif beam_type ==2 %Hierarchical
                    true_loc = locate_AoA_index_hierarchical(angle_ue, N(k));
                elseif beam_type ==3  %DFT   
                    true_loc = locate_AoA_index(angle_ue, N(k));
                end
                
                %2*0.89/N is the beamwidth of [0,2*pi],thats why N/2 is the
                %codebook for[0, pi]    
                % Again create a location array for indeces in beamforming 
                location(true_loc)=1;
                
                 if method == 1    
                    [beam_loc, n_steps] = exhaustive_hybrid_5g(total_codebook, m(j), location, gain_gaussian, angle_ue, threshold(i), beam_type, n_rf);
                    number_of_test_hex(j,k,i) = number_of_test_hex(j,k,i) + n_steps;
                 elseif method ==2
                    [beam_loc, n_steps, valid_loc] = hwang_5g(total_codebook, N(k),m(j), 1:total_codebook,{}, location, 0, 1, gain_gaussian, angle_ue, threshold(i), beam_type);
                     number_of_test_hwang(j,k,i) = number_of_test_hwang(j,k,i) + n_steps;
                 elseif method==3
                      [beam_loc, n_steps] = gt_seperate_5g(total_codebook,m(j), location, gain_gaussian, angle_ue, threshold(i),beam_type, n_rf);
                      n_test_fs_gt(j,k,i) = n_test_fs_gt(j,k,i) + n_steps;
                 elseif method==4
                      [beam_loc, n_steps] = parallel_gt_ack_5g_2(total_codebook,N(k),m(j),1:total_codebook,{}, location,0, gain_gaussian, angle_ue, threshold(i));
                      n_test_f_ack_gt(j,k,i) = n_test_f_ack_gt(j,k,i) + n_steps;
                 elseif method==5
                      [beam_loc, n_steps] = parallel_gt_5g_2(total_codebook,N(k),m(j),1:total_codebook,{}, location,0, gain_gaussian, angle_ue, threshold(i));
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

toc

number_of_test_hex = number_of_test_hex./trial;
number_of_test_hwang= number_of_test_hwang./trial;
n_test_fs_gt = n_test_fs_gt./trial;
n_test_f_ack_gt = n_test_f_ack_gt./trial;
n_test_f_gt = n_test_f_gt./trial;
blockage = blockage./trial;
md = md./trial;

if method == 1
    if beam_type==1
        save("5gsimulation_ntest_hex_05_03_sectored_nrf" +n_rf+"_m"+m, 'number_of_test_hex')
        save("5gsimulation_blockage_hex_05_03_sectored_nrf" +n_rf+"_m"+m, 'blockage')
        save("5gsimulation_md_hex_05_03_sectored_nrf" +n_rf+"_m"+m, 'md')
    elseif beam_type==2
        save('5gsimulation_ntest_hex_05_03_hierarchical', 'number_of_test_hex')
        save('5gsimulation_blockage_hex_05_03_hierarchical', 'blockage')
        save('5gsimulation_md_hex_05_03_hierarchical', 'md')
     elseif beam_type==3
        save('5gsimulation_ntest_hex_05_03_dft', 'number_of_test_hex')
        save('5gsimulation_blockage_hex_05_03_dft', 'blockage')
        save('5gsimulation_md_hex_05_03_dft', 'md')
    end
elseif method ==2
    save('5gsimulation_ntest_hwang_05_03_hierarchical', 'number_of_test_hwang')
    save('5gsimulation_blockage_hwang_05_03_hierarchical', 'blockage')
    save('5gsimulation_md_hwang_05_03_hierarchical', 'md')
elseif method ==3
    save("5gsimulation_ntest_fs_gt_05_03_sectored_nrf" +n_rf+"_m"+m, 'n_test_fs_gt')
    save("5gsimulation_blockage_fs_gt_05_03_sectored_nrf" +n_rf+"_m"+m, 'blockage')
    save("5gsimulation_md_fs_gt_05_03_sectored_nrf" +n_rf+"_m"+m, 'md')
elseif method ==4
    save('5gsimulation_ntest_f_ack_gt_05_03_hierarchical', 'n_test_f_ack_gt')
    save('5gsimulation_blockage_f_ack_gt_05_03_hierarchical', 'blockage')
    save('5gsimulation_md_f_ack_gt_05_03_hierarchical', 'md')
elseif method ==5
    save('5gsimulation_ntest_f_gt_05_03_hierarchical', 'n_test_f_gt')
    save('5gsimulation_blockage_f_gt_05_03_hierarchical', 'blockage')
    save('5gsimulation_md_f_gt_05_03_hierarchical', 'md')
end

