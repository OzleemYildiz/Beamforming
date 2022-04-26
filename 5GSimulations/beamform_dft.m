function pathexists = beamform_dft(total_codebook,n, bf_index,gain_gaussian, angle_ue,threshold)
   
    %This should not happen anyway as well but let's see
    if length(bf_index)==0
        pathexists=0;
        return;
    end
    
    %Transmit power
    p_tx=20; %dBm
    N_antenna= total_codebook;
    
    
    
    %If we were searching one index only: (2*pi/total_codebook)
    %total_index = max(bf_index) - min(bf_index)+1;
    %N_antenna = total_codebook/total_index;
    
%     resolution = (2*pi/total_codebook)* total_index;
% 
%     %fprintf('error %f and %f and %f \n', resolution, total_index,total_codebook )
%     
%     N_antenna = round(1.78 / resolution);
    
    %threshold update to scale with the antenna gain
    %threshold = threshold*sqrt(N_antenna/64); 
    
    %18 is for 64 data beam  
%     %The angle that the beam is focused should be the middle angle between
%     %the indeces that we are searching
%     beam_index= (max(bf_index) + min(bf_index)-1)/2;
%     %angle_beam =  (2*0.89/N_antenna)*beam_index;
%     angle_beam = resolution*beam_index;
    %angle_beam =pi/8;
    
    fc = 28*10^9; %center frequency in Hz
    c = physconst('lightspeed'); %m/s, propagation velocity in free space
    lambda = c/fc; %wavelength
        
       % antenna steering vector
    d = lambda/2; %distance between antenna elements

    %Array y axis
    %ant_steer = exp(-1i*2*pi*d.*cos(angle_ue).*(0:N_antenna-1)'/lambda); %Sundeep Lec8-30

    %Quantized receiver antenna array
    n = sum(angle_ue' > linspace(-pi/2, pi/2, N_antenna+1), 2)';
    theta = -1 + (2*n-1)/ N_antenna;
    
    ant_steer = exp(1i*2*pi*d*theta.*(0:N_antenna-1)'/lambda)/sqrt(N_antenna); %Sundeep Lec8-30


    %gain* steering vector and summed
    channel_matrix= sum(ant_steer.*gain_gaussian,2);

    % dBm-30 = dB  
    s = sqrt(10^((p_tx-30)/10)) ;

    
    w = sqrt(1/2)*(randn(N_antenna,1) +1i*randn(N_antenna, 1));
    %w=0;

    
    %Output
    y = channel_matrix*s +w;
        
    
    %beam_vector = exp(-1i*2*pi*d.*cos(angle_beam).*(0:N_antenna-1)'/lambda)/sqrt(N_antenna); %Sundeep Lec8-30
    
%     beam_dft = dftmtx(N_antenna)/sqrt(N_antenna);
%     beam_dft = flip(beam_dft,2);
%     beam_dft = circshift(beam_dft, [2, -N_antenna/2+1]);
%     
%     beam_vector = beam_dft(:,bf_index);
%     
%     beam_dft = dftmtx(N_antenna)/sqrt(N_antenna);
%     beam_dft = flip(beam_dft,2);
% 
%     beam_dft = circshift(beam_dft, [2, -N_antenna/2+1]);
%     
%     %TO CHECK
%     bf_index= mod(min(bf_index), total_index);
%     
%     sintheta = 1/N_antenna *(bf_index-1);
%     phi = -asin(1/(2*N_antenna));
%     
%     shift = -2*sintheta*(sin(phi/2)^2) + sqrt(1 - sintheta^2)*sin(phi);
%     
%     
%     beam_vector = beam_dft(:,bf_index).*exp(-1i*2*pi*shift.*(0:N_antenna-1)');
%     
%     beam_vector = sum(exp(-1i*2*pi/N_antenna.*(bf_index - (N_antenna+1)./2).*(0:N_antenna-1)')/sqrt(N_antenna),2)/sqrt(length(bf_index));

    beam_dft = dftmtx(N_antenna)/sqrt(N_antenna);    
    beam_dft = circshift(beam_dft, [2, -N_antenna/2-1]);
    beam_vector = beam_dft(:,bf_index);

    res_beam = beam_vector'*y;
    
    res= 20*log10(abs(res_beam ));
    
    if res <= threshold
        pathexists = 0;
    else
        pathexists = 1;
    end
end