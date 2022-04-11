 % What if we use HWANG in 2 frequency with each having 2^{alpha} size
%Every ACK deserves split


function [beam_loc, n_steps] = parallel_gt_ack_5g(total_codebook,n,m, valid_loc, beam_loc, location, n_steps, gain_gaussian, angle_ue, threshold)
%     if n == m
%         %Append the locations to check
%         %But no need to check but I know that all of them are paths
%         beam_loc = [beam_loc, valid_loc];
%         return;
%     end
    
    if n == 0
        return
    end
    
    if m <= 0
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
%            if n == m
%                 beam_loc = [beam_loc, valid_loc];
%                 valid_loc = [];
%                 return;
%            end
           if m ==0
                valid_loc = valid_loc(ex+1:end);
                return;
           end 
            
            n_steps = n_steps +1;
            %check_ex_1 = location(valid_loc(ex)) == 0; % =0 ,ACK
            
            n = n-1;
            %ACK is 1
            pathexists_ex_1 = beamform_sectored(total_codebook,n, valid_loc(ex), gain_gaussian, angle_ue, threshold);

            
            
            if pathexists_ex_1 %ACK
                beam_loc = [beam_loc, valid_loc(ex)];
                m = m-1;
            end
            if ex+1 <= length(valid_loc)
                %check_ex_2 = location(valid_loc(ex+1)) == 0; % =0 ,ACK
                pathexists_ex_2 = beamform_sectored(total_codebook,n, valid_loc(ex+1), gain_gaussian, angle_ue, threshold);

                
                
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
        
        pathexists_1 = beamform_sectored(total_codebook,n, valid_loc(1: size_check), gain_gaussian, angle_ue, threshold);


        %NACK for the second part of a size of 2^alpha
        hold = length(valid_loc(size_check+1: min(2*size_check, end)));
        a_hold = floor(log2(hold));
        hold = 2^a_hold;

        
        %check2 = sum(location(valid_loc(size_check+1: size_check+hold)) == 0)== hold;
        pathexists_2 = beamform_sectored(total_codebook,n, valid_loc(size_check+1: size_check+hold), gain_gaussian, angle_ue, threshold);

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
            
            [beam_loc, n_steps] = parallel_gt_ack_5g(total_codebook,n,m, valid_loc, beam_loc, location, n_steps, gain_gaussian, angle_ue, threshold); 

        end
            
        
        if pathexists_1==0 && pathexists_2 && size_check~=1
            valid_loc = valid_loc(size_check+1: end);
            n = n-size_check;
        elseif pathexists_2==0 && pathexists_1 && size_check~=1
            n = n - hold;
            valid_loc = [valid_loc(1:size_check), valid_loc(size_check +hold+1 :end)];
        elseif pathexists_1 ==0 && pathexists_2==0 && size_check~=1 %BOTH NACK
            n= n - length(valid_loc(1: size_check +hold));
            valid_loc = valid_loc(size_check +hold+1:end);
        end
        
        
        if pathexists_1==0 && pathexists_2==0 && size_check~=1 %Both NACK
            [beam_loc, n_steps] = parallel_gt_ack_5g(total_codebook,n,m, valid_loc, beam_loc, location, n_steps, gain_gaussian, angle_ue, threshold); 
            
        elseif pathexists_1 && pathexists_2 && size_check~=1 % Both side has 1
            %Parallel Binary Splitting
                        
            [beam_loc, test_n1, n,m, valid_loc_1] = binary_split_5g(total_codebook,n, m, location, valid_loc(1:size_check),size_check, beam_loc, 0, gain_gaussian, angle_ue, threshold);
            [beam_loc, test_n2, n,m, valid_loc_2] = binary_split_5g(total_codebook,n, m, location, valid_loc(size_check+1:size_check + hold),hold, beam_loc, 0, gain_gaussian, angle_ue, threshold);
            
            %Note that I count one more in binary split. I check the same
            %size again
            n_steps = n_steps + max(test_n1, test_n2)-1;
            valid_loc = [valid_loc_1, valid_loc_2,  valid_loc(size_check+hold +1:end)];
            
            [beam_loc, n_steps] = parallel_gt_ack_5g(total_codebook,n,m, valid_loc, beam_loc, location, n_steps, gain_gaussian, angle_ue, threshold); 
       
        elseif pathexists_1==0 && pathexists_2 && size_check~=1 % Second one has ACK
            [beam_loc, test_n2, n,m, valid_loc_2] = binary_split_5g(total_codebook,n, m, location, valid_loc(1:hold),hold, beam_loc, 0, gain_gaussian, angle_ue, threshold);
            
            % 2nd one is already gone, what is left in the array
            hold_2 =  length(valid_loc(hold +1:end));
            a_hold = floor(log2(hold_2));
            hold_2 = 2^a_hold;
                    
            if hold_2 > size_check
                hold_2 = size_check;
            end
            
            if hold_2 ~= 0
                %check_in = sum(location(valid_loc(hold +1:hold +hold_2)) == 0)== hold_2;
                pathexists_in = beamform_sectored(total_codebook,n, valid_loc(hold +1:hold +hold_2), gain_gaussian, angle_ue, threshold);

                n_test_in = 1;
                
                
                
                if pathexists_in==0 %NACK
               
                 if isempty(valid_loc(hold+1+hold_2:end))==0 %Not empty so let me check
                    size_more = length(valid_loc(hold+1+hold_2:end));
                    %check_more = sum(location(valid_loc(hold+1+hold_2:end)) == 0)== size_more; %NACK
                    pathexists_more = beamform_sectored(total_codebook,n, valid_loc(hold+1+hold_2:end), gain_gaussian, angle_ue, threshold);
                    
                    n_test_in  = n_test_in +1;
                    if pathexists_more==0 % The rest is also NACK
                        valid_loc = valid_loc_2;% Just use Binary splitting result earlier
                        n = n-hold_2 -size_more; 
                    elseif pathexists_more && size_more ==1 %ACK and size 1
                        beam_loc = [beam_loc,  valid_loc(hold+1+hold_2:end)];
                        valid_loc = valid_loc_2; %The size was 1 and the hold gave NACK so binary split;
                        n = n-hold_2-1; %1 beam we found
                        m = m-1; 
                    else %ACK but not size 1
                        valid_loc = [valid_loc_2, valid_loc(hold+1+hold_2:end)];
                        n = n-hold_2;
                    end 
                else %The rest is empty
                    valid_loc = valid_loc_2;% Just use Binary splitting result earlier
                    n = n-hold_2; %hold_2 part was NACK                       
                end

                  
                
                else
                    [beam_loc, test_n_in, n,m, valid_loc_in] = binary_split_5g(total_codebook,n, m, location, valid_loc(hold +1:hold +hold_2),hold_2, beam_loc, 0, gain_gaussian, angle_ue, threshold);
                    valid_loc = [valid_loc_2, valid_loc_in,  valid_loc(hold+1+hold_2:end)];
                    n_test_in = n_test_in + test_n_in;
                end
            else
                valid_loc = valid_loc_2;
                n_test_in = 0;
            end
            
            n_steps = max(test_n2, n_test_in);
            [beam_loc, n_steps] = parallel_gt_ack_5g(total_codebook,n,m, valid_loc, beam_loc, location, n_steps, gain_gaussian, angle_ue, threshold);           
        elseif pathexists_1 && pathexists_2==0  && size_check~=1 % First one has ACK
            [beam_loc, test_n2, n,m, valid_loc_2] = binary_split_5g(total_codebook,n, m, location, valid_loc(1:size_check),size_check, beam_loc, 0, gain_gaussian, angle_ue, threshold);
            %Change hold_2 to power of 2 -- because of binary split
            
            % 2nd one is already gone, what is left in the array
            hold_2 =  length(valid_loc(size_check +1:end));
            a_hold = floor(log2(hold_2));
            hold_2 = 2^a_hold;
                    
            if hold_2 > size_check
                hold_2 = size_check;
            end
                    
            
            if hold_2 ~= 0
                %check_in = sum(location(valid_loc(size_check+1:size_check+hold_2)) == 0)== hold_2;
                pathexists_in = beamform_sectored(total_codebook,n, valid_loc(size_check+1:size_check+hold_2), gain_gaussian, angle_ue, threshold);

                
                n_test_in = 1;
                if pathexists_in==0 %NACK
                    
                    if isempty(valid_loc(size_check+1+hold_2:end))==0 %Not empty so let me check
                        size_more = length(valid_loc(size_check+1+hold_2:end));
                        %check_more = sum(location(valid_loc(size_check+1+hold_2:end)) == 0)== size_more; %NACK
                        pathexists_more = beamform_sectored(total_codebook,n, valid_loc(size_check+1+hold_2:end), gain_gaussian, angle_ue, threshold);
                        
                        
                        n_test_in  = n_test_in +1;
                        if pathexists_more==0 % The rest is also NACK
                            valid_loc = valid_loc_2;% Just use Binary splitting result earlier
                            n = n-hold_2 -size_more; 
                        elseif pathexists_more && size_more ==1 %ACK and size 1
                            beam_loc = [beam_loc,  valid_loc(size_check+1+hold_2:end)];
                            valid_loc = valid_loc_2; %The size was 1 and the hold gave NACK so binary split;
                            n = n-hold_2-1; %1 beam we found
                            m = m-1; 
                        else %ACK but not size 1
                            valid_loc = [valid_loc_2, valid_loc(size_check+1+hold_2:end)];
                            n = n-hold_2;
                        end 
                    else %The rest is empty
                        valid_loc = valid_loc_2;% Just use Binary splitting result earlier
                        n = n-hold_2; %hold_2 part was NACK                       
                    end
                    
                    
                else
                    [beam_loc, test_n_in, n,m, valid_loc_in] = binary_split_5g(total_codebook,n, m, location, valid_loc(size_check+1:size_check+hold_2),hold_2, beam_loc, 0, gain_gaussian, angle_ue, threshold);
                    valid_loc = [valid_loc_2, valid_loc_in, valid_loc(size_check+1+hold_2:end)];
                    n_test_in = n_test_in + test_n_in;
                end
            else
                valid_loc = valid_loc_2;
                n_test_in = 0;
            end
            
            n_steps = max(test_n2, n_test_in);
            [beam_loc, n_steps] = parallel_gt_ack_5g(total_codebook,n,m, valid_loc, beam_loc, location, n_steps, gain_gaussian, angle_ue, threshold);           
        end
    end
end

