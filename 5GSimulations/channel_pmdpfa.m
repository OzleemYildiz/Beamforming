function [res, angles, bf_index] = channel_pmdpfa(N_antenna,cluster)
    %M = 64; %number of antenna - ULA

    %cluster = 2; %Number of clusters
    %Aykin
    p_tx = 20; %dbm, transmit power---uplink Akdeniz
    fc = 28*10^9; %center frequency in Hz
    bandwidth = 57.6*10^6; %bandwidth in Hz ? Where do we use it

    c = physconst('lightspeed'); %m/s, propagation velocity in free space
    lambda = c/fc; %wavelength

    h_bs  = 10; %m, base station antenna height
    h_ue = 2; %m, ue height by TR36873 is 1.5, Akdeniz says 2
    h_e = 1; %m, effective environment height

    h_e_bs =h_bs -h_e;  %Effective bs antenna height
    h_e_ue =h_ue -h_e;  %Effective ue antenna height


    min_dist = 10; %m, min bs-ue distance
    %UE uniform 
    %v_ue = 3; %km/h, ue mobility %No doppler spread

    cell_radius = 200; %m, cell intersite distance (ISD)

    shadow_fading_los = 4;%dB
    shadow_fading_nlos = 7.82; %dB

    

    
    
    % Uniform random distribute UE
    %unifrnd(0,pi, [1, cluster])
    %There is a image of the beam so we use 0 to pi
    %unifrnd(min_dist,cell_radius, 1)
    ue_loc=unifrnd(min_dist,cell_radius, 1).*exp(1i*unifrnd(0.0001,2*pi , [1, cluster]));
    dist_ue = abs(ue_loc);
    angle_ue = angle(ue_loc); %radian
    
    angles = angle_ue;

    %%
    %d_2d % distance of their locations without the heights, on the surface

    %d_2d = linspace(10,200,100)';
    d_2d = dist_ue;
    d_3d = sqrt(d_2d.^2 +(h_bs -h_ue)^2);

    %d_2d_out %normally p_los depends on this

    d_bp = 4*h_e_bs * h_e_ue*fc/c;%Breakpoint distance

    P_L_los= zeros(1, length(d_2d));
    P_L_nlos= zeros(1, length(d_2d));
    Pr_los= zeros(1, length(d_2d));




    for i =1:length(d_2d)
        %LOS
        if 10 <=d_2d(i) && d_2d(i) <= d_bp
            P_L_los(i) = 32.4 +21*log10(d_3d(i)) + 20*log10(fc/1e9);
        elseif d_bp <=d_2d(i) && d_2d(i) <= 5000
            P_L_los(i) = 32.4 +40*log10(d_3d(i)) + 20*log10(fc/1e9)-9.5*log10(d_bp^2 + (h_bs-h_ue)^2);
        end

        %NLOS

        P_L_nlos_try = 35.3*log10(d_3d(i)) + 22.4 + 21.3*log10(fc/1e9)-0.3*(h_ue -1.5);
        if 10 <= d_2d(i) && d_2d(i) <= 5000
            P_L_nlos(i) = max(P_L_los(i), P_L_nlos_try);
        end

        if d_2d(i) <= 18
            Pr_los(i) = 1; %los probability
        else
            Pr_los(i) = 18/d_2d(i) + exp(-d_2d(i)/36)*(1 -18/d_2d(i));
        end
    end



    %% Add shadowing -- Sundeep Lec2 Slide 63

    %w = randn(1, length(angle_ue));

    P_L_los = P_L_los +randn(1, length(angle_ue)).*shadow_fading_los;
    P_L_nlos = P_L_nlos +randn(1, length(angle_ue)).*shadow_fading_nlos;


    % Select randomly LOS or NLOS
    u = (rand(1, length(angle_ue)) < Pr_los);

    %To make sure that there is only one LOS
    if sum(u == 1) >1
        h = find(u ==1);
        u(h(2:end)) = 0;
    end
    
    N_F = 9;
    T = 290;
    k = physconst('Boltzman');
    EkT = 10*log10(k*T);
    
    %OFDM Symbol Duration https://www.sharetechnote.com/html/5G/5G_FrameStructure.html
    T_dur = 8.92*10^(-6);
    Enoise = EkT + N_F+ 10*log10(1/(T_dur));
    
    P_L = u.*P_L_los + (1-u).*P_L_nlos +Enoise;

    %Cluster powers
    per_cluster_shadowing_std = 3;
    Zn= per_cluster_shadowing_std*randn(1, cluster);
    normalized_pn = 10.^(-Zn/10)./sum(10.^(-Zn/10)); 
    
    if abs(sum(normalized_pn)*1 -1) > 1e15
        fprintf('error normalization wrong\n')
    end
    
    
    gain = normalized_pn.*10.^(-P_L./10);
    %path gain phase  -- uniform
    
    
    gain_gaussian = sqrt(gain/2).*(randn(1,cluster) +1i*randn(1,cluster));

   
        
    s = sqrt(10^((p_tx-30)/10)) ;

   
    bf_index = randi([1,N_antenna]);


    
%     %Sectored antenna model ---
%     antenna_gain = zeros(1, cluster);
%     
%     if sum(n_ueloc == bf_index)>0
%         antenna_gain(n_ueloc == bf_index) = sqrt(M);
%     end
%     
%     w = sqrt(1/2)*(randn(1,1) +1i*randn(1, 1));
% 
%     y = s*gain_gaussian*antenna_gain' +w;
%     


   %% Antenna Steering Vector
    d = lambda/2;
    ant_steer = exp(1i*2*pi*d.*cos(angle_ue).*(0:N_antenna-1)'/lambda)/sqrt(N_antenna); %Sundeep Lec8-30


%% Before beamforming

    channel_matrix= sum(ant_steer.*gain_gaussian,2).*sqrt(N_antenna);
    w = sqrt(1/2)*(randn(N_antenna,1) +1i*randn(N_antenna, 1));
    y =  channel_matrix*s +w ;


%% Hierarchical Codebook Design for Beamforming Training in Millimeter
   % Wave Communication
   
   % analog beamforming is usually preferred, where all the antennas share 
   %a single RF chain and have constant-amplitude (CA) constraint on their weights
   
   % Note that N_antenna must be 2^k
     
    kth_layer = log2(N_antenna); %Last layer
    
    
    l = log2(N_antenna)-kth_layer;
    %Sub array size 
    N_antenna = 2^(floor(l+1/2));
    %Number of antennas in the subarray
    N_s = N_antenna/N_antenna;
    %Number of codewords
    N_k = 2^kth_layer;
    %beamwidth
    beamw= 2/(N_k);
    
    %Number of active antennas
    if mod(l,2)==0 %If l is even
        N_A=N_antenna;
    else
        N_A = N_antenna/2;
    end
    
    %Separate w(k, 1) into M subarrays with f_m when m = 1:M
    
    m = 1:N_A;
    m_rest= N_A+1:N_antenna;
    
    angle_beam = -(-1+(2.*m-1)/N_s);
%     %columns are a vectors, every column corresponds to one m value so [f1, f2, ..., f_m]
    f_m = exp(-1i.*pi.*m.*(N_s-1)./N_s).*exp(1i.*2.*pi.*d.*angle_beam.*(0:N_s-1)'./lambda)./sqrt(N_s);
    f_m = [f_m, zeros(N_s, length(m_rest))];
%    
%     %Unravel them to create the beamforming vector - w(k,1), kth layer
%     %first beam
    beam_vector = reshape(f_m, [ N_antenna,1]);
     
    %beam_vector= [f_m(:,1); zeros(N_antenna- N_s,1)];
          
    %In order to move to w(k,index), we need to Hadamard product with the
    %following shift

    
    %For general k
    angle_shift = -2*(bf_index-1)/N_antenna ; 
        

    shift = sqrt(N_antenna).*exp(1i.*2.*pi.*d.*angle_shift.*(0:N_antenna-1)'./lambda)./sqrt(N_antenna);
    
    %shifting
    beam_vector = beam_vector.*shift;
    
   
    
    %Normalize
    beam_vector = beam_vector./vecnorm(beam_vector);
    
    res_beam = beam_vector'*y;
    
    
    res= 20*log10(abs(res_beam));
end