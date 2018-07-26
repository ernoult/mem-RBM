%% TRAINING A MEMRISTIVE DISCRIMINATIVE RBM (OPTIMIZING P(IMAGE,LABEL))
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
m=40000;
m_test=10000;
mini_batch_size=100;
[data_set, n_vis]=load_data(m,m_test);
n_iterations=m/mini_batch_size;

n_layer=[n_vis,300,10];
lr=[0.05,0.05];
n_epochs=1;

%Uncomment the useful section

% STANDARD ANN (tracking statistics) 
%{
[model,momentum,param]=init('model',{'gen','flip'},n_epochs,n_layer,lr);
stat=init('stat',model,n_epochs*n_iterations,param);
error_tot=init('result','training',n_epochs);
param.bool_stat=1;

for N=1:n_epochs
    model.current=N; 
    fprintf('\n Epoch %d \n',N);
    [model,momentum,param,stat_mini_batch,error]=...
        train(model,@(model,data,counter)gradient_DRBM2(model,data,counter,'bin',1,'det'),...
        momentum,data_set,mini_batch_size,param);
    stat=update_statistics(stat,stat_mini_batch,(N-1)*n_iterations+1:N*n_iterations,param);
    error_tot.train(N)=error.train;
    error_tot.test(N)=error.test;   
end  
plot_statistics(n_epochs,stat,param);
%}

% STANDARD ANN (not tracking statistics) 
%{
[model,momentum,param]=init('model',{'gen','flip'},n_epochs,n_layer,lr);
error_tot=init('result','training',n_epochs);

for N=1:n_epochs
    model.current=N; 
    fprintf('\n Epoch %d \n',N);
    [model,momentum,param,error]=...
        train(model,@(model,data,counter)gradient_DRBM2(model,data,counter,'bin',1,'det'),...
        momentum,data_set,mini_batch_size,param);
    error_tot.train(N)=error.train;
    error_tot.test(N)=error.test;   
end  
%}

% MEM-ANN (tracking statistics)
%{
dt_max=150;
dt_min=dt_max/10000;
G_max=1;
G_ratio=13;
beta=0.005;

[model_mem,momentum_mem,param]=init('model',{'gen','flip'},n_epochs,n_layer,lr,...
    G_max,G_ratio,beta,dt_max,dt_min,...
    [1,2],[dt_max/1000,dt_max/1000],{'Cst','Cst'});
stat_mem=init('stat',model_mem,n_epochs*n_iterations,param);
error_rate_tot_mem=init('result','training',n_epochs);
param.bool_stat=1;

for N=1:n_epochs
    model_mem.current=N;
    fprintf('\n Epoch %d \n',N);   
    fprintf('\n Training the visible and first hidden layers of the memristor RBM...\n')
    [model_mem,momentum_mem,param,stat_mini_batch_mem,error_mem]=...
        train(model_mem,@(model,data,counter)gradient_DRBM2(model,data,counter,'bin',1,'det'),...
        momentum_mem,data_set,mini_batch_size,param);  
    stat_mem=update_statistics(stat_mem,stat_mini_batch_mem,(N-1)*n_iterations+1:N*n_iterations,param);
    error_tot_mem.train(N)=error_mem.train;
    error_tot_mem.test(N)=error_mem.test;   
end
plot_statistics(n_epochs,stat_mem,param);
%}

% MEM-ANN (not tracking statistics)
%{
dt_max=150;
dt_min=dt_max/10000;
G_max=1;
G_ratio=13;
beta=0.005;

[model_mem,momentum_mem,param]=init('model',{'gen','flip'},n_epochs,n_layer,lr,...
    G_max,G_ratio,beta,dt_max,dt_min,...
    [1,2],[dt_max/1000,dt_max/1000],{'Cst','Cst'});

stat_mem=init('stat',model_mem,n_epochs*n_iterations,param);
error_rate_tot_mem=init('result','training',n_epochs);

for N=1:n_epochs
    model_mem.current=N;
    fprintf('\n Epoch %d \n',N);   
    fprintf('\n Training the visible and first hidden layers of the memristor RBM...\n')
    [model_mem,momentum_mem,param,error_mem]=...
        train(model_mem,@(model,data,counter)gradient_DRBM2(model,data,counter,'bin',1,'det'),...
        momentum_mem,data_set,mini_batch_size,param);  
    error_tot_mem.train(N)=error_mem.train;
    error_tot_mem.test(N)=error_mem.test;   
end
%}

%UNCOMMENT TO DISPLAY HIDDEN FEATURES
%{
figure(1)
dispims(transpose(model.n{1}(1:81,1:81)),28,28,1);
ax=gca;
ax.FontSize=13;
title('mem-RBM ($\beta=3$)','interpreter','latex');
%}