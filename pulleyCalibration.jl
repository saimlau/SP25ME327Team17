using Plots
using LinearAlgebra

x = [0, 0.10436, -0.09126, -0.04591, 0.06579];
th = [0, 19.22027, -17.39814, -8.47916, 11.59562];

a = x\th

xs = -0.1:0.01:0.1;
plot(xs,a.*xs)
scatter!(x,th)