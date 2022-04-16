# Adverse Childhood Experiences and Cortisol
## Summary:

The goal of this project was to understand the relationship between adverse childhood experiences and cortisol (a stress-related hormone) over time. To sufficiently capture the natural daily rhythm of cortisol, measures were obtained multiple times daily for each individual. See the figure below for a visual of cortisol's typical daily rhythm. 

<img width="484" alt="Screen Shot 2022-04-16 at 1 59 14 PM" src="https://user-images.githubusercontent.com/39779853/163689663-db01809c-e5ce-4b56-b454-f89481932d81.png">

These data are longitudinal and follow a nonlinear trajectoy. As such, statistical methods for nonlinear longitudinal data were applied. The results demonstrated that adverse childhood experiences predict dysregulation of daily cortisol rhythms. 

## Application of Results:

Dysregulated daily corisol rhythms have been linked to a variety of poor health outcomes (e.g., inflammation, heart disease). See the figure below, which demonstrates daily cortisol rhythms for a sample of individuals across four consequtive days. As the figure demonstrates, some indivdiuals deviate significantly from a typical daily cortisol rhythm.

<img width="474" alt="Screen Shot 2022-04-16 at 2 02 21 PM" src="https://user-images.githubusercontent.com/39779853/163689739-3405ce7e-4005-4cee-9a60-2beaea0dada2.png">

The implications of these findings is that adverse childhood experiences put individuals at greater risk of poor health outcome via chronic high exposure to the stress-related hormone cortisol. 

## Details of the Analysis:

* The SAS file "prep cortisol and ACE data for MI.sas" stored above merges datasets, creates variables, applies exclusion criteria for problematic cortisol values, and prepares the data for analysis.

* The statistical model of interest removes individuals with missing adverse childhood experience measures by default, resulting in a significant loss of data. We applied a statistical method which allowed the model to retain these individuals. The R file "CorACE_imputation.R" was used to augment the data and is stored above.

* Multiple statistical models of interest were fit to the augmented data using SAS. To decrease computation time, these SAS scripts were run in parallel on a UNIX server. The file "Cort_ACE_Model.sas" is an example of one such script and is stored above.

* The "Cort_ACE_Plots.sas" file uses SAS to create visuals of the data based on the model results.    

* A Powerpoint file summarizes the project and is stored above.
