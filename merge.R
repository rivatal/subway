#This actually conducts the merge.
#After running matchnames.py
#Fixed a problem where size quadrupled due to gtfs linenames.
library(dplyr)
mergetable <- read.table("smalleredits.txt",header=FALSE, 
                         sep=",",fill=TRUE, strip.white = TRUE, quote = "", row.names = NULL,
                         stringsAsFactors = FALSE) 
mergetable <- mergetable[c(3,4)]
names(mergetable) <- c("stop_name", "STATION")


#Make sure to change duplicates and every six thing.
#data_dir <- "turnstile_data"
#txts <- Sys.glob(sprintf('%s/turnstile_*.txt', data_dir))
txts <- scan(file="turnstile_files.txt", what="", sep="\n") 
ts_data <- data.frame()

#Just grabbing every eight turnstile dataframes for a good sample of the names.
#txts <- txts[seq(1, length(txts))]
#txts <- txts[1]
setwd("turnstile_data/")
for (txt in txts) {
  print(txt)
  tmp <- read.table(txt, header=TRUE, sep=",",fill=TRUE,quote = "",row.names = NULL, stringsAsFactors = FALSE)
  ts_data <- rbind(ts_data, tmp)
}
ts_data <- arrange(ts_data, LINENAME)
setwd("..")
#join mergetable and ts_data together.
all_ts <- full_join(mergetable, ts_data)

#Read in gtfs dataset
gtfs_data <- read.table("station_ids_trips.csv",header=TRUE, 
                      sep=",",fill=TRUE, quote = "\"", row.names = NULL,
                      stringsAsFactors = FALSE) 
gtfs_data <- gtfs_data[c("stop_name", "route_id", "station_id")]

#Now join them together.
all_ts <- left_join(all_ts, gtfs_data)
all_ts <- all_ts[complete.cases(all_ts),]

#gtfs has one route. LINENAME is all the routes.
all_ts$LINENAME <- sapply(all_ts$LINENAME, toString)
all_ts$gtfs_route <- sapply(all_ts$route_id, toString)
all_ts <- select(all_ts, -route_id) 
all_ts <- all_ts[!duplicated(all_ts),]

#We're at the join!!!!!!!!!!!!!!!!!!!!!!1
#Sebastian's function to get intersection lengths.
overlap <- function(x,y) {length(intersect(strsplit(x, "")[[1]], strsplit(y, "")[[1]]))}

#Columns to get intersection, get min length of string
all_ts$intersect <- mapply(overlap, all_ts$LINENAME, all_ts$gtfs_route)
all_ts <- filter(all_ts, intersect > 0)
all_ts <- select(all_ts, -gtfs_route)
all_ts <- all_ts[!duplicated(all_ts),]


all_ts <- all_ts %>% arrange(station_id)

#non_int <- filter(all_ts, intersect == 0)
write.csv(all_ts, "all_ts.csv")


