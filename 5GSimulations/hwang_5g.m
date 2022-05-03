 % Original method from the paper
% With channel model

function [beam_loc, n_steps, valid_loc] = hwang_5g(total_codebook,n,m, valid_loc, beam_loc, location, n_steps, sp, gain_gaussian, angle_ue, threshold, beam_type)

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

    if sp ~=1
        if n==m
            beam_loc = [beam_loc, valid_loc];
            return;
        end
    end
    
    
    if n <= 2*m-2
        %Exhaustive Search
        size_n = n;
        for ex = 1:size_n
            
%             if n == m
%                 beam_loc = [beam_loc, valid_loc];
%                 valid_loc = [];
%                 return;
%             end
            
            if m ==0
                valid_loc = valid_loc(ex+1:end);
                return;
            end 
           
            %check_ex = location(valid_loc(ex)) == 0; %=0 ACK
            
            if beam_type == 1
                pathexists_1 = beamform_sectored(total_codebook, n, valid_loc(ex), gain_gaussian, angle_ue, threshold);
            elseif beam_type == 2
                pathexists_1 = beamform_hierarchical(total_codebook, n, valid_loc(ex), gain_gaussian, angle_ue, threshold);
            end
            
            n_steps = n_steps +1;
            n= n-1;

            
            if pathexists_1 %ACK
                beam_loc = [beam_loc, valid_loc(ex)];
                m = m-1;
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
        %check1 = sum(location(valid_loc(1: size_check)) == 0)== size_check; 
        
        %=1 when ACK
        
        if beam_type ==1
            pathexists1 = beamform_sectored(total_codebook, n, valid_loc(1: size_check), gain_gaussian, angle_ue, threshold);
        elseif beam_type==2
            pathexists1 = beamform_hierarchical(total_codebook, n, valid_loc(1: size_check), gain_gaussian, angle_ue, threshold);
        end
        n_steps = n_steps + 1;
        
        
        
        if pathexists1 ==0 
            valid_loc = valid_loc(size_check+1: end);
            n = n-size_check;
            
            [beam_loc, n_steps, valid_loc] = hwang_5g(total_codebook, n,m, valid_loc, beam_loc, location, n_steps, sp, gain_gaussian, angle_ue, threshold, beam_type); 
     
                
        else
            %Parallel Binary Splitting
            
            [beam_loc, test_n1, n,m, valid_loc_1] = binary_split_5g(total_codebook, n, m, location, valid_loc(1:size_check) ,size_check, beam_loc, 0, gain_gaussian, angle_ue, threshold, beam_type);
%             if test_n1 > alpha +1
%                 ozzy = 1;
%             end
            valid_loc = [valid_loc_1, valid_loc(size_check+1:end)];
            %Note that I count one more in binary split. I check the same
            %size again
            n_steps = n_steps +test_n1-1;
      
            [beam_loc, n_steps, valid_loc] = hwang_5g(total_codebook,n,m, valid_loc, beam_loc, location, n_steps, sp, gain_gaussian, angle_ue, threshold, beam_type); 
       
        end
    end
end

