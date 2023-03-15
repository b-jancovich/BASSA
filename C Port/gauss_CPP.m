% compute the gaussian coefficient for the desired time point t and
% standard deviation sd
function res = gauss_CPP(t, sd) %#codegen 
    cnorm   = 1 / (sd * sqrt(2 * pi));
    res     = cnorm * exp(-(t^2) / (2 * sd^2));
return;