#This actually conducts the merge.
#After running matchnames.py
library(dplyr)
setwd(".")
mergetable <- read.table("smalleredits.txt",header=FALSE, 
                         sep=",",fill=TRUE, strip.white = TRUE, quote = "", row.names = NULL,
                         stringsAsFactors = FALSE) 
mergetable <- mergetable[c(3,4)]
names(mergetable) <- c("stop_name", "STATION")


#Make sure to change duplicates and every six thing.
data_dir <- "turnstile_data"
txts <- Sys.glob(sprintf('%s/turnstile_*.txt', data_dir))
ts_data <- data.frame()

#Just grabbing every seven turnstile dataframes for a good sample of the names.
txts <- txts[seq(2, length(txts))]
for (txt in txts) {
  tmp <- read.table(txt, header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)
  ts_data <- rbind(ts_data, tmp)
}
#ts_data <- ts_data[c("STATION", "LINENAME")]
ts_data <- ts_data[!duplicated(ts_data),]
ts_data <- arrange(ts_data, LINENAME)
#split and alphebetize linenames?

all_ts <- full_join(mergetable, ts_data)

gtfs_data <- read.table("station_ids_trips.csv",header=TRUE, 
                      sep=",",fill=TRUE, quote = "\"", row.names = NULL,
                      stringsAsFactors = FALSE) 
gtfs_data <- gtfs_data[c("stop_name", "route_id", "station_id")]

all_ts <- full_join(all_ts, gtfs_data)
#names(all_ts)[c("LINENAME")] <- "ts_route"
#names(all_ts)[c("route_id")] <- "gtfs_route"

all_ts$LINENAME <- sapply(all_ts$LINENAME, toString)
all_ts$gtfs_route <- sapply(all_ts$route_id, toString)
all_ts <- all_ts[-13] #Which is route_id, btw.

#We're at the join!!!!!!!!!!!!!!!!!!!!!!1
#Sebastian's function to get intersection lengths.
overlap <- function(x,y) {length(intersect(strsplit(x, "")[[1]], strsplit(y, "")[[1]]))}

#Columns to get intersection, get min length of string
all_ts$intersect <- mapply(overlap, all_ts$LINENAME, all_ts$gtfs_route)
all_ts <- filter(all_ts, intersect > 0)

#non_int <- filter(all_ts, intersect == 0)
write.csv(all_ts, "all_ts.csv")


