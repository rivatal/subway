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
#library(GISTools)

setwd(".")
subwaydata <- read.csv("all_ts.csv", stringsAsFactors = FALSE)  # read csv file 

#SAMPLE!!
subwaydata <- sample_n(subwaydata, (nrow(subwaydata)/4))
# creating dataframe with num_entries, num_exits, and time difference
names(subwaydata) <- tolower(names(subwaydata))
subwaydata$date.time <- with(subwaydata, paste(date, time, sep=' '))
subwaydata$date.time <- with(subwaydata, strptime(date.time, "%m/%d/%Y %H:%M:%S"))
subwaydata$date.time <- with(subwaydata, as.POSIXct((date.time)))
subwaydata <- mutate(subwaydata, day_of_week = dayOfWeek(as.timeDate(date.time)))

subwaydata <- as.data.frame(subwaydata) %>%select(-x, -intersect)

teneleven <- subwaydata # %>% filter(date == "10/11/2014")
teneleven <- teneleven %>% group_by(c.a, unit, scp) %>% arrange(station_id, c.a, unit, scp)

teneleven <- arrange(teneleven, date.time) %>%
  mutate(lasttime = lag(date.time), time.delta = as.numeric(date.time-lag(date.time),units="hours"))

teneleven <- arrange(teneleven, c.a, unit, scp, station, linename, date.time)
teneleven <-teneleven %>%
  mutate(entry_exits_period = as.character(ifelse(time > "0:00:00" & time <= "04:00:00", as.character("0:4"),
                                                  ifelse(time > "04:00:00" & time <= "08:00:00", "4:8",
                                                         ifelse(time > "08:00:00" & time <= "12:00:00", "8:12",
                                                                ifelse(time > "12:00:00" & time <= "16:00:00", "12:16",
                                                                       ifelse(time > "16:00:00" & time <= "20:00:00", "16:20", "20:0")))))))
teneleven <- teneleven %>% mutate(entries.delta = entries - lag(entries), exits.delta = exits - lag(exits))
teneleven <- ungroup(teneleven)
teneleven <- teneleven %>% group_by(station_id, date, day_of_week, entry_exits_period) %>% arrange(station_id, date, entry_exits_period) 
tentwelve <- summarize(teneleven, st.entries = sum(entries.delta, na.rm = TRUE), st.exits = sum(exits.delta, na.rm = TRUE))

tentwelve <- tentwelve %>% 
  filter(st.entries < 75000) %>%                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
  filter(st.exits < 75000) %>%
  filter(st.exits > -1) %>%
  filter(st.entries > -1) 

#daily_entries_exits_rates
write.csv(tentwelve, file = "daily_entries_exits.csv", row.names = FALSE)

#/4 = hourly, since our buckets are four hours each.
#hourly_entries_exits_rates <- group_by(subwaydata, station_id, entry_exits_period, date, day_of_week) %>%
#  summarise(hourly_entries = sum(as.numeric(entries.delta))/4,hourly_exits = sum(as.numeric(exits.delta))/4, station = station[1], linename=linename[1]) 

#write.csv(hourly_entries_exits_rates, file = "subway_entries_exits.csv")


#entries_exits_period <- group_by(hourly_entries_exits_rates, station_id, entry_exits_period) %>%
#  summarise(hourly_entries = mean(hourly_entries),hourly_exits = mean(hourly_exits), station = station[1], linename=linename[1]) 

#entries_exits_period <- entries_exits_period[complete.cases(entries_exits_period),]
#entries_exits_period$hourly_entries_exits
#write.csv(entries_exits_period, file = "entries_exits_average.csv")

########################################################################3
#For the weekend data:
#########################################################################
#weekend_hourly_exits <- group_by(weekenddata, station_id, entry_exits_period, date, day_of_week) %>%
#  summarise(hourly_entries = sum(as.numeric(entries.delta))/4,hourly_exits = sum(as.numeric(exits.delta))/4, station = station[1], linename=linename[1]) 

#weekend_entries_exits <- group_by(weekend_hourly_exits, station_id, entry_exits_period) %>%
#  summarise(hourly_entries = mean(hourly_entries),hourly_exits = mean(hourly_exits), station = station[1], linename=linename[1]) 

#weekend_period <- weekend_entries_exits[complete.cases(weekend_entries_exits),]
#write.csv(weekend_period, file = "weekend_averages.csv", row.names = FALSE)
