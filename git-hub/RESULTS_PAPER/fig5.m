r_tab=[5,10,20,50,100,250,5*10^(2),10^(3),5*10^(3),10^(4),5*10^(4),10^(5)];
figure('Position', [10, 400, 1300, 350])

colors(1,:)=[0.9,0.4,0.1];%Cst 1 CD
%colors(2,:)=[1,0.4,0.3];%RProp 1 CD

subplot(1,2,1)
load fig5_Cst_betalow
error_tab.test=fliplr(error_tab.test);
plot_results(fliplr(1./r_tab),error_tab,'Relative pulse width ($\Delta t/\Delta t_{max}$)',colors(1,:),':'); 
hold on
clear error_tab
load fig5_RProp_betalow
error_tab{1}.test=fliplr(error_tab{1}.test);
plot_results(fliplr(1./r_tab),error_tab{1},'Relative pulse width ($\Delta t/\Delta t_{max}$)',colors(1,:)); 
title('(a) Near-linear memristors ($\beta=0.005$)','interpreter','latex');
legend({'Cst (1 CD)','RProp (1 CD)'},'interpreter','latex','Location','northwest');
ylim([0,90]);
xlim_1=xlim;
line([xlim_1(1) xlim_1(2)],[10 10],'LineWidth',1.5,'LineStyle','--','Color',[0.5 0.5 0.5]);

subplot(1,2,2)
load fig5_Cst_betahigh
error_tab{1}.test=fliplr(error_tab{1}.test);
plot_results(fliplr(1./r_tab),error_tab{1},'Relative pulse width ($\Delta t/\Delta t_{max}$)',colors(1,:),':'); 
hold on
clear error_tab
load fig5_RProp_betahigh
error_tab{1}.test=fliplr(error_tab{1}.test);
plot_results(fliplr(1./r_tab),error_tab{1},'Relative pulse width ($\Delta t/\Delta t_{max}$)',colors(1,:)); 
clear error_tab
title('(b) Non-linear memristors ($\beta=3$)','interpreter','latex');
xlim_1=xlim;
line([xlim_1(1) xlim_1(2)],[20 20],'LineWidth',1.5,'LineStyle','--','Color',[0.5 0.5 0.5]);
ylim([0,90]);