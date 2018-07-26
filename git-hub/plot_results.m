%% PLOTTING THE STATISTICS COLLECTED THROUGHOUT LEARNING
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fig,varargout]=plot_results(var_tab,error_tab,var_lab)

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
            
            figure
            errorbar(var_tab,100*med_train,100*(med_train-neg_train),...
                100*(pos_train-med_train),'LineWidth',1);
            hold on
            errorbar(var_tab,100*med_test,100*(med_test-neg_test),...
                100*(pos_test-med_test),'LineWidth',1);
            set(gca,'XScale','log');
            legend({'Error rate on the training set','Error rate on the test set'},'interpreter','latex');
            xlabel(var_lab,'interpreter','latex');
            ylabel('Error rate (\%)','interpreter','latex');
            ax = gca;
            ax.FontSize = 15;
            axis tight
            grid on
            fig=gcf;
            
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
                neg_cst_test(ind)=neg_temp(I);
                med_cst_test(ind)=med_temp(I);
                pos_cst_test(ind)=pos_temp(I);
            end
            
            figure
            errorbar(var_tab,100*med_cst_test,100*(med_cst_test-neg_cst_test),...
                100*(pos_cst_test-med_cst_test),'LineWidth',3);
            xlabel(var_lab,'interpreter','latex');
            ylabel('Error rate (\%)','interpreter','latex');
            ax = gca;
            ax.FontSize = 15;
            axis tight
            grid on
            fig=gcf;
            
    end
end