library(tidyverse)

mydf <- read_csv("data.csv") %>%
    select("date", matches("net_offline_TV")) %>%
    setNames(gsub("net_Offline_TV_", "", names(.)))
mydf <- mydf[rowSums(mydf[,-1])>0,]
mydf$date <- seq(as.Date("2019-01-01"), length.out=nrow(mydf), by="1 day")
mydfl <- mydf[, c(1:10)] %>%
    #filter(date >= "2016-01-01") %>%
    gather(media, value, -date) %>%
    arrange(date)


library(ggplot2)
ggplot(mydfl, aes(y=value, x=date, fill=media)) +
    geom_bar(stat="identity") +
    theme_minimal() +
    scale_y_continuous(labels=scales::dollar)

library(streamgraph)
streamgraph(mydfl, "media", "value", "date")

library(ggTimeSeries)
ggplot(mydfl, aes(x = date, y = value, group = media, fill = media)) +
  stat_steamgraph() +
  theme_minimal() + scale_y_continuous(labels=scales::dollar)
