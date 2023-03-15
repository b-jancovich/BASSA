% tell me if a number is an integer or a fractional
function res = is_fractional_CPP(x) %#codegen
    res = fix(x) ~= x;
return;