function true_loc = locate_AoA_index_hierarchical(angle_ue, N)

    fc = 28*10^9; %center frequency in Hz
    c = physconst('lightspeed'); %m/s, propagation velocity in free space
    lambda = c/fc; %wavelength
    
    d= lambda/2;
    
    ant_steer = exp(1i*2*pi*d.*cos(angle_ue).*(0:N-1)'/lambda); %Sundeep Lec8-30
    
    %Hierarchical textbook
    N_s = N;
    M = 1;
    N_active = N;
    N_A =M;
    
    m = 1:N_A;
    m_rest= N_A+1:M;
    
    angle_beam = -(-1+(2.*m-1)/N_s);
%   %columns are a vectors, every column corresponds to one m value so [f1, f2, ..., f_m]
    f_m = exp(-1i.*pi.*m.*(N_s-1)./N_s).*exp(1i.*2.*pi.*d.*angle_beam.*(0:N_s-1)'./lambda)./sqrt(N_s);
    f_m = [f_m, zeros(N_s, length(m_rest))];
    
% Unravel them to create the beamforming vector - w(k,1), kth layer
%     %first beam
    beam_vector = reshape(f_m, [ N_active,1]);

    index = 1:64;
    %For general k
    angle_shift = -2.*(index-1)/N_active ; 
    
    %Why do I put minus here??????
    shift = sqrt(N_active).*exp(1i.*2.*pi.*d.*angle_shift.*(0:N_active-1)'./lambda)./sqrt(N_active);
    
    %shifting
    beam_vector = beam_vector.*shift;
    
    %Normalize
    beam_vector = beam_vector./norm(beam_vector);

    
    
    [~, true_loc] = max(abs(beam_vector'*ant_steer));
    
    
end