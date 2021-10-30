function [beam_loc, n_steps] = exhaustive(n, m, location, pmd, pfa)
    beam_loc = {};
    n_steps= 0;
    for ex = 1:n
        if m ==0
            return;
        end 
        
        if ex == n-m+1
           beam_loc = [beam_loc, ex:n]; 
           return;
        end
               
        
        n_steps = n_steps +1;
        check_ex_1 = location(ex) == 0; % =0 ,ACK
        pe1 = rand(1,1);
        pe2 = rand(1,1);
        
        if check_ex_1 == 0 && pe1< pmd % random error satisfies, it's not ACK anymore (Check1 means it was a NACK)
            check_ex_1 = 1;
        elseif  check_ex_1 && pe2< pfa
            check_ex_1 = 0;
        end


        if check_ex_1 == 0 %ACK
            beam_loc = [beam_loc, ex];
            m = m-1;
        end
        
    end
end