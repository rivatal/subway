library(ggmap)
library(ggplot2)
library(dplyr)

setwd(".")

data <- read.csv("daily_entries_exits.csv")
colnames(data)[5] <- "entries"
colnames(data)[6] <- "exits"


Eleventh <- data %>% filter(date=="10/11/2014")
#sum(Eleventh$entries)

popular_times <- data[complete.cases(data),] %>% group_by(entry_exits_period) %>% summarize(entries =mean(as.numeric(entries)), exits= mean(as.numeric(exits)))
names(popular_times) <- c("time_bucket", "entries", "exits")

popular_times$time_bucket <- factor(popular_times$time_bucket, c("0:4", "4:8", "8:12", "12:16", "16:20", "20:0"))
popular_times <- arrange(popular_times, time_bucket)
#cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2")


ggplot(data = popular_times, aes(x = time_bucket, y = entries, fill = time_bucket)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(label = comma)+
  scale_fill_brewer(direction = -1) +
  xlab("Time") + ylab("Entries") + ggtitle("Average entries by time of day (over the entire system)") 
#+ scale_x_discrete(labels = c("12-4 am", "12-4 pm", "4-8 pm", "8-12 am", "4-8 am", "8am-12pm"))

ggplot(data = popular_times, aes(x = time_bucket, y = exits, fill = time_bucket)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(label = comma)+
  scale_fill_brewer(direction = -1) +
  xlab("Time") + ylab("Exits") + ggtitle("Average exits by time of day (over the entire system)") 

ggplot(data = popular_times, aes(x = time_bucket, y = entries/exits, fill = time_bucket)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(label = comma)+
  scale_fill_brewer() +
  xlab("Time") + ylab("Ratio of Entries to Exits") + ggtitle("Average entries/exits by time of day") 

days <- data[complete.cases(data),] %>% group_by(date) %>% summarise(sum(as.numeric(entries)), sum(exits))
names(days) <- c("date", "entries", "exits")

ggplot(data = days, aes(x = date, y=entries, group=1)) + geom_line() +
  scale_y_continuous(label = comma) + scale_fill_brewer()
  
january <- days %>% filter(substring(days$date, 1, 2) == "01")
ggplot(data = january, aes(x = date, y=entries, group=1)) + geom_line() +
  scale_y_continuous(label = comma) + scale_fill_brewer()

october <- days %>% filter(substring(days$date, 1, 2) == "10")
ggplot(data = october, aes(x = date, y=entries, group=1)) + geom_line() +
  scale_y_continuous(label = comma) + scale_fill_brewer()
#Okay, what? How are there 2 trillion entries and exits in the metro? That makes no sense.
for(i in 1:12){
  x <- days %>% filter(substring(days$date, 1, 2) == (paste0("0", i)))
  g <- ggplot(data = x, aes(x = date, y=entries, group=1)) + geom_line() +
    scale_y_continuous(label = comma) + scale_fill_brewer()
  ggsave(filename = paste0(paste0("plot", i), ".pdf"), plot = g)
}
