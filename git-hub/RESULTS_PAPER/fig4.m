
%{
colors(1,:)=[0.1,0.7,0.7];
colors(2,:)=[0.1,0.4,0.8];
colors(3,:)=[0.1,0.1,0.6];
%}


colors(1,:)=[1,0,0];
%colors(2,:)=0.2*[0.1,0.7,0.7]+0.8*[1,0,0];
colors(2,:)=[0.9,0.4,0.1];
colors(3,:)=0.7*[0.1,0.7,0.7]+0.3*[1,0,0];



r_tab=[5,10,20,50,100,250,5*10^(2),10^(3),5*10^(3),10^(4),5*10^(4),10^(5)];
beta_tab=[0.005,1,2,3,5];

figure('Position', [10, 400, 1300, 350])
%colors=get(gca,'colororder');
subplot(1,2,1)
load fig4_data_1mb_betalow
error_tab.test=fliplr(error_tab.test);
plot_results(fliplr(1./r_tab),error_tab,'Relative pulse width ($\Delta t/\Delta t_{max}$)',colors(1,:),':'); 
clear error_tab
hold on
load fig4_data_100mb_betalow
error_tab.test=fliplr(error_tab.test);
plot_results(fliplr(1./r_tab),error_tab,'Relative pulse width ($\Delta t/\Delta t_{max}$)',colors(2,:),':'); 
clear error_tab
load fig4_data_100mb_20CD_betalow
error_tab{1}.test=fliplr(error_tab{1}.test);
plot_results(fliplr(1./r_tab),error_tab{1},'Relative pulse width ($\Delta t/\Delta t_{max}$)',colors(3,:),':'); 
clear error_tab
legend({'mini-batch size $=1$, 1 CD',...
    'mini-batch size $=100$, 1 CD',...
    'mini-batch size $=100$, 20 CD'},'interpreter','latex','Location','northwest');
set(gca,'YScale','log');
title('(a) Near-linear memristors ($\beta=0.005$)','interpreter','latex');
ylim([5,100]);


subplot(1,2,2)
load fig4_data_1mb_betahigh
error_tab.test=fliplr(error_tab.test);
plot_results(fliplr(1./r_tab),error_tab,'Relative pulse width ($\Delta t/\Delta t_{max}$)',colors(1,:),':'); 
clear error_tab
hold on
load fig4_data_100mb_betahigh
error_tab{1}.test=fliplr(error_tab{1}.test);
plot_results(fliplr(1./r_tab),error_tab{1},'Relative pulse width ($\Delta t/\Delta t_{max}$)',colors(2,:),':'); 
clear error_tab
load fig4_data_100mb_20CD_betahigh
error_tab{1}.test=fliplr(error_tab{1}.test);
plot_results(fliplr(1./r_tab),error_tab{1},'Relative pulse width ($\Delta t/\Delta t_{max}$)',colors(3,:),':'); 
clear error_tab
legend({'mini-batch size $=1$, 1 CD',...
    'mini-batch size $=100$, 1 CD',...
    'mini-batch size $=100$, 20 CD'},'interpreter','latex','Location','northwest');
set(gca,'YScale','log');
title('(b) Non-linear memristors ($\beta=3$)','interpreter','latex');
ylim([5,100]);

figure('Position', [10, 400, 1300, 350])
subplot(1,2,1)
load fig4_data_betacurve_1mb
plot_results(beta_tab,error_tab,'Non-linearity parameter ($\beta$)',colors(1,:),':'); 
hold on
clear error_tab
load fig4_data_betacurve_1CD
plot_results(beta_tab,error_tab,'Non-linearity parameter ($\beta$)',colors(2,:),':'); 
clear error_tab
load fig4_data_betacurve_20CD
plot_results(beta_tab,error_tab,'Non-linearity parameter ($\beta$)',colors(3,:),':'); 
clear error_tab
legend({'mini-batch size $=1$, 1 CD',...
    'mini-batch size $=100$, 1 CD',...
    'mini-batch size $=100$, 20 CD'},'interpreter','latex','Location','northwest');
set(gca,'YScale','log');
title('(c)','interpreter','latex');
