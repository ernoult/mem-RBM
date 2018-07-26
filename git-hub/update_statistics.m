%% UPDATING STATISTICS THROUGHOUT LEARNING
%(Maxence Ernoult, 25/07/2018)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stat=update_statistics(stat,stat_temp,range,param)
    I=length(stat.w.n.mean);
    switch length(range)<2
        case 0
            for ind=1:I
                stat.w.n.mean{ind}(range)=stat_temp.w.n.mean{ind};
                stat.w.n.sd{ind}(range)=stat_temp.w.n.sd{ind};
                stat.delta_w.n.mean{ind}(range)=stat_temp.delta_w.n.mean{ind};
                stat.delta_w.n.sd{ind}(range)=stat_temp.delta_w.n.sd{ind};
                stat.w.n.final{ind}=stat_temp.w.n.final{ind};
                stat.delta_w.n.final{ind}=stat_temp.delta_w.n.final{ind};
                stat.nb_updates{ind}(range)=stat_temp.nb_updates{ind};
            end

            if (isfield(param,'G_max'))
                for ind=1:I
                    stat.w.p.mean{ind}(range)=stat_temp.w.p.mean{ind};
                    stat.w.m.mean{ind}(range)=stat_temp.w.m.mean{ind};
                    stat.w.p.sd{ind}(range)=stat_temp.w.p.sd{ind};
                    stat.w.m.sd{ind}(range)=stat_temp.w.m.sd{ind};
                    stat.delta_w.p.mean{ind}(range)=stat_temp.delta_w.p.mean{ind};
                    stat.delta_w.m.sd{ind}(range)=stat_temp.delta_w.m.sd{ind};
                    stat.w.p.final{ind}=stat_temp.w.p.final{ind};
                    stat.w.m.final{ind}=stat_temp.w.m.final{ind};
                    stat.delta_w.p.final{ind}=stat_temp.delta_w.p.final{ind};
                    stat.delta_w.m.final{ind}=stat_temp.delta_w.m.final{ind};
                    stat.dt.p.mean{ind}(range)=stat_temp.dt.p.mean{ind};
                    stat.dt.m.mean{ind}(range)=stat_temp.dt.m.mean{ind};
                    stat.dt.p.sd{ind}(range)=stat_temp.dt.p.sd{ind};
                    stat.dt.m.sd{ind}(range)=stat_temp.dt.m.sd{ind};
                end
            end

        case 1
            for ind=1:I
                stat.w.n.mean{ind}(range)=mean(reshape(stat_temp.w.n{ind},...
                    [1,size(stat_temp.w.n{ind},1)*size(stat_temp.w.n{ind},2)]));
                stat.w.n.sd{ind}(range)=std(reshape(stat_temp.w.n{ind},...
                    [1,size(stat_temp.w.n{ind},1)*size(stat_temp.w.n{ind},2)]));
                stat.delta_w.n.mean{ind}(range)=mean(reshape(stat_temp.delta_w.n{ind},...
                    [1,size(stat_temp.delta_w.n{ind},1)*size(stat_temp.delta_w.n{ind},2)]));
                stat.delta_w.n.sd{ind}(range)=std(reshape(stat_temp.delta_w.n{ind},...
                    [1,size(stat_temp.delta_w.n{ind},1)*size(stat_temp.delta_w.n{ind},2)]));
                stat.w.n.final{ind}=stat_temp.w.n{ind};
                stat.delta_w.n.final{ind}=stat_temp.delta_w.n{ind};
                stat.nb_updates{ind}(range)=stat_temp.nb_updates{ind};
            end

            if (isfield(param,'G_max'))
                for ind=1:I
                    stat.w.p.mean{ind}(range)=mean(reshape(stat_temp.w.p{ind},...
                        [1,size(stat_temp.w.p{ind},1)*size(stat_temp.w.p{ind},2)]));
                    stat.w.m.mean{ind}(range)=mean(reshape(stat_temp.w.m{ind},...
                        [1,size(stat_temp.w.m{ind},1)*size(stat_temp.w.m{ind},2)]));
                    stat.w.p.sd{ind}(range)=std(reshape(stat_temp.w.p{ind},...
                        [1,size(stat_temp.w.p{ind},1)*size(stat_temp.w.p{ind},2)]));
                    stat.w.m.sd{ind}(range)=std(reshape(stat_temp.w.m{ind},...
                        [1,size(stat_temp.w.m{ind},1)*size(stat_temp.w.m{ind},2)]));
                    stat.delta_w.p.mean{ind}(range)=mean(reshape(stat_temp.delta_w.p{ind},...
                        [1,size(stat_temp.w.p{ind},1)*size(stat_temp.w.p{ind},2)]));
                    stat.delta_w.m.mean{ind}(range)=mean(reshape(stat_temp.delta_w.m{ind},...
                        [1,size(stat_temp.w.m{ind},1)*size(stat_temp.w.m{ind},2)]));
                    stat.delta_w.p.sd{ind}(range)=std(reshape(stat_temp.delta_w.p{ind},...
                        [1,size(stat_temp.w.p{ind},1)*size(stat_temp.w.p{ind},2)]));
                    stat.delta_w.m.sd{ind}(range)=std(reshape(stat_temp.delta_w.m{ind},...
                        [1,size(stat_temp.w.m{ind},1)*size(stat_temp.w.m{ind},2)]));
                    stat.w.p.final{ind}=stat_temp.w.p{ind};
                    stat.w.m.final{ind}=stat_temp.w.m{ind};
                    stat.delta_w.p.final{ind}=stat_temp.delta_w.p{ind};
                    stat.delta_w.m.final{ind}=stat_temp.delta_w.m{ind};
                    stat.dt.p.mean{ind}(range)=mean(reshape(param.dt.p{ind},...
                        [1,size(param.dt.p{ind},1)*size(param.dt.p{ind},2)]));
                    stat.dt.m.mean{ind}(range)=mean(reshape(param.dt.m{ind},...
                        [1,size(param.dt.m{ind},1)*size(param.dt.m{ind},2)]));
                    stat.dt.p.sd{ind}(range)=std(reshape(param.dt.p{ind},...
                        [1,size(param.dt.p{ind},1)*size(param.dt.p{ind},2)]));
                    stat.dt.m.sd{ind}(range)=std(reshape(param.dt.m{ind},...
                        [1,size(param.dt.m{ind},1)*size(param.dt.m{ind},2)]));
                end
            end

    end
end