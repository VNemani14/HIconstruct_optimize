# Optimized Health Index Construction

This repository contains parts of code for the publication "
Structural and Multidisciplinary Optimization
Health Index Construction with Feature Fusion Optimization for Predictive Maintenance
of Physical Systems" by Venkat Nemani, Austin Bray, Adam Thelen, Chao Hu, Steve Daining submitted to **Structural and Multidiciplinary Optimization** (SMO) special issue on _Advanced Optimization Enabling Digital Twin Technology_. 

We use two publicly available datasets
 - XJTU-SY bearing run-to-failure dataset 
[Biao Wang et al. “A Hybrid Prognostics Approach for Estimating Remaining Useful Life of Rolling Element Bearings”, IEEE Transactions on Reliability](https://ieeexplore.ieee.org/document/8576668)
- IEEE PHM 2012 bearing run-to-failure dataset [Nectoux, Patrick, et al. "PRONOSTIA: An experimental platform for bearings accelerated degradation tests." IEEE International Conference on Prognostics and Health Management, PHM'12.. IEEE Catalog Number: CPF12PHM-CDR, 2012.](https://hal.archives-ouvertes.fr/hal-00719503/)

The XJTU data repositories can be downloaded at: https://data.mendeley.com//datasets/mpn45f4gxc/1 and placed in the `Raw_Data` Folder
- `originaldata` contains the vibration data in .mat files. These are obtained from the original XJTU-SY Dataset with csv files: https://github.com/WangBiaoXJTU/xjtu-sy-bearing-datasets
- `processeddata` contains vibration data processed into velocity domain

## Models for Comparison
- Guo1/Guo2: [Guo, Liang, et al. "A recurrent neural network based health indicator for remaining useful life prediction of bearings." Neurocomputing 240 (2017): 98-109.](https://doi.org/10.1016/j.neucom.2017.02.045) with difference in feature set.
- Liu1: [Liu, Kaibo, and Shuai Huang. "Integration of data fusion methodology and degradation modeling process to improve prognostics." IEEE Transactions on Automation Science and Engineering 13.1 (2014): 344-354.](https://ieeexplore.ieee.org/document/6902828)
- Liu2: [Liu, Kaibo, Abdallah Chehade, and Changyue Song. "Optimize the signal quality of the composite health index via data fusion for degradation modeling and prognostic analysis." IEEE Transactions on Automation Science and Engineering 14.3 (2015): 1504-1514.](https://ieeexplore.ieee.org/document/7165684)
- Chen: [Chen, Zhen, et al. "A Health Index Construction Framework for Prognostics Based on Feature Fusion and Constrained Optimization." IEEE Transactions on Instrumentation and Measurement 70 (2021): 1-15.](https://ieeexplore.ieee.org/document/9512068)  
- Our method: Code not provided due to restrictions from funding agency. 

Summary of the various methods
![image](https://user-images.githubusercontent.com/94071944/174451865-f68933ec-ae7f-4b28-a59d-2329f5434ff6.png)

## Code Description
### Bearing_Features_Extract:
`get_features_acc_Guo.m` - To extract features for the Guo1 model  
`get_features_acc.m` - To extract features in the accleration domain  
`get_features_vel.m` - To extract features in the velocity domain  
`concatenate_features.m` - To concatenate features in acceleration and velocity domain. This gives a final feature list. 


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
