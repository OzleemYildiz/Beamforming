N = 8:2:64;
m = 2:4; %defective, %clusters
threshold= [3, 6.5, 13];



trial = 1000000;


number_of_test_hex =zeros(length(m), length(threshold));
blockage_hex = zeros(length(m), length(threshold));
md_hex = zeros(length(m), length(threshold));

for j = 1:length(m)        
    for i = 1:length(threshold)
        for tr = 1:trial  
            
            %Because of ULA antenna array, angles of user is limited to be
            %in [0, pi]. I should decide allocations and make changes to
            %search only in this region. 
            [gain_gaussian, angle_ue] = channel(m(j));
            resolution = (2*pi/N);
            N_antenna=  round(2*0.89/resolution);
            beam_locs = 0:2*0.89/N_antenna:pi;
            
            %Where are the locations of the angles
            %I compare with the beams ending locations and sum to find the
            %index
            
            true_loc = sum(angle_ue' > beam_locs,2);
            
            %2*0.89/N is the beamwidth of [0,2*pi],thats why N/2 is the
            %codebook for[0, pi]    
            % Again create a location array for indeces in beamforming 
            location = zeros(1, N/2);
            total_codebook = N/2;
            location(true_loc)=1;
            
            [beam_loc, n_steps] = exhaustive_hybrid_5g(N, m(j), location, gain_gaussian, angle_ue, threshold(i));

             
             res_hex = cell2mat(beam_loc);
             if length(res_hex) > m(j)
                 fprintf('error\n')
             end
             
             if isempty(res_hex)
                 blockage_hex(j,i) = blockage_hex(j,i) +1;
             else   
                 if sum(true_loc == res_hex', 'all') == 0
                     blockage_hex(j,i) = blockage_hex(j,i) +1;
                 end
                 if sum(true_loc == res_hex', 'all') ~= m(j)
                     md_hex(j,i) = md_hex(j,i) + abs(m(j) - sum(true_loc == res_hex', 'all'));
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
