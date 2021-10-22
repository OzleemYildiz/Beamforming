
L = 8:35;
P = 2;

% L = [8:27, 30];
% P = 3;

% L = [8:24, 26];
% P = 4;

lpb = b_optimize(P,L);

num_step_mlbs = zeros(4, length(lpb)); 
pmd = [0, 0.39,0.19, 0.12];
pfa = [0,0.05,0.19, 0.4]; 

trial =5000000;
constant = length(lpb);

blockage_mlbs = zeros(length(lpb),4);
md_mlbs = zeros(length(lpb),4);

for k=1:4
    for j = 1:constant
    %     tree_aykin = load("/scratch/zy2043/beamforming/Beamforming/tree/aykin_tree_L" + lpb(j,1)  + "P" + lpb(j,2) + "B" + lpb(j,3) + ".mat");
        tree_aykin = load("/Users/ozlemyildiz/Desktop/Beamforming_ICC/Beamforming/tree/aykin_tree_L" + lpb(j,1)  + "P" + lpb(j,2) + "B" + lpb(j,3) + ".mat");

        for i=1:trial  
            location = [ones(1,lpb(j,2)), zeros(1,lpb(j,1)-lpb(j,2))];
            location = location(randperm(length(location))); 

            [res, num_s] = tree_trace(location, tree_aykin, 0, pmd(k), pfa(k));
            num_step_mlbs(j) = num_step_mlbs(j) + num_s;
            true_loc = find(location == 1 );
            
            if isempty(res)
                 blockage_mlbs(j,k) = blockage_mlbs(j,k) +1;
            else   
                 if sum(true_loc == res', 'all') == 0
                     blockage_mlbs(j,k) = blockage_mlbs(j,k) +1;
                 end
                 if sum(true_loc == res', 'all') ~= P
                     md_mlbs(j,k) = md_mlbs(j,k) + abs(P - sum(true_loc == res', 'all'));
                 end
            end
        end
    end
end
num_step_mlbs = num_step_mlbs./trial;
md_mlbs = md_mlbs./trial;
blockage_mlbs = blockage_mlbs./trial;

save("num_step_aykinP" +P , 'num_step_mlbs');
save("md_mlbsP" +P , 'md_mlbs');
save("blockage_mlbsP" +P , 'blockage_mlbs');
