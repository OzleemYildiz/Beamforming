figure;

plot(8:64, number_of_test_freq_GT(1,:), 'LineWidth', 2);
hold on;
plot(8:64, number_of_test_freq_GT_update(1,:), 'LineWidth', 2);
hold on;
plot(8:64, number_of_test_freq_Hwang(1,:), 'LineWidth', 2);
hold on;
plot(8:64, number_of_test_Hwang(1,:), 'LineWidth', 2);
hold on;
plot(8:35, num_step_mlbs_2, 'LineWidth', 2);

legend('Frequency GT','Frequency GT Update','Frequency GT, Hwang','Hwang GT', 'MLBS')
title('2 paths')
xlabel('n (Total number of beams)')
ylabel('t (time slot)')

figure;

plot(8:64, number_of_test_freq_GT(2,:), 'LineWidth', 2);
hold on;
plot(8:64, number_of_test_freq_GT_update(2,:), 'LineWidth', 2);
hold on;
plot(8:64, number_of_test_freq_Hwang(2,:), 'LineWidth', 2);
hold on;
plot(8:64, number_of_test_Hwang(2,:), 'LineWidth', 2);
hold on;
plot([8:26, 30], num_step_mlbs_3, 'LineWidth', 2);

legend('Frequency GT','Frequency GT Update','Frequency GT, Hwang','Hwang GT', 'MLBS')
title('3 paths')
xlabel('n (Total number of beams)')
ylabel('t (time slot)')

figure;

plot(8:64, number_of_test_freq_GT(3,:), 'LineWidth', 2);
hold on;
plot(8:64, number_of_test_freq_GT_update(3,:), 'LineWidth', 2);
hold on;
plot(8:64, number_of_test_freq_Hwang(3,:), 'LineWidth', 2);
hold on;
plot(8:64, number_of_test_Hwang(3,:), 'LineWidth', 2);
hold on;
plot([8:24], num_step_mlbs_4, 'LineWidth', 2);

legend('Frequency GT','Frequency GT Update','Frequency GT, Hwang','Hwang GT', 'MLBS')
title('4 paths')
xlabel('n (Total number of beams)')
ylabel('t (time slot)')