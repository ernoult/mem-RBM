%% CONDUCTANCE DEPRESSION
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dG = grad_mem_m(G,param,dt,bool_tab,ind)

G_max=param.G_max{ind};
G_min=param.G_min{ind};
Cm=param.C.m{ind};
betam=param.betam;
dG=-(G_max(bool_tab)-G_min(bool_tab))./betam.*...
    log(1+(betam./(G_max(bool_tab)-G_min(bool_tab))).*Cm(bool_tab).*dt(bool_tab).*...
    exp(-betam.*(G_max(bool_tab)-G(bool_tab))./(G_max(bool_tab)-G_min(bool_tab))));
end

