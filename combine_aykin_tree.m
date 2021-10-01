%%% Optimization of B 
P = 2:4;
L = 8:64;
lpb = b_optimize(P,L);


for i =1:length(lpb)   
    tree_aykin = setup_mlbs(lpb(i, 1),lpb(i, 2),lpb(i,3));
    save("aykin_tree_L"+lpb(i, 1)+"P"+lpb(i, 2)+"B" +lpb(i, 3)+".mat" ,'-struct', 'tree_aykin' )
end


function setup = setup_mlbs(L,P,B)
    rows = nchoosek(1:L, P);
    global columns
    columns = nchoosek(1:L, B);
    global D; 
    D = sparse(size(rows,1), size(columns,1));

    for i= 1:size(rows,1)
        for j = 1:size(columns,1)
            if sum(ismember(rows(i, :), columns(j,:))) >0
               D(i,j) = 1;
            end        
        end
    end

    root = 1:B;
    setup = MLBS(rows, root);
end

function tree = MLBS(remaining_rows, parent)
global columns
global D
    
    check = sum(remaining_rows ~= zeros(size(remaining_rows)),1);
    if check(1) > 2 
        ind = find(sum(columns == parent,2)== length(parent));
        indeces_1 = find(D(:,ind) == 1);
        indeces_0 = find(D(:,ind) == 0);
        
        kk = remaining_rows == zeros(size(remaining_rows));
        ff =find(kk(:,1)==1);
        indeces_1 = indeces_1(find(sum((indeces_1- ff') == 0, 2)== 0));
        indeces_0 = indeces_0(find(sum((indeces_0- ff') == 0, 2)== 0));
        
%         remaining_left =  remaining_rows(indeces_1, :);
%         remaining_right =  remaining_rows(indeces_0, :);
        remaining_left = remaining_rows ;
        remaining_left(indeces_0, :) = 0;
        
        remaining_right = remaining_rows ;
        remaining_right(indeces_1, :) = 0;

        

%         D(:,ind) = [];
%         columns(ind, :) = [];
%         
%         [~, ll_i] = min(abs(sum(D(indeces_1, :) == 1)- length(indeces_1)/2));
%         ll = columns(ll_i, :); 
%         
%    
%         root.leftchild = ll;

        root.root = parent;

        check_l = sum(remaining_left ~= zeros(size(remaining_left)),1);
        
        if check_l == 1
            ll = remaining_left(remaining_left ~= 0)';
            root.leftchild = ll;
            tree_left = ll;
        else
            [~, ll_i] = min(abs(sum(D(indeces_1, :) == 1)- length(indeces_1)/2));
            ll = columns(ll_i, :);
            root.leftchild = ll;
            tree_left = MLBS (remaining_left, ll );
        end
        
        check_r = sum(remaining_right ~= zeros(size(remaining_right)),1);
        
        if check_r == 1
            rr = remaining_right(remaining_right ~= 0)';
            root.rightchild = rr;
            tree_right = rr;
        else
            [~, rr_i] = min(abs(sum(D(indeces_0, :) == 1)- length(indeces_0)/2));
            rr = columns(rr_i, :);
            root.rightchild = rr;
            tree_right = MLBS (remaining_right, rr );
        end

           
%         tree_left = MLBS(remaining_left, ll );

        tree = struct('root', root,'left', tree_left, 'right',tree_right);
        
    else
        ind = find(sum(columns == parent,2)== length(parent));
        indeces_1 = find(D(:,ind) == 1);
        indeces_0 = find(D(:,ind) == 0);
%         remaining_left =  remaining_rows(indeces_1, :);
%         remaining_right =  remaining_rows(indeces_0, :);
        
        kk = remaining_rows == zeros(size(remaining_rows));
        ff =find(kk(:,1)==1);
        indeces_1 = indeces_1(find(sum((indeces_1- ff') == 0, 2)== 0));
        indeces_0 = indeces_0(find(sum((indeces_0- ff') == 0, 2)== 0));
        
        
        remaining_left = remaining_rows ;
        remaining_left(indeces_0, :) = 0;
        
        remaining_right = remaining_rows ;
        remaining_right(indeces_1, :) = 0;
        
        root.leftchild  = remaining_left(remaining_left ~= 0);
        root.root = parent;
        root.rightchild = remaining_right(remaining_right ~= 0);
        
        tree = {root};
    end
end

function lpb = b_optimize(P,L)

    lpb = zeros(length(P)*length(L), 3);
    ind = 1;
    for k = L
        for m = P
            sum = zeros(1, length(3:k));
            for B = 3:k
                for i = 0 : B-2
                    for j = 0: i
                        sum(1, B-2) = sum(1, B-2) + (k-m -j)/(k-1-j);
                    end
                end
            end
            sum = (sum +1)*m/k ;
            [~, b] = min(abs(sum - 0.5));

            lpb(ind, :) = [k,m, b+2];
            ind = ind +1; 
        end
    end
end


