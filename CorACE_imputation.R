## Install and call necessary packages 
install.packages("micemd")
install.packages("mice")
install.packages("micemd")
install.packages("plyr")
install.packages("naniar")
install.packages("tidyr")
install.packages("dplyr")

library("micemd")
library("mice")
library("micemd")
library("plyr")
library("naniar")
library("tidyr")
library("dplyr")

## Read in data (mi_data2.csv is the results of a SAS script)
data <- read.csv("/Users/madelinecraft/Desktop/Cortisol Research/all_long_mi.csv")

# Count the number of individuals with cortisol measures (should be 1020)
dim(aggregate(data$logcortx, by=list(data$M2ID), FUN=length)) # 1020 individuals

## Data preparation
# Remove unnecessary variables (RaceWhite, m2_agg, m2, daily are constants) 
data <- subset(data, select = -c(X_TYPE_, X_FREQ_, RaceWhite, m2_agg, m1, daily, numstress, pmeancortwaketime, pmc_cortwt, 
                                 logcortx, day, CORTx, CORTtime, CORTpctime))

# Revalue depression variable
data$A1PDEPRE <- revalue(data$A1PDEPRE, c("(0) Lowest depression" = "1", "(7) Highest depression" = "7"))

# Treat depression as numeric
data$A1PDEPRE <- as.numeric(data$A1PDEPRE)

## Create derived variables 
# femXage
data$femXage <- data$fem*data$B1PAGE_M2

# ACE
data$ACE <- data$sexabuse+data$welfare+data$peducation+
  data$pdivorce+data$pdeath+data$pemoabuse+data$pphyabuse

## Sort data by M2ID and time for transposing
data <- data[with(data, order(M2ID, M2FAMNUM, t)),]

## Create a wide version of the data set (meanCORTx is the only time-varying variable necessary for imputation)
# Remove duplicate t by M2ID
data2 <- data %>% group_by(M2ID) %>% filter (! duplicated(t))

# Convert resulting tibble to dataframe
data2 <- as.data.frame(data2)
datawide <- spread(data2, key = t, value = meanCORTx) 

# Rename columns "1", "2", "3", and "4"
names(datawide)[names(datawide)=="1"] <- "meanCORTx1"
names(datawide)[names(datawide)=="2"] <- "meanCORTx2"
names(datawide)[names(datawide)=="3"] <- "meanCORTx3"
names(datawide)[names(datawide)=="4"] <- "meanCORTx4"

### Imputation 
## Visualize missing data
gg_miss_var(datawide) # ACE through sdCORTx have missing data

## Which variables are numeric?
str(datawide) # Logincome A1PDEPRE posaff negaff lifesat dailymeannumstressors sdCORTx meanCORTx1-4

## Examine distributions of all numeric variables
hist(datawide$sdCORTx)    # skewed, transformation helped
hist(datawide$meanCORTx1) # skewed, transformation helped
hist(datawide$meanCORTx2) # skewed, transformation helped
hist(datawide$meanCORTx3) # skewed, transformation helped
hist(datawide$meanCORTx4) # skewed, transformation helped
hist(datawide$lifesat)    # positively skewed, transformation helped 

hist(datawide$A1PDEPRE)              # skewed, transformations didn't help
hist(datawide$negaff)                # skewed, transformations didn't help 
hist(datawide$dailymeannumstressors) # skewed, transformations didn't help
hist(datawide$mhprofessional)        # skewed, transformations didn't help 

hist(datawide$posaff)            # normal 
hist(datawide$Logincome)         # non-normal (many zeros)

## Transform variables (if the transformation helps) and remove non-transformed versions
datawide$logsdCORTx <-log(datawide$sdCORTx)
datawide$logmeanCORTx1 <- log(datawide$meanCORTx1)
datawide$logmeanCORTx2 <- log(datawide$meanCORTx2)
datawide$logmeanCORTx3 <- log(datawide$meanCORTx3)
datawide$logmeanCORTx4 <- log(datawide$meanCORTx4)
datawide$sqlifesat <- (datawide$lifesat)^2
datawide <- subset(datawide, select = -c(sdCORTx, meanCORTx1:meanCORTx4, lifesat))

## Store data correctly for imputation
# Create vector of factor variables and make sure they're stored as factors
names <- c("sexabuse", "highschoolGED", "fouryrcollegeplus", "smoking", "Hispanic", "ownmeds", "dameds", "welfare", "peducation",
           "pdivorce", "pdeath", "pemoabuse", "pphyabuse", "fem", "medicationsX")
datawide[,names] <- lapply(datawide[,names], factor)

# Create vector of ordinal variables and make sure they're stored as ordinal
names2 <- c("anxiety", "ACE", "A1PDEPRE")
datawide[,names2] <- lapply(datawide[,names2], ordered)

## Obtain imputation method defaults
imp0 <- mice(datawide, maxit = 0) 
impmethod <- imp0$method 

## Assign imputation methods
impmethod[c("sexabuse", "ownmeds", "dameds", "welfare", "peducation", "pdivorce", "pdeath", "pemoabuse", "pphyabuse", "Hispanic", "highschoolGED", "fouryrcollegeplus", "smoking",
            "anxiety", "ACE", "A1PDEPRE",
            "mhprofessional",
            "Logincome", "posaff", "logmeanCORTx1", "logmeanCORTx2", "logmeanCORTx3", "logmeanCORTx4", "sqlifesat", "logsdCORTx",
            "negaff")] <- 
  c("logreg", "logreg", "logreg", "logreg", "logreg", "logreg", "logreg", "logreg", "logreg", "logreg", "logreg", "logreg", "logreg",
    "pmm", "pmm", "pmm",
    "pmm",
    "norm", "norm", "norm", "norm", "norm", "norm", "norm", "norm",
    "pmm") # Justification for pmm for skewed variables: https://stefvanbuuren.name/fimd/sec-nonnormal.html
           # Justification for pmm for count variables: https://stefvanbuuren.name/fimd/other-data-types.html 

## Create the predictor matrix
# Extract all variable names in dataset
allVars <- names(datawide)

# Create an object containing the names of variables with missingness
missVars <- names(datawide)[colSums(is.na(datawide)) > 0]

# Create a predictor matrix
predictorMatrix <- matrix(0, ncol = length(allVars), nrow = length(allVars))
rownames(predictorMatrix) <- allVars
colnames(predictorMatrix) <- allVars

# Specify variables informing imputation
imputerVars <- c("sexabuse", "highschoolGED", "fouryrcollegeplus", "smoking", "Hispanic", "Logincome", "A1PDEPRE", "posaff",
                 "negaff", "anxiety", "mhprofessional", "ownmeds", "dameds", "welfare", "peducation", "pdivorce", "pdeath", "pemoabuse",
                 "pphyabuse", "B1PAGE_M2", "fem", "medicationsX", "pmeancortwaketime", "dailymeannumstressors", "femXage", "logsdCORTx",
                 "logmeanCORTx1", "logmeanCORTx2", "logmeanCORTx3", "logmeanCORTx4", "sqlifesat", "ACE")

# Keep variables that actually exist in data set
imputerVars <- intersect(unique(imputerVars), allVars)

# Add 1's to imperMatrix for imputer variables
imputerMatrix <- predictorMatrix
imputerMatrix[,imputerVars] <- 1

# Specify variables with missingness to be imputed 
imputedVars <- intersect(imputerVars, missVars)
imputedMatrix <- predictorMatrix

# Add 1's to imputedMatrix for imputed variables
imputedMatrix[imputedVars,] <- 1

# Construct the predictor matrix (rows: imputed variables; cols: imputer variables)
predictorMatrix <- imputerMatrix * imputedMatrix

# Diagonals must be zeros (a variable cannot impute itself)
diag(predictorMatrix) <- 0 

# Don't allow the sum score (ACE) and its components to predict missing variables at the same time -- colinearity
predictorMatrix[, c("sexabuse", "welfare", "peducation", "pdivorce", "pdeath", "pemoabuse", "pphyabuse")] <- 0 

# Don't allow the sum score (ACE) to predict its components -- colinearity
predictorMatrix[c("sexabuse", "welfare", "peducation", "pdivorce", "pdeath", "pemoabuse", "pphyabuse"), "ACE"] <- 0 

# Allow the components to predict each other
predictorMatrix["sexabuse", c("welfare", "peducation", "pdivorce", "pdeath", "pemoabuse", "pphyabuse")] <- 1
predictorMatrix["welfare", c("sexabuse", "peducation", "pdivorce", "pdeath", "pemoabuse", "pphyabuse")] <- 1
predictorMatrix["peducation", c("sexabuse", "welfare", "pdivorce", "pdeath", "pemoabuse", "pphyabuse")] <- 1
predictorMatrix["pdivorce", c("sexabuse", "welfare", "peducation", "pdeath", "pemoabuse", "pphyabuse")] <- 1
predictorMatrix["pdeath", c("sexabuse", "welfare", "peducation", "pdivorce", "pemoabuse", "pphyabuse")] <- 1
predictorMatrix["pemoabuse", c("sexabuse", "welfare", "peducation", "pdivorce", "pdeath", "pphyabuse")] <- 1
predictorMatrix["pphyabuse", c("sexabuse", "welfare", "peducation", "pdivorce", "pdeath", "pemoabuse")] <- 1

# Allow the components to predict ACE 
predictorMatrix["ACE", c("sexabuse", "welfare", "peducation", "pdivorce", "pdeath", "pemoabuse", "pphyabuse")] <- 1

# Don't allow the interaction (femXage) and its components to predict missing variables at the same time -- colinearity
predictorMatrix[, c("fem", "B1PAGE_M2")] <- 0 

## Run multiple imputations
imp <- mice(datawide, m=20, predictorMatrix=predictorMatrix, 
            method=impmethod, maxit=5)

# Store imputed data 
mi_data <- complete(imp, action = "long")

# Check convergence
plot(imp, c("welfare", "sexabuse"))

# Check for missing data
gg_miss_var(mi_data)

## Prepare imputed data for analysis
# Subset variables of interest for analysis
mi_data$imp = mi_data$.imp
names = c("imp", ".id", "M2ID", "ACE")
mi_data2 <- mi_data[,names]

# Transpose ACE long to wide
mi_data3 <- mi_data2[with(mi_data2, order(M2ID, imp)),]
mi_datawide <- spread(mi_data3, key = imp, value = ACE)

# Merge with level 2 variables for analysis
data_analysis <- merge(mi_datawide, datawide7, by = "M2ID")

# Subset
data_analysis$id = data_analysis$.id
data_analysis$imp1 = data_analysis$`1`
data_analysis$imp2 = data_analysis$`2`
data_analysis$imp3 = data_analysis$`3`
data_analysis$imp4 = data_analysis$`4`
data_analysis$imp5 = data_analysis$`5`
data_analysis$imp6 = data_analysis$`6`
data_analysis$imp7 = data_analysis$`7`
data_analysis$imp8 = data_analysis$`8`
data_analysis$imp9 = data_analysis$`9`
data_analysis$imp10 = data_analysis$`10`
data_analysis$imp11 = data_analysis$`11`
data_analysis$imp12 = data_analysis$`12`
data_analysis$imp13 = data_analysis$`13`
data_analysis$imp14 = data_analysis$`14`
data_analysis$imp15 = data_analysis$`15`
data_analysis$imp16 = data_analysis$`16`
data_analysis$imp17 = data_analysis$`17`
data_analysis$imp18 = data_analysis$`18`
data_analysis$imp19 = data_analysis$`19`
data_analysis$imp20 = data_analysis$`20`
data_analysis <- subset(data_analysis, select = c(M2ID, imp1:imp20, M2FAMNUM, RaceWhite, Hispanic, B1PAGE_M2, fem, pmeancortwaketime,
                                                  dailymeannumstressors, smoking, medicationsX, highschoolGED, fouryrcollegeplus))

# Merge with level 1 variables for analysis
data <- subset(data, select = c(M2ID, M2FAMNUM, day, numstress, pmc_cortwt, t, CORTx, logcortx, CORTtime, CORTpctime))
analysis_long <- merge(data, data_analysis, by = c("M2ID", "M2FAMNUM"))

# Transpose to wide to long for imputation style file
analysis_long2 <- analysis_long %>% gather(imp, ACE, imp1:imp20)

# Prepare for analysis
analysis_long2$imp <- revalue(analysis_long2$imp, c("imp1" = "1", "imp2" = "2", "imp3" = "3", "imp4" = "4", "imp5" = "5", "imp6" = "6", "imp7" = "7", "imp8" = "8", "imp9" = "9", "imp10" = "10",
                                                    "imp11" = "11", "imp12" = "12", "imp13" = "13", "imp14" = "14", "imp15" = "15", "imp16" = "16", "imp17" = "17", "imp18" = "18", "imp19" = "19", "imp20" = "20"))
analysis_long2$imp <- as.numeric(analysis_long2$imp)
analysis_long2 <- analysis_long2[with(analysis_long2, order(M2ID, imp)),]

# Subset into two data sets with ten imputations each for running analyses in parallel on UNIX server
mi_data1 <- analysis_long2[ which(analysis_long2$imp < 11), ]
mi_data2 <- analysis_long2[ which(analysis_long2$imp > 10), ]

# Export imputed data
setwd("/Users/madelinecraft/Desktop/Cortisol Research")
write.table(x = mi_data1, file='mi_data1.txt', row.names = F, col.names = T)
write.table(x = mi_data2, file='mi_data2.txt', row.names = F, col.names = T)