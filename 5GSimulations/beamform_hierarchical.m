function pathexists = beamform_hierarchical(total_codebook,n, bf_index,gain_gaussian, angle_ue,threshold)
   
    %This should not happen anyway as well but let's see
    if length(bf_index)==0
        pathexists=0;
        return;
    end
    
    
    %Transmit power
    p_tx=20; %dBm
    N_antenna= total_codebook;
    
    total_index = max(bf_index) - min(bf_index)+1;
    if mod(log2(total_index),1) >0
        fprintf('error')
    end
    
    
    N_active = total_codebook/total_index;
    
    %% Try doubling the antenna and getting rid of the overlapped area
    
    
    N_active = N_active*2;
    
    %We optimize the threshold according to N = 64
    threshold = threshold*sqrt(N_active/64);
    
    %For the grouped model indexing so that we can find the beamforming
    %vector w(k,n) where n is the index and k is the layer 
    %index = mod(min(bf_index),total_index );
    
    index = bf_index*2-1; % 1,3,5,7 .. use for 1,2,3,4
    
    kth_layer = log2(N_active);
    
    %% Hierarchical Codebook Design for Beamforming Training in Millimeter
   % Wave Communication
   
   % analog beamforming is usually preferred, where all the antennas share 
   %a single RF chain and have constant-amplitude (CA) constraint on their weights
   
   % Note that N_antenna must be 2^k
  
    l = log2(N_active)-kth_layer;
    %Sub array size 
    M = 2^(floor(l+1/2));
    %Number of antennas in the subarray
    N_s = N_active/M;
    %Number of codewords
    N_k = 2^kth_layer;
    %beamwidth
    beamw= 2/(N_k);
    

    fc = 28*10^9; %center frequency in Hz
    c = physconst('lightspeed'); %m/s, propagation velocity in free space
    lambda = c/fc; %wavelength
        
    % antenna steering vector
    d = lambda/2; %distance between antenna elements

    %Array y axis
    ant_steer = exp(1i*2*pi*d.*cos(angle_ue).*(0:N_active-1)'/lambda)/sqrt(N_active); %Sundeep Lec8-30

    

    %gain* steering vector and summed
    channel_matrix= sum(ant_steer.*gain_gaussian,2);

    % dBm-30 = dB  
    s = sqrt(10^((p_tx-30)/10)) ;
    if mod(N_active,1) > 0
        fprintf('error\n');
    end
    
    w = sqrt(1/2)*(randn(N_active,1) +1i*randn(N_active, 1));
    %w=0;

    
    %Output
    y = channel_matrix*s +w;
        
%Beam vector calculation
    %Number of active antennas
    if mod(l,2)==0 %If l is even
        N_A=M;
    else
        N_A = M/2;
    end
    
    %Separate w(k, 1) into M subarrays with f_m when m = 1:M
    
    m = 1:N_A;
    m_rest= N_A+1:M;
    
    angle_beam = -(-1+(2.*m-1)/N_s);
%   %columns are a vectors, every column corresponds to one m value so [f1, f2, ..., f_m]
    f_m = exp(-1i.*pi.*m.*(N_s-1)./N_s).*exp(1i.*2.*pi.*d.*angle_beam.*(0:N_s-1)'./lambda)./sqrt(N_s);
    f_m = [f_m, zeros(N_s, length(m_rest))];
    
% Unravel them to create the beamforming vector - w(k,1), kth layer
%     %first beam
    beam_vector = reshape(f_m, [ N_active,1]);

    %For general k
    angle_shift = -2*(index-1)/N_active ; 
    
    if rem(min(bf_index), total_index)
      angle_shift = -2*(index-1)/N_active - 2/64*(min(bf_index)-1);  
    end
    
    shift = sqrt(N_active).*exp(1i.*2.*pi.*d.*angle_shift.*(0:N_active-1)'./lambda)./sqrt(N_active);
    
    %shifting
    beam_vector = beam_vector.*shift;
    res_beam = beam_vector'*y;

    res= 20*log10(abs(res_beam ));
    


    if res <= threshold
        pathexists = 0;
    else
        pathexists = 1;
    end

end