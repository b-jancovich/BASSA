% map one point from a linear range to another linear range
function y = r2rmap_CPP(x, x1, x2, y1, y2) %#codegen
y = y1 + (y2 - y1) / (x2 - x1) * (x - x1);
return;
