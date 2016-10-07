library(ggmap)
library(ggplot2)
library(dplyr)

#Read in exits for every station for every four hours for every day.
daily_entries_exits <- read.csv("daily_entries_exits.csv")
colnames(daily_entries_exits)[4] <- "entries"
colnames(daily_entries_exits)[5] <- "exits"

daily_entries_exits <- mutate(daily_entries_exits, day_of_week = dayOfWeek(as.timeDate(date)))

###########################################################################################
#Popularity by day of week:
###########################################################################################
averagedays <- daily_entries_exits %>% group_by(date) %>% summarize(day_of_week = day_of_week[1], entries = sum(entries), exits=sum(exits)) 
averagedays <- averagedays %>% group_by(day_of_week) %>% summarize(entries = mean(entries), exits=mean(exits))
averagedays$day_of_week <- ordered(averagedays$day_of_week, levels = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"))

g <- ggplot(averagedays, aes(x = day_of_week, y=entries, fill = entries)) +
  geom_bar(stat="identity") +
  scale_y_continuous(label=comma) +
  xlab("Time") + ylab("Entries") + ggtitle("Most Popular Days") 
ggsave(filename = "graphics/daypopularity.png", plot=g)

###########################################################################################
#Mean with and without weekends
###########################################################################################
weekdays <- daily_entries_exits[complete.cases(daily_entries_exits),] %>% group_by(date, day_of_week) %>% summarise(sum(as.numeric(entries)), sum(exits))
names(weekdays) <- c("date", "day_of_week", "entries", "exits")
a <- mean(weekdays$entries)
weekends <- weekdays[which(weekdays$day_of_week == "Sat" | weekdays$day_of_week == "Sun"),]
b <- mean(weekends$entries)
weekdays <- weekdays[which(weekdays$day_of_week != "Sat" & weekdays$day_of_week != "Sun"),]
c <- mean(weekdays$entries)
averagetable <- data.frame(rbind(c("total", ceiling(a)), c("weekends", ceiling(b)), c("weekdays", ceiling(c))))
names(averagetable) <- c("period", "average")

###########################################################################################
#Average numbers for timebuckets.
###########################################################################################
popular_times <- daily_entries_exits[complete.cases(daily_entries_exits),] %>% group_by(entry_exits_period) %>% summarize(entries =mean(as.numeric(entries)), exits= mean(as.numeric(exits)))
names(popular_times) <- c("time_bucket", "entries", "exits")
popular_times$time_bucket <- factor(popular_times$time_bucket, c("0:4", "4:8", "8:12", "12:16", "16:20", "20:0"))
popular_times <- arrange(popular_times, time_bucket)

g <- ggplot(data = popular_times, aes(x = time_bucket, y = entries, fill = time_bucket)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(label = comma)+
  scale_fill_brewer(direction = -1) +
  xlab("Time") + ylab("Entries") + ggtitle("Average entries by time of day (over the entire system)") 
ggsave("graphics/avg_entries.png", plot=g)

h <- ggplot(data = popular_times, aes(x = time_bucket, y = exits, fill = time_bucket)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(label = comma)+
  scale_fill_brewer(direction = -1) +
  xlab("Time") + ylab("Exits") + ggtitle("Average exits by time of day (over the entire system)") 
ggsave("graphics/avg_exits.png", plot=h)

i <- ggplot(data = popular_times, aes(x = time_bucket, y = entries/exits, fill = time_bucket)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(label = comma)+
  scale_fill_brewer() +
  xlab("Time") + ylab("Ratio of Entries to Exits") + ggtitle("Average entries/exits by time of day") 
ggsave("graphics/entries_exits_ratio.png", plot=i)

###########################################################################################
#Day by day overview of entries and exits
###########################################################################################
daily_entries_exits <- daily_entries_exits %>% mutate(year = substring(daily_entries_exits$date, 7,11))
daily_entries_exits <- daily_entries_exits %>% mutate(month = substring(daily_entries_exits$date, 1, 2))
daily_entries_exits <- daily_entries_exits %>% mutate(day = substring(date, 4,5))

#All exits/entries per day across the system.
days <- daily_entries_exits[complete.cases(daily_entries_exits),] %>% group_by(date, year, month, day) %>% summarise(sum(as.numeric(entries)), sum(exits))
names(days) <- c("date", "year", "month", "day", "entries", "exits")

#Difference between 2015 and 2016
for(i in 1:12){
  if(i < 10){
    month <- days %>% filter(month == paste0("0", i))
  }else{
    month <- days %>% filter(month == i)
  }
  g<- ggplot(data = month, aes(x = day, y=entries, group=year)) + geom_line(aes(color=year)) +
    scale_y_continuous(label = comma) + scale_x_discrete()
  ggsave(paste0("graphics/", paste0(paste0("all_", i), ".png")), plot=g)
}

#Make graphs of every month of every year.
#for(j in 2015:2016){
#  for(i in 1:12){
#    if(i < 10){
#        x <- days %>% filter(month == (paste0("0", i)), year == j)
#    }else{
#      x <-days %>% filter(month == i) %>% filter(year == j)
#    }
#    print(i)
#    print(j)
#    if(!is.null(x)){
#      g <- ggplot(data = x, aes(x = day, y=entries, group=1)) + geom_line(color = "steelblue") +
#      scale_y_continuous(label = comma) + ggtitle(i)
#      ggsave(filename = paste0(paste0(paste0("plot", i), j), ".png"), plot = g)
#    }
#  }
#}
#j <- 2014
#months <- days %>% filter(year == 2014) %>% group_by(month) %>% summarise()
#Have to run 2014 separately for lack of months
#for(i in 10:12){
#  print(i)
#  if(i < 10){
#    x <- days %>% filter(month == (paste0("0", i)), year == j)
#  }else{
#    x <-days %>% filter(month == i) %>% filter(year == j)
#  }
#  print(i)
#  print(j)
#  View(x)
#  if(!is.null(x)){
#    g <- ggplot(data = x, aes(x = date, y=entries, group=1)) + geom_line(color = "steelblue") +
#      scale_y_continuous(label = comma) + ggtitle(i)
#    ggsave(filename = paste0(paste0(paste0("plot", i), j), ".png"), plot = g)
#  }
#}

####################################################################################
#Testing my nums
####################################################################################
days$date <- as.Date(days$date, format="%m/%d/%Y")

myfunc <- function(x,y){days[days$date >= x & days$date <= y,]}
DATE1 <- as.Date("06/27/2015", format="%m/%d/%Y")
DATE2 <- as.Date("07/03/2015", format="%m/%d/%Y")
test <- myfunc(DATE1,DATE2)
test <- test[c(1,5)]
names(test) <- c("date", "r_entries")

july <- read.csv("turnstile_data/julynums.csv", header = FALSE)
names(july) <- c("date", "awk_entries")
july$date <- as.Date(july$date, format="%m/%d/%Y")

july <- full_join(july, test)
july <- july %>% mutate(diff = r_entries - awk_entries) %>% mutate(absdif = abs(diff))

#The difference, at least for this particular subset, seems quite high
#and not always positive or always negative, as we'd expect if the problem is merely
#joining on station names. But to be sure, let's create a load_subway_trips that 
#calculates days based on station names and see how much closer it is.
source("station_blind_load_subway_trips.R")
station_entries_exits <- read.csv("station_entries_exits.csv")
colnames(station_entries_exits)[4] <- "entries"
colnames(station_entries_exits)[5] <- "exits"
station_entries_exits <- station_entries_exits %>% mutate(year = substring(station_entries_exits$date, 7,11))
station_entries_exits <- station_entries_exits %>% mutate(month = substring(station_entries_exits$date, 1, 2))
station_entries_exits <- station_entries_exits %>% mutate(day = substring(date, 4,5))

#All exits/entries per day across the system.
days <- station_entries_exits[complete.cases(station_entries_exits),] %>% group_by(date, year, month, day) %>% summarise(sum(as.numeric(entries)), sum(exits))
names(days) <- c("date", "year", "month", "day", "entries", "exits")
days$date <- as.Date(days$date, format="%m/%d/%Y")
test <- myfunc(DATE1,DATE2)
test <- test[c(1,5)]
names(test) <- c("date", "r_station_entries")
july <- full_join(july, test)
july <- mutate(july, awkdiff = awk_entries - r_station_entries)
july <- mutate(july, rvsrstation = r_entries - r_station_entries)
