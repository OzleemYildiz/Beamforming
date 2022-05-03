% HGTBA_1

%Seperate parallel group testing operations in different RF-chains

function [beam_loc, n_steps] = gt_seperate_5g(n, m, location, gain_gaussian, angle_ue, threshold, n_rf)
    
    beam_loc ={};
    n_steps= zeros(1,n_rf);
    valid_loc = {};
    %Seperate Hwang does not end when m==n
    
    n_search = ceil(n/n_rf);
    m_search = ceil(m/n_rf);
    for i=1:n_rf
        n_search_current= min(i*n_search,n)-(i-1)*n_search;
        ind = (1+(i-1)*n_search):min(i*n_search,n);
        [beam_loc_1, n_steps(i), valid_loc1] = hwang_5g(n,n_search_current ,m_search,ind ,{}, location, 0, 1, gain_gaussian, angle_ue, threshold);
        beam_loc = [beam_loc, beam_loc_1];
        valid_loc = [valid_loc,valid_loc1];
        
%         if length(valid_loc1)>0
%            fprintf('Does this happen?\n');
%         end
%             
        if size(cell2mat(beam_loc),2)==m
            break;
        end
    end
%     [beam_loc_1, n_steps_1, valid_loc1] = hwang_5g(n, ceil(n/2), ceil(m/2),1:ceil(n/2),{}, location, 0, 1, gain_gaussian, angle_ue, threshold);
%     
%     [beam_loc_2, n_steps_2, valid_loc2] = hwang_5g(n, floor(n/2), floor(m/2),ceil(n/2) + 1:n,{}, location, 0, 1, gain_gaussian, angle_ue, threshold);
% 
%     beam_loc_3 = {};
%     n_steps_3 = 0; 
% 
%     %temp = cell2mat(beam_loc_2) + ceil(n/2); /no need

%     tot_beam = size(cell2mat(beam_loc_1),2) + size(cell2mat(beam_loc_2),2);
    tot_beam = size(cell2mat(beam_loc),2);
    n_steps_last = 0;
    ind_last =cell2mat(valid_loc);
    beam_loc_3 =[];
     %When all of AoAs could not be found, one last check is necessary
    if tot_beam ~= m && size(cell2mat(valid_loc),2) > 0
        rest_m = m - tot_beam;
        rest_n= size(ind_last,2);
        [beam_loc_3, n_steps_last, ~] = hwang_5g(n,rest_n, rest_m,ind_last,{}, location, 0, 1, gain_gaussian, angle_ue, threshold);

    %         if ceil(m/2) == size(cell2mat(beam_loc_1),2)
    %             [beam_loc_3, n_steps_3, ~] = hwang_5g(n,size(valid_loc1,2), rest,valid_loc1,{}, location, 0, 1, gain_gaussian, angle_ue, threshold);
    %         elseif floor(m/2) == size(cell2mat(beam_loc_2),2)
    %             [beam_loc_3, n_steps_3, ~] = hwang_5g(n,size(valid_loc2,2), rest,valid_loc2,{}, location, 0, 1, gain_gaussian, angle_ue, threshold);
    %         end
     end
    %     beam_loc = [beam_loc_1, beam_loc_2, beam_loc_3];
    beam_loc = [beam_loc, beam_loc_3];

    % 
    % 
    n_steps = max(n_steps)+ n_steps_last;
    end