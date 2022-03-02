 % What if we use HWANG in 2 frequency with each having 2^{alpha} size
%Change for 5G
function [beam_loc, n_steps] = parallel_gt_5g(n,m, valid_loc, beam_loc, location, n_steps, gain_gaussian, angle_ue, threshold)
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
    
%     if n==m
%         beam_loc = [beam_loc, valid_loc];
%         return;
%     end

    if n <= 2*m-2
        %Exhaustive Search and I have 2 frequencies
        size_n = n;
        for ex = 1:2:size_n
           if m ==0
                valid_loc = valid_loc(ex+1:end);
                return;
           end 
%            if n == m
%                 beam_loc = [beam_loc, valid_loc];
%                 valid_loc = [];
%                 return;
%            end
            
            n_steps = n_steps +1;
            %check_ex_1 = location(valid_loc(ex)) == 0; % =0 ,ACK
            pathexists_ex_1 = beamform(4*n, valid_loc(ex), gain_gaussian, angle_ue, threshold);

            n = n-1;
            

            
            
            if pathexists_ex_1 %ACK
                beam_loc = [beam_loc, valid_loc(ex)];
                m = m-1;
            end
            if ex+1 <= length(valid_loc)
                %check_ex_2 = location(valid_loc(ex+1)) == 0; % =0 ,ACK
                pathexists_ex_2 = beamform(4*n, valid_loc(ex+1), gain_gaussian, angle_ue, threshold);
                n = n-1;

                
                
                if pathexists_ex_2 %ACK
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
        %check1 = sum(location(valid_loc(1: size_check)) == 0)== size_check;
        
        pathexists_1 = beamform(4*n,valid_loc(1: size_check), gain_gaussian, angle_ue, threshold);
        
        
        %NACK for the second part of a size of 2^alpha
        hold = length(valid_loc(size_check+1: min(2*size_check, end)));
        %check2 = sum(location(valid_loc(size_check+1: min(2*size_check, end))) == 0)== hold;
        pathexists_2 = beamform(4*n,valid_loc(size_check+1: min(2*size_check, end)), gain_gaussian, angle_ue, threshold);

        n_steps = n_steps + 1;
        
      
        
        
        if size_check == 1 
            if pathexists_1 && pathexists_2 && hold ~= 0
                beam_loc = [beam_loc, valid_loc(1: 2*size_check)];
                valid_loc = valid_loc(2*size_check+1: end);
                n = n-2;
                m = m-2;
            elseif pathexists_1 && pathexists_2==0  && hold ~= 0
                beam_loc = [beam_loc, valid_loc(1: size_check)];
                valid_loc = valid_loc(2*size_check+1: end);
                n = n-2;
                m = m-1;
            elseif pathexists_1==0 && pathexists_2  && hold ~= 0
                beam_loc = [beam_loc, valid_loc(size_check+1: 2*size_check)];
                valid_loc = valid_loc(2*size_check+1: end);
                n = n-2;
                m = m-1;
            elseif pathexists_1
                beam_loc = [beam_loc, valid_loc(1: size_check)];
                valid_loc = valid_loc(size_check+1: end);
                n = n-1;
                m = m-1;
            else
                valid_loc = valid_loc(size_check+hold+1: end);
                n = n-size_check-hold;
            end
            
            [beam_loc, n_steps] = parallel_gt_5g(n,m, valid_loc, beam_loc, location, n_steps,gain_gaussian, angle_ue, threshold); 

        end
            
        
        if pathexists_1==0 && pathexists_2 && size_check~=1
            valid_loc = valid_loc(size_check+1: end);
            n = n-size_check;
        elseif pathexists_2==0 && pathexists_1 && size_check~=1
            n = n - length(valid_loc(size_check+1: min(2*size_check, end)));
            valid_loc = [valid_loc(1:size_check), valid_loc(min(2*size_check, end)+1 :end)];
        elseif pathexists_1==0 && pathexists_2==0 && size_check~=1
            n= n - length(valid_loc(1: min(2*size_check, end)));
            valid_loc = valid_loc(min(2*size_check, end)+1:end);
        end
        
        
        if (pathexists_1==0 || pathexists_2==0) && size_check~=1
            [beam_loc, n_steps] = parallel_gt_5g(n,m, valid_loc, beam_loc, location, n_steps,gain_gaussian, angle_ue, threshold); 
            
        elseif pathexists_1 && pathexists_2 && size_check~=1 % Both side has 1
            %Parallel Binary Splitting
                        
            [beam_loc, test_n1, n,m, valid_loc_1] = binary_split_5g(n, m, location, valid_loc(1:size_check),size_check, beam_loc, 0, gain_gaussian, angle_ue, threshold);
            [beam_loc, test_n2, n,m, valid_loc_2] = binary_split_5g(n, m, location, valid_loc(size_check+1:min(2*size_check,end)),hold, beam_loc, 0, gain_gaussian, angle_ue, threshold);
            
            %Note that I count one more in binary split. I check the same
            %size again
            n_steps = n_steps + max(test_n1, test_n2)-1;
            valid_loc = [valid_loc_1, valid_loc_2,  valid_loc(min(2*size_check +1, end):end)];
            
            [beam_loc, n_steps] = parallel_gt_5g(n,m, valid_loc, beam_loc, location, n_steps, gain_gaussian, angle_ue, threshold); 
       
        end
    end
end

