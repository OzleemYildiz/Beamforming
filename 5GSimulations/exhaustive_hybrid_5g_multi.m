%Hybrid Exhaustive search with beamforming
%function pathexists = beamform(total_codebook, bf_index,gain_gaussian, angle_ue,threshold)
%indeces will be checked through beamform function instead of putting yes.

function [beam_loc, n_steps, snr_2paths, snr_1path, count_2paths,count_1path] = exhaustive_hybrid_5g_multi(n, m, location, gain_gaussian, angle_ue, threshold)
    %I nitalization for multi-level
    count_2paths = 0;
    snr_2paths = 0;
    snr_1path = 0;
    count_1path = 0;
    
    
    beam_loc = {};
    n_steps= 0;
    for ex = 1:2:n
        if m ==0
            return;
        end 
        
        if ex == n-m+1
           beam_loc = [beam_loc, ex:n]; 
           return;
        end
               
        
        n_steps = n_steps +1;
        %check_ex_1 = location(ex) == 0; % =0 ,ACK
        
        %Perform beamforming and =1 is ACK
        [pathexists_1, snr_2paths_1, snr_1path_1, count_2paths_1, count_1path_1] = beamform_sectored(n,n, ex,gain_gaussian, angle_ue, threshold);


        if pathexists_1 %ACK
            beam_loc = [beam_loc, ex];
            m = m-1;
        end
        
        if ex+1 <= n
            %check_ex_2 = location(ex+1) == 0; % =0 ,ACK
            [pathexists_2, snr_2paths_2, snr_1path_2, count_2paths_2,count_1path_2] = beamform_sectored(n,n, ex+1, gain_gaussian, angle_ue, threshold);

            %ACK
            if pathexists_2 && m ~=0
                beam_loc = [beam_loc, ex+1];
                m = m-1;
            end
            
            %Addition for Multi-level measuring
            count_2paths = count_2paths + count_2paths_1 + count_2paths_2;
            count_1path = count_1path + count_1path_1 + count_1path_2;
            snr_2paths = snr_2paths + snr_2paths_1 + snr_2paths_2;
            snr_1path = snr_1path+ snr_1path_1 + snr_1path_2;
        else
            count_1path = count_1path + count_1path_1;
            count_2paths = count_2paths+ count_2paths_1;
            snr_2paths = snr_2paths +snr_2paths_1;
            snr_1path = snr_1path +snr_1path_1;
        end
               

    end
end