%% WEIGHT UPDATE FUNCTION (INCLUDING CONDUCTANCE UPDATE)
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [model,momentum,param,varargout]=update_weight(model,momentum,gradient,param)

    for ind=1:length(gradient)
        momentum_temp=momentum{ind};
        gradient_temp=gradient{ind};

        if (~sum(param.to_mem==ind))
            momentum_new_temp=0.9*momentum_temp+gradient_temp;
            lr=param.lr{ind};
            w_old_temp=model.n{ind};
            w_new_temp=w_old_temp+lr*momentum_new_temp;
            delta_w_temp=w_new_temp-w_old_temp;
            model.n{ind}=w_new_temp;

            momentum{ind}=momentum_new_temp;
            if nargout>3
                stat.w.n{ind}=w_old_temp;
                stat.delta_w.n{ind}=delta_w_temp;
                stat.nb_updates{ind}=2*length(find(delta_w_temp~=0));
                varargout{1}=stat;
            end


        else
            momentum_new_temp=gradient_temp;
            w_p_old_temp=model.p{ind};
            w_m_old_temp=model.m{ind};
            delta_w_p_temp=zeros(size(w_p_old_temp));
            delta_w_m_temp=zeros(size(w_m_old_temp));
            dt_temp_p=param.dt.p{ind};
            dt_temp_m=param.dt.m{ind};
            dt_max=param.dt_max{ind};
            dt_min=param.dt_min{ind};
            dt_0=param.dt_0{ind};
            G_max=param.G_max{ind};
            G_min=param.G_min{ind};
            a=param.a;
            b=param.b;

            if (mean(mean(gradient_temp==0))~=0)
                switch param.scheme{ind}

                    case 'Cst'
                        %CHOICE OF THE PULSE WIDTH
                        dt_new_temp_p=dt_temp_p;
                        dt_new_temp_m=dt_temp_m;
                        param.dt.p{ind}=dt_new_temp_p;
                        param.dt.m{ind}=dt_new_temp_m;

                        %CONDUCTANCE UPDATE
                        bool_temp=momentum_new_temp>0;
                        delta_w_p_temp(bool_temp)=delta_w_p_temp(bool_temp)+...
                            grad_mem_p(w_p_old_temp,param,dt_new_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)=delta_w_m_temp(bool_temp)+...
                            grad_mem_m(w_m_old_temp,param,dt_new_temp_m,bool_temp,ind);

                        bool_temp=momentum_new_temp<0;
                        delta_w_p_temp(bool_temp)=delta_w_p_temp(bool_temp)+...
                            grad_mem_m(w_p_old_temp,param,dt_new_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)=delta_w_m_temp(bool_temp)+...
                            grad_mem_p(w_m_old_temp,param,dt_new_temp_m,bool_temp,ind);

                    case 'RProp'
                        %CHOICE OF THE PULSE WIDTH
                        dt_new_temp_p=zeros(size(dt_temp_p));
                        dt_new_temp_m=zeros(size(dt_temp_m));
                        bool_1=(momentum_temp.*momentum_new_temp)>0;
                        bool_2=(momentum_temp.*momentum_new_temp)<0;
                        bool_3=(momentum_temp.*momentum_new_temp)==0;

                        dt_new_temp_p(bool_1)=dt_new_temp_p(bool_1)+min(a{ind}.*dt_temp_p(bool_1),dt_0(bool_1));
                        dt_new_temp_m(bool_1)=dt_new_temp_m(bool_1)+min(a{ind}.*dt_temp_m(bool_1),dt_0(bool_1));

                        dt_new_temp_p(bool_2)=dt_new_temp_p(bool_2)+max(b{ind}.*dt_temp_p(bool_2),zeros(size(dt_temp_p(bool_2))));
                        dt_new_temp_m(bool_2)=dt_new_temp_m(bool_2)+max(b{ind}.*dt_temp_m(bool_2),zeros(size(dt_temp_m(bool_2))));

                        dt_new_temp_p(bool_3)=dt_new_temp_p(bool_3)+dt_temp_p(bool_3);
                        dt_new_temp_m(bool_3)=dt_new_temp_m(bool_3)+dt_temp_m(bool_3);

                        param.dt.p{ind}=dt_new_temp_p;
                        param.dt.m{ind}=dt_new_temp_m;

                        %CONDUCTANCE UPDATE
                        bool_temp=momentum_new_temp>0 & bool_1;
                        delta_w_p_temp(bool_temp)= delta_w_p_temp(bool_temp)+...
                            grad_mem_p(w_p_old_temp,param,dt_new_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)= delta_w_m_temp(bool_temp)+ ...
                            grad_mem_m(w_m_old_temp,param,dt_new_temp_m,bool_temp,ind);

                        bool_temp=momentum_new_temp<0 & bool_1;
                        delta_w_p_temp(bool_temp)=delta_w_p_temp(bool_temp)+ ...
                            grad_mem_m(w_p_old_temp,param,dt_new_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)= delta_w_m_temp(bool_temp)+ ...
                            grad_mem_p(w_m_old_temp,param,dt_new_temp_m,bool_temp,ind);

                        bool_temp=momentum_temp>0 & bool_2;
                        delta_w_p_temp(bool_temp)= delta_w_p_temp(bool_temp)+...
                            grad_mem_m(w_p_old_temp,param,dt_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)= delta_w_m_temp(bool_temp)+ ...
                            grad_mem_p(w_m_old_temp,param,dt_temp_m,bool_temp,ind);

                        bool_temp=momentum_temp<0 & bool_2;
                        delta_w_p_temp(bool_temp)=delta_w_p_temp(bool_temp)+ ...
                            grad_mem_p(w_p_old_temp,param,dt_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)= delta_w_m_temp(bool_temp)+ ...
                            grad_mem_m(w_m_old_temp,param,dt_temp_m,bool_temp,ind);
                        
                        momentum_new_temp(bool_2)=0;
                       
                        bool_temp=momentum_new_temp>0 & bool_3;
                        delta_w_p_temp(bool_temp)= delta_w_p_temp(bool_temp)+...
                            grad_mem_p(w_p_old_temp,param,dt_new_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)= delta_w_m_temp(bool_temp)+ ...
                            grad_mem_m(w_m_old_temp,param,dt_new_temp_m,bool_temp,ind);

                        bool_temp=momentum_new_temp<0 & bool_3;
                        delta_w_p_temp(bool_temp)=delta_w_p_temp(bool_temp)+ ...
                            grad_mem_m(w_p_old_temp,param,dt_new_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)= delta_w_m_temp(bool_temp)+ ...
                            grad_mem_p(w_m_old_temp,param,dt_new_temp_m,bool_temp,ind);


                    case 'soft_RProp'
                        %CHOICE OF THE PULSE WIDTH
                        dt_new_temp_p=zeros(size(dt_temp_p));
                        dt_new_temp_m=zeros(size(dt_temp_m));
                        bool_1=(momentum_temp.*momentum_new_temp)>0;
                        bool_2=(momentum_temp.*momentum_new_temp)<0;
                        bool_3=(momentum_temp.*momentum_new_temp)==0;

                        dt_new_temp_p(bool_1)=dt_new_temp_p(bool_1)+min(a.*dt_temp_p(bool_1),dt_max(bool_1));
                        dt_new_temp_m(bool_1)=dt_new_temp_m(bool_1)+min(a.*dt_temp_m(bool_1),dt_max(bool_1));

                        dt_new_temp_p(bool_2)=dt_new_temp_p(bool_2)+dt_min(bool_2);
                        dt_new_temp_m(bool_2)=dt_new_temp_m(bool_2)+dt_min(bool_2);

                        dt_new_temp_p(bool_3)=dt_new_temp_p(bool_3)+dt_temp_p(bool_3);
                        dt_new_temp_m(bool_3)=dt_new_temp_m(bool_3)+dt_temp_m(bool_3);

                        param.dt.p{ind}=dt_new_temp_p;
                        param.dt.m{ind}=dt_new_temp_m;

                        %CONDUCTANCE UPDATE
                        bool_temp=momentum_new_temp>0 & bool_1;
                        delta_w_p_temp(bool_temp)= delta_w_p_temp(bool_temp)+...
                            grad_mem_p(w_p_old_temp,param,dt_new_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)= delta_w_m_temp(bool_temp)+ ...
                            grad_mem_m(w_m_old_temp,param,dt_new_temp_m,bool_temp,ind);

                        bool_temp=momentum_new_temp<0 & bool_1;
                        delta_w_p_temp(bool_temp)=delta_w_p_temp(bool_temp)+ ...
                            grad_mem_m(w_p_old_temp,param,dt_new_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)= delta_w_m_temp(bool_temp)+ ...
                            grad_mem_p(w_m_old_temp,param,dt_new_temp_m,bool_temp,ind);

                        bool_temp=momentum_temp>0 & bool_2;
                        delta_w_p_temp(bool_temp)= delta_w_p_temp(bool_temp)+...
                            grad_mem_m(w_p_old_temp,param,dt_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)= delta_w_m_temp(bool_temp)+ ...
                            grad_mem_p(w_m_old_temp,param,dt_temp_m,bool_temp,ind);

                        bool_temp=momentum_temp<0 & bool_2;
                        delta_w_p_temp(bool_temp)=delta_w_p_temp(bool_temp)+ ...
                            grad_mem_p(w_p_old_temp,param,dt_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)= delta_w_m_temp(bool_temp)+ ...
                            grad_mem_m(w_m_old_temp,param,dt_temp_m,bool_temp,ind);
                        momentum_new_temp(momentum_temp.*momentum_new_temp<0)=0;

                        bool_temp=momentum_new_temp>0 & bool_3;
                        delta_w_p_temp(bool_temp)= delta_w_p_temp(bool_temp)+...
                            grad_mem_p(w_p_old_temp,param,dt_new_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)= delta_w_m_temp(bool_temp)+ ...
                            grad_mem_m(w_m_old_temp,param,dt_new_temp_m,bool_temp,ind);

                        bool_temp=momentum_new_temp<0 & bool_3;
                        delta_w_p_temp(bool_temp)=delta_w_p_temp(bool_temp)+ ...
                            grad_mem_m(w_p_old_temp,param,dt_new_temp_p,bool_temp,ind);
                        delta_w_m_temp(bool_temp)= delta_w_m_temp(bool_temp)+ ...
                            grad_mem_p(w_m_old_temp,param,dt_new_temp_m,bool_temp,ind);

                end

                noise_p=param.bool_var_dyn*normrnd(0,param.var_dyn.*(G_max-G_min),size(G_max));
                noise_m=param.bool_var_dyn*normrnd(0,param.var_dyn.*(G_max-G_min),size(G_max));

                if (param.n_bits{ind}<64)
                    w_p_new_temp=floor((w_p_old_temp+delta_w_p_temp-G_min)./param.gran{ind}).*param.gran{ind}...
                        +G_min+noise_p;
                    w_m_new_temp=floor((w_m_old_temp+delta_w_m_temp-G_min)./param.gran{ind}).*param.gran{ind}...
                        +G_min+noise_m;
                else
                    w_p_new_temp=w_p_old_temp+delta_w_p_temp+noise_p;
                    w_m_new_temp=w_m_old_temp+delta_w_m_temp+noise_m;
                end

                w_p_new_temp(w_p_new_temp<G_min)=G_min(w_p_new_temp<G_min);
                w_p_new_temp(w_p_new_temp>G_max)=G_max(w_p_new_temp>G_max);
                w_m_new_temp(w_m_new_temp<G_min)=G_min(w_m_new_temp<G_min);
                w_m_new_temp(w_m_new_temp>G_max)=G_max(w_m_new_temp>G_max);

                delta_w_p_temp=w_p_new_temp-w_p_old_temp;
                delta_w_m_temp=w_m_new_temp-w_m_old_temp;

                model.p{ind}=w_p_new_temp;
                model.m{ind}=w_m_new_temp;
                model.n{ind}=w_p_new_temp-w_m_new_temp;
                momentum{ind}=momentum_new_temp;
            end
            if (nargout>3)
                stat.w.p{ind}=w_p_old_temp;
                stat.w.m{ind}=w_m_old_temp;
                stat.w.n{ind}=w_p_old_temp-w_m_old_temp;
                stat.delta_w.p{ind}=delta_w_p_temp;
                stat.delta_w.m{ind}=delta_w_m_temp;
                stat.delta_w.n{ind}=delta_w_p_temp-delta_w_m_temp;
                stat.nb_updates{ind}=length(find(delta_w_p_temp~=0))+length(find(delta_w_m_temp~=0));
                varargout{1}=stat;
            end

        end
    end
end