trial =10;

%L = [8:26, 29:35];
%P = 2;

%L = [8:26, 30];
%P = 3;

%L = [8:24];
%P = 4;



lpb = b_optimize(P,L);


num_step_mlbs = zeros(1, length(lpb)); 

for j = 1:length(lpb)
    tree_aykin = load("~/Desktop/Beamforming_ICC/Beamforming/tree/aykin_tree_L" + lpb(j,1)  + "P" + lpb(j,2) + "B" + lpb(j,3) + ".mat");
    for i=1:trial  
        location = [ones(1,lpb(j,2)), zeros(1,lpb(j,1)-lpb(j,2))];
        location = location(randperm(length(location))); 

        [res, num_s] = tree_trace(location, tree_aykin, 0);
        num_step_mlbs(j) = num_step_mlbs(j) + num_s;
    end
end
num_step_mlbs = num_step_mlbs./trial;

save('num_step_aykin_2', 'num_step_mlbs');
save('b_optimize2', 'lpb')
