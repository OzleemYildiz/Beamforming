
function [pathexists, snr_2paths, snr_1path, count_2paths, count_1path] = beamform_sectored(total_codebook,n, bf_index,gain_gaussian, angle_ue,threshold)
   
    %This should not happen anyway as well but let's see
    if length(bf_index)==0
        pathexists=0;
        return;
    end
    
    %beamwidth adjust
    total_index = max(bf_index) - min(bf_index)+1;
    
    %gain adjust
    N_antenna = total_codebook/total_index;
    
    %threshold adjust
    %I take 64 as a base case
    threshold = threshold*sqrt(N_antenna/64);
    


    
    
    %Transmit power
    p_tx=20; %dBm
    %N_antenna= total_codebook;
    
    s = sqrt(10^((p_tx-30)/10)) ;    
    
    % If the angle is in, we apply a gain
    antenna_gain = zeros(1, length(angle_ue));
    
    %Check if the UE's location is in 
    n_ueloc = sum(angle_ue' > linspace(0, 2*pi, total_codebook+1), 2)';

    %Check which AoAs are in the angular interval that we are searching
    %in_out_check= and(n_ueloc <= max(bf_index) , n_ueloc >= min(bf_index));
    in_out = sum (n_ueloc' == bf_index,2)>0;
    
%     if sum(in_out_check== in_out') ~=length(antenna_gain)
%         fprintf('Error at sectored antenna with the bf power\n')
%     end
    
    if sum(in_out)>0
        antenna_gain(in_out) = sqrt(N_antenna);
    end
    

    w = sqrt(1/2)*(randn(1,1) +1i*randn(1, 1));

    y = s*gain_gaussian*antenna_gain' +w;
    
    res= 20*log10(abs(y));
    
    if res <= threshold
        pathexists = 0;
    else
        pathexists = 1;
    end
    
   
    
    %Addition for Multi-Level measuring
    % Measure the energy difference when there are two paths in the beam
   count_2paths = 0; 
   snr_2paths = 0;
   snr_1path = 0;
   count_1path =0;
   
   if sum(in_out)>=2  %There are at least two AoAs in the angular interval
       snr_2paths = res;
       count_2paths= 1;       
   elseif sum(in_out)==1 %There is only one AoA in the angular interval
       snr_1path = res;
       count_1path = 1;
   end
    
    
end