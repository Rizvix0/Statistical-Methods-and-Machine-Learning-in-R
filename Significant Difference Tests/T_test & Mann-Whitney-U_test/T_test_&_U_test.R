"
NOTE: First Column is treated as 1 in the Selection of Data:

1- Please make sure your csv file contains only numeric variables with headers for the code and one 
   first column with Name of the Elements (for sample check the dataset provided with the 
   name 'practice file').
   
                   Column(Instance) 1      Column(Instance) 2         . . . .    Column(Instance) n
      
      Row(Variable) 1      (Value)                  (Value)           . . . .         (Value)
      
      Row(Variable) 2      (Value)                  (Value)           . . . .         (Value)
      
      .                       .                        .                                 .
      .                       .                        .                                 .
      .                       .                        .                                 .
      .                       .                        .                                 .
      
      Row(Variable) n      (Value)                  (Value)           . . . .         (Value)

2- To run the code, select the whole code and run as source (top right in this window) & enter parameters
   which will be asked on running the code in the CONSOLE screen. In this case select:
   
   a- dataset to work on (after screen pops out)
   b- Type of separator used in the file
   c- Type of test to be performed 'U-test' or 'T-test'
   b- Ranges of both groups (Group-1 and Group-2)
   c- Parameter(paired) value for the test, either TRUE or FALSE
      (Here TRUE indicates that groups are PAIRED, and FALSE indicates that groups are UN-PAIRED)
      
3- After providing all the parameters, the code will compute following:
   * p-Value for the est  
         a- alternative: the alternative hypothesis. Allowed value is one of “two.sided” (default), “greater” or “less”.
         b- conf.level:  the default value of the Confidence-level is 0.95                                
   * Bonferoni Correction for p-value                       
   * Benjamin Hochberger Correction for p-value               
   * Averages of group-1 and group-2
   * p & w values for Shapiro Normality test
   
4- After all the executions the final resulting file(in CSV format) will be saved on your current
   working directory. In the resulting file you can find all the calulated values done through the 
   analysis.
"
#------------------------------------------------
"REQUIRED PACKAGES FOR T-TEST"
#------------------------------------------------

# Cleaning the workspace to start over
cat("\f")       # Clear old outputs
rm(list=ls())   # Clear all variables

# Installing  Packages
# Package for package administration:
if(!require("tidyr")) install.packages("tidyr")             #package for Data-wrangling
if(!require("ggplot2")) install.packages("ggplot2")         #package for Data-visualization
if(!require("ggpubr")) install.packages("ggpubr")           #package for Data-visualization
if(!require("dplyr")) install.packages("dplyr")             #package for Data-wrangling
if(!require("qualityTools")) install.packages("qualityTools") #package for Data-visualization

# Load packages:
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggpubr)
library(qualityTools)

cat("\f")       # Clear old outputs
#------------------------------------------------
"SELECTION OF DATSET AND PARAMETERS"
#------------------------------------------------
# Choose a csv file
print(paste("Please select Input CSV", " The different samples in columns and the measured variables in the rows."), quote = FALSE)
fname <- file.choose()     #choose all metaprotein.csv

#Choose the Separator for file
ask_sep <- as.character(readline(prompt = "ENTER the SEPARATOR for file(',' or ';') : "))

#file wtih mumerical data only
matrix <- read.csv(fname, sep=ask_sep, row.names = 1) 

#Which type of test user will perform:
#Choose the Separator for file
ask_test <- as.character(readline(prompt = "ENTER 't' for t-test & 'u' for u-test: "))


#List for Start of the groups:
group_start <- list()

#List for End of the groups:
group_end <- list()

for (i in 1:2) {
  group_start[i] <- as.integer(readline(prompt = "Enter values for Start of group: "))
  group_end[i]   <- as.integer(readline(prompt = "Enter values for End of group: "))
}

#Sets are paired or unpaired
PairedValue <- readline(prompt = "Enter TRUE/FALSE for Paired or Unpaired in the Test: ")
PairedValue <- as.logical(PairedValue)

#------------------------------------------------
"CALCULATIONS FOR T-TEST OR U-TEST"
#------------------------------------------------
if (ask_test == 't'){

  "CALCULATIONS FOR T-TEST"
  #File name of resulting csv 
  outputname = "Result_of_T_test.csv"
  
  # Create new output vectors for the results:
  
  EMPTY_First                                      <-  (rep("",nrow(matrix))) # + 1
  pValue_TTest                                     <-  (rep(0, nrow(matrix))) # + 2
  BonferoniCorrection_TTest                        <-  (rep(0, nrow(matrix))) # + 3
  BenjaminHochbergerCorrection_TTest               <-  (rep(0, nrow(matrix))) # + 4
  EMPTY_Second                                     <-  (rep("", nrow(matrix)))# + 5
  average_group_1                                  <-  (rep(0, nrow(matrix))) # + 6
  average_group_2                                  <-  (rep(0, nrow(matrix))) # + 7
  average_group_1div2                              <-  (rep(0, nrow(matrix))) # + 8
  Log2_average_group_1div2                         <-  (rep(0, nrow(matrix))) # + 9
  shapiro_Wvalue                                   <-  (rep(0, nrow(matrix))) # + 10
  shapiro_Pvalue                                   <-  (rep(0, nrow(matrix))) # + 11
  
  
  #Combined it to the output matrix:
  newMatrix <-  cbind(  matrix, EMPTY_First,pValue_TTest, BonferoniCorrection_TTest, BenjaminHochbergerCorrection_TTest,
                        
                        EMPTY_Second, average_group_1, average_group_2, average_group_1div2, Log2_average_group_1div2,
                        
                        shapiro_Wvalue,shapiro_Pvalue)
  
  
  #Normality Test"
  #Shapiro test values to check normality:
  
  for (i in 1:nrow(matrix)) { 
    newMatrix[i,ncol(matrix) + 10]   <- shapiro.test(as.numeric(matrix[i,]))$statistic # w-value
    newMatrix[i,ncol(matrix) + 11]   <- shapiro.test(as.numeric(matrix[i,]))$p.value   #p-value
    
  }
  
  # Calculate the T-TEST for all variables: 
  for (i in 1:nrow(matrix)) {
    #Average of Groups: 
    
    newMatrix[i,ncol(matrix) + 6]    <- mean(as.numeric( matrix[i, group_start[[1]] : group_end[[1]] ] ))
    newMatrix[i,ncol(matrix) + 7]    <- mean(as.numeric( matrix[i, group_start[[2]] : group_end[[2]] ] ))
    newMatrix[i,ncol(matrix) + 8]    <- mean( as.numeric(matrix[i, group_start[[1]] : group_end[[1]] ] ))/
      mean(as.numeric( matrix[i, group_start[[2]] : group_end[[2]] ] ))
    newMatrix[i,ncol(matrix) + 9]    <-  log2(newMatrix[i,ncol(matrix) + 8])
    
    # Calculation of P-Value for t-Test: 
    newMatrix[i,ncol(matrix)+ 2]      <- t.test(as.numeric(matrix[i,group_start[[1]] : group_end[[1]] ]),
                                                as.numeric(matrix[i,group_start[[2]] : group_end[[2]] ]),
                                                alternative = c("two.sided"), paired = PairedValue, 
                                                conf.level = 0.95)$p.value  
  }
  
  # Bonferroni and Benjamin-Hochberger Corrections for T-Test:
  #Save P-Value of T-Test in 'p':
  p <- newMatrix[1:nrow(matrix),ncol(matrix)+ 2] 
  
  #apply Bonferroni correction:
  newMatrix[1:nrow(matrix),ncol(matrix)+ 3]   <- p.adjust(p,method = "bonferroni", n = length(p)) 
  
  #apply Benjamin-Hochberger correction:
  newMatrix[1:nrow(matrix),ncol(matrix)+ 4]   <-  p.adjust(p, method = "BH", n = length(p))
  
  
} else if( ask_test == 'u'){
  # Output file name:
  outputname = "Result_of_U_test.csv"
  
  "CALCULATIONS FOR U-TEST"
  # Create new output vectors for the results:
  EMPTY_First                                      <-  (rep("",nrow(matrix))) # + 1
  pValue_UTest                                     <-  (rep(0, nrow(matrix))) # + 2
  BonferoniCorrection_UTest                        <-  (rep(0, nrow(matrix))) # + 3
  BenjaminHochbergerCorrection_UTest               <-  (rep(0, nrow(matrix))) # + 4
  EMPTY_Second                                     <-  (rep("", nrow(matrix)))# + 5
  average_group_1                                  <-  (rep(0, nrow(matrix))) # + 6
  average_group_2                                  <-  (rep(0, nrow(matrix))) # + 7
  average_group_1div2                              <-  (rep(0, nrow(matrix))) # + 8
  Log2_average_group_1div2                         <-  (rep(0, nrow(matrix))) # + 9
  shapiro_Wvalue                                   <-  (rep(0, nrow(matrix))) # + 10
  shapiro_Pvalue                                   <-  (rep(0, nrow(matrix))) # + 11
  
  
  # Combined it to the output matrix:
  newMatrix <-  cbind(  matrix, EMPTY_First, pValue_UTest, BonferoniCorrection_UTest, BenjaminHochbergerCorrection_UTest,
                        
                        EMPTY_Second, average_group_1, average_group_2, average_group_1div2, Log2_average_group_1div2,
                        
                        shapiro_Wvalue,shapiro_Pvalue)
  
  
  "Normality Test"
  #Shapiro test values to check normality:
  
  for (i in 1:nrow(matrix)) { 
    newMatrix[i,ncol(matrix) + 10]   <- shapiro.test(as.numeric(matrix[i,]))$statistic # w-value
    newMatrix[i,ncol(matrix) + 11]   <- shapiro.test(as.numeric(matrix[i,]))$p.value   #p-value
  }
  
  # Calculate the U-TEST for all variables: 
  for (i in 1:nrow(matrix)) {
    #Average of Groups: 
    newMatrix[i,ncol(matrix) + 6]    <- mean(as.numeric( matrix[i, group_start[[1]] : group_end[[1]] ] ))
    newMatrix[i,ncol(matrix) + 7]    <- mean(as.numeric( matrix[i, group_start[[2]] : group_end[[2]] ] ))
    newMatrix[i,ncol(matrix) + 8]    <- mean( as.numeric( matrix[i, group_start[[1]] : group_end[[1]] ] ))/
      mean(as.numeric( matrix[i, group_start[[2]] : group_end[[2]] ] ))
    newMatrix[i,ncol(matrix) + 9]    <-  log2(newMatrix[i,ncol(matrix) + 8])
    
    # Calculation of P-Value for U-Test
    newMatrix[i,ncol(matrix)+ 2]      <- wilcox.test(as.numeric(matrix[i,group_start[[1]]:group_end[[1]]]),
                                                     as.numeric(matrix[i,group_start[[2]]:group_end[[2]]]),
                                                     alternative = c("two.sided"), paired = PairedValue, 
                                                     conf.level = 0.95)$p.value
  }
  
  # Bonferroni and Benjamin-Hochberger Corrections for P-VALUES:
  # Save P-Value of U-Test in 'p':
  p <- newMatrix[1:nrow(matrix),ncol(matrix)+ 2]
  
  #apply Bonferroni correction:
  newMatrix[1:nrow(matrix),ncol(matrix)+ 3]   <- p.adjust(p,method = "bonferroni", n = length(p)) 
  
  #apply Benjamin-Hochberger correction:
  newMatrix[1:nrow(matrix),ncol(matrix)+ 4]   <-  p.adjust(p, method = "BH", n = length(p))
}

#--------------------------------------------------
"VISUALIZATIONS FOR T-TEST OR U-TEST"
#--------------------------------------------------

if (ask_test == 't'){
  "Visualization for Individual test"
  #Scatter-Plot for T-Test according to P-Value:
  
  pValueGreatTTest            <- newMatrix  %>% filter(pValue_TTest>=0.05)      #filter matrix with p value >0.05
  pVlaueLessTTest             <- newMatrix  %>% filter(pValue_TTest <= 0.05)    #filter matrix with p value <0.05
  
  # Visualization for T-Test:
  ggplot()+geom_point(aes(x=pValueGreatTTest$average_group_1,y=pValueGreatTTest$average_group_2,color= '>0.05'))+
    geom_point(aes(x=pVlaueLessTTest$average_group_1,y=pVlaueLessTTest$average_group_2,color= '<0.05'))+
    geom_abline(aes(intercept=0,slope=1),color='blue')+xlab('Average of Group1')+ylab('Average of Group2')+labs(color='P-values')+
    ggtitle("Group abandance w.r.t P-Value(T-Test)") + theme(plot.title = element_text(hjust = 0.5))
  
  
  
} else if( ask_test == 'u'){
  #Scatter-Plot for U-Test according to P-Value:
  pValueGreatUTest            <- newMatrix %>% filter(pValue_UTest>=0.05)        #filter matrix with p value >0.05
  pVlaueLessUTest             <- newMatrix  %>% filter(pValue_UTest <= 0.05)     #filter matrix with p value <0.05
  
  # Visualization for U-Test:
  ggplot()+geom_point(aes(x=pValueGreatUTest$average_group_1,y=pValueGreatUTest$average_group_2,color= '>0.05'))+
    geom_point(aes(x=pVlaueLessUTest$average_group_1,y=pVlaueLessUTest$average_group_2,color= '<0.05'))+
    geom_abline(aes(intercept=0,slope=1),color='blue')+xlab('Average of Group1')+ylab('Average of Group2')+labs(color='P-values')+
    ggtitle("Group abandance  w.r.t  P-Value(U-Test)") + theme(plot.title = element_text(hjust = 0.5))
  
}

cat("\f")       # Clear old outputs
#--------------------------------------------------
"EXPORT THE RESULTS INTO CSV"
#--------------------------------------------------
# Output file:
write.table(newMatrix, file = paste(outputname), append = FALSE, quote = TRUE, sep = ask_sep,
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = NA, qmethod = c("escape", "double"),
            fileEncoding = "")

print(paste("FINISHED"), quote = FALSE)
options(warn = -1)
cat("\f")       # Clear old outputs
