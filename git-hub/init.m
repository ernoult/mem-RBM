%% INITIALIZE WEIGHTS, MOMENTUM AND HYPERPARAMETERS
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout=init(string,varargin)

switch string
    
    case 'model'%standard (i.e. non memristive) model
        s=1;
        model.bool_gen=0;
        bool_flip=0;
        if iscell(varargin{1})
            s=s+1;
            for k=1:length(varargin{1})
                switch char(varargin{1}(k))
                    case 'gen'
                        model.bool_gen=1;
                    case 'flip'
                        bool_flip=1;
                end
            end
        end
        model.n_epochs=varargin{s};
        layer_size=varargin{s+1};
        lr=varargin{s+2};
        
        for k=1:length(layer_size)-1
            %%%%%%%%%NOTE THE VARIANCE%%%%%%%%%%%%%%%%%%%%%%%%
            %w=normrnd(0,0.065,[layer_size(k+1),layer_size(k)]);
            w=-sqrt(1/max([layer_size(k+1),layer_size(k)]))+...
                2*sqrt(1/max([layer_size(k+1),layer_size(k)])).*rand([layer_size(k+1),layer_size(k)]);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            w=cat(1,w,zeros(1,size(w,2)));
            w=cat(2,w,zeros(size(w,1),1));
            model.n{k}=w;
            model.ini.n{k}=w;
            momentum{k}=zeros(size(w));
            param.lr{k}=lr(k);
            param.n_bits{k}=64;
        end
        param.bool_stat=0;
        if (length(varargin)<5)
            param.to_mem=[];
            if (bool_flip)
                model.n{end}=transpose(model.n{end});
                momentum{end}=transpose(momentum{end});
            end
            varargout{1}=model;
            varargout{2}=momentum;
            varargout{3}=param;
            
        else %memristive model
            G_max=varargin{s+3};
            G_ratio=varargin{s+4};
            beta=varargin{s+5};
            dt_max=varargin{s+6};
            dt_min=varargin{s+7};
            G_min=(1/G_ratio)*G_max;
            param.betap=beta;
            param.betam=beta;
            [Cp,Cm]=sym_charac(G_max,G_min,beta,beta,dt_max);
            
            param.bool_var_space=0;
            param.bool_var_dyn=0;
            param.var_dyn=0;
            param.var_Gmax_bool=0;
            param.bool_gran=0;
            imperfections={'var_space','var_dyn','gran','var_Gmax'};
            %i.e. device-to-device variability, cycle-to-cycle variability,
            %weight granularity (in bits), variability on the maximal
            %conductance
            
            s=s+7;
            k=1;
            
            while (sum(contains(imperfections,char(varargin{2*k+s-1}))))
                if (strcmp(varargin{2*k+s-1},imperfections{1})==1)
                    param.bool_var_space=1;
                    variability=varargin{2*k+s};
                    k=k+1;
                elseif (strcmp(varargin{2*k+s-1},imperfections{2})==1)
                    param.bool_var_dyn=1;
                    param.var_dyn=varargin{2*k+s};
                    k=k+1;
                elseif (strcmp(varargin{2*k+s-1},imperfections{3})==1)
                    param.bool_gran=1;
                    n_bits=varargin{2*k+s};
                    k=k+1;
                elseif (strcmp(varargin{2*k+s-1},imperfections{4})==1)
                    param.var_Gmax_bool=1;
                    variability_Gmax=varargin{2*k+s};
                    k=k+1;
                end
            end
            
            s=2*(k-1)+s;
            
            to_mem=varargin{s+1};
            dt_0=varargin{s+2};
            scheme=varargin{s+3};
            inc=1;
            for k=to_mem
                param.scheme{k}=scheme{inc};
                [p,q]=size(model.n{k});
                param.a{k}=1/0.99;
                param.b{k}=0.99;
                
                G_mean=0.5*(G_max+G_min);
                %%%%%%%%%%%NOTE THE VARIANCE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                w_p=normrnd(G_mean,0.1*G_mean,[p-1,q-1]);
                w_m=normrnd(G_mean,0.1*G_mean,[p-1,q-1]);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                w_p=cat(1,w_p,0.5*(G_max+G_min).*ones(1,size(w_p,2)));
                w_p=cat(2,w_p,0.5*(G_max+G_min).*ones(size(w_p,1),1));
                w_m=cat(1,w_m,0.5*(G_max+G_min).*ones(1,size(w_m,2)));
                w_m=cat(2,w_m,0.5*(G_max+G_min).*ones(size(w_m,1),1));

                
                if (param.bool_gran)
                    param.n_bits{k}=n_bits(inc);
                    param.gran{k}=(G_max-G_min)/(2^(n_bits(inc))-1);
                    [C_lin,~]=sym_charac(G_max,G_min,0.005,...
                        0.005,dt_max);
                    param.dt_min{k}=param.gran{k}/C_lin;
                    w_p=floor((w_p-G_min)./param.gran{k}).*param.gran{k}+G_min;
                    w_m=floor((w_m-G_min)./param.gran{k}).*param.gran{k}+G_min;
                end
                
                model.p{k}=w_p;
                model.m{k}=w_m;
                model.n{k}=w_p-w_m;
                model.ini.n{k}=w_p-w_m;
                momentum{k}=zeros(size(w_p));
                
                param.dt.p{k}=ones([p,q])*dt_0(inc);
                param.dt.m{k}=ones([p,q])*dt_0(inc);
                param.dt_0{k}=ones([p,q])*dt_0(inc);
                param.dt_max{k}=ones([p,q])*dt_max;
                param.dt_min{k}=ones([p,q])*dt_min;
                
                if (param.bool_var_space)
                    Cp_temp=lognrnd(log(Cp^2/sqrt((variability*Cp)^2+Cp^2)),sqrt(log((variability*Cp)^2/(Cp^2)+1)),[p,q]);
                    Cm_temp=lognrnd(log(Cm^2/sqrt((variability*Cp)^2+Cm^2)),sqrt(log((variability*Cp)^2/(Cm^2)+1)),[p,q]);
                    param.C.p{k}=Cp_temp;
                    param.C.m{k}=Cm_temp;
                else
                    param.C.p{k}=ones([p,q])*Cp;
                    param.C.m{k}=ones([p,q])*Cm;
                end
                
                if (param.var_Gmax_bool)
                    Gmax_temp=normrnd(G_max,variability_Gmax*G_max,[p,q]);
                    Gmax_temp(Gmax_temp<0)=0;
                else
                    Gmax_temp=G_max.*ones([p,q]);
                end
                param.G_max{k}=Gmax_temp;
                param.G_min{k}=G_min.*ones([p,q]);
                inc=inc+1;
            end
            
            if (bool_flip)
                model.n{end}=transpose(model.n{end});
                model.p{end}=transpose(model.p{end});
                model.m{end}=transpose(model.m{end});
                param.dt.p{end}=transpose(param.dt.p{end});
                param.dt.m{end}=transpose(param.dt.m{end});
                param.dt_max{end}=transpose(param.dt_max{end});
                param.dt_min{end}=transpose(param.dt_min{end});
                param.C.p{end}=transpose(param.C.p{end});
                param.C.m{end}=transpose(param.C.m{end});
                param.G_max{end}=transpose(param.G_max{end});
                param.G_min{end}=transpose(param.G_min{end});
                momentum{end}=transpose(momentum{end});
            end
            
            param.to_mem=to_mem;
            varargout{1}=model;
            varargout{2}=momentum;
            varargout{3}=param;
        end
        
    case 'result'%error array
        n=varargin{2};
        error.train=zeros([1,n]);
        error.test=zeros([1,n]);
        varargout{1}=error;
        
    case 'stat'%object collecting statistics during learning
        model=varargin{1};
        n=varargin{2};
        param=varargin{3};
        
        for k=1:length(model.n)
            stat.w.n.mean{k}=zeros(1,n);
            stat.w.n.mean{k}(1)=...
                mean(reshape(model.n{k},[1,size(model.n{k},1)*size(model.n{k},2)]));
            stat.w.n.sd{k}=zeros(1,n);
            stat.w.n.sd{k}(1)=...
                std(reshape(model.n{k},[1,size(model.n{k},1)*size(model.n{k},2)]));
            stat.w.n.final{k}=model.n{k};
            stat.delta_w.n.mean{k}=zeros(1,n);
            stat.delta_w.n.sd{k}=zeros(1,n);
            stat.delta_w.n.final{k}=zeros(size(model.n{k}));
            stat.nb_updates{k}=zeros(1,n);
        end
        
        if (~isfield(stat.w,'ini'))
            for k=1:length(model.n)
                stat.w.n.ini{k}=model.ini.n{k};
            end
        end
        
        if (~isempty(param.to_mem))
            for k=param.to_mem
                stat.w.p.mean{k}=zeros(1,n);
                stat.w.p.mean{k}(1)=mean(reshape(model.p{k},[1,size(model.p{k},1)*size(model.p{k},2)]));
                stat.w.p.sd{k}=zeros(1,n);
                stat.w.p.sd{k}(1)=std(reshape(model.p{k},[1,size(model.p{k},1)*size(model.p{k},2)]));
                stat.w.p.final{k}=model.p{k};
                stat.w.m.mean{k}=zeros(1,n);
                stat.w.m.mean{k}(1)=mean(reshape(model.m{k},[1,size(model.m{k},1)*size(model.m{k},2)]));
                stat.w.m.sd{k}=zeros(1,n);
                stat.w.m.sd{k}(1)=std(reshape(model.m{k},[1,size(model.m{k},1)*size(model.m{k},2)]));
                stat.w.m.final{k}=model.m{k};
                stat.delta_w.p.mean{k}=zeros(1,n);
                stat.delta_w.p.sd{k}=zeros(1,n);
                stat.delta_w.p.final{k}=zeros(size(model.p{k}));
                stat.delta_w.m.mean{k}=zeros(1,n);
                stat.delta_w.m.sd{k}=zeros(1,n);
                stat.delta_w.m.final{k}=zeros(size(model.m{k}));
                stat.dt.p.mean{k}=ones(1,n)*mean(reshape(param.dt.p{k},[1,size(param.dt.p{k},1)*size(param.dt.p{k},2)]));
                stat.dt.p.sd{k}=zeros(1,n);
                stat.dt.m.mean{k}=ones(1,n)*mean(reshape(param.dt.m{k},[1,size(param.dt.m{k},1)*size(param.dt.m{k},2)]));
                stat.dt.m.sd{k}=zeros(1,n);
            end
        end
        varargout{1}=stat;
        
end