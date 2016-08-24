###############################################################################################
#Riva Tropp
#Acc' to join_gtfs.R, there are 440 individual stations, but only 377 individual names.
################################################################################################

library(dplyr)
setwd(".")

station_ids_trips <- read.table("station_ids_trips.csv",header=TRUE, 
                         sep=",",fill=TRUE,quote = "\"",row.names = NULL,
                         stringsAsFactors = FALSE) 

names_stations <- station_ids_trips[c("stop_name", "station_id")] %>% arrange(stop_name)
names_stations <- names_stations[!duplicated(names_stations),]

#This gives me 461 observations, which means multiple station ids match to the same name, as expected.
names_stations <- names_stations %>% group_by(stop_name) %>% mutate("count" = n())

#This is the number of names that see multiple occurrences, in my case 61.
num_diffs <- names_stations %>% filter(count > 1) 

#There are 144 stations with multiple names.
num_stations_with_multiples <- num_diffs %>% ungroup() %>% group_by(station_id) %>% summarize(length(station_id))

#But only 61 names encompassing all of those stations.
num_names_with_multiples <- num_diffs %>% summarize(length(stop_name))

#440 - 61 = 379. There are also two records missing between num_diffs and num_stations_with_multiples. Same two?

