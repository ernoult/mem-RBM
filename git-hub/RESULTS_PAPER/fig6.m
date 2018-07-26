vardyn_tab=[0.001,0.003,0.006,0.01,0.02,0.03];
varspa_tab=[0.01,0.1,1,2,4];
r_tab_cst_1CD=[5,10,20,50,100,250,5*10^(2),10^(3)];
r_tab_rprop_1CD=[5,10,20,30,50];
r_tab_cst_20CD=[5,10,20,50,100,250,5*10^(2),10^(3),5*10^(3)];
r_tab_rprop_20CD=[5,10,20,50,100,250,5*10^(2),10^(3),5*10^(3)];

colors(1,:)=[0.9,0.4,0.1];%Cst 1 CD 
colors(2,:)=[0.9,0.4,0.1];%RProp 1 CD
colors(3,:)=0.7*[0.1,0.7,0.7]+0.3*[1,0,0];
colors(4,:)=0.7*[0.1,0.7,0.7]+0.3*[1,0,0];%RProp 20 CD 

figure('Position', [10, 400, 1300, 350])
subplot(1,2,1)
load fig_6_data_1CD_Cst
plot_results(vardyn_tab,error_tab,'Cycle-to-cycle variability ($\sigma_{intra}/(G_{max}-G_{min})$)',colors(1,:),':');

for ind=1:length(error_tab)
    stat_temp=quantile(error_tab{ind}.test,[0.25,0.5,0.75],1);
    med_temp=stat_temp(2,:);
    [~,I]=min(med_temp);
    SNR{1}(ind)=2/(r_tab_cst_1CD(I)*vardyn_tab(ind));
end

hold on

load fig_6_data_1CD_RProp
plot_results(vardyn_tab,error_tab,'Cycle-to-cycle variability($\sigma_{intra}/(G_{max}-G_{min})$)',colors(2,:));

for ind=1:length(error_tab)
    stat_temp=quantile(error_tab{ind}.test,[0.25,0.5,0.75],1);
    med_temp=stat_temp(2,:);
    [~,I]=min(med_temp);
    SNR{2}(ind)=2/(r_tab_rprop_1CD(I)*vardyn_tab(ind));
end

clear error_tab
load fig_6_data_20CD_Cst
plot_results(vardyn_tab,error_tab,'Cycle-to-cycle variability ($\sigma_{intra}/(G_{max}-G_{min})$)',colors(3,:),':'); 

for ind=1:length(error_tab)
    stat_temp=quantile(error_tab{ind}.test,[0.25,0.5,0.75],1);
    med_temp=stat_temp(2,:);
    [~,I]=min(med_temp);
    SNR{3}(ind)=2/(r_tab_cst_20CD(I)*vardyn_tab(ind));
end

clear error_tab
load fig_6_data_20CD_RProp
plot_results(vardyn_tab,error_tab,'Cycle-to-cycle variability ($\sigma_{intra}/(G_{max}-G_{min})$)',colors(4,:)); 

for ind=1:length(error_tab)
    stat_temp=quantile(error_tab{ind}.test,[0.25,0.5,0.75],1);
    med_temp=stat_temp(2,:);
    [~,I]=min(med_temp);
    SNR{4}(ind)=2/(r_tab_rprop_20CD(I)*vardyn_tab(ind));
end
clear error_tab
legend({'Cst (1 CD)','RProp (1 CD)',...
    'Cst (20 CD)','RProp (20 CD)'},...
    'interpreter','latex','Location','northwest');
set(gca,'XScale','log');
title('(a) Near-linear memristors ($\beta=0.005$)','interpreter','latex');
ylim_temp_1=ylim;
line([6*10^(-3) 6*10^(-3)],[ylim_temp_1(1) ylim_temp_1(2)],'LineWidth',1.5,'LineStyle','--','Color',[0.5 0.5 0.5]);

subplot(1,2,2)
%IF YOU WANT TO PLOT SNR
plot(vardyn_tab,SNR{1},':','LineWidth',2,'Color',colors(1,:));
hold on
plot(vardyn_tab,SNR{2},'LineWidth',2,'Color',colors(2,:));
plot(vardyn_tab,SNR{3},':','LineWidth',2,'Color',colors(3,:));
plot(vardyn_tab,SNR{4},'LineWidth',2,'Color',colors(4,:));
xlabel('Cycle-to-cycle variability ($\sigma_{intra}/(G_{max}-G_{min})$)','interpreter','latex');
ylabel('$2\Delta t^{*}(0)/\Delta t_{max}\sigma_{intra}$','interpreter','latex');
ax = gca;
ax.FontSize = 13;
axis tight
grid on
hold on
set(gca,'YScale','log');
set(gca,'XScale','log');
title('(b)','interpreter','latex');
ylim_temp_2=ylim;
line([6*10^(-3) 6*10^(-3)],[ylim_temp_2(1) ylim_temp_2(2)],'LineWidth',1.5,'LineStyle','--','Color',[0.5 0.5 0.5]);
%subplot(1,2,1)
%ylim([min(ylim_temp_1(1),ylim_temp_2(1)),max(ylim_temp_1(2),ylim_temp_2(2))]);
%subplot(1,2,2)
%ylim([min(ylim_temp_1(1),ylim_temp_2(1)),max(ylim_temp_1(2),ylim_temp_2(2))]);

%IF YOU WANT TO PLOT INTER

figure
load fig6_data_inter_1CD_Cst
plot_results(varspa_tab,error_tab,'Device-to-device variability ($(\sigma/\mu)_{inter}$)',colors(1,:),':'); 
hold on
clear error_tab
load fig6_data_inter_1CD_RProp
plot_results(varspa_tab,error_tab,'Device-to-device variability ($(\sigma/\mu)_{inter}$)',colors(2,:)); 
clear error_tab
load fig6_data_inter_20CD_Cst
plot_results(varspa_tab,error_tab,'Device-to-device variability ($(\sigma/\mu)_{inter}$)',colors(3,:),':'); 
clear error_tab
load fig6_data_inter_20CD_RProp
plot_results(varspa_tab,error_tab,'Device-to-device variability ($(\sigma/\mu)_{inter}$)',colors(4,:));
title('Near-linear memristors ($\beta=0.005$)','interpreter','latex');
legend({'Cst (1 CD)','RProp (1 CD)','Cst (20 CD)','RProp (20 CD)'},'interpreter','latex','Location','northwest');
ylim_temp_2=ylim;
%}

