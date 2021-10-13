clc;
clearvars;

n=8:64; % 64 angular sectors 
m= 2:4; % need to find 2 angles
trial = 1000000;

num_tests = zeros(length(n), length(m));
for b = 1:trial
    for v=n
        for l= m
            inds=sort(randi(v,1,l)); % indices of 2 defectives which we need to estimate
            num_stages = 3; % Assume you need to ID the 2 beams in 3 stages
            grsize=zeros(1,num_stages);
            for i=1:num_stages
                grsize(i) = round((v/l)^((num_stages-i)/num_stages)); % group size in each stage
            end
            itemsrem=1:v; % all items are remaining initially
            %% Stage 1 

            num_groups= round(v/grsize(1)); % vum of groups in stage 1
            for j=1:num_groups-1
                % checking if each group contains defective
                if isempty(intersect(1+(j-1)*grsize(1):(j)*grsize(1),inds))
                    itemsrem=setdiff(itemsrem,1+(j-1)*grsize(1):(j)*grsize(1)); % discarding if defectives are not present
                end
            end
            
            % last group in each stage treated separately to tackle roundoff issues
            if isempty(intersect(1+(num_groups-1)*grsize(1):v,inds))
                 itemsrem=setdiff(itemsrem,1+(num_groups-1)*grsize(1):v);
            end      
            
            if ~isempty(1+(num_groups-1)*grsize(1):v)
                num_tests(v-7, l-1) = num_tests(v-7, l-1)+ ceil(num_groups/2);
            else
                num_tests(v-7, l-1) = num_tests(v-7, l-1) + ceil((num_groups-1)/2);
            end
            %% Stage 2 
            items=itemsrem;
            num_groups= round(numel(items)/grsize(2));
            for j=1:num_groups-1
                if isempty(intersect(items(1+(j-1)*grsize(2):(j)*grsize(2)),inds))
                    itemsrem=setdiff(itemsrem,items(1+(j-1)*grsize(2):(j)*grsize(2)));
                end
            end
            
            if isempty(intersect(items(1+(num_groups-1)*grsize(2):end),inds))
                itemsrem=setdiff(itemsrem,items(1+(num_groups-1)*grsize(2):end));                
            end
            
            if ~isempty(1+(num_groups-1)*grsize(2):v)
                num_tests(v-7, l-1) = num_tests(v-7, l-1)+ ceil(num_groups/2);
            else
                num_tests(v-7, l-1) = num_tests(v-7, l-1) + ceil((num_groups-1)/2);
            end

            %% stage 3 
            %individual testing
            Num_individ_tests_stage3= numel(itemsrem);
            num_tests(v-7, l-1) = num_tests(v-7, l-1)+ ceil(Num_individ_tests_stage3/2);
            
        end 
    end
end

num_tests = num_tests./trial;
save('num_tests_J', 'num_tests');