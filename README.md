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
- update_weight.m: function which updates weights. 
- grad_mem_p.m: function which implements conductance potentiation.
- grad_mem_m.m: function which implements conductance depression. 
- update_statistics: function which collects and updates the statistics collected throughout learning. 

