% What if we don't change the size but continue halving in both of them
% after getting both ACK's


function [beam_loc, n_steps, m] = freq_GT_update(n,m, valid_loc, beam_loc, location, n_steps, mid)
    
    d = false;
    %Nothing to look for
    if m == 0
        return
    end
    
    if n == 1
        if location(valid_loc) == 1 %ACK
            beam_loc = [beam_loc, valid_loc];
        end
        return;
    end
    
    %All my group includes the defectives
%     if n <= m
%         beam_loc = [beam_loc, valid_loc];
%         m = m -n;
%         return
%     end
    
    
    
    %First half test gives NACK if ==1
    check1 = sum(location(valid_loc(1:mid)) == 0) == mid;
     % Second half test gives NACK if ==1
    check2 = sum(location(valid_loc(mid+1:end)) == 0) == (length(valid_loc)- mid);
    
    if mid ==1 
        n = n-1;
        if check1 == 0
            m = m-1;
            beam_loc = [beam_loc, valid_loc(1:mid)];
        end
        
        valid_loc = valid_loc(2:end);
        mid = ceil(length(valid_loc)/2);
        d = true;
    end
    
    n_steps = n_steps +1;
    
        
    
    if check1 && mid ~=1 
        valid_loc = valid_loc(mid+1:end); 
        n = n-mid;
        
        mid = ceil(length(valid_loc)/2);
    end
    
    if check2 && d == false
        valid_loc = valid_loc(1:mid);   
        n = mid;        
        mid = ceil(length(valid_loc)/2);
    end
    
    if check1 == 0 && check2 == 0 && d == false
        [beam_loc, n_steps,m] = freq_GT_update(mid ,m, valid_loc(1:mid), beam_loc,location, n_steps, ceil(mid/2));
        [beam_loc, n_steps,m] = freq_GT_update(length(valid_loc)- mid,m, valid_loc(mid+1: end), beam_loc,location, n_steps, ceil(length( valid_loc(mid+1: end))/2));   
    else
        [beam_loc, n_steps,m] = freq_GT_update(n,m, valid_loc, beam_loc,location, n_steps, mid);
    end
    
    

end