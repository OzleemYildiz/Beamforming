function setup = setup_mlbs(L,P,B)
    rows = nchoosek(1:L, P);
    global columns
    columns = nchoosek(1:L, B);
    global D; 
    D = sparse(size(rows,1), size(columns,1));
    
   nn =  496*2;
   for ic = 1:nn
        A = repmat(rows,[size(columns,1)/nn, 1]);

    %     B_1 = repmat(columns',[ size(rows,1),1]);
    %     B_1 = reshape(B_1,[prod(size(B_1))/size(columns,2), size(columns,2)]);
        B_1 = zeros(size(rows,1)*size(columns,1)/nn, size(columns,2));
        range = (ic-1)*size(columns,1)/nn +1 :ic*size(columns,1)/nn; 

        for k = 1: size(columns,2)
            B_1(:, k) = repelem(columns(range, k),  size(rows,1));
        end

        D1 = sparse(size(B_1,1),1);
        for k = 1: size(rows,2)
            D1 = D1 + sum((A(:, k) - B_1) == 0 ,2);
        end
        D1 = D1>0;
        D(:, range) = reshape(D1, [size(rows,1), size(columns,1)/nn]);
   end
   
%     D1 = sum(ismember([A, zeros(size(A,1), size(B_1,2)-size(A,2))], B_1),2)>0;

    
%     for i= 1:size(rows,1)
%         for j = 1:size(columns,1)
%             if sum(ismember(rows(i, :), columns(j,:))) >0
%                D(i,j) = 1;
%             end        
%         end
%     end
    
   
    root = 1:B;
    setup = MLBS(rows, root);
end