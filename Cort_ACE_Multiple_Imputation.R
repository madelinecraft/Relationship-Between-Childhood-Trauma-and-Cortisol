install.packages("micemd")
library("mice")
library("micemd")
library("plyr")
library("naniar")
library("tidyr")

# read in data
data <- read.csv("/Users/madelinecraft/Desktop/Cortisol Research/mi_data2.csv")

# data cleaning
#data <- subset(data, select = -c(M2FAMNUM, numstress, pmc_cortwt, CORTx, logcortx, CORTtime, CORTpctime, X_TYPE_, X_FREQ_))
data <- subset(data, select = -c(X_TYPE_, X_FREQ_))
data$A1PDEPRE <- revalue(data$A1PDEPRE, c("(0) Lowest depression" = "1", "(7) Highest depression" = "7"))
data$A1PDEPRE <- as.numeric(data$A1PDEPRE)
data$femXage <- data$fem*data$B1PAGE_M2

# transpose meanCORTx long to wide
data <- data[
  with(data, order(M2ID, t)),
  ]
#sum(is.na(data$meanCORTx))

datawide <- spread(data, key = t, value = meanCORTx)
#sum(is.na(datawide$`1`))

meanCORTx1 <- aggregate(datawide[, "1"], list(datawide$M2ID), mean, na.rm = T)
names(meanCORTx1)[names(meanCORTx1) == "Group.1"] <- "M2ID"
names(meanCORTx1)[names(meanCORTx1) == "x"] <- "meanCORTx1"

meanCORTx2 <- aggregate(datawide[, "2"], list(datawide$M2ID), mean, na.rm = T)
names(meanCORTx2)[names(meanCORTx2) == "Group.1"] <- "M2ID"
names(meanCORTx2)[names(meanCORTx2) == "x"] <- "meanCORTx2"

meanCORTx3 <- aggregate(datawide[, "3"], list(datawide$M2ID), mean, na.rm = T)
names(meanCORTx3)[names(meanCORTx3) == "Group.1"] <- "M2ID"
names(meanCORTx3)[names(meanCORTx3) == "x"] <- "meanCORTx3"

meanCORTx4 <- aggregate(datawide[, "4"], list(datawide$M2ID), mean, na.rm = T)
names(meanCORTx4)[names(meanCORTx4) == "Group.1"] <- "M2ID"
names(meanCORTx4)[names(meanCORTx4) == "x"] <- "meanCORTx4"

datawide2 <- merge(datawide, meanCORTx1, by = "M2ID")
datawide3 <- merge(datawide2, meanCORTx2, by = "M2ID")
datawide4 <- merge(datawide3, meanCORTx3, by = "M2ID")
datawide5 <- merge(datawide4, meanCORTx4, by = "M2ID")

datawide6 <- subset(datawide5, select = -c(`1`, `2`, `3`, `4`))

datawide7 = datawide6[order(datawide6[,'M2ID'],-datawide6[,'sexabuse']),]
datawide7 = datawide7[!duplicated(datawide7$M2ID),]

#datawide7$M2ID <- NULL

# examine distributions of all numeric variables
par(mfrow = c(1,1))
hist(datawide7$sdCORTx) #skewed, transformation helped
hist(datawide7$meanCORTx1) #skewed, transformation helped
hist(datawide7$meanCORTx2) #skewed, transformation helped
hist(datawide7$meanCORTx3) #skewed, transformation helped
hist(datawide7$meanCORTx4) #skewed, transformation helped
hist(datawide7$lifesat) #positively skewed, transformation helped (has missing data, use norm imputation)

hist(datawide7$A1PDEPRE) #skewed, transformations didn't help
hist(datawide7$negaff) #skewed, transformations didn't help (has missing data, use pmm imputation)
hist(datawide7$dailymeannumstressors) #skewed, transformations didn't help

hist(datawide7$posaff) #normal (has missing data, use norm imputation)
hist(datawide7$pmeancortwaketime) #normal

# transform negatively skewed variables (if the transformation helps) and remove nontransformed variable
datawide7$logsdCORTx <-log(datawide7$sdCORTx)
datawide7$logmeanCORTx1 <- log(datawide7$meanCORTx1)
datawide7$logmeanCORTx2 <- log(datawide7$meanCORTx2)
datawide7$logmeanCORTx3 <- log(datawide7$meanCORTx3)
datawide7$logmeanCORTx4 <- log(datawide7$meanCORTx4)
#datawide7 <- subset(datawide7, select = -c(day, sdCORTx, meanCORTx1:meanCORTx4))
datawide7 <- subset(datawide7, select = -c(sdCORTx, meanCORTx1:meanCORTx4))

# transform positively skewed variable and remove nontransformed variable
datawide7$sqlifesat <- (datawide7$lifesat)^2
datawide7$lifesat <- NULL

### imputation 
names(datawide7)
# "sexabuse", "highschoolGED", "fouryrcollegeplus", "RaceWhite", "smoking", "Hispanic", "Logincome", "A1PDEPRE", 
# "posaff", "negaff", "anxiety", "mhprofessional", "ownmeds", "dameds", "welfare", "peducation", "pdivorce", "pdeath", 
# "pemoabuse", "pphyabuse", "B1PAGE_M2", "fem", "medicationsX", "pmeancortwaketime", "dailymeannumstressors",  
# "femXage", "logsdCORTx", "logmeanCORTx1",, "logmeanCORTx2", "logmeanCORTx3", "logmeanCORTx4" "sqlifesat"

# visualize missing data
gg_miss_var(datawide7) # anxiety is the last variable with missing data

## settings
imp0 <- mice(datawide7, maxit = 0) # setup run of mice()
impmethod <- imp0$method # default method
# determine imputation method for each variable
# justification for pmm for skewed variables: https://stefvanbuuren.name/fimd/sec-nonnormal.html
# justification for pmm for count variables: https://stefvanbuuren.name/fimd/other-data-types.html 
str(datawide7) 
  # binary: sexabuse, RaceWhite, ownmeds, dameds, welfare, peducation, pdivorce, pdeath, pemoabuse, pphyabuse LOGREG
  # ordinal: anxiety POLR
  # count: mhprofessional (high proportion of zeros) PMM
  # normal: Logincome, posaff, logsdCORTx, logmeanCORTx1-logmeanCORTx4, sqlifesat NORM
  # skewed: negaff  PMM
names <- c("sexabuse", "RaceWhite", "ownmeds", "dameds", "welfare", "peducation", "pdivorce", "pdeath", "pemoabuse", "pphyabuse") 
datawide7[,names] <- lapply(datawide7[,names], factor)
datawide7$anxiety <- ordered(datawide7$anxiety)
impmethod[c("sexabuse", "RaceWhite", "ownmeds", "dameds", "welfare", "peducation", "pdivorce", "pdeath", "pemoabuse", "pphyabuse",
            "anxiety",
            "mhprofessional",
            "Logincome", "posaff", "logmeanCORTx1", "logmeanCORTx2", "logmeanCORTx3", "logmeanCORTx4", "sqlifesat",
            "negaff")] <- 
  c("logreg", "logreg", "logreg", "logreg", "logreg", "logreg", "logreg", "logreg", "logreg", "logreg",
    "polr",
    "pmm",
    "norm", "norm", "norm", "norm", "norm", "norm", "norm", 
    "pmm")
# extract all variable names in dataset
allVars <- names(datawide7)
# names of variables with missingness
missVars <- names(datawide7)[colSums(is.na(datawide7)) > 0]
# mice predictorMatrix
predictorMatrix <- matrix(0, ncol = length(allVars), nrow = length(allVars))
rownames(predictorMatrix) <- allVars
colnames(predictorMatrix) <- allVars
# specify variables informing imputation
imputerVars <- c("sexabuse", "highschoolGED", "fouryrcollegeplus", "RaceWhite", "smoking", "Hispanic", "Logincome", "A1PDEPRE", "posaff",
                 "negaff", "anxiety", "mhprofessional", "ownmeds", "dameds", "welfare", "peducation", "pdivorce", "pdeath", "pemoabuse",
                 "pphyabuse", "B1PAGE_M2", "fem", "medicationsX", "pmeancortwaketime", "dailymeannumstressors", "femXage", "logsdCORTx",
                 "logmeanCORTx1", "logmeanCORTx2", "logmeanCORTx3", "logmeanCORTx4", "sqlifesat")
# keep variables that actually exist in dataset
imputerVars <- intersect(unique(imputerVars), allVars)
imputerVars
imputerMatrix <- predictorMatrix
imputerMatrix[,imputerVars] <- 1
imputerMatrix
# specify variables with missingness to be imputed 
imputedVars <- intersect(imputerVars, missVars)
imputedVars
imputedMatrix <- predictorMatrix
imputedMatrix[imputedVars,] <- 1
imputedMatrix
# construct a full predictor matrix (rows: imputed variables; cols: imputer variables)
predictorMatrix <- imputerMatrix * imputedMatrix
# diagonals must be zeros (a variable cannot impute itself)
diag(predictorMatrix) <- 0
predictorMatrix 

## run multiple imputations
imp <- mice(datawide7, m=20, predictorMatrix=predictorMatrix, 
            method=impmethod, maxit=10)

# store imputed data 
mi_data <- complete(imp, action = "long")
gg_miss_var(mi_data)

# create ACE score
mi_data[,"sexabuse"] <- as.numeric(as.character(mi_data[,"sexabuse"]))
mi_data[,"welfare"] <- as.numeric(as.character(mi_data[,"welfare"]))
mi_data[,"peducation"] <- as.numeric(as.character(mi_data[,"peducation"]))
mi_data[,"pdivorce"] <- as.numeric(as.character(mi_data[,"pdivorce"]))
mi_data[,"pdeath"] <- as.numeric(as.character(mi_data[,"pdeath"]))
mi_data[,"pemoabuse"] <- as.numeric(as.character(mi_data[,"pemoabuse"]))
mi_data[,"pphyabuse"] <- as.numeric(as.character(mi_data[,"pphyabuse"]))
mi_data$ACE <- mi_data$sexabuse+mi_data$welfare+mi_data$peducation+mi_data$pdivorce+mi_data$pdeath+mi_data$pemoabuse+mi_data$pphyabuse

# subset variables of interest for analysis
mi_data$imp = mi_data$.imp
names = c("imp", ".id", "M2ID", "ACE")
mi_data2 <- mi_data[,names]

# transpose ACE long to wide
mi_data3 <- mi_data2[
  with(mi_data2, order(M2ID, imp)),
  ]
mi_datawide <- spread(mi_data3, key = imp, value = ACE)

# merge with level 2 variables for analysis
data_analysis <- merge(mi_datawide, datawide7, by = "M2ID")

# subset
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
gg_miss_var(data_analysis)

# merge with level 1 variables for analysis
data <- subset(data, select = c(M2ID, M2FAMNUM, day, numstress, pmc_cortwt, t, CORTx, logcortx, CORTtime, CORTpctime))
analysis_long <- merge(data, data_analysis, by = c("M2ID", "M2FAMNUM"))

# transpose to wide to long for imputation style file
analysis_long2 <- analysis_long %>% gather(imp, ACE, imp1:imp20)

# prepare for analysis
analysis_long2$imp <- revalue(analysis_long2$imp, c("imp1" = "1", "imp2" = "2", "imp3" = "3", "imp4" = "4", "imp5" = "5", "imp6" = "6", "imp7" = "7", "imp8" = "8", "imp9" = "9", "imp10" = "10",
                                                    "imp11" = "11", "imp12" = "12", "imp13" = "13", "imp14" = "14", "imp15" = "15", "imp16" = "16", "imp17" = "17", "imp18" = "18", "imp19" = "19", "imp20" = "20"))
analysis_long2$imp <- as.numeric(analysis_long2$imp)
analysis_long2 <- analysis_long2[
  with(analysis_long2, order(M2ID, imp)),
  ]

# subset into two datasets with ten imputations each
mi_data1 <- analysis_long2[ which(analysis_long2$imp < 11), ]
mi_data2 <- analysis_long2[ which(analysis_long2$imp > 10), ]

# export imputed data
setwd("/Users/madelinecraft/Desktop/Cortisol Research")
write.table(x = mi_data1, file='mi_data1.txt', row.names = F, col.names = T)
write.table(x = mi_data2, file='mi_data2.txt', row.names = F, col.names = T)
