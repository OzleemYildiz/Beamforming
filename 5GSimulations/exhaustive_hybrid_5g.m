%Hybrid Exhaustive search with beamforming
%function pathexists = beamform(total_codebook, bf_index,gain_gaussian, angle_ue,threshold)
%indeces will be checked through beamform function instead of putting yes.

function [beam_loc, n_steps] = exhaustive_hybrid_5g(n, m, location, gain_gaussian, angle_ue, threshold, beam_type, n_rf)
  
    beam_loc = {};
    n_steps= 0;
    for ex = 1:n_rf:n
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
        %[pathexists_1] = beamform_sectored(n,n, ex,gain_gaussian, angle_ue, threshold);
        if beam_type==1
            [pathexists_1] = beamform_sectored(n,n, ex,gain_gaussian, angle_ue, threshold);
        elseif beam_type==2
            [pathexists_1] = beamform_hierarchical(n,n, ex,gain_gaussian, angle_ue, threshold);
        elseif beam_type==3
            [pathexists_1] = beamform_dft(n,n, ex,gain_gaussian, angle_ue, threshold);
        end

        if pathexists_1 %ACK
            beam_loc = [beam_loc, ex];
            m = m-1;
        end
        
        for k = 1:n_rf-1
            if ex+k <= n
                %check_ex_2 = location(ex+1) == 0; % =0 ,ACK
                %[pathexists_2] = beamform_sectored(n,n, ex+1, gain_gaussian, angle_ue, threshold);
                if beam_type==1                
                    [pathexists_2] = beamform_sectored(n,n, ex+k, gain_gaussian, angle_ue, threshold);
                elseif beam_type==2
                    [pathexists_2] = beamform_hierarchical(n,n, ex+k, gain_gaussian, angle_ue, threshold);
                elseif beam_type==3
                    [pathexists_2] = beamform_dft(n,n, ex+k,gain_gaussian, angle_ue, threshold);
                end

                %ACK
                if pathexists_2 && m ~=0
                    beam_loc = [beam_loc, ex+k];
                    m = m-1;
                end
            end
        end

    end
end