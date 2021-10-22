function [res, num_s] = tree_trace(location, tree_aykin, num_step, pmd, pfa)

    num_s = num_step;
    if isfield(tree_aykin, 'root')
        num_s = num_s +1;
        if isfield(tree_aykin.root, 'root')  
            root = tree_aykin.root.root;
            check = sum (location(root)== 1) >0; %If ACK, its 1
            
            pe = rand(1,1);
            if check == 1 && pe< pmd % random error satisfies, it's not ACK anymore 
                check = 0;
            elseif  check == 0 && pe< pfa
                check = 1;
            end
            
            if check % I got 1-> Left
                [res, num_s] = tree_trace(location, tree_aykin.left, num_s, pmd,pfa);
            else % I got 0 -> Right
                [res, num_s] = tree_trace(location, tree_aykin.right, num_s, pmd,pfa);
            end
        else
            root = tree_aykin.root;
            
            check = sum (location(root)== 1) >0; %If ACK, its 1
            
            pe = rand(1,1);
            if check == 1 && pe< pmd % random error satisfies, it's not ACK anymore 
                check = 0;
            elseif  check == 0 && pe< pfa
                check = 1;
            end
            
            if check % I got 1-> Left
                res = tree_aykin.leftchild;
            else % I got 0 -> Right
                res = tree_aykin.rightchild;
            end
        end
    else
        res = tree_aykin;
    end
end