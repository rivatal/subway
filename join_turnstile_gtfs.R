###############################################################################################
#Riva Tropp
#Join turnstile and gtfs dataframes
###############################################################################################
library(dplyr)
setwd(".")

matchtable <- read.table("matchtable.txt",header=FALSE, 
                         sep=",",fill=TRUE,quote = "",row.names = NULL,
                         stringsAsFactors = FALSE) 

unsafe <- matchtable %>% filter(V1 >= 0)
