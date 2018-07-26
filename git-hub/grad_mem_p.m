%% CONDUCTANCE POTENTIATION
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dG = grad_mem_p(G,param,dt,bool_tab,ind)

G_max=param.G_max{ind};
G_min=param.G_min{ind};
Cp=param.C.p{ind};
betap=param.betap;
dG=(G_max(bool_tab)-G_min(bool_tab))./betap.*...
    log(1+(betap./(G_max(bool_tab)-G_min(bool_tab))).*Cp(bool_tab).*dt(bool_tab).*...
    exp(-betap.*(G(bool_tab)-G_min(bool_tab))./(G_max(bool_tab)-G_min(bool_tab))));
end


