###############################################################################################
#Riva Tropp
#Checked 9/5/16
#Produces a database of all gtfs data, joined, with custom station ids.
################################################################################################
library(dplyr)
#stop_times <- "gtfs_data/"
stop_times <- read.table("gtfs_data/stop_times.txt",header=TRUE, 
                         sep=",",fill=TRUE,quote = "",row.names = NULL,
                         stringsAsFactors = FALSE) 

stops <- read.table("gtfs_data/stops.txt", header=TRUE, 
                    sep=",",fill=TRUE,quote = "",row.names = NULL,
                    stringsAsFactors = FALSE)

trips <- read.table("gtfs_data/trips.txt",header=TRUE, 
                    sep=",",fill=TRUE,quote = "",row.names = NULL,
                    stringsAsFactors = FALSE) 


#This line reduces trips to just the B records-- the largest ones. Remove if it messes up your work.
#trips <- filter(trips, substr(trips$service_id, 1, 1) == "B")
#Processing stop_times
#Getting rid of columns "stop_headsign", "pickup_type", "dropoff_type", "shape_dist_traveled"
stop_times <- stop_times[1:5]
#Getting rid of useless NS indicators
stop_times$stop_id = substr(stop_times$stop_id,0,3)
#Converting to POSIXct
stop_times$arrival_time <- as.POSIXct(stop_times$arrival_time, format='%H:%M:%S')
stop_times$departure_time <- as.POSIXct(stop_times$departure_time, format='%H:%M:%S')

#Processing stops file
stops <- stops[c(1,3,5,6)] #Getting rid of NA columns and location type field
stops$stop_id= substr(stops$stop_id,0,3)
#Every stop has a parent station and an extra row without one
stops = stops[!duplicated(stops),]

#Merging stops and stop_times to get the names of each stop
stop_times_names <- inner_join(stop_times,stops)


#Processing trips file
#Getting rid of NA block_id field and shape_id field
trips <- trips[1:5]


trips <- inner_join(stop_times_names, trips)



#Getting the time from stop to stop along a given route in a given direction (in minutes)
trips <- arrange(trips, direction_id, route_id)
trips <- trips[!duplicated(trips),]
trips <- group_by(trips, route_id, direction_id) %>% mutate(travel_time = departure_time - lag(arrival_time))
trips[trips$stop_sequence == 1,]$travel_time = 0

###################################################################################################
trips <- arrange(trips, route_id, stop_sequence)

#Getting rid of trip_id, service_id, arrival_time, and departure_time in order to generalize.
avg_trips <- trips[c(4,5,6,7,8,9,11,12,13)]

#This is the average travel time to a stop from its predecessor that occurs over any variation of the MTA routes. What a headache!
avg <- group_by(trips, route_id, stop_sequence, stop_name, stop_id, stop_lon, stop_lat, trip_headsign, direction_id) %>% summarize(mean(travel_time))
avg <- arrange(avg, direction_id, route_id)
avg <- avg[complete.cases(avg),]
  
###################################################################################################

#Now, on to creating unique ids for each station. The idea is to use the route_id (route_id corresponds to a single trip by a train) 
#and stop_sequence, then join on identical stop_ids and transfers in the gtfs database.
#To do that, however, we really need to take one route and stick with it.
#This takes the number of stops per trip so we can get the biggest trip.
trips <- trips %>% arrange(trip_id)
stops_per_trip <- trips %>%
  mutate(c=as.numeric(as.character(stop_sequence))) %>%  
  group_by(trip_id) %>%
  summarise(total.count=n())

trips <- left_join(trips, stops_per_trip)

#Grabbing the trips with the most stops (highest total.count of stops) for each route. 
trips <- trips %>% group_by(route_id) %>%
  filter(total.count == max(total.count)) %>%
  arrange(route_id,stop_sequence,total.count)


trips <- trips[c(4,5,6,7,8,9,11,12,13,14)]
trips <- trips[!duplicated(trips),]

#Averaging the stops per route-- time taken to get to the second stop on route 1 (from the first) should be an average of the recorded durations.
avg_time <- trips %>% group_by(route_id, stop_sequence, stop_id) %>% summarize(mean_duration = mean(travel_time, na.rm = TRUE))
trips <- left_join(trips, avg_time)

trips <- trips[c(6,2,1,3,4,5,8,11)]

#This is a dataframe with the largest possible trip for each route and durations averaged along instances of each trip.
trips <- trips[!duplicated(trips),]
trips <- arrange(trips, route_id, direction_id)
trips <- trips %>% filter(direction_id == 0) #Why are there more in the 0 direction than the 1 direction!?

#Combine trips with their stops to get format of B01 B02 etc. Thanks, Eiman!
zero<- "0"
trips$stop_sequence <- paste(zero,trips$stop_sequence,sep="")
trips$station_id <- paste("s",trips$route_id,trips$stop_sequence,sep="")

#Giving stations with the same stop_id the same station_id.
trips <- ungroup(trips) %>% arrange(stop_id)
n <- 2:length(trips$stop_id)
for (i in n){
  if(trips$stop_id[i] == trips$stop_id[i-1] ){
    trips$station_id[i] = trips$station_id[i-1]
  }
}

#Loading in transfer stops.
transfers <- read.table("gtfs_data/transfers.txt",header=TRUE, 
                        sep=",",fill=TRUE,quote = "",row.names = NULL,
                        stringsAsFactors = FALSE) 

transfers <- transfers[c(1,2)]
transfers <- transfers %>% filter(from_stop_id != to_stop_id) 
#Pretty sure the transfers where the stations are equal are for transferring from one direction to another
#(i.e, you can transfer from going south to going north on the C train at 168th-st washington hts (112))
#We're assuming most people are not going back and forth along the same route.

#Get all the stations that transfer to each other in one column.
#127, Times Square = 127,725,902,A27, & R16
transfers$all_stat = paste(transfers$from_stop_id, transfers$to_stop_id, sep = ",")
n <- 2:length(transfers$from_stop_id)
for (i in n){
  if(transfers$from_stop_id[i] == transfers$from_stop_id[i-1]){
    transfers$all_stat[i] <- paste(transfers$all_stat[i-1], transfers$to_stop_id[i], sep = ",")
    transfers$all_stat[i-1] <- ""
  }
}
transfers <- transfers %>% filter(transfers$all_stat != "")

#Alphabetize inside column, stack overflow style
strSort <- function(x)
  sapply(lapply(strsplit(x, ","), sort), paste, collapse=",")

transfers$all_stat<- lapply(transfers$all_stat, strSort)
transfers$all_stat <- unlist(transfers$all_stat)
transfers <- arrange(transfers, as.factor(all_stat))

#Now there's a column of all stop ids that are really the same acc' to transfers.txt
trips <- left_join(trips, transfers, by = c("stop_id" = "from_stop_id"))


#Now go through and if a stop is part of the same stop_set (all_stat), give it the same station_id.
trips <- arrange(trips, all_stat)
n <- 2:length(trips$all_stat)
for (i in n){
  if(!is.na(trips$all_stat[i]) && trips$all_stat[i] == trips$all_stat[i-1]){
    trips$station_id[i] = trips$station_id[i-1]
  }
}
trips <- arrange(trips, route_id, stop_sequence)
trips <- trips[1:9] #Getting rid of extra stop_id stuff from transfers.
#At this point, one station id should = one stop.

#CHANGED THIS PRETTY LATE, SO THERE MAY BE ISSUES
stations <- trips %>% group_by(station_id) %>% summarise(vector=paste(route_id, collapse=""))
trips <- left_join(trips, stations)
names(trips)[10] <- "routes"
#############################################################################################
write.csv(trips, "station_ids_trips.csv", row.names = FALSE)
#Fields: "route_id", "stop_sequence","stop_id","stop_name","stop_lat","stop_lon","direction_id","mean_duration","station_id" 
#############################################################################################

#Now create a datset that's just stations, their ids, routes, and their lats and long, used in map analysis.
stations <- trips[c("routes", "station_id", "stop_lat", "stop_lon")] 
stations <- stations %>% group_by(routes, station_id) %>% summarize(stop_lat = stop_lat[1], stop_lon = stop_lon[1])
write.csv(stations, "station_ids_coords.csv", row.names = FALSE)

#Now get all the routes. 

trips <- trips %>% arrange(route_id, as.numeric(stop_sequence))

names(trips)[9] <- "to_id"
names(trips)[4] <- "to_station"
trips <- trips %>% mutate(from_id = lag(to_id), from_station = lag(to_station))

trips$from_id[trips$stop_sequence == "01"] <- NA
trips <- trips[complete.cases(trips),]

trains_info <- data.frame(trips[,c(1,12,11,4,9,8)])
names(trains_info) <- c("Train","FromStation",'FromStationID','ToStation','ToStationID',"TravelTime")
write.csv(trains_info, "train_travel.csv")
