# Robust Local Learning with Memristor-Based Restricted Boltzmann Machines
(Maxence Ernoult, Damien Querlioz, Julie Grollier)

The following repository contains:
- RESULTS_PAPER: the folder containing the data and figures appearing in the draft.
- main_RBM_soft.m: the main to execute a standard or memristive RBM topped by a softmax classifier.
- simu_mem_RBM_soft.m: the simulation script to investigate the effect of non-linearity, cycle-to-cycle variability and device-to-device variability on the performance of a memristive RBM topped by a softmax classifier on MNIST. 
- main_DRBM.m: the main to execute a standard or memristive Discriminative RBM.
- simu_mem_DRBM.m: the simulation script to investigate the effect of non-linearity, cycle-to-cycle variability and device-to-device variability on the performance of a memristive Discriminative RBM on MNIST. 
- main_DBN.m: the main to execute a standard or memristive Deep Belief Net of arbitrary depth. 
- simu_mem_DBN.m: the simulation script to investigate the effect of non-linearity, cycle-to-cycle variability and device-to-device variability on the performance of a memristive Deep Belief Net on MNIST. 
- tune_RBM_soft.m: the simulation script to tune a standard RBM topped by a softmax.
- tune_DRBM.m: the simulation script to tune a standard Discriminative RBM.
- tune_DBN.m: the simulation script to tune a standard Deep Belief Net.
- init.m: function to create weights, momentum and hyperparameters (including all the memristive hyperparameters).
- train.m: function executing training on an epoch accross mini-batches.
- gradient_RBM_soft.m: function which computes the gradient of a RBM topped by a softmax classifier. 
- gradient_DRBM.m: function which computes the gradient of a Discriminative RBM.
- gradient_RBM.m: function which computes the gradient of a RBM. 
- feed_next_RBM.m: function which passes features extracted from a RBM into the next RBM (when training a Deep Belief Net). 
- update_weight.m: function which updates weights. 
- grad_mem_p.m: function which implements conductance potentiation.
- grad_mem_m.m: function which implements conductance depression. 
- update_statistics.m: function which collects and updates the statistics collected throughout learning. 
- plot_statistics.m: function which plots the statistics collected throughout learning (weight statistics, weight increment statistics, pulse width, number of weight updates).

For the sake of explanation, files main_RBM_soft.m and simu_mem_RBM_soft.m have been further commented.

We want to highlight some precisions on the functions written:

- the main_X.m files are meant for quick testing, prototyping abd debugging along with the plot_statistics function which enables to track all quantities throughout learning. 

- the simu_X.m files are the scripts which generate statistically relevant results like those presented in the paper. 

- init.m: when defining a memristive model, one can partially "memristorize" the model: we can ask init to carry out standard gradient descent on some weights and memristor based gradient descent on other weights. The weights which are "memristorized" are specified in brackets (an example is provided below). For memristors, this function handles four possible imperfections: cycle-to-cycle variability ('var_dyn'), device-to-device variability ('var_space'), granularity ('gran'), and the variability of the maximal conductance ('var_Gmax'). One can arbitrarily select one or several of these imperfections in any order when calling the function. Finally, when defining a memristive model, the programming scheme for each "memristorized" weights has to be specified (i.e. either Cst or RProp). 

Example to memristorize weights 1 only, taking into account cycle-to-cycle variability and 8 bits granularity: 
[model_mem,momentum_mem,param]=init('model',{'gen','flip'},n_epochs,n_layer,lr,...
    G_max,G_ratio,beta,dt_max,dt_min,...
    'var_dyn',0.01,'gran',8,...
    [1],[dt_max/1000],{'Cst'});
    
- gradient_RBM_soft.m and gradient_RBM.m: one has to specify a 'type' that is either 'normal' or 'bin', respectively corresponding to taking real values or binary values for neurons respectively when computing the gradient. 

- gradient_DRBM2.m: one has to specify a 'type1' which is either 'normal' or 'bin' for the computation of the gradient as in gradient_RBM_soft.m. The argument 'n_iter_train' (following 'type1') is the number of parallel Gibbs chains which are used to compute the gradient (i.e. what is called #CD in the draft). The argument 'type2' correspond to the type of inference that is used as test time to compute error rates. If 'type2' is set to 'det', then the free-energy deterministic technique is used to compute error rates. If 'type2' is set to 'sto', then the stochastic sampling technique is used to compute error rates and the number of parallel Gibbs chains which are used at test time has to be specified in the varargin.

- feed_next_RBM.m: passes features from one RBM to another one. The features can either be real-valued ('normal') or binarized ('bin'). 

- grad_mem_p.m and grad_mem_m.m: these files fully specify the conductance update model used. 

- weight_update.m: the schemes 'Cst' and 'RProp' are defined in this function. 


