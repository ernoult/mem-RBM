%% STUDY MEMRISTIVE RBM TOPPED BY A SOFTMAX
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
%% 0- DEFINITION OF THE PERMANENT VARIABLES 
%LOAD DATA
m=40000;
m_test=10000;
[data_set, n_vis]=load_data(m,m_test);

%NETWORK TOPOLOGY AND CONDUCTANCE WINDOW
n_layer=[n_vis,300,10];
lr=[0.05,0.05];
dt_max=150;
dt_min=dt_max/10000;
G_max=1;
G_ratio=13;

%SIMULATION PARAMETERS
N_trials=5;%number of trials

%%%%%WATCH OUT%%%%%%%
n_epochs=30;
mini_batch_size=100;
nb_bits=64;%bit resolutions of the weights
scheme='Cst';%programming scheme used
%%%%%%%%%%%%%%%%%%%%%
beta_tab=[0.005,1,2,3,5];%table of non-linearities to explore

% CREATE DIRECTORY TO SAVE RESULTS
file_name=cat(2,sprintf('RBM_soft_%depoch_%dmb_%dbits_',n_epochs,mini_batch_size,nb_bits),scheme);
mkdir(file_name)
current_dir=pwd;
%% 1- TUNE dT/dT_max FOR EACH BETA, BUILD THE BETA CURVE
r_tab_temp=[5*10^(2),10^(3),5*10^(3),10^(4),5*10^(4),10^(5)];
%grid search over dt_max/dt to find the best pulse width

r_tab=repmat(r_tab_temp,[N_trials,1]);
r_tab=reshape(r_tab,[1,N_trials*length(r_tab_temp)]);
fprintf(cat(2,'\n Starting beta curve of ',file_name));

for ind_beta=1:length(beta_tab)%for each value of beta ...
    fprintf(cat(2,'\n',file_name,sprintf(' : beta =%.2g',beta_tab(ind_beta))));
    parfor ind_dt=1:length(r_tab)%tune the model with the best pulse width
        [model,momentum,param]=init('model',n_epochs,n_layer,lr,...
            G_max,G_ratio,beta_tab(ind_beta),dt_max,dt_min,...
            [1,2],[dt_max/r_tab(ind_dt),dt_max/r_tab(ind_dt)],{scheme,scheme});
        %UNCOMMENT IF YOU WISH TO PLOT STATISTICS
        %{
        n_iterations=m/mini_batch_size;
        stat=init('stat',model,n_epochs*n_iterations,param);
        param.bool_stat=1;
        %}
        for N=1:n_epochs
            model.current=N;
            %UNCOMMENT IF YOU WISH TO PLOT STATISTICS
            %{
            [model,momentum,param,stat_mini_batch,error_mem]=...
                train(model,@(model,data,counter)gradient_RBM_soft(model,data,'bin',counter),...
                momentum,data_set,mini_batch_size,param);
            stat=update_statistics(stat,stat_mini_batch,(N-1)*n_iterations+1:N*n_iterations,param);
            %}
            [model,momentum,param,error_mem]=...
            train(model,@(model,data,counter)gradient_RBM_soft(model,data,'bin',counter),...
            momentum,data_set,mini_batch_size,param);            
        end
        error_tab_train(ind_dt)=error_mem.train;
        error_tab_test(ind_dt)=error_mem.test;
    end
    clear error_mem
    error_tab_train=reshape(error_tab_train,[N_trials,length(r_tab_temp)]);
    error_tab_test=reshape(error_tab_test,[N_trials,length(r_tab_temp)]);
    error_tab{ind_beta}.train=error_tab_train;
    error_tab{ind_beta}.test=error_tab_test;
    clear error_tab_train error_tab_test
end
fprintf(cat(2,'\n Finished beta curve of ',file_name,' !'))

%SAVE RESULTS
save(fullfile(current_dir,file_name,cat(2,'error_beta_',file_name,'.mat')),'error_tab');
for ind_beta=1:length(beta_tab)
    error_tab{ind_beta}.train=fliplr(error_tab{ind_beta}.train);
    error_tab{ind_beta}.test=fliplr(error_tab{ind_beta}.test);
    fig_temp=plot_results(fliplr(1./r_tab_temp),error_tab{ind_beta},'$dt/dt_{max}$');
    saveas(fig_temp,fullfile(current_dir,file_name,cat(2,'fig_dt_',file_name,sprintf('_beta_%.2g',ind_beta))));
    clear fig_temp
end
[fig_temp,~]=plot_results(beta_tab,error_tab,'$\beta$'); 
saveas(fig_temp,fullfile(current_dir,file_name,cat(2,'beta_curve_',file_name)));

clear error_tab
%% 2- CYCLE-TO-CYCLE VARIABILITY AT LOW BETA
var_tab=[0.001,0.003,0.006,0.01,0.02,0.03];
%table of cycle-to-cycle variabilities to explore
fprintf(cat(2,'\n Starting intra-var curve of ',file_name));
for ind_var=1:length(var_tab)%for each cycle-to-cycle variability ...
    fprintf(cat(2,'\n',file_name,sprintf(' : intra-var =%.2g',var_tab(ind_var))));
    parfor ind_dt=1:length(r_tab)%find the best pulse width
        [model,momentum,param]=init('model',n_epochs,n_layer,lr,...
            G_max,G_ratio,beta_tab(1),dt_max,dt_min,...
            'var_dyn',var_tab(ind_var),...
            [1,2],[dt_max/r_tab(ind_dt),dt_max/r_tab(ind_dt)],{scheme,scheme});
        %UNCOMMENT IF YOU WISH TO PLOT STATISTICS
        %{
    n_iterations=m/mini_batch_size;
    stat=init('stat',model,n_epochs*n_iterations,param);
    param.bool_stat=1;
        %}
        for N=1:n_epochs
            model.current=N;
            %UNCOMMENT IF YOU WISH TO PLOT STATISTICS
            %{
        [model,momentum,param,stat_mini_batch,error_mem]=...
            train(model,@(model,data,counter)gradient_RBM_soft(model,data,'bin',counter),...
            momentum,data_set,mini_batch_size,param);
        stat=update_statistics(stat,stat_mini_batch,(N-1)*n_iterations+1:N*n_iterations,param);
            %}
            [model,momentum,param,error_mem]=...
                train(model,@(model,data,counter)gradient_RBM_soft(model,data,'bin',counter),...
                momentum,data_set,mini_batch_size,param);
        end
        error_tab_train(ind_dt)=error_mem.train;
        error_tab_test(ind_dt)=error_mem.test;
    end
    clear error_mem
    error_tab_train=reshape(error_tab_train,[N_trials,length(r_tab_temp)]);
    error_tab_test=reshape(error_tab_test,[N_trials,length(r_tab_temp)]);
    error_tab{ind_var}.train=error_tab_train;
    error_tab{ind_var}.test=error_tab_test;
    clear error_tab_train error_tab_test
end

fprintf(cat(2,'\n Finished intra-curve of ',file_name,' !'))

%SAVE RESULTS
save(fullfile(current_dir,file_name,cat(2,'error_intra_',file_name,'.mat')),'error_tab');
for ind_var=1:length(var_tab)
    error_tab{ind_var}.train=fliplr(error_tab{ind_var}.train);
    error_tab{ind_var}.test=fliplr(error_tab{ind_var}.test);
    fig_temp=plot_results(fliplr(1./r_tab_temp),error_tab{ind_var},'$dt/dt_{max}$');
    saveas(fig_temp,fullfile(current_dir,file_name,cat(2,'fig_dt_',file_name,sprintf('_intra_%.2g',ind_var))));
    clear fig_temp
end
[fig_temp,~]=plot_results(beta_tab,error_tab,'$\sigma_{intra}/(G_{max}-G_{min})$'); 
saveas(fig_temp,fullfile(current_dir,file_name,cat(2,'intra_curve_',file_name)));

clear error_tab
%% 3- DEVICE-TO-DEVICE VARIABILITY AT LOW BETA
var_tab_temp=[0.01,0.1,1,2,4];
%table of device-to-device variabilities to explore
fprintf(cat(2,'\n Starting intra-var curve of ',file_name));
for ind_var=1:length(var_tab)%for each value of device-to-device variability ...
    fprintf(cat(2,'\n',file_name,sprintf(' : intra-var =%.2g',var_tab(ind_var))));
    parfor ind_dt=1:length(r_tab)%find the best pulse width
        [model,momentum,param]=init('model',n_epochs,n_layer,lr,...
            G_max,G_ratio,beta_tab(1),dt_max,dt_min,...
            'var_space',var_tab(ind_var),...
            [1,2],[dt_max/r_tab(ind_dt),dt_max/r_tab(ind_dt)],{scheme,scheme});
        %UNCOMMENT IF YOU WISH TO PLOT STATISTICS
        %{
    n_iterations=m/mini_batch_size;
    stat=init('stat',model,n_epochs*n_iterations,param);
    param.bool_stat=1;
        %}
        for N=1:n_epochs
            model.current=N;
            %UNCOMMENT IF YOU WISH TO PLOT STATISTICS
            %{
        [model,momentum,param,stat_mini_batch,error_mem]=...
            train(model,@(model,data,counter)gradient_RBM_soft(model,data,'bin',counter),...
            momentum,data_set,mini_batch_size,param);
        stat=update_statistics(stat,stat_mini_batch,(N-1)*n_iterations+1:N*n_iterations,param);
            %}
            [model,momentum,param,error_mem]=...
                train(model,@(model,data,counter)gradient_RBM_soft(model,data,'bin',counter),...
                momentum,data_set,mini_batch_size,param);
        end
        error_tab_train(ind_dt)=error_mem.train;
        error_tab_test(ind_dt)=error_mem.test;
    end
    clear error_mem
    error_tab_train=reshape(error_tab_train,[N_trials,length(r_tab_temp)]);
    error_tab_test=reshape(error_tab_test,[N_trials,length(r_tab_temp)]);
    error_tab{ind_var}.train=error_tab_train;
    error_tab{ind_var}.test=error_tab_test;
    clear error_tab_train error_tab_test
end

fprintf(cat(2,'\n Finished inter-curve of ',file_name,' !'))

%SAVE RESULTS
save(fullfile(current_dir,file_name,cat(2,'error_inter_',file_name,'.mat')),'error_tab');
for ind_var=1:length(var_tab)
    error_tab{ind_var}.train=fliplr(error_tab{ind_var}.train);
    error_tab{ind_var}.test=fliplr(error_tab{ind_var}.test);
    fig_temp=plot_results(fliplr(1./r_tab_temp),error_tab{ind_var},'$dt/dt_{max}$');
    saveas(fig_temp,fullfile(current_dir,file_name,cat(2,'fig_dt_',file_name,sprintf('_inter_%.2g',ind_var))));
    clear fig_temp
end
[fig_temp,~]=plot_results(beta_tab,error_tab,'$(\sigma/\mu)_{inter}$'); 
saveas(fig_temp,fullfile(current_dir,file_name,cat(2,'inter_curve_',file_name)));

