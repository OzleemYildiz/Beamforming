 % Original method from the paper
 % if noisy use pmd (misdetection probability) and pfa (false alarm
 % probability) to demonstrate noise

 % When it's ACK, getting NACK : MD (False negative)
  % When it's NACK, getting ACK : FA (False positive)

function [beam_loc, n_steps, valid_loc] = Hwang_gt(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa)

%     if n == m
%         %Append the locations to check
%         %But no need to check but I know that all of them are paths
%         
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
        %Exhaustive Search
        size_n = n;
        for ex = 1:size_n
            n_steps = n_steps +1;
            check_ex = location(valid_loc(ex)) == 0; %=0 ACK
            pe = rand(1,1);
            
            if check_ex == 0 && pe< pmd % random error satisfies, it's not ACK anymore (Check1 means it was a NACK)
                check_ex = 1;
            elseif  check_ex && pe< pfa
                check_ex = 0;
            end
            
            if check_ex == 0 %ACK
                beam_loc = [beam_loc, valid_loc(ex)];
                m = m-1;
                n= n-1;
            end
            if m ==0
                valid_loc = valid_loc(ex+1:end);
                return;
            end    
        end      
        valid_loc = []; %I checked every one of them but m is still not 0. 
        return;
    else
        l = n - m +1;
        alpha = floor(log2(l/m));
        size_check = 2^alpha;
        
        % I ADDED A CONDITION --- this reduces to bisection
        if size_check >=n
            size_check = ceil(n/2);
        end
        
       
        %NACK when check1 ==1 for the first part of a size of 2^alpha
        check1 = sum(location(valid_loc(1: size_check)) == 0)== size_check;  
        n_steps = n_steps + 1;
        
        % The impact of noise with respect to pmd and pfa
        pe = rand(1,1);
        if check1 == 0 && pe< pmd % random error satisfies, it's not ACK anymore (Check1 means it was a NACK)
            check1 = 1;
        elseif  check1 && pe< pfa
            check1 = 0;
        end
        
        
        
        if check1 
            valid_loc = valid_loc(size_check+1: end);
            n = n-size_check;
            
            [beam_loc, n_steps, valid_loc] = Hwang_gt(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa); 
     
                
        else
            %Parallel Binary Splitting
            
            [beam_loc, test_n1, n,m, valid_loc_1] = binary_split(n, m, location, valid_loc(1:size_check) ,size_check, beam_loc, 0, pmd, pfa);
            
            valid_loc = [valid_loc_1, valid_loc(size_check+1:end)];
            %Note that I count one more in binary split. I check the same
            %size again
            n_steps = n_steps +test_n1-1;
      
            [beam_loc, n_steps, valid_loc] = Hwang_gt(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa); 
       
        end
    end
end

