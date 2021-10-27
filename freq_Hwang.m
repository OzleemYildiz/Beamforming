 % What if we use HWANG in 2 frequency with each having 2^{alpha} size

function [beam_loc, n_steps] = freq_Hwang(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa)
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
    
    if n==m
        beam_loc = [beam_loc, valid_loc];
        return;
    end

    if n <= 2*m-2
        %Exhaustive Search and I have 2 frequencies
        size_n = n;
        for ex = 1:2:size_n
           if m ==0
                valid_loc = valid_loc(ex+1:end);
                return;
           end 
           if n == m
                beam_loc = [beam_loc, valid_loc];
                valid_loc = [];
                return;
           end
            
            n_steps = n_steps +1;
            check_ex_1 = location(valid_loc(ex)) == 0; % =0 ,ACK
            n = n-1;
            
            pe1 = rand(1,1);
            pe2=  rand(1,1);
            
            if check_ex_1 == 0 && pe1< pmd % random error satisfies, it's not ACK anymore (Check1 means it was a NACK)
                check_ex_1 = 1;
            elseif  check_ex_1 && pe2< pfa
                check_ex_1 = 0;
            end
            
            
            if check_ex_1 == 0 %ACK
                beam_loc = [beam_loc, valid_loc(ex)];
                m = m-1;
            end
            if ex+1 <= length(valid_loc)
                check_ex_2 = location(valid_loc(ex+1)) == 0; % =0 ,ACK
                
                n = n-1;
                
                pe1 = rand(1,1);
                pe2=  rand(1,1);
                if check_ex_2 == 0 && pe1< pmd % random error satisfies, it's not ACK anymore (Check1 means it was a NACK)
                    check_ex_2 = 1;
                elseif  check_ex_2 && pe2< pfa
                    check_ex_2 = 0;
                end
                
                
                if check_ex_2 ==0
                    beam_loc = [beam_loc, valid_loc(ex+1)];
                    m = m-1;
                end
            end   
        end      
        valid_loc = []; %I checked every one of them but m is still not 0. 
        return;
    else
        l = n - m +1;
        alpha = floor(log2(l/m));
        size_check = 2^alpha;
        
        % I ADDED A CONDITION
        if size_check >=n
            size_check = ceil(n/2);
        end
        
       
        %NACK for the first part of a size of 2^alpha
        check1 = sum(location(valid_loc(1: size_check)) == 0)== size_check;
        
        % The impact of noise with respect to pmd and pfa
        pe1 = rand(1,1);
        pe2=  rand(1,1);
        if check1 == 0 && pe1< pmd % random error satisfies, it's not ACK anymore (Check1 means it was a NACK)
            check1 = 1;
        elseif  check1 && pe2< pfa
            check1 = 0;
        end
        
        %NACK for the second part of a size of 2^alpha
        hold = length(valid_loc(size_check+1: min(2*size_check, end)));
        check2 = sum(location(valid_loc(size_check+1: min(2*size_check, end))) == 0)== hold;
        n_steps = n_steps + 1;
        
        % The impact of noise with respect to pmd and pfa
        pe1 = rand(1,1);
        pe2=  rand(1,1);
        if check2 == 0 && pe1< pmd % random error satisfies, it's not ACK anymore (Check1 means it was a NACK)
            check2 = 1;
        elseif  check2 && pe2< pfa
            check2 = 0;
        end
        
      
        
        
        
        if size_check == 1 
            if check1 == 0 && check2 == 0 && hold ~= 0
                beam_loc = [beam_loc, valid_loc(1: 2*size_check)];
                valid_loc = valid_loc(2*size_check+1: end);
                n = n-2;
                m = m-2;
            elseif check1 == 0 && check2  && hold ~= 0
                beam_loc = [beam_loc, valid_loc(1: size_check)];
                valid_loc = valid_loc(2*size_check+1: end);
                n = n-2;
                m = m-1;
            elseif check1 && check2 ==0  && hold ~= 0
                beam_loc = [beam_loc, valid_loc(size_check+1: 2*size_check)];
                valid_loc = valid_loc(2*size_check+1: end);
                n = n-2;
                m = m-1;
            elseif check1 == 0
                beam_loc = [beam_loc, valid_loc(1: size_check)];
                valid_loc = valid_loc(size_check+1: end);
                n = n-1;
                m = m-1;
            else
                valid_loc = valid_loc(size_check+hold+1: end);
                n = n-size_check-hold;
            end
            
            [beam_loc, n_steps] = freq_Hwang(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa); 

        end
            
        
        if check1 && check2 == 0 && size_check~=1
            valid_loc = valid_loc(size_check+1: end);
            n = n-size_check;
        elseif check2 && check1 == 0 && size_check~=1
            n = n - length(valid_loc(size_check+1: min(2*size_check, end)));
            valid_loc = [valid_loc(1:size_check), valid_loc(min(2*size_check, end)+1 :end)];
        elseif check1 && check2 && size_check~=1
            n= n - length(valid_loc(1: min(2*size_check, end)));
            valid_loc = valid_loc(min(2*size_check, end)+1:end);
        end
        
        
        if check1 || check2 && size_check~=1
            [beam_loc, n_steps] = freq_Hwang(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa); 
            
        elseif check1 == 0 && check2 == 0 && size_check~=1 % Both side has 1
            %Parallel Binary Splitting
                        
            [beam_loc, test_n1, n,m, valid_loc_1] = binary_split(n, m, location, valid_loc(1:size_check),size_check, beam_loc, 0, pmd, pfa);
            [beam_loc, test_n2, n,m, valid_loc_2] = binary_split(n, m, location, valid_loc(size_check+1:min(2*size_check,end)),hold, beam_loc, 0, pmd, pfa);
            
            %Note that I count one more in binary split. I check the same
            %size again
            n_steps = n_steps + max(test_n1, test_n2)-1;
            valid_loc = [valid_loc_1, valid_loc_2,  valid_loc(min(2*size_check +1, end):end)];
            
            [beam_loc, n_steps] = freq_Hwang(n,m, valid_loc, beam_loc, location, n_steps, pmd, pfa); 
       
        end
    end
end

