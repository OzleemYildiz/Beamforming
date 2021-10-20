 % What if we use HWANG in 2 frequency with each having 2^{alpha} size
%Every ACK deserves split


function [beam_loc, n_steps] = freq_GT_hwang_nocomingback(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa)
%     if n == m
%         %Append the locations to check
%         %But no need to check but I know that all of them are paths
%         beam_loc = [beam_loc, valid_loc];
%         return;
%     end
    
    if n == 0
        return
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
        
        % The impact of noise with respect to pmd and pfa
        pe = rand(1,1);
        if check1 == 0 && pe< pmd % random error satisfies, it's not ACK anymore (Check1 means it was a NACK)
            check1 = 1;
        elseif  check1 && pe< pfa
            check1 = 0;
        end
        
        %NACK for the second part of a size of 2^alpha
        hold = length(valid_loc(size+1: min(2*size, end)));
        check2 = sum(location(valid_loc(size+1: min(2*size, end))) == 0)== hold;
        n_steps = n_steps + 1;
        
        % The impact of noise with respect to pmd and pfa
        pe = rand(1,1);
        if check2 == 0 && pe< pmd % random error satisfies, it's not ACK anymore (Check1 means it was a NACK)
            check2 = 1;
        elseif  check2 && pe< pfa
            check2 = 0;
        end
        
        
        if size == 1 
            if check1 == 0 && check2 == 0 && hold ~= 0
                beam_loc = [beam_loc, valid_loc(1: 2*size)];
                valid_loc = valid_loc(2*size+1: end);
                n = n-2;
                m = m-2;
            elseif check1 == 0 && check2  && hold ~= 0
                beam_loc = [beam_loc, valid_loc(1: size)];
                valid_loc = valid_loc(2*size+1: end);
                n = n-2;
                m = m-1;
            elseif check1 && check2 ==0  && hold ~= 0
                beam_loc = [beam_loc, valid_loc(size+1: 2*size)];
                valid_loc = valid_loc(2*size+1: end);
                n = n-2;
                m = m-1;
            elseif check1 == 0
                beam_loc = [beam_loc, valid_loc(1: size)];
                valid_loc = valid_loc(size+1: end);
                n = n-1;
                m = m-1;
            else
                valid_loc = valid_loc(size+hold+1: end);
                n = n-size-hold;
            end
            
            [beam_loc, n_steps] = freq_GT_hwang_nocomingback(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa); 

        end
            
        
        if check1 && check2 == 0 && size~=1
            valid_loc = valid_loc(size+1: end);
            n = n-size;
        elseif check2 && check1 == 0 && size~=1
            n = n - length(valid_loc(size+1: min(2*size, end)));
            valid_loc = [valid_loc(1:size), valid_loc(min(2*size, end)+1 :end)];
        elseif check1 && check2 && size~=1
            n= n - length(valid_loc(1: min(2*size, end)));
            valid_loc = valid_loc(min(2*size, end)+1:end);
        end
        
        
        if check1 && check2 && size~=1 %Both ACK
            [beam_loc, n_steps] = freq_GT_hwang_nocomingback(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa); 
            
        elseif check1 == 0 && check2 == 0 && size~=1 % Both side has 1
            %Parallel Binary Splitting
                        
            [beam_loc, test_n1, n,m, valid_loc_1] = binary_split(n, m, location, valid_loc(1:size),size, beam_loc, 0, pmd, pfa);
            [beam_loc, test_n2, n,m, valid_loc_2] = binary_split(n, m, location, valid_loc(size+1:min(2*size,end)),hold, beam_loc, 0, pmd, pfa);
            
            %Note that I count one more in binary split. I check the same
            %size again
            n_steps = n_steps + max(test_n1, test_n2)-1;
            valid_loc = [valid_loc_1, valid_loc_2,  valid_loc(min(2*size +1, end):end)];
            
            [beam_loc, n_steps] = freq_GT_hwang_nocomingback(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa); 
       
        elseif check1 && check2 == 0 && size~=1 % Second one has ACK
            [beam_loc, test_n2, n,m, valid_loc_2] = binary_split(n, m, location, valid_loc(1:hold),hold, beam_loc, 0, pmd, pfa);
            
            hold_2 =  length(valid_loc(hold +1:end));
            if hold_2 > size
                hold_2 = size;
            end
            
            if hold_2 ~= 0
                check_in = sum(location(valid_loc(hold +1:hold +hold_2)) == 0)== hold_2;
                n_test_in = 1;
                if check_in == 1 %NACK
                    valid_loc = [valid_loc_2,  valid_loc(hold+1+hold_2:end)];
                    n = n-hold_2; % Just use Binary splitting result earlier
                else
                    [beam_loc, test_n_in, n,m, valid_loc_in] = binary_split(n, m, location, valid_loc(hold +1:hold +hold_2),hold_2, beam_loc, 0, pmd, pfa);
                    valid_loc = [valid_loc_2, valid_loc_in,  valid_loc(hold+1+hold_2:end)];
                    n_test_in = n_test_in + test_n_in;
                end
            else
                valid_loc = valid_loc_2;
                n_test_in = 0;
            end
            
            n_steps = max(test_n2, n_test_in);
            [beam_loc, n_steps] = freq_GT_hwang_nocomingback(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa);           
        elseif check1 == 0 && check2  && size~=1 % First one has ACK
            [beam_loc, test_n2, n,m, valid_loc_2] = binary_split(n, m, location, valid_loc(1:size),size, beam_loc, 0, pmd, pfa);
            % 2nd one is already gone
            hold_2 =  length(valid_loc(size +1:end));
            if hold_2 > size
                hold_2 = size;
            end
            
            
            if hold_2 ~= 0
                check_in = sum(location(valid_loc(size+1:size+hold_2)) == 0)== hold_2;
                n_test_in = 1;
                if check_in == 1 %NACK
                    valid_loc = [valid_loc_2, valid_loc(size+1+hold_2:end)];% Just use Binary splitting result earlier
                    n = n-hold_2; 
                else
                    [beam_loc, test_n_in, n,m, valid_loc_in] = binary_split(n, m, location, valid_loc(size+1:size+hold_2),hold_2, beam_loc, 0, pmd, pfa);
                    valid_loc = [valid_loc_2, valid_loc_in, valid_loc(size+1+hold_2:end)];
                    n_test_in = n_test_in + test_n_in;
                end
            else
                valid_loc = valid_loc_2;
                n_test_in = 0;
            end
            
            n_steps = max(test_n2, n_test_in);
            [beam_loc, n_steps] = freq_GT_hwang_nocomingback(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa);           
        end
    end
end

