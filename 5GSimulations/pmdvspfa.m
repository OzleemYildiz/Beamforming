%%
threshold = -20:0.5:60;
%ratio = 1.1:0.1:2;

% multilevel =1;
tic
pr_fa= zeros(size(threshold)); % No path but we think there is
pr_md= zeros(size(threshold)); % Yes path but it should not be

% count_2paths = zeros(size(threshold), size(ratio)); 
% snr_2paths = zeros(size(threshold), size(ratio));
% snr_1path = zeros(size(threshold), size(ratio));
% count_1path = zeros(size(threshold), size(ratio));


trial = 100;
path_exist= zeros(size(threshold));
path_nonexist = zeros(size(threshold));

M = 64; %We take this base case

for j= 1:length(threshold)
    
    for i= 1:trial   

        [res_snr, angle_ue, bf_index] = channel_pmdpfa(M,4);


%      %% Multi-level check           
%             %Check if real index of UE
             true_loc = locate_AoA_index_hierarchical(angle_ue, M);
% 
%             %Check which AoAs are in the angular interval that we are searching
%             in_out= true_loc ==  bf_index; 
% 
%             %Addition for Multi-Level measuring
%             %Measure the energy difference when there are two paths in the beam
% 
% 
%             if sum(in_out)>=2  %There are at least two AoAs in the angular interval
%                snr_2paths(j) = snr_2paths(j) + res;
%                count_2paths(j)= count_2paths(j)+1;       
%             elseif sum(in_out)==1 %There is only one AoA in the angular interval
%                snr_1path(j) = snr_1path(j)+res;
%                count_1path(j) = count_1path(j)+1;
%             end

        %check_ans = rad2deg(angle) >= 90 && rad2deg(angle) <= 95.6250; 

%         offset = 1*0.89/M; % Half width of the beam
%         a1 = angles >= angle_beam - offset;
%         a2= angles <= angle_beam + offset;
%         check_ans = isempty(find(a1+a2 ==2))==0;


        %true_loc = sum(angle_ue' > linspace(0, 2*pi,M+1), 2)';


%% Pr MD and FA
        check_ans = sum(true_loc == bf_index) ~= 0;

        if check_ans==1 %There is a path
            path_exist(j)=path_exist(j)+1;
        else
            path_nonexist(j)=path_nonexist(j)+1;
        end

        check_snr = threshold(j)<=res_snr; %ACK or NACK response

        if check_snr ~= check_ans
            if check_ans == 0
                pr_fa(j) = pr_fa(j)+1;
            else
                pr_md(j) = pr_md(j)+1;
            end

        end

    end
    
end

pr_fa = pr_fa./path_nonexist;
pr_md = pr_md./path_exist;

%snr_2paths = snr_2paths./count_2paths;
%snr_1path = snr_1path./count_1path;

save('pr_fa', 'pr_fa');
save('pr_md', 'pr_md');
% save('snr_1path', 'snr_1path');
% save('snr_2paths', 'snr_2paths');

toc
% %%
% figure; 
% plot(threshold, pr_fa, 'r','Linewidth', 3);
% hold on
% plot(threshold, pr_md, 'b','Linewidth', 3);
% grid on;
% grid minor;
% set(gca, 'Fontsize', 16);
% xlim([min(threshold), max(threshold)])
% xlabel('Threshold (SNR)','Interpreter','latex','FontSize', 18);
% ylabel('Probability','Interpreter','latex','FontSize', 18);
% legend('False Alarm', 'Misdetection','Location','southeast','Interpreter','latex','FontSize', 18')
% title('$N_{TX}= 64$, $M =2$','Interpreter','latex','FontSize', 18)
