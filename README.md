# Cortisol-and-ACE-Project
Summary:
The goal of this project was to understand the relationship between adverse childhood experiences and cortisol (a stress-related hormone) over time. To sufficiently capture the natural daily rhythm of cortisol, measures were obtained multiple times daily for each individual. Therefore, these data are longitudinal, and statistical methods for longitudinal data were applied. The results of the analysis showed that adverse childhood experiences...







Cortisol, a stress-related hormone, has a daily rhythm that is best-identified through multiple daily measures. 

The prep cortisol and ACE data for MI.sas file merges MIDUS datasets, creates variables, applies exclusion criteria for problematic cortisol values, and preps the data for multiple imputation.

The CorACE_imputation.R file performs multilevel multiple imputation using the R package "mice".

The Cort_ACE_Model.sas file is one of 2 SAS scripts for fitting models to the imputed datasets on a UNIX server. 

The Cort_ACE_Plots.sas file uses SAS to create visuals of the data based on the model results.    

The Powerpoint file provides a summary of the project.




Summary:

The goal of this project was to understand the relationship between the sentiment of YouTube video comments and the number of "likes" a comment receives. Comments and each comment's number of "likes" were scraped from YouTube and comments were analyzed for sentiment. The results of the analysis showed that the more positively sentimented a comment was, the more "likes" a comment received.

Application of Results:

The implication of these findings is that positivity increases engagement. If a platform were interested in increasing engagement, they may wish to build an algorithm that promotes positively sentimented content.

Details of the Analysis:

Python was used to access YouTube's API to scrape YouTube video comments and the number of "likes" a comment received. Python was also used to access IBM Watson's Natural Language Understanding tool, which analyzed each comment for sentiment. Both Python scripts are stored above.

SAS was used to fit the statistical model of interest, and the SAS script is stored above.

A Powerpoint file summarizes the project and is stored above.
