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