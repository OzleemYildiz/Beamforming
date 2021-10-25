function [beam_loc, test_n, n,m, valid_loc] = binary_split(n, m, location, valid_loc,size_check, beam_loc, n_tests, pmd, pfa)
    
    if n == 0 || size(valid_loc,2) == 0 %Sometimes I can end without finding the beam
        test_n = n_tests;
        return
    end
    if m == 0
        test_n = n_tests;
        return
    end
    
    if length(valid_loc) < size_check % Sometimes it's not balanced because of error
        size_check = length(valid_loc);
    end
    
    if isempty(valid_loc)
        return
    end

    check =  sum(location(valid_loc(1:size_check)) == 0) == size_check; %NACK is 1
    test_n = n_tests +1;
    
     % The impact of noise with respect to pmd and pfa
    pe = rand(1,1);
    if check == 0 && pe< pmd % random error satisfies, it's not ACK anymore (Check1 means it was a NACK)
        check = 1;
    elseif  check && pe< pfa
        check = 0;
    end
    
    
    if size_check == 1
        if check ==0 %ACK
            beam_loc = [beam_loc, valid_loc(1:size_check)];
            valid_loc = valid_loc(size_check+1:end);
            n = n-1;
            m = m-1;
        elseif n == 2 && size(valid_loc,2) > 1 %NACK so other one is ACK
            beam_loc = [beam_loc, valid_loc(size_check+1)];
            valid_loc = valid_loc(size_check+2:end);
            n =n -2;
            m = m-1;
        elseif  size(valid_loc,2) >= 2
            beam_loc = [beam_loc, valid_loc(size_check+1)];
            valid_loc = valid_loc(size_check+2:end);
            n =n -2;
            m = m-1;
        elseif check && n ==1 % There was an error, we ended without finding the beam
            valid_loc = valid_loc(size_check+1:end);
            n = n-1;
        elseif check 
            valid_loc = valid_loc(size_check+1:end);
            n = n-1;
            [beam_loc, test_n, n, m, valid_loc] = binary_split(n, m, location, valid_loc, 1, beam_loc, test_n, pmd, pfa);
        end
        
     elseif check
        valid_loc = valid_loc(size_check+1:end);
        n = n - size_check;
        m = m;
        [beam_loc, test_n, n, m, valid_loc] = binary_split(n, m, location, valid_loc, floor(size_check/2), beam_loc, test_n, pmd, pfa);
    else
       [beam_loc, test_n, n, m, valid_loc] = binary_split(n, m, location, valid_loc, floor(size_check/2), beam_loc, test_n, pmd, pfa);
               
    end
  
 end