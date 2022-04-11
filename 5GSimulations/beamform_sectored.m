
function pathexists = beamform_sectored(total_codebook,n, bf_index,gain_gaussian, angle_ue,threshold)
   
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
    
    antenna_gain = zeros(1, length(angle_ue));
    n_ueloc = sum(angle_ue' > linspace(0, 2*pi, total_codebook+1), 2)';

    %Comparison for every case adjust
    in_out= and(n_ueloc <= max(bf_index) , n_ueloc >= min(bf_index));
    if sum(in_out)>0
        antenna_gain(in_out) = sqrt(N_antenna);
    end
    
    w = sqrt(1/2)*(randn(1,1) +1i*randn(1, 1));

    y = s*gain_gaussian*antenna_gain' +w;
    
    res= 20*log10(abs(y ));
    
    if res <= threshold
        pathexists = 0;
    else
        pathexists = 1;
    end
    
end