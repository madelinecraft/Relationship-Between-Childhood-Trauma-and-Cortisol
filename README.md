# Cortisol-and-ACE-Project
Summary:
The goal of this project was to understand the relationship between adverse childhood experiences and daily cortisol trajectories. 

The prep cortisol and ACE data for MI.sas file merges MIDUS datasets, creates variables, applies exclusion criteria for problematic cortisol values, and preps the data for multiple imputation.

The CorACE_imputation.R file performs multilevel multiple imputation using the R package "mice".

The Cort_ACE_Model.sas file is one of 2 SAS scripts for fitting models to the imputed datasets on a UNIX server. 

The Cort_ACE_Plots.sas file uses SAS to create visuals of the data based on the model results.    

The Powerpoint file provides a summary of the project.
