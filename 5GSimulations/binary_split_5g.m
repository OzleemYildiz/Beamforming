function [beam_loc, test_n, n,m, valid_loc] = binary_split_5g(total_codebook,n, m, location, valid_loc,size_check, beam_loc, n_tests, gain_gaussian, angle_ue, threshold)
    
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

    %check =  sum(location(valid_loc(1:size_check)) == 0) == size_check; %NACK is 1
    
    %pathexists = beamform_sectored(total_codebook,n, valid_loc(1: size_check), gain_gaussian, angle_ue, threshold);
    pathexists = beamform_hierarchical(total_codebook,n, valid_loc(1: size_check), gain_gaussian, angle_ue, threshold);

    test_n = n_tests +1;
    
    
    
    if size_check == 1
        if pathexists %ACK
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
        elseif pathexists==0 && n ==1 % There was an error, we ended without finding the beam, NACK
            valid_loc = valid_loc(size_check+1:end);
            n = n-1;
        elseif pathexists==0 %NACK 
            valid_loc = valid_loc(size_check+1:end);
            n = n-1;
            [beam_loc, test_n, n, m, valid_loc] = binary_split_5g(total_codebook,n, m, location, valid_loc, 1, beam_loc, test_n, gain_gaussian, angle_ue, threshold);
        end
        
     elseif pathexists ==0 %NACK
        valid_loc = valid_loc(size_check+1:end);
        n = n - size_check;
        m = m;
        [beam_loc, test_n, n, m, valid_loc] = binary_split_5g(total_codebook,n, m, location, valid_loc, floor(size_check/2), beam_loc, test_n, gain_gaussian, angle_ue, threshold);
    else
       [beam_loc, test_n, n, m, valid_loc] = binary_split_5g(total_codebook,n, m, location, valid_loc, floor(size_check/2), beam_loc, test_n, gain_gaussian, angle_ue, threshold);
               
    end
  
 end