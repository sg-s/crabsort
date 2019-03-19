% computes some statistics on the raw data

function [mu, sigma, abs_max] = getDataStatistics(obj, options)


mu = mean(obj.raw_data);
sigma = std(obj.raw_data);
abs_max = max(abs(obj.raw_data));