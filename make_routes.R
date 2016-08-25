###############################################################################################
#Riva Tropp
#8/25/16
#Gets the gtfs dataset in order of routes so we can easily compute the flow.
################################################################################################

library(dplyr)
setwd(".")

station_ids_trips <- read.table("station_ids_trips.csv",header=TRUE, 
                         sep=",",fill=TRUE,quote = "\"",row.names = ,
                         stringsAsFactors = FALSE) 

to_from_route <- station_ids_trips %>% arrange(route_id, stop_sequence) %>% mutate(to_stop = "") %>% mutate(to_station = "")

n <- 2:nrow(to_from_route)
for (i in n){
  if(!is.na(to_from_route$stop_name[i]) && to_from_route$stop_sequence[i] != 1){
    to_from_route$to_stop[i] = to_from_route$stop_name[i-1]
    to_from_route$to_station[i] = to_from_route$station_id[i-1]
  }
}

colnames(to_from_route)[4] = "from_stop"
colnames(to_from_route)[9] = "from_station"

write.csv(to_from_route, "train_travel.csv", row.names = FALSE)
