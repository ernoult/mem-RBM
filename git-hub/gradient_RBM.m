%% GRADIENT COMPUTATION OF A RBM
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [gradient,counter]=gradient_RBM(model,mini_batch,counter,index,type)

    w=model.n{index};
    L=length(model.n);
    data=mini_batch;
    mini_batch_size =size(data,2);
    
    
    %INFERENCE DURING TRAINING WITH BINARY ACTIVATIONS
    data_bin = binornd(1,data);
    data_bin_temp=cat(1,data_bin,ones(1,size(data_bin,2)));
    p_hidden=sigmoid(w(1:size(w,1)-1,:)*data_bin_temp);
    p_hidden_0=p_hidden;
    
    for k=1:1
       %HID_k~p(.|VIS_k)
       hidden=binornd(1,p_hidden);
       hidden_temp=cat(1,hidden,ones(1,size(hidden,2)));
       p_visible=sigmoid(transpose(w(:,1:size(w,2)-1))*hidden_temp);
       %VIS_k+1~p(.|HID_k)
       visible=binornd(1,p_visible);
       visible_temp=cat(1,visible,ones(1,size(visible,2)));       
       p_hidden=sigmoid(w(1:size(w,1)-1,:)*visible_temp);      
    end
    
    %WEIGHT UPDATE
    switch type
        case 'normal'
            data_temp=cat(1,data,ones(1,size(data,2)));
            p_visible_temp=cat(1,p_visible,ones(1,size(p_visible,2)));
            p_hidden_temp=cat(1,p_hidden,ones(1,size(p_hidden,2)));
            p_hidden_0_temp=cat(1,p_hidden_0,ones(1,size(p_hidden_0,2)));
            gradient{index}=(1/mini_batch_size)*(p_hidden_0_temp*transpose(data_temp)-p_hidden_temp*transpose(p_visible_temp));
            
        case 'bin'
            data_bin_temp=cat(1,data_bin,ones(1,size(data_bin,2)));
            hidden_0=binornd(1,p_hidden_0);
            hidden_0_temp=cat(1,hidden_0,ones(1,size(hidden_0,2)));
            hidden=binornd(1,p_hidden);
            hidden_temp=cat(1,hidden,ones(1,size(hidden,2)));
            gradient{index}=(1/mini_batch_size)*(hidden_0_temp*transpose(data_bin_temp)-hidden_temp*transpose(visible_temp));
            
    end
    
    for k=1:L
        if (k~=index)
            gradient{k}=zeros(size(model.n{k}));
        end
    end  

end