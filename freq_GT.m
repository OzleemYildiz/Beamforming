% Hybrid Beamforming
% Jyotish method
%


% 2 frequencies 
% Halve after discarding
% If both ACK, change size and then halve 

function [beam_loc, n_steps] = freq_GT(n,m, valid_loc, beam_loc, location, n_steps, mid)
    
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
    
        
    %There is no beams
    if check1 && check2
        return
    end
    
    if check1 && d == false
        valid_loc = valid_loc(mid+1:end); 
        n = n-mid;
        
        mid = ceil(length(valid_loc)/2);
    end
    
    if check2 
        valid_loc = valid_loc(1:mid);   
        n = mid;
        
        mid = ceil(length(valid_loc)/2);
    end
    
    if check1 == 0 && check2 == 0 && d == false
        %There is a problem with circshift, I may never get four of them
        %next to each other as NACK
        %valid_loc = circshift(valid_loc, 1);
        
        % I might still not find enough 0's next to each other
        %valid_loc = valid_loc(randperm(length(valid_loc)));
        mid = floor(mid/2);
        
    end
    
    [beam_loc, n_steps] = freq_GT(n,m, valid_loc, beam_loc,location, n_steps, mid);

end