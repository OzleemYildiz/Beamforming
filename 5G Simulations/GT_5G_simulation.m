N = 8:4:64;
m = 2; %defective, %clusters
threshold= [3, 6.5, 13, 20];



trial = 50000;


number_of_test_hex =zeros(length(m),length(N), length(threshold));
blockage_hex = zeros(length(m),length(N),  length(threshold));
md_hex = zeros(length(m), length(N), length(threshold));

for k = 1:length(N)
    resolution = (2*pi/N(k));
    N_antenna=  round(2*0.89/resolution);
    beam_locs = 0:2*0.89/N_antenna:pi;
    
    total_codebook = N(k)/2;
    
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

                [beam_loc, n_steps] = exhaustive_hybrid_5g(total_codebook, m(j), location, gain_gaussian, angle_ue, threshold(i));
                number_of_test_hex(j,k,i) = number_of_test_hex(j,k,i) + n_steps;

                res_hex = cell2mat(beam_loc);
                res_hex = unique(res_hex); 
                
                if length(res_hex) > m(j)
                     fprintf('error\n')
                end
                
                if isempty(res_hex)
                     blockage_hex(j,k,i) = blockage_hex(j,k,i) +1;
                     md_hex(j,k,i) = md_hex(j,k,i) + m(j);
                else   
                     if sum(true_loc == res_hex', 'all') == 0
                         blockage_hex(j,k,i) = blockage_hex(j,k,i) +1;
                         md_hex(j,k,i) = md_hex(j,k,i) + m(j);                     
                    elseif sum(true_loc == res_hex', 'all') ~= length(true_loc)
                         md_hex(j,k,i) = md_hex(j,k,i) + abs(length(true_loc) - sum(true_loc == res_hex', 'all'));

                     end
                end

            end

        end

    end
end

number_of_test_hex = number_of_test_hex./trial;
blockage_hex = blockage_hex./trial;
md_hex = md_hex./trial;


save('5gsimulation_ntest_hex_02_27_22', 'number_of_test_hex')
save('5gsimulation_blockage_hex_02_27_22', 'number_of_test_hex')
save('5gsimulation_md_hex_02_27_22', 'number_of_test_hex')
