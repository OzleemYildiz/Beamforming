function true_loc = locate_AoA_index(angle_ue, N)

    fc = 28*10^9; %center frequency in Hz
    c = physconst('lightspeed'); %m/s, propagation velocity in free space
    lambda = c/fc; %wavelength
    
    d= lambda/2;
    
    ant_steer = exp(-1i*2*pi*d.*cos(angle_ue).*(0:N-1)'/lambda); %Sundeep Lec8-30
    
%     beam_dft = dftmtx(N)/sqrt(N);
%     beam_dft = flip(beam_dft,2);
%     beam_dft = circshift(beam_dft, [2, -N/2+1]);
    
    
    beam_dft = dftmtx(N)/sqrt(N);
    beam_dft = flip(beam_dft,2);

    beam_dft = circshift(beam_dft, [2, -N/2+1]);
    
    sintheta = 1/N *(0:N-1);
    phi = -asin(1/(2*N));
    
    shift = -2.*sintheta.*(sin(phi/2)^2) + sqrt(1 - sintheta.^2).*sin(phi);
       
    beam_dft = beam_dft.*exp(-1i*2*pi*shift.*(0:N-1)');
    
    %beam_vector = beam_dft(:,index);
    
    [~, true_loc] = max(abs(beam_dft'*ant_steer));
    
    
end