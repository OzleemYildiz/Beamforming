function [beam_loc, n_steps] = gt_seperate_5g(n, m, location, gain_gaussian, angle_ue, threshold)

    %Seperate Hwang does not end when m==n
    [beam_loc_1, n_steps_1, valid_loc1] = hwang_5g(n, ceil(n/2), ceil(m/2),1:ceil(n/2),{}, location, 0, 1, gain_gaussian, angle_ue, threshold);
    
    [beam_loc_2, n_steps_2, valid_loc2] = hwang_5g(n, floor(n/2), floor(m/2),ceil(n/2) + 1:n,{}, location, 0, 1, gain_gaussian, angle_ue, threshold);

    beam_loc_3 = {};
    n_steps_3 = 0; 

    %temp = cell2mat(beam_loc_2) + ceil(n/2); /no need
    tot_beam = size(cell2mat(beam_loc_1),2) + size(cell2mat(beam_loc_2),2);
    if tot_beam ~= m
        rest = m - tot_beam;
        if ceil(m/2) == size(cell2mat(beam_loc_1),2)
            [beam_loc_3, n_steps_3, ~] = hwang_5g(n,size(valid_loc1,2), rest,valid_loc1,{}, location, 0, 1, gain_gaussian, angle_ue, threshold);
        elseif floor(m/2) == size(cell2mat(beam_loc_2),2)
            [beam_loc_3, n_steps_3, ~] = hwang_5g(n,size(valid_loc2,2), rest,valid_loc2,{}, location, 0, 1, gain_gaussian, angle_ue, threshold);
        end
    end
    beam_loc = [beam_loc_1, beam_loc_2, beam_loc_3];


    n_steps = max(n_steps_1, n_steps_2) + n_steps_3;
end