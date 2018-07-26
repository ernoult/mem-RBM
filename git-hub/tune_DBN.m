%% TUNE STANDARD DBN (without fine-tuning)
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
%% 0- DEFINITION OF THE PERMANENT VARIABLES 
%LOAD DATA
m=60000;
m_test=10000;
[data_set, n_vis]=load_data(m,m_test);
%NETWORK TOPOLOGY AND CONDUCTANCE WINDOW
n_layer=[n_vis,500,500,2000,10];
dt_max=150;
dt_min=dt_max/10000;
G_max=1;
G_ratio=13;

%SIMULATION PARAMETERS
N_trials=5;
%%%%%WATCH OUT%%%%%%%
n_epochs=30;
mini_batch_size=100;
nb_CD=1;
nb_bits=64;
scheme='std';
%%%%%%%%%%%%%%%%%%%%%
nb_infer=40;

% CREATE DIRECTORY TO SAVE RESULTS
file_name=cat(2,sprintf('tune_DBN_%depoch_%dmb_%dCD_%dbits_',n_epochs,mini_batch_size,nb_CD,nb_bits),scheme);
mkdir(file_name)
current_dir=pwd;
%% 1- TUNE dT/dT_max FOR EACH BETA, BUILD THE BETA CURVE
lr_tab_temp=[10^(-4),5*10^(-4),10^(-3),5*10^(-3),10^(-2),5*10^(-2),10^(-1),5*10^(-1)];
lr_tab=repmat(lr_tab_temp,[N_trials,1]);
lr_tab=reshape(lr_tab,[1,N_trials*length(lr_tab_temp)]);
fprintf(cat(2,'\n Starting tuning curve of ',file_name))
for ind_lr=1:length(lr_tab)
    data.train=data_set.train.inputs;
    data.test=data_set.test.inputs;
    lr=[lr_tab(ind_lr),lr_tab(ind_lr),lr_tab(ind_lr),lr_tab(ind_lr)];
    [model,momentum,param]=init('model',{'gen','flip'},n_epochs,n_layer,lr);
    L=length(model.n);
    for ind=1:L-2
        for N=1:n_epochs
            model.current=N;
            [model,momentum,param]=...
                train(model,@(model,data,counter)gradient_RBM(model,data,counter,ind,'bin'),...
                momentum,data.train,mini_batch_size,param);
        end
        data=feed_next_RBM(model,ind,data,'bin');
    end      
    data_top={data.train,data_set.train.targets,data.test,data_set.test.targets};
    for N=1:n_epochs
        model.current=N;
        [model,momentum,param,error_mem]=...
            train(model,@(model,data,counter)gradient_DRBM2(model,data,counter,'bin',nb_CD,'sto',nb_infer),...
            momentum,data_top,mini_batch_size,param);
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

