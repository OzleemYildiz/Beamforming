% What if we don't change the size but continue halving in both of them
% after getting both ACK's

%NOT WORKING
function [beam_loc, n_steps, m] = freq_GT_updatewithhwang(n,m, valid_loc, beam_loc, location, n_steps)
    
    d = false;
    %Nothing to look for
    if m == 0
        return
    end
    if n == 0
        return
    end
    
    if n == 1
        if location(valid_loc) == 1 %ACK
            beam_loc = [beam_loc, valid_loc];
        end
        return;
    end
    
    if n > 2*m -2
        l = n - m +1;
        alpha = floor(log2(l/m));
        size = 2^alpha;
    else
        size = 1; 
    end
    
    if size == n
        size = ceil(n/2);
    end
    
    %First half test gives NACK if ==1
    check1 = sum(location(valid_loc(1:size)) == 0) == size;
     % Second half test gives NACK if ==1
    hold = length(valid_loc(size+1:min(2*size,end)));
    check2 = sum(location(valid_loc(size+1:min(2*size,end))) == 0) == hold ;
    
    if size ==1 
        n = n-1;
        if check1 == 0
            m = m-1;
            beam_loc = [beam_loc, valid_loc(1:size)];
        end
        
        valid_loc = valid_loc(2:end);
        d = true;
    end
    
    n_steps = n_steps +1;
    
    if check1&& check2 && size ~= 1
        valid_loc = valid_loc(min(2*size+1,end):end); 
        n = n-size-hold;     
    elseif check1 && size ~=1 
        valid_loc = valid_loc(size+1:end); 
        n = n-size;    
    elseif check2 && size ~=1   
        valid_loc = valid_loc([1:size, min(2*size+1, end):end]);   
        n = n-hold;
    elseif check2 && size ==1 
        valid_loc = valid_loc(hold+1:end);   
        n = n-hold;
    end
    
    if check1 == 0 && check2 == 0 && d == false
        [beam_loc, n_steps,m] = freq_GT_updatewithhwang(size ,m, valid_loc(1:size), beam_loc,location, n_steps);
        [beam_loc, n_steps,m] = freq_GT_updatewithhwang(size,m, valid_loc(min(size+1,end):2*size), beam_loc,location, n_steps);   
    else
        [beam_loc, n_steps,m] = freq_GT_updatewithhwang(n,m, valid_loc, beam_loc,location, n_steps);
    end
    
    

end