function [beam_loc, n_steps] = GT_Prob_Seperate(n, m, location, pmd, pfa)

    %Seperate Hwang does not end when m==n
    [beam_loc_1, n_steps_1, valid_loc1] = Hwang_gt(ceil(n/2), ceil(m/2),1:ceil(n/2),{}, location, 0, pmd, pfa, 1);
    
    [beam_loc_2, n_steps_2, valid_loc2] = Hwang_gt(floor(n/2), floor(m/2),ceil(n/2) + 1:n,{}, location, 0, pmd, pfa,1);

    beam_loc_3 = {};
    n_steps_3 = 0; 

    %temp = cell2mat(beam_loc_2) + ceil(n/2); /no need
    tot_beam = size(cell2mat(beam_loc_1),2) + size(cell2mat(beam_loc_2),2);
    if tot_beam ~= m
        rest = m - tot_beam;
        if ceil(m/2) == size(cell2mat(beam_loc_1),2)
            [beam_loc_3, n_steps_3, ~] = Hwang_gt(size(valid_loc1,2), rest,valid_loc1,{}, location, 0, pmd, pfa,1);
        elseif floor(m/2) == size(cell2mat(beam_loc_2),2)
            [beam_loc_3, n_steps_3, ~] = Hwang_gt(size(valid_loc2,2), rest,valid_loc2,{}, location, 0, pmd, pfa,1);
        end
    end
    beam_loc = [beam_loc_1, beam_loc_2, beam_loc_3];


    n_steps = max(n_steps_1, n_steps_2) + n_steps_3;
end