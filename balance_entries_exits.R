# Riva Tropp
# 8/24/2016
# Simple script to scale up exits to match entries for use in min-cost-flow algorithm.

library(dplyr)
setwd(".")

all_sub <- read.table("entries_exits_average.csv",header=TRUE, sep=",", # current turnstyle dataframe
                      quote = "\"", row.names = NULL, strip.white = TRUE, 
                      stringsAsFactors = FALSE) 

balancethings <- function(all_sub){
  #uniquetravel<- unique(subset(traintravel,select=c("station_id","station")))
  #all_sub<- inner_join(uniquetravel,all_sub, by = "station_id")
  #nrow(all_sub)
  
  #Get the ratio of entries to exits by time bucket and add that to the df.
  all_sub %>% group_by(entry_exits_period) %>% 
    summarise(sum_entries = sum(hourly_entries), sum_exits = sum(hourly_exits)) -> sums
  sums %>% mutate(ratio = sum_entries/sum_exits) -> sums
  sums$sum_exits <- NULL
  sums$sum_entries <- NULL
  all_sub <- merge(all_sub, sums, by = "entry_exits_period")
  
  all_sub %>% mutate(scaled_exits = hourly_exits * ratio) -> all_sub
  all_sub %>% mutate(rounded_scaled_exits = as.integer(scaled_exits+.5)) -> all_sub
  all_sub %>% mutate(rounded_hourly_entries = as.integer(hourly_entries+.5)) -> all_sub
  
  all_sub %>% group_by(entry_exits_period) %>% 
    summarise(sum_entries = sum(rounded_hourly_entries), sum_exits = sum(rounded_scaled_exits)) -> diff_sub
  
  diff_sub$diff <- diff_sub$sum_entries-diff_sub$sum_exits
  
  diff_sub <- data.frame(diff_sub[,c(1,4)])
  
  all_sub <- inner_join(all_sub, diff_sub)
  
  #s1013 = Penn station
  all_sub %>% mutate(rounded_hourly_entries = ifelse(station_id == "s1013", rounded_hourly_entries - diff, rounded_hourly_entries)) -> all_sub
  return(all_sub)
}


all_sub <- balancethings(all_sub)

the_wanted <- subset(all_sub,select=c('entry_exits_period','station','rounded_scaled_exits','rounded_hourly_entries','station_id'))


latenight <- filter(the_wanted, entry_exits_period == "0:4")
morning <- filter(the_wanted, entry_exits_period == "4:8")
latemorning <- filter(the_wanted, entry_exits_period == "8:12")
noon <- filter(the_wanted, entry_exits_period == "12:16")
evening <- filter(the_wanted, entry_exits_period == "16:20")
night <- filter(the_wanted, entry_exits_period == "20:0")


write.csv(latenight, "f_latenight.csv",quote=FALSE)
write.csv(morning, "f_morning.csv",quote=FALSE)
write.csv(noon, "f_noon.csv",quote=FALSE)
write.csv(evening, "f_evening.csv",quote=FALSE)
write.csv(night, "f_night.csv",quote=FALSE)
write.csv(latemorning, "f_latemorning.csv",quote=FALSE)
write.csv(the_wanted, "all_entries_exits.csv", quote = FALSE)

#Checking to make sure it's 0:
#all_sub %>% group_by(entry_exits_period) %>% 
#  summarise(sum_entries = sum(rounded_hourly_entries), sum_exits = sum(rounded_scaled_exits)) -> diffsub

#diffsub$diff <- diffsub$sum_entries-diffsub$sum_exits
#head(diffsub)
