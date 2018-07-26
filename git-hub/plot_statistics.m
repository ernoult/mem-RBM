function plot_statistics(n_epochs,varargin)

N=length(varargin);
figure('Position', [10, 300, 1600, 350])
for k=1:N/2
    stat=varargin{2*k-1};
    param=varargin{2*k};
    L=length(stat.w.n.mean);
    
    for ind=0:L-1
        subplot(L,8,ind*8+2)
        w_temp=stat.w.n.ini{L-ind};
        if (mean(mean(w_temp))~=0)
            mean_temp=mean(reshape(w_temp,[1,size(w_temp,1)*size(w_temp,2)]));
            sd_temp=std(reshape(w_temp,[1,size(w_temp,1)*size(w_temp,2)]));
            histogram(w_temp,'Normalization','probability','BinWidth',sd_temp/3);
            legend(sprintf('\\mu = %.2g, \\sigma=%.2g\n',mean_temp,sd_temp));
            xlim([mean_temp-4*sd_temp,mean_temp+4*sd_temp]);
            title(sprintf('Initial W_{%d}',L-ind));
            xlabel(sprintf('%d bits',param.n_bits{L-ind}));
            grid on
            ax = gca;
            ax.FontSize = 11;
            axis tight
            hold on
        end
        
        subplot(L,8,ind*8+4)
        colors = get(gca,'ColorOrder');
        mean_temp=stat.w.n.mean{L-ind};
        sd_temp=stat.w.n.sd{L-ind};
        x=linspace(0,n_epochs,length(mean_temp));
        jbfill(x,mean_temp+sd_temp,mean_temp-sd_temp,colors(k,:),colors(k,:),0,0.1);
        hold on
        plot(x,mean_temp,'Color',colors(k,:),'LineWidth',1);
        xlabel('Epochs','interpreter','latex');
        ylabel(sprintf('W_{%d} :\\mu \\pm \\sigma',L-ind));
        grid on
        axis tight
        ax = gca;
        ax.FontSize = 11;
        
        subplot(L,8,ind*8+5)
        w_temp=stat.w.n.final{L-ind};
        if (mean(mean(w_temp))~=0)
            mean_temp=mean(reshape(w_temp,[1,size(w_temp,1)*size(w_temp,2)]));
            sd_temp=std(reshape(w_temp,[1,size(w_temp,1)*size(w_temp,2)]));
            histogram(w_temp,'Normalization','probability','BinWidth',sd_temp/3);
            legend(sprintf('\\mu = %.2g, \\sigma=%.2g\n',mean_temp,sd_temp));
            xlim([mean_temp-4*sd_temp,mean_temp+4*sd_temp]);
            title(sprintf('Final W_{%d}',L-ind));
            grid on
            ax = gca;
            ax.FontSize = 11;
            hold on
        end
        
        subplot(L,8,ind*8+6)
        colors = get(gca,'ColorOrder');
        mean_temp=stat.delta_w.n.mean{L-ind};
        sd_temp=stat.delta_w.n.sd{L-ind};
        x=linspace(0,n_epochs,length(mean_temp));
        jbfill(x,mean_temp+sd_temp,mean_temp-sd_temp,colors(k,:),colors(k,:),0,0.1);
        hold on
        plot(x,mean_temp,'Color',colors(k,:),'LineWidth',1);
        xlabel('Epochs','interpreter','latex');
        ylabel(sprintf('\\Delta W_{%d} :\\mu \\pm \\sigma',L-ind));
        grid on
        axis tight
        ax = gca;
        ax.FontSize = 11;
        
        subplot(L,8,ind*8+7)
        w_temp=stat.delta_w.n.final{L-ind};
        if (mean(mean(w_temp))~=0)
            mean_temp=mean(reshape(w_temp,[1,size(w_temp,1)*size(w_temp,2)]));
            sd_temp=std(reshape(w_temp,[1,size(w_temp,1)*size(w_temp,2)]));
            histogram(w_temp,'Normalization','probability','BinWidth',sd_temp/3);
            legend(sprintf('\\mu = %.2g, \\sigma=%.2g\n',mean_temp,sd_temp));
            xlim([mean_temp-4*sd_temp,mean_temp+4*sd_temp]);
            title(sprintf('Final \\Delta W_{%d}',L-ind));
            grid on
            ax = gca;
            ax.FontSize = 11;
            hold on
        end
        
        subplot(L,8,(ind+1)*8)
        x=linspace(0,n_epochs,length(stat.nb_updates{L-ind}));
        plot(x,stat.nb_updates{L-ind},'LineWidth',1);
        xlabel('Epochs','interpreter','latex');
        ylabel('\# updates','interpreter','latex');
        set(gca,'YScale','log');
        grid on 
        axis tight
        ax = gca;
        ax.FontSize = 11;
        hold on
        
        if (sum(param.to_mem==L-ind))
            subplot(L,8,ind*8+1)
            colors = get(gca,'ColorOrder');
            plot_charac(param,colors(k,:));
            hold on
            
            subplot(L,8,ind*8+3)
            colors = get(gca,'ColorOrder');
            dt_max=mean(mean(param.dt_max{L-ind}));
            mean_temp=stat.dt.p.mean{L-ind}./dt_max;
            sd_temp=stat.dt.p.sd{L-ind}./dt_max;
            
            x=linspace(0,n_epochs,length(mean_temp));
            
            if (mean(mean(sd_temp))>10^(-4))
                jbfill(x,mean_temp+sd_temp,mean_temp-sd_temp,colors(k,:),colors(k,:),0,0.1);
            end
            
            hold on
            plot(x,mean_temp,'Color',colors(k,:),'LineWidth',1);
            xlabel('Epochs','interpreter','latex');
            ylabel(sprintf('\\Delta t_{%d}/dt_{max} :\\mu \\pm \\sigma',L-ind));
            grid on
            axis tight
            ax = gca;
            ax.FontSize = 11;
            
        end
        
    end
    
end
    
end