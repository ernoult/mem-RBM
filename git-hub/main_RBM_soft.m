%% TRAINING A MEMRISTIVE RBM TOPPED BY A SOFTMAX 
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
m=40000;%number of training samples
m_test=10000;%number of test samples
mini_batch_size=100;
[data_set, n_vis]=load_data(m,m_test);
n_iterations=m/mini_batch_size;

n_layer=[n_vis,300,10];%topology
lr=[0.05,0.05];%learning rate for each weight
n_epochs=1;

%Uncomment the useful section

% STANDARD ANN (tracking statistics)
%{
[model,momentum,param]=init('model',n_epochs,n_layer,lr);%initialize weights, momentum and hyperparameters
error_tot=init('result','training',n_epochs);%initialize error rate array
stat=init('stat',model,n_epochs*n_iterations,param);%initialize statistics
param.bool_stat=1;%boolean indicating that we store statistics
for N=1:n_epochs
    model.current=N;%useful to compute only the last error rate to increase computational efficiency
    fprintf('\n Epoch %d \n',N);
    [model,momentum,param,stat_mini_batch,error]=...
        train(model,@(model,data,counter)gradient_RBM_soft(model,data,'bin',counter),...
        momentum,data_set,mini_batch_size,param);%train performs training on one epoch, looping over mini-batches
    stat=update_statistics(stat,stat_mini_batch,(N-1)*n_iterations+1:N*n_iterations,param);%update statistics accross mini-batches
    error_tot.train(N)=error.train;%stores current error
    error_tot.test(N)=error.test;
end
plot_statistics(n_epochs,stat,param);
%plot all weight and hyperparameter statistics throughout learning 
%it can take on more arguments to display several statistics (e.g.
%plot_statistics(n_epochs,stat_1,param_1,stat_2,param_2)
%}

% STANDARD ANN (not tracking statistics)
%{
[model,momentum,param]=init('model',n_epochs,n_layer,lr);
error_tot=init('result','training',n_epochs);
for N=1:n_epochs
    model.current=N;
    fprintf('\n Epoch %d \n',N);
    [model,momentum,param,error]=...
        train(model,@(model,data,counter)gradient_RBM_soft(model,data,'bin',counter),...
        momentum,data_set,mini_batch_size,param);
    error_tot.train(N)=error.train;
    error_tot.test(N)=error.test;
end
%}

% MEM-ANN (tracking statistics)
%{
dt_max=150;%maximal programming pulse width
dt_min=dt_max/10000;%minimal programming pulse width
G_max=1;%maximal conductance
G_ratio=13;%maximal conductance/minimal conductance ratio
beta=0.005;%non-linearity

[model_mem,momentum_mem,param]=init('model',n_epochs,n_layer,lr,...
    G_max,G_ratio,beta,dt_max,dt_min,...
    'gran',[6,6],...
    [1,2],[dt_max/50,dt_max/50],{'RProp','RProp'});%initializes weights, momentum and memristive hyperparameters
%(for more details go in the README.txt)

error_rate_tot_mem=init('result','training',n_epochs);
stat_mem=init('stat',model_mem,n_epochs*n_iterations,param);
param.bool_stat=1;

for N=1:n_epochs
    model_mem.current=N;
    fprintf('\n Epoch %d \n',N);   
    fprintf('\nTraining the visible and first hidden layers of the memristor RBM...\n')
    [model_mem,momentum_mem,param,stat_mini_batch_mem,error_mem]=...
        train(model_mem,@(model,data,counter)gradient_RBM_soft(model,data,'bin',counter),...
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

[model_mem,momentum_mem,param]=init('model',n_epochs,n_layer,lr,...
    G_max,G_ratio,beta,dt_max,dt_min,...
    'gran',[6,6],...
    [1,2],[dt_max/50,dt_max/50],{'RProp','RProp'});
error_rate_tot_mem=init('result','training',n_epochs);

for N=1:n_epochs
    model_mem.current=N;
    fprintf('\n Epoch %d \n',N);   
    fprintf('\nTraining the visible and first hidden layers of the memristor RBM...\n')
    [model_mem,momentum_mem,param,error_mem]=...
        train(model_mem,@(model,data,counter)gradient_RBM_soft(model,data,'bin',counter),...
        momentum_mem,data_set,mini_batch_size,param);     
    error_tot_mem.train(N)=error_mem.train;
    error_tot_mem.test(N)=error_mem.test;   
end
%}

