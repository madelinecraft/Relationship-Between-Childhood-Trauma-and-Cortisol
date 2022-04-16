# Adverse Childhood Experiences and Cortisol
Summary:

The goal of this project was to understand the relationship between adverse childhood experiences and cortisol (a stress-related hormone) over time. To sufficiently capture the natural daily rhythm of cortisol, measures were obtained multiple times daily for each individual. Therefore, these data are longitudinal, and statistical methods for nonlinear longitudinal data were applied. The results demonstrated that adverse childhood experiences predict dysregulation of daily cortisol rhythms. 

Application of Results:

Dysregulated daily corisol rhythms have been linked to a variety of poor health outcomes (e.g., inflammation, heart disease). The implications of these findings is that adverse childhood experiences put individuals at greater risk of poor health outcome via chronic high exposure to the stress-related hormone cortisol. 

Details of the Analysis:

* The SAS file "prep cortisol and ACE data for MI.sas" stored above merges datasets, creates variables, applies exclusion criteria for problematic cortisol values, and prepares the data for analysis.

* The statistical model of interest removes individuals with missing adverse childhood experience measures by default, resulting in a significant loss of data. We applied a statistical method which allowed the model to retain these individuals. The R file "CorACE_imputation.R" was used to augment the data and is stored above.

* Multiple statistical models of interest were fit to the augmented data using SAS. To decrease computation time, these SAS scripts were run in parallel on a UNIX server. The file "Cort_ACE_Model.sas" is an example of one such script and is stored above.

* The "Cort_ACE_Plots.sas" file uses SAS to create visuals of the data based on the model results.    

* A Powerpoint file summarizes the project and is stored above.
