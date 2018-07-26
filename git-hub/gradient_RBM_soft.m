%% GRADIENT COMPUTATION OF A RBM TOPPED BY A SOFTMAX
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [gradient,counter]=gradient_RBM_soft(model,mini_batch,type,counter)

    L=length(model.n);
    w_1=model.n{L-1};
    w_2=model.n{L};
    
    data = mini_batch.train.inputs;
    mini_batch_size =size(data,2);
    
    %1-TRAINING RBM
    %INFERENCE DURING TRAINING WTIH BINARY ACTIVATIONS
    data_bin=binornd(1,data);
    data_bin_temp=cat(1,data_bin,ones(1,size(data_bin,2)));
    targets=mini_batch.train.targets;
    targets_temp=cat(1,targets,ones(1,size(targets,2)));
    p_hidden=sigmoid(w_1(1:size(w_1,1)-1,:)*data_bin_temp);
    p_hidden_0=p_hidden;
    
    for k=1:1
       %H_k~p(.|V_k)
       hidden=binornd(1,p_hidden);
       hidden_temp=cat(1,hidden,ones(1,size(hidden,2)));
       p_visible=sigmoid(transpose(w_1(:,1:size(w_1,2)-1))*hidden_temp);
       %V_k+1~p(.|H_k)
       visible=binornd(1,p_visible);
       visible_temp=cat(1,visible,ones(1,size(visible,2)));       
       p_hidden=sigmoid(w_1(1:size(w_1,1)-1,:)*visible_temp);      
    end
    
    p_hidden_temp=cat(1,p_hidden,ones(1,size(p_hidden,2)));
    switch type 
        case 'normal'
            data_temp=cat(1,data,ones(1,size(data,2)));
            p_visible_temp=cat(1,p_visible,ones(1,size(p_visible,2)));
            p_hidden_0_temp=cat(1,p_hidden_0,ones(1,size(p_hidden_0,2)));
            gradient{L-1}=(1/mini_batch_size)*(p_hidden_0_temp*transpose(data_temp)-p_hidden_temp*transpose(p_visible_temp));
            gradient{L-1}(end,end)=0;
            
        case 'bin'
            hidden_0=binornd(1,p_hidden_0);
            hidden_0_temp=cat(1,hidden_0,ones(1,size(hidden_0,2)));
            hidden=binornd(1,p_hidden);
            hidden_temp=cat(1,hidden,ones(1,size(p_hidden,2)));
            gradient{L-1}=(1/mini_batch_size)*(hidden_0_temp*transpose(data_bin_temp)-hidden_temp*transpose(visible_temp));
            gradient{L-1}(end,end)=0;
    end
    %2-TRAINING SOFTMAX
    %INFERENCE DURING TRAINING WTIH BINARY ACTIVATIONS
    hidden_temp=binornd(1,p_hidden_temp);
    z_2 = w_2(1:size(w_2,1)-1,:)*hidden_temp; 
    logZ = log_sum_exp_over_rows(z_2); 
    log_lab = z_2 - repmat(logZ, [size(z_2, 1), 1]);
    p_lab = exp(log_lab);
    
    switch type
        case 'normal'
            p_lab_temp=cat(1,p_lab,ones(1,size(p_lab,2)));
            gradient{L}=(1/mini_batch_size)*(targets_temp - p_lab_temp)* transpose(p_hidden_temp);
            gradient{L}(end,:)=0;
        case 'bin'
            xx = cumsum(p_lab,1);
            xx1 = rand(1,mini_batch_size);
            lab = p_lab*0;
            for jj=1:mini_batch_size
                index = min(find(xx1(jj) <= xx(:,jj)));
                lab(index,jj) = 1;
            end
            lab_temp=cat(1,lab,ones(1,size(lab,2)));
            gradient{L}=(1/mini_batch_size)*(targets_temp - lab_temp)* transpose(hidden_temp);
            gradient{L}(end,:)=0;
    end
    
    if L>2
        for k=1:L-2
            gradient{k}=zeros(size(model.n{k}));
        end
    end

    
    %INFERENCE AT TEST TIME
    %INFERENCE ON TRAINING DATA WITH BINARY ACTIVATIONS
    p_hidden=sigmoid(w_1(1:size(w_1,1)-1,:)*data_bin_temp);
    p_hidden_temp=cat(1,p_hidden,ones(1,size(p_hidden,2)));
    hidden_temp=binornd(1,p_hidden_temp);
    z_2 = w_2(1:size(w_2,1)-1,:)*hidden_temp;
    logZ = log_sum_exp_over_rows(z_2);
    log_lab = z_2 - repmat(logZ, [size(z_2, 1), 1]);
    p_lab = exp(log_lab);
    [~,J]=max(p_lab,[],1);
    [~,J1]=max(targets,[],1);
    counter.train=counter.train+length(find(J==J1));
    
    %INFERENCE ON TEST DATA WITH BINARY ACTIVATIONS
    if isfield(mini_batch,'test')
        data=mini_batch.test.inputs;
        data_bin=binornd(1,data);
        data_bin_temp=cat(1,data_bin,ones(1,size(data_bin,2)));
        targets=mini_batch.test.targets;  
        p_hidden=sigmoid(w_1(1:size(w_1,1)-1,:)*data_bin_temp);
        p_hidden_temp=cat(1,p_hidden,ones(1,size(p_hidden,2)));
        hidden_temp=binornd(1,p_hidden_temp);
        z_2 = w_2(1:size(w_2,1)-1,:)*hidden_temp;
        logZ = log_sum_exp_over_rows(z_2);
        log_lab = z_2 - repmat(logZ, [size(z_2, 1), 1]);
        p_lab = exp(log_lab);
        [~,J]=max(p_lab,[],1);
        [~,J1]=max(targets,[],1);
        counter.test=counter.test+length(find(J==J1));
    end



end