function ret = log_sum_exp_over_rows(matrix)
  maxs_small = max(matrix, [], 1);
  maxs_big = repmat(maxs_small, [size(matrix, 1), 1]);
  ret = log(sum(exp(matrix - maxs_big), 1)) + maxs_small;
end