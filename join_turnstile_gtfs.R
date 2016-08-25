###############################################################################################
#Riva Tropp
#Join turnstile and gtfs dataframes
###############################################################################################
library(dplyr)
setwd(".")

matchtable <- read.table("smalleredits.txt",header=FALSE, 
                         sep=",",fill=TRUE,quote = "",row.names = NULL,
                         stringsAsFactors = FALSE) 

