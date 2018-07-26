%% GRADIENT COMPUTATION OF A DISCRIMINATIVE RBM
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [gradient,counter]=gradient_DRBM2(model,mini_batch,counter,type_1,n_iter_train,type_2,varargin)

    L=length(model.n);
    w_1=model.n{L-1};
    w_2=model.n{L};
    data = mini_batch.train.inputs;
    mini_batch_size =size(data,2);
    grad_1_temp=zeros(size(w_1));
    grad_2_temp=zeros(size(w_2));
    %INFERENCE DURING TRAINING WITH BINARY ACTIVATIONS
    for iter=1:n_iter_train
        data_bin=binornd(1,data);
        data_bin_temp=cat(1,data_bin,ones(1,size(data_bin,2)));
        targets=mini_batch.train.targets;
        p_hidden=sigmoid(w_1(1:end-1,:)*data_bin_temp+w_2(1:end-1,1:end-1)*targets);
        p_hidden_0=p_hidden;
        hidden_0=binornd(1,p_hidden_0);
        for k=1:1
            hidden=binornd(1,p_hidden);
            hidden_temp=cat(1,hidden,ones(1,size(hidden,2)));
            p_visible=sigmoid(transpose(w_1(:,1:size(w_1,2)-1))*hidden_temp);
            visible=binornd(1,p_visible);
            visible_temp=cat(1,visible,ones(1,size(visible,2)));
            p_lab=exp(transpose(w_2(:,1:size(w_2,2)-1))*hidden_temp);
            p_lab=p_lab./(ones(10,1)*sum(p_lab,1));
            xx = cumsum(p_lab,1);
            xx1 = rand(1,mini_batch_size);
            lab = p_lab*0;
            for jj=1:mini_batch_size
                index = min(find(xx1(jj) <= xx(:,jj)));
                lab(index,jj) = 1;
            end
            p_hidden=sigmoid(w_1(1:size(w_1,1)-1,:)*visible_temp+w_2(1:size(w_2,1)-1,1:size(w_2,2)-1)*lab);
        end
        hidden=binornd(1,p_hidden);
        hidden_temp=cat(1,hidden,ones(1,size(hidden,2)));
        lab_temp=cat(1,lab,ones(1,size(lab,2)));
        targets_temp=cat(1,targets,ones(1,size(targets,2)));
        hidden_0_temp=cat(1,hidden_0,ones(1,size(hidden_0,2)));
        grad_1_temp=grad_1_temp+(1/(mini_batch_size*n_iter_train))*(hidden_0_temp*transpose(data_bin_temp)-hidden_temp*transpose(visible_temp));
        grad_2_temp=grad_2_temp+(1/(mini_batch_size*n_iter_train))*(hidden_0_temp*transpose(targets_temp)-hidden_temp*transpose(lab_temp));
    end
    %WEIGHT UPDATE
    switch type_1
        case 'normal'
            data_temp=cat(1,data,ones(1,size(data,2)));
            p_hidden_0_temp=cat(1,p_hidden_0,ones(1,size(p_hidden_0,2)));
            p_hidden_temp=cat(1,p_hidden,ones(1,size(p_hidden,2)));
            gradient{L-1}=(1/mini_batch_size)*(p_hidden_0_temp*transpose(data_bin_temp)-p_hidden_temp*transpose(visible_temp));
            gradient{L-1}(end,end)=0;
            gradient{L}=(1/mini_batch_size)*(p_hidden_0_temp*transpose(targets_temp)-p_hidden_temp*transpose(lab_temp));
            gradient{L}(1:end,end)=0;

        case 'bin'
            gradient{L-1}=grad_1_temp;
            gradient{L-1}(end,end)=0;
            gradient{L}=grad_2_temp;
            gradient{L}(1:end,end)=0;
    end
   
    if L>2
        for k=1:L-2
            gradient{k}=zeros(size(model.n{k}));
        end
    end
    
    if (model.current==model.n_epochs)
        switch type_2
            case 'sto' %STOCHASTIC INFERENCE (GIBBS SAMPLING AVERAGED 50 TIMES) AT TEST TIME
                n_iter_infer=varargin{1};
                %INFERENCE ON TRAINING DATA WITH BINARY ACTIVATIONS
                lab_tab=zeros(size(lab));
                for p=1:n_iter_infer
                    p_lab_error=(1/10)*ones(10,mini_batch_size);
                    p_hidden=sigmoid(w_1(1:size(w_1,1)-1,:)*data_bin_temp+w_2(1:size(w_2,1)-1,1:size(w_2,2)-1)*p_lab_error);
                    for k=1:2
                        hidden=binornd(1,p_hidden);
                        hidden_temp=cat(1,hidden,ones(1,size(hidden,2)));
                        %sample visible
                        p_visible=sigmoid(transpose(w_1(:,1:size(w_1,2)-1))*hidden_temp);
                        visible=binornd(1,p_visible);
                        visible_temp=cat(1,visible,ones(1,size(visible,2)));
                        %sample label
                        p_lab=exp(transpose(w_2(:,1:size(w_2,2)-1))*hidden_temp);
                        p_lab=p_lab./(ones(10,1)*sum(p_lab,1));
                        xx = cumsum(p_lab,1);
                        xx1 = rand(1,mini_batch_size);
                        lab = p_lab*0;
                        for jj=1:mini_batch_size
                            index = min(find(xx1(jj) <= xx(:,jj)));
                            lab(index,jj) = 1;
                        end
                        p_hidden=sigmoid(w_1(1:size(w_1,1)-1,:)*visible_temp+w_2(1:size(w_2,1)-1,1:size(w_2,2)-1)*lab);
                    end
                    lab_tab=lab_tab+lab;
                end
                lab_tab=(1/n_iter_infer)*lab_tab;
                [~,J]=max(lab_tab,[],1);
                [~,J1]=max(targets,[],1);
                counter.train=counter.train+length(find(J==J1));
                
                %INFERENCE ON TEST DATA WITH BINARY ACTIVATIONS
                if isfield(mini_batch,'test')
                    data_bin = binornd(1,mini_batch.test.inputs);
                    data_bin_temp=cat(1,data_bin,ones(1,size(data,2)));
                    targets=mini_batch.test.targets;
                    lab_tab=zeros(size(p_lab_error));
                    
                    for p=1:n_iter_infer
                        p_lab_error=(1/10)*ones(10,mini_batch_size);
                        p_hidden=sigmoid(w_1(1:size(w_1,1)-1,:)*data_bin_temp+w_2(1:size(w_2,1)-1,1:size(w_2,2)-1)*p_lab_error);
                        for k=1:2
                            hidden=binornd(1,p_hidden);
                            hidden_temp=cat(1,hidden,ones(1,size(hidden,2)));
                            %sample visible
                            p_visible=sigmoid(transpose(w_1(:,1:size(w_1,2)-1))*hidden_temp);
                            visible=binornd(1,p_visible);
                            visible_temp=cat(1,visible,ones(1,size(visible,2)));
                            %sample label
                            p_lab=exp(transpose(w_2(:,1:size(w_2,2)-1))*hidden_temp);
                            p_lab=p_lab./(ones(10,1)*sum(p_lab,1));
                            xx = cumsum(p_lab,1);
                            xx1 = rand(1,mini_batch_size);
                            lab = p_lab*0;
                            for jj=1:mini_batch_size
                                index = min(find(xx1(jj) <= xx(:,jj)));
                                lab(index,jj) = 1;
                            end
                            p_hidden=sigmoid(w_1(1:size(w_1,1)-1,:)*visible_temp+w_2(1:size(w_2,1)-1,1:size(w_2,2)-1)*lab);
                        end
                        lab_tab=lab_tab+lab;
                    end
                    
                    lab_tab=(1/n_iter_infer)*lab_tab;
                    [~,J]=max(lab_tab,[],1);
                    [~,J1]=max(targets,[],1);
                    counter.test=counter.test+length(find(J==J1));
                end
                
            case 'det' %DETERMINISTIC INFERENCE (FREE ENERGY METHOD)AT TEST TIME
                %INFERENCE ON TRAINING DATA WITH PROBABILITIES
                F=zeros(size(p_lab));
                for p=1:10
                    label_test=zeros(size(p_lab));
                    label_test(p,:)=ones([1,size(p_lab,2)]);
                    
                    F(p,:)=-w_1(end,1:end-1)*data-w_2(end,1:end-1)*label_test...
                        -sum(log(ones(size(p_hidden))+exp(w_1(1:end-1,1:end-1)*data+w_2(1:end-1,1:end-1)*label_test+w_1(1:end-1,end))),1);
                    
                end
                [~,J]=min(F,[],1);
                targets=mini_batch.train.targets;
                [~,J1]=max(targets,[],1);
                counter.train=counter.train+length(find(J==J1));
                
                %INFERENCE ON TRAINING DATA WITH PROBABILITIES
                if isfield(mini_batch,'test')
                    data = binornd(1,mini_batch.test.inputs);
                    targets=mini_batch.test.targets;
                    F=zeros(size(p_lab));
                    
                    for p=1:10
                        label_test=zeros(size(p_lab));
                        label_test(p,:)=ones([1,size(p_lab,2)]);
                        F(p,:)=-w_1(end,1:end-1)*data-w_2(end,1:end-1)*label_test...
                            -sum(log(ones(size(p_hidden))+exp(w_1(1:end-1,1:end-1)*data+w_2(1:end-1,1:end-1)*label_test+w_1(1:end-1,end))),1);
                    end
                    [~,J]=min(F,[],1);
                    [~,J1]=max(targets,[],1);
                    counter.test=counter.test+length(find(J==J1));
                end
        end
    end