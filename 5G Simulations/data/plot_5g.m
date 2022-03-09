
clear all;
close all;


load('5gsimulation_ntest_hwang_03_01_threshold.mat')
load('5gsimulation_ntest_hex_03_01_threshold.mat')
load('5gsimulation_ntest_fs_gt_03_01_threshold--t.mat')
load('5gsimulation_ntest_f_gt_03_01_threshold.mat')
load('5gsimulation_ntest_f_ack_gt_03_01_threshold.mat')

th= -10:40;
load('5gsimulation_blockage_hex_03_01_threshold.mat')
blockage_hex = reshape( blockage, [1,51]);
load('5gsimulation_blockage_hwang_03_01_threshold.mat')
blockage_hwang = reshape( blockage, [1,51]);
load('5gsimulation_blockage_fs_gt_03_01_threshold--t.mat')
blockage_fs_gt= reshape( blockage, [1,51]);
load('5gsimulation_blockage_f_gt_03_01_threshold.mat')
blockage_f_gt= reshape( blockage, [1,51]);
load('5gsimulation_blockage_f_ack_gt_03_01_threshold.mat')
blockage_f_ack_gt= reshape( blockage, [1,51]);

load('5gsimulation_md_hex_03_01_threshold.mat')
md_hex = reshape( md, [1,51]);
load('5gsimulation_md_hwang_03_01_threshold.mat')
md_hwang = reshape( md, [1,51]);
load('5gsimulation_md_fs_gt_03_01_threshold--t.mat')
md_fs_gt= reshape( md, [1,51]);
load('5gsimulation_md_f_gt_03_01_threshold.mat')
md_f_gt= reshape( md, [1,51]);
load('5gsimulation_md_f_ack_gt_03_01_threshold.mat')
md_f_ack_gt= reshape( md, [1,51]);

figure;

plot(th,blockage_hex , 'LineWidth',2)
hold on
plot(th,blockage_hwang , 'LineWidth',2)
hold on
plot(th,blockage_fs_gt , 'LineWidth',2)
hold on
plot(th,blockage_f_gt , 'LineWidth',2)
hold on
plot(th,blockage_f_ack_gt ,  'LineWidth',2)
title('Blockage')
legend('hes','hwang', 'freq seperate', 'freq', 'freq ack')
grid on;

figure;
plot(th,reshape(number_of_test_hex, [1,51]) , 'LineWidth',2)
hold on
plot(th,reshape(number_of_test_hwang, [1,51]) , 'LineWidth',2)
hold on
plot(th,reshape(n_test_fs_gt, [1,51]) , 'LineWidth',2)
hold on
plot(th,reshape(n_test_f_gt, [1,51]) , 'LineWidth',2)
hold on
plot(th,reshape(n_test_f_ack_gt, [1,51]) , 'LineWidth',2)
title('BA duration')
legend('hes', 'freq seperate', 'freq', 'freq ack')
grid on;

figure;
plot(th,md_hex, 'LineWidth',2)
hold on
plot(th,md_hwang, 'LineWidth',2)
hold on
plot(th,md_fs_gt, 'LineWidth',2)
hold on
plot(th,md_f_gt , 'LineWidth',2)
hold on
plot(th,md_f_ack_gt ,  'LineWidth',2)
title('Misdetected paths')
legend('hes', 'hwang', 'freq seperate', 'freq', 'freq ack')
grid on;