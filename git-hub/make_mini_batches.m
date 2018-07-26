%% CREATING MINI-BATCHES
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mini_batch_cell,m]=make_mini_batches(data_set,mini_batch_size)

    if (iscell(data_set))
        data_set_temp.train.inputs=data_set{1};
        data_set_temp.train.targets=data_set{2};
        data_set_temp.test.inputs=data_set{3};
        data_set_temp.test.targets=data_set{4};
        m.train=length(data_set{1});
        m.test=length(data_set{3});
        
        if (length(data_set)>4)
            data_set_temp.train.real_inputs=data_set{5};
            data_set_temp.test.real_inputs=data_set{6};
        end
        data_set=data_set_temp;
    end
    
    start_of_next_mini_batch = 1;
    if (isfield(data_set,'inputs'))
        m.train=size(data_set.inputs,2);
        n_iterations=m.train/mini_batch_size;
        for k=randperm(n_iterations)
            mini_batch_cell{k}.inputs = ...
                data_set.inputs(:, start_of_next_mini_batch : start_of_next_mini_batch + mini_batch_size - 1);
            mini_batch_cell{k}.targets = ...
                data_set.targets(:, start_of_next_mini_batch : start_of_next_mini_batch + mini_batch_size - 1);
            start_of_next_mini_batch = mod(start_of_next_mini_batch + mini_batch_size, m.train);
            if (mini_batch_size==1)
                start_of_next_mini_batch = start_of_next_mini_batch + mini_batch_size;
            end
        end

    elseif(isfield(data_set,'train'))
        m.train=size(data_set.train.inputs,2);
        m.test=size(data_set.test.inputs,2);
        n_iterations=m.train/mini_batch_size;
        n_iterations_test=m.test/mini_batch_size;
        
        for k=randperm(n_iterations)
            mini_batch_cell{k}.train.inputs = ...
                data_set.train.inputs(:, start_of_next_mini_batch : start_of_next_mini_batch + mini_batch_size - 1);
            mini_batch_cell{k}.train.targets = ...
                data_set.train.targets(:, start_of_next_mini_batch : start_of_next_mini_batch + mini_batch_size - 1);
            start_of_next_mini_batch = mod(start_of_next_mini_batch + mini_batch_size, m.train);
            if (mini_batch_size==1)
                start_of_next_mini_batch = start_of_next_mini_batch + mini_batch_size;
            end
            
        end
        
        start_of_next_mini_batch = 1;
        for k=n_iterations-n_iterations_test+1:n_iterations  
            mini_batch_cell{k}.test.inputs = ...
                data_set.test.inputs(:, start_of_next_mini_batch : start_of_next_mini_batch + mini_batch_size - 1);
            mini_batch_cell{k}.test.targets = ...
                data_set.test.targets(:, start_of_next_mini_batch : start_of_next_mini_batch + mini_batch_size - 1);
            start_of_next_mini_batch = mod(start_of_next_mini_batch + mini_batch_size, m.test);
            if (mini_batch_size==1)
                start_of_next_mini_batch = start_of_next_mini_batch + mini_batch_size;
            end
        end
        
        if (isfield(data_set.train,'real_inputs'))
            
            for k=randperm(n_iterations)
                mini_batch_cell{k}.train.real_inputs = ...
                    data_set.train.real_inputs(:, start_of_next_mini_batch : start_of_next_mini_batch + mini_batch_size - 1);
                mini_batch_cell{k}.train.real_targets = ...
                    data_set.train.targets(:, start_of_next_mini_batch : start_of_next_mini_batch + mini_batch_size - 1);
                start_of_next_mini_batch = mod(start_of_next_mini_batch + mini_batch_size, m.train);
                if (mini_batch_size==1)
                    start_of_next_mini_batch = start_of_next_mini_batch + mini_batch_size;
                end
            end
            
            start_of_next_mini_batch = 1;
            for k=n_iterations-n_iterations_test+1:n_iterations
                mini_batch_cell{k}.test.real_inputs = ...
                    data_set.test.real_inputs(:, start_of_next_mini_batch : start_of_next_mini_batch + mini_batch_size - 1);
                    mini_batch_cell{k}.test.real_targets = ...
                    data_set.test.targets(:, start_of_next_mini_batch : start_of_next_mini_batch + mini_batch_size - 1);
                start_of_next_mini_batch = mod(start_of_next_mini_batch + mini_batch_size, m.test);
                if (mini_batch_size==1)
                    start_of_next_mini_batch = start_of_next_mini_batch + mini_batch_size;
                end
            end
        end

    else
        m.train=size(data_set,2);
        n_iterations=m.train/mini_batch_size;
        for k=randperm(n_iterations)
            mini_batch_cell{k} = ...
                data_set(:, start_of_next_mini_batch : start_of_next_mini_batch + mini_batch_size - 1);
            start_of_next_mini_batch = mod(start_of_next_mini_batch + mini_batch_size, m.train);
            if (mini_batch_size==1)
                start_of_next_mini_batch = start_of_next_mini_batch + mini_batch_size;
            end
        end
    end


end