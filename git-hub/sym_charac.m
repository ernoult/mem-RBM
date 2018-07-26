function [Cp,Cm]=sym_charac(Gmax,Gmin,betap,betam,T_max)

dG=Gmax-Gmin;
Cp=(dG/T_max)*(exp(betap)-1)/betap;
Cm=(dG/T_max)*(exp(betam)-1)/betam;
end


