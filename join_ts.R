#For joining TS and GTFS data, we just want names and station_ids AND ROUTES
names_trips <- trips[c("stop_name", "station_id", "route_id")]
names_trips$route_id <- sort(names_trips$route_id)
names_trips <- names_trips[!duplicated(names_trips),]
names_trips <- arrange(names_trips, station_id)


##########################################################################################
setwd("~/working-directory/")
write.csv(names_trips, "names_trips.csv")
#Fields: "stop_name"  "station_id" "route_id"
##########################################################################################
#----------------------------------------------------------------------------------------#
#Last thing we need to do is grab all the turnstile station names from the second dataset
#----------------------------------------------------------------------------------------#
##########################################################################################

setwd("~/working-directory/")

#Thanks, Steve.
data_dir <- "turnstile_data"
txts <- Sys.glob(sprintf('%s/turnstile_*.txt', data_dir))
ts_data <- data.frame()

#Just grabbing every six turnstile dataframes for a good sample of the names.
txts <- txts[seq(1, length(txts), 6)]
for (txt in txts) {
  tmp <- read.table(txt, header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)
  ts_data <- rbind(ts_data, tmp)
}
ts_data <- ts_data[c("STATION", "LINENAME")]
ts_data <- ts_data[!duplicated(ts_data),]
ts_data$LINENAME <- sort(ts_data$LINENAME)
ts_data <- arrange(ts_data, LINENAME)
names(ts_data) <- c("stop_name", "route_id")

##########################################################################################
setwd("~/working-directory/")
write.csv(ts_data, "names_ts.csv")
#Fields: "STATION"  "LINENAME"
##########################################################################################
#Actual Joining?
########################################################################################



