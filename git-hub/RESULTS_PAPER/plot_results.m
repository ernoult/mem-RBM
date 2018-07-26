function plot_results(var_tab,error_tab,var_lab,varargin)

    switch iscell(error_tab)
        
        case 0
            stat_train=quantile(error_tab.train,[0.25,0.5,0.75],1);
            neg_train=stat_train(1,:);
            med_train=stat_train(2,:);
            pos_train=stat_train(3,:);
            
            stat_test=quantile(error_tab.test,[0.25,0.5,0.75],1);
            neg_test=stat_test(1,:);
            med_test=stat_test(2,:);
            pos_test=stat_test(3,:);
            
            switch length(varargin)
                case 0
                    errorbar(var_tab,100*med_test,100*(med_test-neg_test),...
                        100*(pos_test-med_test),'LineWidth',2);
                case 1
                    errorbar(var_tab,100*med_test,100*(med_test-neg_test),...
                        100*(pos_test-med_test),'LineWidth',2,'Color',varargin{1});
                case 2
                    errorbar(var_tab,100*med_test,100*(med_test-neg_test),...
                        100*(pos_test-med_test),varargin{2},'LineWidth',2,'Color',varargin{1});
            end
            set(gca,'XScale','log');
            xlabel(var_lab,'interpreter','latex');
            ylabel('Error rate (\%)','interpreter','latex');
            ax = gca;
            ax.FontSize = 13;
            axis tight
            grid on
            
        case 1
            for ind=1:length(error_tab)
                stat_temp=quantile(error_tab{ind}.test,[0.25,0.5,0.75],1);
                neg_temp=stat_temp(1,:);
                med_temp=stat_temp(2,:);
                pos_temp=stat_temp(3,:);
                [~,I]=min(med_temp);
                if (ind==1 && nargout>1)
                    varargout{1}=I;
                end
                neg_test(ind)=neg_temp(I);
                med_test(ind)=med_temp(I);
                pos_test(ind)=pos_temp(I);
            end
                
            switch length(varargin)
                case 0
                    errorbar(var_tab,100*med_test,100*(med_test-neg_test),...
                        100*(pos_test-med_test),'LineWidth',2);
                case 1
                    errorbar(var_tab,100*med_test,100*(med_test-neg_test),...
                        100*(pos_test-med_test),'LineWidth',2,'Color',varargin{1});
                case 2
                    errorbar(var_tab,100*med_test,100*(med_test-neg_test),...
                        100*(pos_test-med_test),varargin{2},'LineWidth',2,'Color',varargin{1});
            end
            
            xlabel(var_lab,'interpreter','latex');
            ylabel('Error rate (\%)','interpreter','latex');
            ax = gca;
            ax.FontSize = 13;
            axis tight
            grid on
            
    end
end