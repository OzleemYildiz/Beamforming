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