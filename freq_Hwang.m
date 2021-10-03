 % What if we use HWANG in 2 frequency with each having 2^{alpha} size

function [beam_loc, n_steps] = freq_Hwang(n,m, valid_loc, beam_loc, location, n_steps)
    if n == m
        %Append the locations to check
        %But no need to check but I know that all of them are paths
        beam_loc = [beam_loc, valid_loc];
        return;
    end
    
    if m == 0
        return
    end

    if n <= 2*m-2
        %Exhaustive Search and I have 2 frequencies
        n_steps = n_steps + ceil(n/2); 
        beam_loc = [beam_loc, find(location(valid_loc)==1)]; 
        return;
    else
        l = n - m +1;
        alpha = floor(log2(l/m));
        size = 2^alpha;
        
        % I ADDED A CONDITION
        if size >=n
            size = ceil(n/2);
        end
        
       
        %NACK for the first part of a size of 2^alpha
        check1 = sum(location(valid_loc(1: size)) == 0)== size;
        
        %NACK for the second part of a size of 2^alpha
        check2 = sum(location(valid_loc(size+1: min(2*size, end))) == 0)== length(valid_loc(size+1: min(2*size, end)));
        n_steps = n_steps + 1;
        
        
        if check1 && check2 == 0
            valid_loc = valid_loc(size+1: end);
            n = n-size;
        elseif check2 && check1 == 0
            n = n - length(valid_loc(size+1: min(2*size, end)));
            valid_loc = [valid_loc(1:size), valid_loc(min(2*size, end)+1 :end)];
        elseif check1 && check2
            n= n - length(valid_loc(1: min(2*size, end)));
            valid_loc = valid_loc(min(2*size, end)+1:end);
           
        end
        
        
        if check1 || check2
            [beam_loc, n_steps] = freq_Hwang(n,m, valid_loc, beam_loc, location, n_steps); 
            
        elseif check1 == 0 && check2 == 0 % Both side has 1
            %Parallel Binary Splitting
                        
            [beam_loc, test_n1, n,m, valid_loc_1] = binary_split(n, m, location, valid_loc(1:size),size, beam_loc, 0);
            [beam_loc, test_n2, n,m, valid_loc_2] = binary_split(n, m, location, valid_loc(size+1:end),size, beam_loc, 0);
            
            %Note that I count one more in binary split. I check the same
            %size again
            n_steps = n_steps + max(test_n1, test_n2)-1;
            valid_loc = [valid_loc_1, valid_loc_2];
            
            [beam_loc, n_steps] = freq_Hwang(n,m, valid_loc, beam_loc, location, n_steps); 
       
        end
    end
end

