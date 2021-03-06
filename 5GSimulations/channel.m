%% Channel generation for beam alignment purposes
%Inputs
% cluster : Number of AoAs
% multi-level : if it's done for multi-level measuring purposes then I will
% put 2 of the angles with an epsilon value difference

%Outputs
% gain_gaussian: channel gain after path loss and shadowing for every
% angles: AoAs of the UE

function [gain_gaussian, angles] = channel(cluster, multilevel)
    %Antenna ULA
 
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
    
    %There is a image of the beam so we use 0 to pi if its real beam
    % But now, we use 0 to 2*pi if we use sectored antenna model
    
    % Change for multi-level measuring, put two angles in same interval
    if multilevel 
        rand_ang= unifrnd(0.0001,pi, [1, cluster-1]);
        
        if rand_ang(1)- 0.01 < 0
            repeat_ang = rand_ang(1)+ 0.01;
        else
            repeat_ang = rand_ang(1)- 0.01;
        end
        
        angle_create = [rand_ang,repeat_ang];
    else
        angle_create = unifrnd(0.0001,pi, [1, cluster]);
    end
    
    ue_loc=unifrnd(min_dist,cell_radius, 1).*exp(1i*angle_create);
    dist_ue = abs(ue_loc);
    %If sectored antenna-----
%     %angle returns in [-pi, pi], I need [0,2*pi]
%     angle_ue = angle(ue_loc) + pi; %radian
     
    %If hierarchical antenna 
    angle_ue = angle(ue_loc);

    angles = angle_ue;

    %%
    %d_2d % distance of their locations without the heights, on the surface

    d_2d = dist_ue; %m
    d_3d = sqrt(d_2d.^2 +(h_bs -h_ue)^2);%m

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

   
    
%     % antenna steering vector
%     d = lambda/2; %distance between antenna elements
% 
%     %Array y axis
%     ant_steer = exp(-1i*2*pi*d.*cos(angle_ue).*(0:N_antenna-1)'/lambda); %Sundeep Lec8-30
% 
% 
%     %gain* steering vector and summed
%     channel_matrix= sum(ant_steer.*gain_gaussian,2);
% 
%     % dBm-30 = dB  
%     s = sqrt(10^((p_tx-30)/10)) ;
% 
%     
%     w = sqrt(1/2)*(randn(N_antenna,1) +1i*randn(N_antenna, 1));
%     
% 
%     
%     %Output
%     y = channel_matrix*s +w;
    
end