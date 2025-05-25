using LinearAlgebra
using Plots

Ll = 0.124;
Lb = 0.04;
Ls = 0.064;
Rs = 0.04;
L0 = 0.14;

function get_x(θs)
    try
        d1 = sqrt(Lb^2+Rs^2+2*Lb*Rs*cos(θs))
        θd1 = atan(Rs*sin(θs), Lb+Rs*cos(θs))
        θ1 = acos((Ll^2+d1^2-Ls^2)/(2*Ll*d1)) + θd1
        θ2 = asin((Ll*sin(θ1)-d1*sin(θd1))/Ls)
        θ3 = θd1 - acos((Ll^2+d1^2-Ls^2)/(2*Ll*d1))
        θ4 = asin((Ll*sin(θ3)-d1*sin(θd1))/Ls)
        d2 = Ls*sqrt(2)*sqrt(1-cos(θ4-θ2))
        θd2 = atan(sin(θ4)-sin(θ2),cos(θ4)-cos(θ2))
        θ5 = acos(d2/2/Ls) + θd2
        θ6 = asin(9Ls*sin(θ5)-d2*sin(θd2))/Ls
        xp = Rs*sin(θs)+Ls*sin(θ2)+Ls*sin(θ5)
        yp = Rs*cos(θs)+Ls*cos(θ2)+Ls*cos(θ5)
        return (xp, yp, θ1, θ2, θ3, θ4, θ5, θ6)
    catch
        return (Inf,Inf,NaN,NaN,NaN,NaN,NaN,NaN)
    end
end

function get_tau(θs, Fp)
    xp, yp, θ1, θ2, θ3, θ4, θ5, θ6 = get_x(θs)
    Fdp = Fp/(sin(θ5)-cos(θ5)*tan(θ6))
    Fcp = Fp/(sin(θ6)-cos(θ6)*tan(θ5))
    Fbd = Fdp*(sin(θ5)-cos(θ5)*tan(θ1))/(sin(θ2)-cos(θ2)*tan(θ1))
    Fad = Fdp*(sin(θ5)-cos(θ5)*tan(θ2))/(sin(θ1)-cos(θ1)*tan(θ2))
    Fbc = Fcp*(sin(θ6)-cos(θ6)*tan(θ3))/(sin(θ4)-cos(θ4)*tan(θ3))
    Fac = Fcp*(sin(θ6)-cos(θ6)*tan(θ4))/(sin(θ3)-cos(θ3)*tan(θ4))
    τs = Fbc*sin(θ4-θs) + Fbd*sin(θ2-θs)
    return [xp,τs]
end

function get_x_linear(θs)
    xp = L0*sin(θs)/(1+cos(θs))
    return xp
end

function get_tau_linear(θs, Fp)
    return [get_x_linear(θs), L0*Fp/(1+cos(θs))]
end

θss = 0:0.01:2*pi;
temp = get_x.(θss);
sol = stack(temp)';

sol_simp = get_x_linear.(θss);

plot(θss, sol_simp, linewidth=2, linstyle="--")
plot!(θss, sol[:,1], framestyle = :box, xguidefontsize=12, yguidefontsize=12,legendfontsize=12, ytickfontsize = 12, xtickfontsize = 12,
                linewidth=2, label="trajectory")
xlims!(-0.1,6.5);
ylims!(-0.15, 0.15);
xlabel!("θₛ");
ylabel!("xₚ");
savefig("simplifiedPosCalComparsion.png")


# anim = @animate for i ∈ eachindex(θss)
#     plot(sol[:,2],sol[:,1], aspect_ratio = 1, framestyle = :box, xguidefontsize=12, yguidefontsize=12,legendfontsize=12, ytickfontsize = 12, xtickfontsize = 12,
#                linewidth=2, label="trajectory")
#     scatter!([sol[i,2]],[sol[i,1]], color="red", label="paddle")
#     title!("θs=$(round(rad2deg(θss[i]),sigdigits=3)) deg, (x,y)=($(round((sol[i,1]),sigdigits=3)), $(round((sol[i,2]),sigdigits=3)))")
#     xlabel!("y")
#     ylabel!("x")
# end
# gif(anim, "linkageTraj.gif", fps = 24)
# plot(θss, sol[:,1])

plot(sol[:,2],sol[:,1], aspect_ratio = 1, framestyle = :box, xguidefontsize=12, yguidefontsize=12,legendfontsize=12, ytickfontsize = 12, xtickfontsize = 12,
               linewidth=2, label="trajectory")


θc = acos((Ll-Ls)^2/2/Lb^2-1);
crit1 = get_x(θc-1e-12);
crit2 = get_x(-θc+1e-12);
scatter!([crit1[2], crit2[2]],[crit1[1], crit2[1]], color="red", label="paddle")
savefig("criticalPoints.png")

θ_test = 50/180*pi;
Fps = 0:0.001:5;
temp = get_tau.(θ_test, Fps);
T_sol = stack(temp)';

temp = get_tau_linear.(θ_test, Fps);
T_sol_simp = stack(temp)';

plot(Fps, T_sol[:,2], framestyle = :box, xguidefontsize=12, yguidefontsize=12,legendfontsize=12, ytickfontsize = 12, xtickfontsize = 12,
               linewidth=2, label="Static Linkage Ana.", color = "red")
plot!(Fps, T_sol_simp[:,2], linewidth=2, linstyle="--", color = "blue", label="Conservation of Power")
xlabel!("Fp")
ylabel!("τs")
title!("θs = $(round(θ_test,sigdigits=3)), xp = $(round(T_sol[1,1],sigdigits=3))")
savefig("forceComparsion.png")
plot!()



xp, yp, θ1, θ2, θ3, θ4, θ5, θ6 = get_x(θ_test);
tempX = [0,Rs*cos(θ_test),Rs*cos(θ_test)+Ls*cos(θ2),Rs*cos(θ_test)+Ls*cos(θ4),Rs*cos(θ_test)+Ls*cos(θ2)+Ls*cos(θ5),-Lb];
tempY = [0,Rs*sin(θ_test),Rs*sin(θ_test)+Ls*sin(θ2),Rs*sin(θ_test)+Ls*sin(θ4),Rs*sin(θ_test)+Ls*sin(θ2)+Ls*sin(θ5),0];
idx = [1,2,3,5,4,6,3,2,4];
plot(tempX[idx], tempY[idx], aspect_ratio=1, linewidth=2, framestyle = :box, xguidefontsize=12, yguidefontsize=12,legendfontsize=12, ytickfontsize = 12, xtickfontsize = 12, label="links", legend=:topleft);
scatter!(tempX,tempY, markerstyle=".", markersizetitle!("θs = $(round(θ_test,sigdigits=3)), xp = $(round(T_sol[1,1],sigdigits=3))")=9, label="joints")
title!("θs = $(round(θ_test,sigdigits=3)), xp = $(round(T_sol[1,1],sigdigits=3))")
xlabel!("yp")
ylabel!("xp")
savefig("verifyLocations.png")
