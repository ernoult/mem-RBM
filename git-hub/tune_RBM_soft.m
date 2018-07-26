%% TUNE STANDARD RBM topped by a softmax 
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
%% 0- DEFINITION OF THE PERMANENT VARIABLES 
%LOAD DATA
m=40000;
%m=4000;
m_test=10000;
%m_test=1000;
[data_set, n_vis]=load_data(m,m_test);
%NETWORK TOPOLOGY AND CONDUCTANCE WINDOW
n_layer=[n_vis,300,10];
dt_max=150;
dt_min=dt_max/10000;
G_max=1;
G_ratio=13;

%SIMULATION PARAMETERS
N_trials=5;
%N_trials=1;
%%%%%WATCH OUT%%%%%%%
n_epochs=30;
%n_epochs=1;
mini_batch_size=100;
nb_CD=1;
nb_bits=64;
scheme='std';
%%%%%%%%%%%%%%%%%%%%%

% CREATE DIRECTORY TO SAVE RESULTS
file_name=cat(2,sprintf('tune_DRBM_%depoch_%dmb_%dCD_%dbits_',n_epochs,mini_batch_size,nb_CD,nb_bits),scheme);
mkdir(file_name)
current_dir=pwd;
%% 1- TUNE dT/dT_max FOR EACH BETA, BUILD THE BETA CURVE
lr_tab_temp=[10^(-4),5*10^(-4),10^(-3),5*10^(-3),10^(-2),5*10^(-2),10^(-1),5*10^(-1)];
%lr_tab_temp=[10^(-4),5*10^(-4)];
lr_tab=repmat(lr_tab_temp,[N_trials,1]);
lr_tab=reshape(lr_tab,[1,N_trials*length(lr_tab_temp)]);
fprintf(cat(2,'\n Starting tuning curve of ',file_name))
parfor ind_lr=1:length(lr_tab)
    lr=[lr_tab(ind_lr),lr_tab(ind_lr)];
    [model,momentum,param]=init('model',n_epochs,n_layer,lr);
    for N=1:n_epochs
        model.current=N;
        [model,momentum,param,error_mem]=...
        train(model,@(model,data,counter)gradient_RBM_soft(model,data,'bin',counter),...
        momentum,data_set,mini_batch_size,param)
    end
    error_tab_train(ind_lr)=error_mem.train;
    error_tab_test(ind_lr)=error_mem.test;
end
clear error_mem
error_tab_train=reshape(error_tab_train,[N_trials,length(lr_tab_temp)]);
error_tab_test=reshape(error_tab_test,[N_trials,length(lr_tab_temp)]);
error_tab.train=error_tab_train;
error_tab.test=error_tab_test;

%SAVE RESULTS
save(fullfile(current_dir,file_name,cat(2,'error_dt_',file_name,'.mat')),'error_tab');
fig_temp=plot_results(lr_tab_temp,error_tab,'Learning rate');
saveas(fig_temp,fullfile(current_dir,file_name,cat(2,'fig_dt_',file_name)));

