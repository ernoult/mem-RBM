function subset = extract_subset(data_set, start_i, n_cases)
    if (isfield(data_set,'inputs'))
        subset.inputs = data_set.inputs(:, start_i : start_i + n_cases - 1);
        subset.targets = data_set.targets(:, start_i : start_i + n_cases - 1);
    else
        subset = data_set(:, start_i : start_i + n_cases - 1);
    end  
end
