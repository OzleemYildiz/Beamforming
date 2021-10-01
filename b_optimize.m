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