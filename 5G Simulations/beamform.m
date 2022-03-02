function pathexists = beamform(total_codebook, bf_index,gain_gaussian, angle_ue,threshold)
   
    %This should not happen anyway as well but let's see
    if length(bf_index)==0
        pathexists=0;
        return;
    end
    
    %Transmit power
    p_tx=20; %dBm
    %If we were searching one index only: (2*pi/total_codebook)
    total_index = max(bf_index) - min(bf_index)+1;
    resolution = (2*pi/total_codebook)* total_index;

    %fprintf('error %f and %f and %f \n', resolution, total_index,total_codebook )
    
    N_antenna = round(1.78 / resolution);
    
    %threshold update to scale with the antenna gain
    threshold = threshold*sqrt(N_antenna/18); %18 is for 64 data beam
    
    %The angle that the beam is focused should be the middle angle between
    %the indeces that we are searching
    beam_index= (max(bf_index) + min(bf_index)-1)/2;
    angle_beam =  (2*0.89/N_antenna)*beam_index;
    
    fc = 28*10^9; %center frequency in Hz
    c = physconst('lightspeed'); %m/s, propagation velocity in free space
    lambda = c/fc; %wavelength
        
       % antenna steering vector
    d = lambda/2; %distance between antenna elements

    %Array y axis
    ant_steer = exp(-1i*2*pi*d.*cos(angle_ue).*(0:N_antenna-1)'/lambda); %Sundeep Lec8-30


    %gain* steering vector and summed
    channel_matrix= sum(ant_steer.*gain_gaussian,2);

    % dBm-30 = dB  
    s = sqrt(10^((p_tx-30)/10)) ;

    
    w = sqrt(1/2)*(randn(N_antenna,1) +1i*randn(N_antenna, 1));
    

    
    %Output
    y = channel_matrix*s +w;
        
    
    beam_vector = exp(-1i*2*pi*d.*cos(angle_beam).*(0:N_antenna-1)'/lambda)/sqrt(N_antenna); %Sundeep Lec8-30

    res_beam = beam_vector'*y;
    
    res= 10*log10(abs(res_beam ));
    
    if res <= threshold
        pathexists = 0;
    else
        pathexists = 1;
    end
end