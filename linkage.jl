using LinearAlgebra
using Plots

Ll = 0.124;
Lb = 0.04;
Ls =0.064;
Rs = 0.04;

function get_x(θs, Ll, Lb, Ls, Rs)
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
        return [xp, yp]
    catch
        return (Inf,Inf)
    end
end

θss = 0:0.01:2*pi;
temp = get_x.(θss, Ll, Lb, Ls, Rs);
sol = stack(temp)';


anim = @animate for i ∈ eachindex(θss)
    plot(sol[:,2],sol[:,1], aspect_ratio = 1, framestyle = :box, xguidefontsize=12, yguidefontsize=12,legendfontsize=12, ytickfontsize = 12, xtickfontsize = 12,
               linewidth=2, label="trajectory")
    scatter!([sol[i,2]],[sol[i,1]], color="red", label="paddle")
    title!("θs=$(round(rad2deg(θss[i]),sigdigits=3)) deg, (x,y)=($(round(rad2deg(sol[i,1]),sigdigits=3)), $(round(rad2deg(sol[i,2]),sigdigits=3)))")
    xlabel!("y")
    ylabel!("x")
end
gif(anim, "linkageTraj.gif", fps = 24)
# plot(θss, sol[:,1])