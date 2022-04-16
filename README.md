# Cortisol-and-ACE-Project
Summary:

The goal of this project was to understand the relationship between adverse childhood experiences and cortisol (a stress-related hormone) over time. To sufficiently capture the natural daily rhythm of cortisol, measures were obtained multiple times daily for each individual. Therefore, these data are longitudinal, and statistical methods for nonlinear longitudinal data were applied. The results of the analysis showed that adverse childhood experiences predict dysregulated daily cortisol rhythms. 

Application of Results:

Dysregulated daily corisol rhythms have been linked to a variety of poor health outcomes (e.g., inflammation, heart disease, depression/anxiety). The implications of these findings is that adverse childhood experiences put individuals at greater risk of poor health outcome via chronically high exposure to the stress-related hormone cortisol. 

Details of the Analysis:

The SAS "file prep cortisol and ACE data for MI.sas" stored above merges MIDUS datasets, creates variables, applies exclusion criteria for problematic cortisol values, and prepares the data for analysis.

Missing values of the variable adverse childhood experiences resulted in a significant loss of data. Therefore, a data augmentation method, called multiple imputation, was performed using the R package "mice" (see the file "CorACE_imputation.R"). 


HERE!!


The Cort_ACE_Model.sas file is one of 2 SAS scripts for fitting models to the imputed datasets on a UNIX server. 

The Cort_ACE_Plots.sas file uses SAS to create visuals of the data based on the model results.    

The Powerpoint file provides a summary of the project.




Application of Results:

The implication of these findings is that positivity increases engagement. If a platform were interested in increasing engagement, they may wish to build an algorithm that promotes positively sentimented content.

Details of the Analysis:

Python was used to access YouTube's API to scrape YouTube video comments and the number of "likes" a comment received. Python was also used to access IBM Watson's Natural Language Understanding tool, which analyzed each comment for sentiment. Both Python scripts are stored above.

SAS was used to fit the statistical model of interest, and the SAS script is stored above.

A Powerpoint file summarizes the project and is stored above.
