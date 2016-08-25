########################################################################################################################################################################
# Description: Code to load turnstile data into master dataframe and review statistics
# 
########################################################################################################################################################################
#CHANGE TO ALL_TS!
library(dplyr)
library(timeDate) 
library(reshape)
library(ggplot2)
library(data.table)
library(tidyr)
library(scales)
#?
library(GISTools)

setwd(".")
subwaydata <- read.csv("sample_ts.csv", stringsAsFactors = FALSE)  # read csv file 

# creating dataframe with num_entries, num_exits, and time difference
names(subwaydata) <- tolower(names(subwaydata))
subwaydata$date.time <- with(subwaydata, paste(date, time, sep=' '))
subwaydata$date.time <- with(subwaydata, strptime(date.time, "%m/%d/%Y %H:%M:%S"))
subwaydata$date.time <- with(subwaydata, as.POSIXct((date.time)))

#Might need to re-add those to make the lines.
subwaydata <- as.data.frame(subwaydata) %>%select(-gtfs_route) # drop incomplete gtfs routes

subwaydata <- group_by(subwaydata, c.a, unit, scp, station, linename) # select unique turnstiles for each station
subwaydata <- arrange(subwaydata, date.time) %>%
  mutate(time.delta = as.numeric(date.time-lag(date.time),units="hours"),
         entries.delta = entries - lag(entries),
         exits.delta = exits - lag(exits),
         day_of_week = dayOfWeek(as.timeDate(date)))

#Why are we bucketing? What does it look like without the buckets?
subwaydata <-subwaydata %>%
  mutate(entry_exits_period = as.character(ifelse(time > "0:00:00" & time <= "04:00:00", as.character("0:4"),
                                          ifelse(time > "04:00:00" & time <= "08:00:00", "4:8",
                                          ifelse(time > "08:00:00" & time <= "12:00:00", "8:12",
                                          ifelse(time > "12:00:00" & time <= "16:00:00", "12:16",
                                          ifelse(time > "16:00:00" & time <= "20:00:00", "16:20", "20:0")))))))

#0 entries!
#weirddata <- subwaydata %>% 
#  filter(entries.delta >= 100000) %>%
#  filter(exits.delta >= 100000) %>%
#  filter(exits.delta <= -1) %>%
#  filter(entries.delta <= -1) 

subwaydata <- subwaydata %>% 
  filter(entries.delta < 100000) %>%
  filter(exits.delta < 100000) %>%
  filter(exits.delta > -1) %>%
  filter(entries.delta > -1) 


#/4 = hourly, since our buckets are four hours each.
hourly_entries_exits_rates <- group_by(subwaydata, station_id, entry_exits_period, date, day_of_week) %>%
  summarise(hourly_entries = sum(as.numeric(entries.delta))/4,hourly_exits = sum(as.numeric(exits.delta))/4, station = station[1], linename=linename[1]) 

write.csv(hourly_entries_exits_rates, file = "subway_entries_exits.csv")


entries_exits_period <- group_by(hourly_entries_exits_rates, station_id, entry_exits_period) %>%
  summarise(hourly_entries = mean(hourly_entries),hourly_exits = mean(hourly_exits), station = station[1], linename=linename[1]) 

entries_exits_period <- entries_exits_period[complete.cases(entries_exits_period),]
#entries_exits_period$hourly_entries_exits
write.csv(entries_exits_period, file = "entries_exits_average.csv")


#Dates against numbers
#subwaydates <- subwaydata[c("date", "entries.delta")]
#subwaydates <- subwaydates[complete.cases(subwaydates),]
#subwaydates <- subwaydates %>% group_by(date) %>% summarise(entries = sum(as.numeric(entries.delta)))
#ggplot(data=subwaydates, aes(x=date, y=entries)) + geom_histogram(stat="identity")  
#+ scale_y_continuous(labels = comma) + scale_x_discrete()

#####################################################3
#HourlyEntriesPerDay
#Commented out because Saturday what.
#########################################################
#subway_facet <- hourly_entries_exits_rates[c("day_of_week", "hourly_entries")]
#subway_facet <- subway_facet[complete.cases(subway_facet),]

#subway_facet <- subway_facet %>% group_by(day_of_week) %>% summarise(hourly_entries = mean(hourly_entries))
#subway_facet <- as.data.frame(subway_facet)

#ggplot(data=subway_facet, aes(x=day_of_week, y=hourly_entries)) + geom_point() + 
#  scale_y_continuous(labels = comma) + scale_x_discrete()



#Where do we get NAs for entries delta?
#Teneighteen <- subwaydata %>% filter(date == "10/18/2014")
#Teneighteen$entries.delta[is.na(Teneighteen$entries.delta)] <- 0
#Teneighteen <- Teneighteen %>% group_by(station_id) %>% summarize(entries.delta = sum(as.numeric(entries.delta)))
#Teneighteen$station_id <- as.factor(Teneighteen$station_id)
#Teneighteen$entries.delta <- as.double(Teneighteen$entries.delta)

#Teneighteen <- ungroup(Teneighteen)
#EighteenTen = as.data.frame(t(Teneighteen))

#ggplot(data = Teneighteen, aes(x=entries)) + geom_bar() + scale_x_continuous(labels = comma)

#ggplot(data=Teneighteen, aes(x=Teneighteen$station_id, y=Teneighteen$entries.delta, fill=sample))
#  geom_bar(position = 'dodge') +
#  geom_text(aes(label=Number), position=position_dodge(width=0.9), vjust=-0.25)


