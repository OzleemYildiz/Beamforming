%%% Optimization of B 
P = 2:4;
L = 8:64;
lpb = b_optimize(P,L);


for i =1:length(lpb)   
    tree_aykin = setup_mlbs(lpb(i, 1),lpb(i, 2),lpb(i,3));
    save("aykin_tree_L"+lpb(i, 1)+"P"+lpb(i, 2)+"B" +lpb(i, 3)+".mat" ,'-struct', 'tree_aykin' )
end






