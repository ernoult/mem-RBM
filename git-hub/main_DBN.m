%% TRAINING A MEMRISTIVE DEEP BELIEF NET (WITHOUT FINE TUNING)
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
m=40000;
m_test=10000;
mini_batch_size=100;
[data_set, n_vis]=load_data(m,m_test);
data.train=data_set.train.inputs;
data.test=data_set.test.inputs;
n_iterations=m/mini_batch_size;
n_layer=[n_vis,500,500,2000,10];
lr=[0.05,0.05,0.05,0.05];
n_epochs=1;

%Uncomment the useful section

% STANDARD ANN (tracking statistics)
%{
[model,momentum,param]=init('model',{'gen','flip'},n_epochs,n_layer,lr);
L=length(model.n);
stat=init('stat',model,(L-1)*n_epochs*n_iterations,param);
error_tot=init('result','training',n_epochs);
param.bool_stat=1;

for ind=1:L-2
    fprintf('\n Training RBM %d ... \n',ind);
    for N=1:n_epochs
        model.current=N;
        fprintf('\n Epoch %d \n',N);
        [model,momentum,param,stat_mini_batch]=...
            train(model,@(model,data,counter)gradient_RBM(model,data,counter,ind,'bin'),...
            momentum,data.train,mini_batch_size,param);
        stat=update_statistics(stat,stat_mini_batch,...
            (N-1+(ind-1)*n_epochs)*n_iterations+1:(N+(ind-1)*n_epochs)*n_iterations,param);
    end
    data=feed_next_RBM(model,ind,data,'normal');
end

data_top={data.train,data_set.train.targets,data.test,data_set.test.targets};
fprintf('\n Training top DRBM ... \n');

for N=1:n_epochs
    model.current=N;
    fprintf('\n Epoch %d \n',N);
    [model,momentum,param,stat_mini_batch,error]=...
        train(model,@(model,data,counter)gradient_DRBM2(model,data,counter,'bin',20,'det'),...
        momentum,data_top,mini_batch_size,param);
    stat=update_statistics(stat,stat_mini_batch,...
        (N-1+(L-2)*n_epochs)*n_iterations+1:(N+(L-2)*n_epochs)*n_iterations,param);
    error_tot.train(N)=error.train;
    error_tot.test(N)=error.test;   
end  
plot_statistics(n_epochs,stat,param);
%}

% STANDARD ANN (without tracking statistics)
%{
[model,momentum,param]=init('model',{'gen','flip'},n_epochs,n_layer,lr);
L=length(model.n);
error_tot=init('result','training',n_epochs);

for ind=1:L-2
    fprintf('\n Training RBM %d ... \n',ind);
    for N=1:n_epochs
        model.current=N;
        fprintf('\n Epoch %d \n',N);
        [model,momentum,param]=...
            train(model,@(model,data,counter)gradient_RBM(model,data,counter,ind,'bin'),...
            momentum,data.train,mini_batch_size,param);
    end
    data=feed_next_RBM(model,ind,data,'normal');
end

data_top={data.train,data_set.train.targets,data.test,data_set.test.targets};
fprintf('\n Training top DRBM ... \n');

for N=1:n_epochs
    model.current=N;
    fprintf('\n Epoch %d \n',N);
    [model,momentum,param,error]=...
        train(model,@(model,data,counter)gradient_DRBM2(model,data,counter,'bin',20,'det'),...
        momentum,data_top,mini_batch_size,param);
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
    [1,2,3,4],[dt_max/500,dt_max/500,dt_max/500,dt_max/500],{'Cst','Cst','Cst','Cst'});

L=length(model_mem.n);
stat_mem=init('stat',model_mem,(L-1)*n_epochs*n_iterations,param);
error_tot=init('result','training',n_epochs);
param.bool_stat=1;

for ind=1:L-2
    fprintf('\n Training RBM %d ... \n',ind);
    for N=1:n_epochs
        model_mem.current=N;
        fprintf('\n Epoch %d \n',N);
        [model_mem,momentum_mem,param,stat_mini_batch_mem]=...
            train(model_mem,@(model,data,counter)gradient_RBM(model,data,counter,ind,'bin'),...
            momentum_mem,data.train,mini_batch_size,param);
        stat_mem=update_statistics(stat_mem,stat_mini_batch_mem,...
            (N-1+(ind-1)*n_epochs)*n_iterations+1:(N+(ind-1)*n_epochs)*n_iterations,param);
    end
    data=feed_next_RBM(model_mem,ind,data,'normal');
end

data_top={data.train,data_set.train.targets,data.test,data_set.test.targets};

fprintf('\n Training top DRBM ... \n');
for N=1:n_epochs
    model_mem.current=N;
    fprintf('\n Epoch %d \n',N);
    [model_mem,momentum_mem,param,stat_mini_batch_mem,error]=...
        train(model_mem,@(model,data,counter)gradient_DRBM2(model,data,counter,'bin',20,'det'),...
        momentum_mem,data_top,mini_batch_size,param);
    stat_mem=update_statistics(stat_mem,stat_mini_batch_mem,(N-1+(L-2)*n_epochs)*n_iterations+1:(N+(L-2)*n_epochs)*n_iterations,param);
    error_tot.train(N)=error.train;
    error_tot.test(N)=error.test;   
end  
plot_statistics(n_epochs,stat_mem,param);
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
    [1,2,3,4],[dt_max/500,dt_max/500,dt_max/500,dt_max/500],{'Cst','Cst','Cst','Cst'});

L=length(model_mem.n);
error_tot=init('result','training',n_epochs);

for ind=1:L-2
    fprintf('\n Training RBM %d ... \n',ind);
    for N=1:n_epochs
        model_mem.current=N;
        fprintf('\n Epoch %d \n',N);
        [model_mem,momentum_mem,param]=...
            train(model_mem,@(model,data,counter)gradient_RBM(model,data,counter,ind,'bin'),...
            momentum_mem,data.train,mini_batch_size,param);
    end
    data=feed_next_RBM(model_mem,ind,data,'normal');
end

data_top={data.train,data_set.train.targets,data.test,data_set.test.targets};

fprintf('\n Training top DRBM ... \n');
for N=1:n_epochs
    model_mem.current=N;
    fprintf('\n Epoch %d \n',N);
    [model_mem,momentum_mem,param,error]=...
        train(model_mem,@(model,data,counter)gradient_DRBM2(model,data,counter,'bin',20,'det'),...
        momentum_mem,data_top,mini_batch_size,param);
    error_tot.train(N)=error.train;
    error_tot.test(N)=error.test;   
end  
%}



