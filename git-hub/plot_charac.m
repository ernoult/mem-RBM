function plot_charac(param,color,varargin)

G_max=mean(mean(param.G_max{end}));
G_min=mean(mean(param.G_min{end}));
C_p=param.C.p{end};
C_m=param.C.m{end};
betap=param.betap;
betam=param.betam;
dt_max=mean(mean(param.dt_max{end}));
x=linspace(0,dt_max,500);

if (nargin<3)
    Cp_mean=mean(reshape(C_p,[1,size(C_p,1)*size(C_p,2)]));
    Cm_mean=mean(reshape(C_m,[1,size(C_m,1)*size(C_m,2)]));
    sigma_Cp=std(reshape(C_p,[1,size(C_p,1)*size(C_p,2)]));
    sigma_Cm=std(reshape(C_m,[1,size(C_m,1)*size(C_m,2)]));

    f=min(G_min+((G_max-G_min)/betap).*log(1+betap*Cp_mean*x/(G_max-G_min)),G_max);
    Gm(1)=f(end);
    cst=exp((betam/(G_max-G_min))*(G_max-Gm(1)));
    g=max(G_max-((G_max-G_min)/betam).*log(cst+betam*Cm_mean*x/(G_max-G_min)),G_min);
    plot(x,f,'Color',color,'LineWidth',2);
    hold on
    plot(x,g,'Color',color,'LineWidth',2);

    if (sigma_Cp>10^(-5))
        Cp_plus=Cp_mean+sigma_Cp/2;
        Cp_minus=max(Cp_mean-sigma_Cp/2,0);
        Cm_plus=Cm_mean+sigma_Cm/2;
        Cm_minus=max(Cm_mean-sigma_Cm/2,0);
        f_plus=min(G_min+((G_max-G_min)/betap).*log(1+betap*Cp_plus*x/(G_max-G_min)),G_max);
        f_minus=min(G_min+((G_max-G_min)/betap).*log(1+betap*Cp_minus*x/(G_max-G_min)),G_max);
        g_plus=max(G_max-((G_max-G_min)/betam).*log(cst+betam*Cm_plus*x/(G_max-G_min)),G_min);
        g_minus=max(G_max-((G_max-G_min)/betam).*log(cst+betam*Cm_minus*x/(G_max-G_min)),G_min);
        jbfill(x,f_plus,f_minus,color,color,0,0.1);
        jbfill(x,g_plus,g_minus,color,color,0,0.1);
    elseif (param.bool_var_dyn)
        f_noisy=f+normrnd(0,param.var_dyn,size(x));
        g_noisy=g+normrnd(0,param.var_dyn,size(x));
        scatter(x,f_noisy,15,'r.');
        scatter(x,g_noisy,15,'r.');
    end

    if (sigma_Cp>10^(-5))
        string_charac_up=sprintf('C=%.2g \\pm %.2g, \\beta=%.2g',Cp_mean,sigma_Cp/2,betap);
    else
        string_charac_up=sprintf('\\beta=%.2g',betap);
    end
else
    for k=1:size((varargin{1}),1)*size((varargin{1}),2)
        if (varargin{1}(k)==1)
            disp(k)
            Cp_mean=C_p(varargin{1}(k));
            Cm_mean=C_p(varargin{1}(k));
            f=min(G_min+((G_max-G_min)/betap).*log(1+betap*Cp_mean*x/(G_max-G_min)),G_max);
            Gm(1)=f(end);
            cst=exp((betam/(G_max-G_min))*(G_max-Gm(1)));
            g=max(G_max-((G_max-G_min)/betam).*log(cst+betam*Cm_mean*x/(G_max-G_min)),G_min);
            plot(x,f,'Color',[0,0,1],'LineWidth',2);
            hold on
            plot(x,g,'Color',[1,0,0],'LineWidth',2);
        end
    end
end

title(string_charac_up);
xlabel('Pulse duration (a.u.)','interpreter','latex');
grid on
axis tight
ax = gca; 
ax.FontSize = 11;
end