%% TRAIN FUNCTION
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [model,momentum,param,varargout]=...
    train(model,gradient_function,momentum,training_data,mini_batch_size,param)

    [mini_batch_cell,m]=make_mini_batches(training_data,mini_batch_size);
    n_iterations=length(mini_batch_cell);
    counter.train=0;
    counter.test=0;
    inc_out=1;
    
    if (param.bool_stat==1)%if we decide to collect statistics
        stat=init('stat',model,n_iterations,param);
        for iteration_number=1:n_iterations%looping over mini-batches
            fprintf(' \n Epoch %d, mini-batch %d \n',model.current,iteration_number);
            mini_batch=mini_batch_cell{iteration_number};
            [gradient,counter]=gradient_function(model,mini_batch,counter);
            [model,momentum,param,stat_temp]=...
                update_weight(model,momentum,gradient,param);
            stat=update_statistics(stat,stat_temp,iteration_number,param);
        end
        varargout{inc_out}=stat;
        inc_out=inc_out+1;
        if nargout>4
            error.train=1-(1/m.train)*counter.train;
            error.test=1-(1/m.test)*counter.test;
            fprintf('\n Classification error rate on training data (%d elements) : %.3g %%\n',m.train,100*error.train);
            fprintf('\n Classification error rate on test data (%d elements) : %.3g %%\n',m.test,100*error.test);
            varargout{inc_out}=error;
        end
    else%we don't collect statistics
        for iteration_number=1:n_iterations%looping over mini-batches
            fprintf(' \n Epoch %d, mini-batch %d \n',model.current,iteration_number);
            mini_batch=mini_batch_cell{iteration_number};
            [gradient,counter]=gradient_function(model,mini_batch,counter);
            [model,momentum,param]=...
                update_weight(model,momentum,gradient,param);
        end
        if nargout>3
            error.train=1-(1/m.train)*counter.train;
            error.test=1-(1/m.test)*counter.test;
            if (counter.train~=0)
                fprintf('\n Classification error rate on training data (%d elements) : %.3g %%\n',m.train,100*error.train);
                fprintf('\n Classification error rate on test data (%d elements) : %.3g %%\n',m.test,100*error.test);
            end
            varargout{inc_out}=error;
        end
        
    end

end
