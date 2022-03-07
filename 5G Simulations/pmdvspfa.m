%%
threshold = -30:50;

pr_fa= zeros(size(threshold)); % No path but we think there is
pr_md= zeros(size(threshold)); % Yes path but it should not be

trial = 1000000;
path_exist= zeros(size(threshold));
path_nonexist = zeros(size(threshold));

M = 64; %We take this base case

for j= 1:length(threshold)
    for i= 1:trial   
        
        [res_snr, angle_ue, bf_index] = channel_pmdpfa(M,2);

        %check_ans = rad2deg(angle) >= 90 && rad2deg(angle) <= 95.6250; 
        
%         offset = 1*0.89/M; % Half width of the beam
%         a1 = angles >= angle_beam - offset;
%         a2= angles <= angle_beam + offset;
%         check_ans = isempty(find(a1+a2 ==2))==0;
        
        %true_loc = locate_AoA_index(angle_ue, M);
        true_loc = sum(angle_ue' > linspace(-pi/2, pi/2,M+1), 2)';

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

save('pr_fa', 'pr_fa');
save('pr_md', 'pr_md');


% figure; 
% plot(threshold, pr_fa, 'r','Linewidth', 3);
% hold on
% plot(threshold, pr_md, 'b','Linewidth', 3);
% grid on;
% grid minor;
% set(gca, 'Fontsize', 16);
% xlabel('Threshold (SNR)','Interpreter','latex','FontSize', 18);
% ylabel('Probability','Interpreter','latex','FontSize', 18);
% legend('False Alarm', 'Misdetection','Location','northwest','Interpreter','latex','FontSize', 18')
% title('$N_{TX}= 64$, $M =2$','Interpreter','latex','FontSize', 18)
