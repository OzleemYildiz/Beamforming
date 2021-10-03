lpb(1,:) = [64, 2, 6];
lpb(2,:)  = [64, 3, 5];
lpb(3,:)  = [64, 4, 4];
lpb(4,:)  = [64, 5, 4];
lpb(5,:) = [32, 2, 4];
lpb(6,:)  = [32, 3, 4];
lpb(7,:)  = [32, 4, 3];
lpb(8,:)  = [32, 5, 3];
lpb(9,:) = [16, 2, 3];
lpb(10,:)  = [16, 3, 3];
lpb(11,:)  = [16, 4, 3];
lpb(12,:)  = [16, 5, 3];

trial = 100000;

L = 32;
P = 4;
B = 3;
% 
% L =5;
% P=2;
% B=2;

tree_aykin = load('aykin_tree_L32P4B3.mat');
num_step_mlbs = 0; 

for i=1:trial  
    location = [ones(1,P), zeros(1,L-P)];
    location = location(randperm(length(location))); 
    
    [res, num_s] = tree_trace(location, tree_aykin, 0);
    num_step_mlbs = num_step_mlbs + num_s;
end

num_step_mlbs = num_step_mlbs/trial;

function [res, num_s] = tree_trace(location, tree_aykin, num_step)

    num_s = num_step;
    if isfield(tree_aykin, 'root')
        num_s = num_s +1;
        if isfield(tree_aykin.root, 'root')  
            root = tree_aykin.root.root;
            if sum (location(root)== 1) >0 % I got 1-> Left
                [res, num_s] = tree_trace(location, tree_aykin.left, num_s);
            else % I got 0 -> Right
                [res, num_s] = tree_trace(location, tree_aykin.right, num_s);
            end
        else
            root = tree_aykin.root;
            if sum (location(root)== 1) >0 % I got 1-> Left
                res = tree_aykin.leftchild;
            else % I got 0 -> Right
                res = tree_aykin.rightchild;
            end
        end
    else
        res = tree_aykin;
    end
end