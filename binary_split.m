function [beam_loc, test_n, n,m, valid_loc] = binary_split(n, m, location, valid_loc,size, beam_loc, n_tests)
    test_n = n_tests +1;
    
    if size == 1
        if location(valid_loc(1)) == 1 %ACK
            beam_loc = [beam_loc, valid_loc(1:size)];
            valid_loc = valid_loc(size+1:end);
            n = n-1;
        else %NACK so other one is ACK
            beam_loc = [beam_loc, valid_loc(size+1)];
            valid_loc = valid_loc(size+2:end);
            n =n -2;
        end
        m = m-1;
     elseif sum(location(valid_loc(1:size)) == 0) == size
        valid_loc = valid_loc(size+1:end);
        n = n - size;
        m = m;
        [beam_loc, test_n, n, m, valid_loc] = binary_split(n, m, location, valid_loc, size/2, beam_loc, test_n);
    else
       [beam_loc, test_n, n, m, valid_loc] = binary_split(n, m, location, valid_loc, size/2, beam_loc, test_n);
               
    end
  
 end