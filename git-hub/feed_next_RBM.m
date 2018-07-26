function data=feed_next_RBM(model,ind,data,type,varargin)

    p=1;
    if (~isempty(varargin))
        p=varargin{1};
    end

    switch type

        case 'normal'
            data_train_temp=cat(1,data.train,ones(1,size(data.train,2)));
            data_test_temp=cat(1,data.test,ones(1,size(data.test,2)));

            data.train=sigmoid(p.*model.n{ind}(1:size(model.n{ind},1)-1,:)*data_train_temp);
            data.test=sigmoid(p.*model.n{ind}(1:size(model.n{ind},1)-1,:)*data_test_temp);

        case 'bin'
            data_train_temp=cat(1,data.train,ones(1,size(data.train,2)));
            data_test_temp=cat(1,data.test,ones(1,size(data.test,2)));
            data.train=sigmoid(p.*model.n{ind}(1:size(model.n{ind},1)-1,:)*data_train_temp);
            data.test=sigmoid(p.*model.n{ind}(1:size(model.n{ind},1)-1,:)*data_test_temp);
            data.train=binornd(1,data.train);
            data.test=binornd(1,data.test);
    end


end