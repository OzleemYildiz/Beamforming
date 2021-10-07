 % What if we use HWANG in 2 frequency with each having 2^{alpha} size

function [beam_loc, n_steps] = Hwang_gt(n,m, valid_loc, beam_loc, location, n_steps)
    if n == 0
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
        n_steps = n_steps + 1;
        
        
        if check1 
            valid_loc = valid_loc(size+1: end);
            n = n-size;
            
            [beam_loc, n_steps] = Hwang_gt(n,m, valid_loc, beam_loc, location, n_steps); 
     
                
        else
            %Parallel Binary Splitting
                        
            [beam_loc, test_n1, n,m, valid_loc] = binary_split(n, m, location, valid_loc ,size, beam_loc, 0);
            
            %Note that I count one more in binary split. I check the same
            %size again
            n_steps = n_steps +test_n1-1;
      
            [beam_loc, n_steps] = Hwang_gt(n,m, valid_loc, beam_loc, location, n_steps); 
       
        end
    end
end

