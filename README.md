# Optimized Health Index Construction

This repository contains parts of code for the publication "
Health Index Construction with Feature Fusion Optimization for Predictive Maintenance
of Physical Systems" by _Venkat Nemani, Austin Bray, Adam Thelen, Chao Hu, Steve Daining_ submitted to **Structural and Multidiciplinary Optimization** (SMO) special issue on _Advanced Optimization Enabling Digital Twin Technology_. (currently in print as of Oct 15 2022)

We use two publicly available datasets
 - XJTU-SY bearing run-to-failure dataset 
[Biao Wang et al. “A Hybrid Prognostics Approach for Estimating Remaining Useful Life of Rolling Element Bearings”, IEEE Transactions on Reliability](https://ieeexplore.ieee.org/document/8576668)
- IEEE PHM 2012 bearing run-to-failure dataset [Nectoux, Patrick, et al. "PRONOSTIA: An experimental platform for bearings accelerated degradation tests." IEEE International Conference on Prognostics and Health Management, PHM'12.. IEEE Catalog Number: CPF12PHM-CDR, 2012.](https://hal.archives-ouvertes.fr/hal-00719503/)

The XJTU data repositories can be downloaded at: https://data.mendeley.com/datasets/mpn45f4gxc/1 and placed in the `Raw_Data` Folder
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
- `get_features_acc_Guo.m` - To extract features for Guo1 model  
- `get_features_acc.m` - To extract features in accleration domain  
- `get_features_vel.m` - To extract features in velocity domain  
- `concatenate_features.m` - To concatenate features in acceleration and velocity domains. This gives a final feature list.  

### Bearing_Features_Extract:
- `paper_HI_construct_Guo1.m` - To construct HI using Guo1 model and Guo-proposed features
- `paper_HI_construct_Guo2.m` - To construct HI using Guo2 model on final feature set
- `paper_HI_construct_Liu1.m` - To construct HI using Liu1 model on final feature set (multiple objectives)
- `paper_HI_construct_Liu2.m` - To construct HI using Liu2 model on final feature set (single objective)
- `paper_HI_construct_Chen.m` - To construct HI using Chen model on final feature set (single objective)
#### Function files
- `get_metrics.m` - To obtain pearson correlation, proposed monotonicity etc. 
- `get_metaprobability.m` - To obtain the proposed meta probability metric
- `get_snr.m` - To obtain the modified signal-to-noise ratio as proposed in Liu2 model
- `get_modified_monotonicity.m` - To obtain the proposed modified monotonicity
- `get_liumetrics.m` - To get the objectives for Liu1 model
- `lhsdesignbnd.m` - To generate LHS samples ([source](https://github.com/rikblok/matlab-lhsdesigncon)) 



NOTE: Please contact Venkat Nemani (nemani1401@gmail.com) or Chao Hu (huchaostu@gmail.com) for any queries.
