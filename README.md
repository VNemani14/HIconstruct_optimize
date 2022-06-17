# HIconstruct_optimize

This repository contains parts of code for the publication "NAME HERE" by Nemani et al. in Structural and Multidiciplinary Optimization. 

We use publically available XJTU-SY bearing run to failure dataset Biao Wang et al. “A Hybrid Prognostics Approach for Estimating Remaining Useful Life of Rolling Element Bearings”, IEEE Transactions on Reliability and IEEE 2012 Bearing Prognostics Challenge run to failure data set available at FINISH. 

Brief description of the provided code:

concatenate_features.m: Concatenates acc features extracted in get_features code. Creates "PaperFeaturesFinal..." output. 

get_features_acc.m: Extracts features from raw vibration data and outputs into .mat file. 

get_features_acc_LGUO.m: Extracts features from raw vibration data required for XXX method.  

get_features_vel.m: Extracts velocity features from raw vibration data. 

get_metrics.m: This is a function used by other scripts to calculate monotonicity, pearson correlation and spearman corrrelation.

get_mod_monotonicity.m: This is a function that calculates the modified definition of monotonicity within other scripts. 

lhsdesignbnd.m: This function generates a NxP latin hypercube sample with bounds for other scripts. 

paper_evaluateLIU_1.m: This method (Liu1) is based on the paper "Integration of Data Fusion Methodology and Degradation Modeling Process to Improve Prognostics" by Kaibo Liu. 

paper_evaluateLIU_2_LHS.m This method (Liu2) is also based on the paper "Integration of Data Fusion Methodology and Degradation Modeling Process to Improve Prognostics by Kaibo Liu. 

paper_evaluateYGLEE1.m: This method (Guo1) is based on the paper "A recurrent neural network based health indicator for remaining useful life prediction of bearings" by L. Guo et al. 

paper_evaluateYGLEE2.m: This method (Guo2) is based on the paper "A recurrent neural network based health indicator for remaining useful life prediction of bearings" by L. Guo et al. 

paper_evaluate_CHEN_lhs.m: This method (Chen) is based on the paper "A Health Index Construction Framework for Prognostics Based on Feature Fusion and Constrained Optimization".

paper_evaluate_RMS.m: This uses a root mean square method to calculate the health index. 




NOTE: Please contact Prof. Chao Hu, chaohu@iastate.edu or huchaostu@gmail.com, for any questions.
