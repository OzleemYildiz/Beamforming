
% Compare the energy level detection for 1 AoA in one angular interval and
% 2 AoA in one angular interval

% In order to justify multi-level, we need to demonstrate that the energy
% level helps us to determine

% I will check for only hybrid exhaustive
%method =1;
N = 2.^(3:7);
m = 4; %defective, %clusters
threshold= 12;
tic
%Multilevel initalization
count_2paths = zeros(length(N),1);
count_1path = zeros(length(N),1);
snr_2paths = zeros(length(N),1);
snr_1path = zeros(length(N),1);


trial = 100;

%Since this simulation is for multilevel measuring
multilevel =1;

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
                %Because of ULA antenna array, angles of user is limited to be
                %in [0, pi]. I should decide allocations and make changes to
                %search only in this region. 
               
                [gain_gaussian, angle_ue] = channel(m(j), multilevel); 


                %Where are the locations of the angles
                %I compare with the beams ending locations and sum to find the
                %index

                %true_loc = sum(angle_ue' > beam_locs,2)';
                true_loc = locate_AoA_index_hierarchical(angle_ue, N(k));
                %true_loc = sum(angle_ue' > linspace(0, 2*pi, N(k)+1), 2)';

                
                % Again create a location array for indeces in beamforming 
                location(true_loc)=1;
                
   
                [beam_loc, n_steps, snr_2paths_i, snr_1path_i, count_2paths_i,count_1path_i ] = exhaustive_hybrid_5g_multi(total_codebook, m(j), location, gain_gaussian, angle_ue, threshold(i));
                    
                count_2paths(k) = count_2paths(k)+count_2paths_i;
                count_1path(k) = count_1path(k)+count_1path_i;
                snr_2paths(k) = snr_2paths(k)+snr_2paths_i;
                snr_1path(k) = snr_1path(k)+snr_1path_i;

                res_hex = cell2mat(beam_loc);
                res_hex = unique(res_hex); 
                
                if length(res_hex) > m(j)
                     %fprintf('error\n')
                end
                
                

            end

        end

    end
end

toc
snr_1path = snr_1path./count_1path;
snr_2paths = snr_2paths./count_2paths;


save('snr_1path_angledifference_01', 'snr_1path')
save('snr_2paths_angledifference_01', 'snr_2paths')
