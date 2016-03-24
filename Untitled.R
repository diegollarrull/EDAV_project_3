library(dplyr)
library(ggplot2)
library(ggmap)
library(animation)

#################
## Exploratory ##
#################

yelp <- read.csv("yelp api/yelp.csv")
yelp_rating <- read.csv("yelp api/yelp_rating.csv")

dat <- read.csv("clean-data/Traffic_Violations_alcohol.csv", stringsAsFactors = F)
## Latitude and longitude coordinates are (sometimes) incorrect...
dat$New.Lat <- pmax(dat$Latitude, dat$Longitude)
dat$New.Lon <- pmin(dat$Latitude, dat$Longitude)
dat$Date.Of.Stop <- as.Date(dat$Date.Of.Stop, format = "%m/%d/%Y")

## Violations by minute.
dat %>%
  mutate(Time = as.POSIXct(Time.Of.Stop, format="%H:%M:%S")) %>%
  group_by(Time) %>%
  tally() %>%
  ggplot() + geom_bar(aes(x=Time, y = n), stat = "identity") +
  theme_bw() + ggtitle("Total Violations per Hour")

## Violations by weekday.
dat %>%
  mutate(Time = weekdays(as.Date(Date.Of.Stop, format="%m/%d/%Y"))) %>%
  group_by(Time) %>%
  tally() %>%
  ggplot() + geom_bar(aes(x=Time, y = n), stat = "identity") +
  theme_bw() + ggtitle("Total Violations per Weekday")

## Violations by month.
dat %>%
  mutate(Time = months(as.Date(Date.Of.Stop, format="%m/%d/%Y"))) %>%
  group_by(Time) %>%
  tally() %>%
  ggplot() + geom_bar(aes(x=Time, y = n), stat = "identity") +
  theme_bw() + ggtitle("Total Violations per Month")

## Violations by race.
dat %>%
  group_by(Race) %>%
  tally() %>%
  ggplot() + geom_bar(aes(x=Race, y = n), stat = "identity") +
  theme_bw() + ggtitle("Total Violations per Month")

##################
## Geo-mapping. ##
##################
test.dat <- dat[sample(nrow(dat)),] %>%
  select(Location, Latitude, Longitude) %>%
  filter(!is.na(Latitude)) %>%
  head(500)

## Contour Plot.
map <- get_map(location = c(lon = -77.129074, lat = 39.10359), zoom =11, maptype = "roadmap")

alcohol.map <- ggmap(map,  extent="panel") %+%
  unique(dat[!is.na(dat$New.Lat),c("New.Lat", "New.Lon")]) +
  aes(x = New.Lon, y = New.Lat) +
  stat_density2d(aes(fill = ..level.., alpha = ..level..), geom = "polygon") +
  scale_fill_gradient(low = "orange", high = "red") +
  scale_alpha(range = c(0.1, 0.3)) +
  labs(x = "Longitude", y = "Latitude", title = "Montgomery County, Maryland") +
  theme(legend.position = "none") +
  coord_map()

alcohol.map +
  geom_point(aes(x = New.Lon, y = New.Lat), fill="red", shape=21, alpha=0.3, size = 1) +
  geom_point(data = yelp, aes(x = longitude, y = latitude), fill="blue", alpha = 0.7, shape=21, size = 3)

##################
## Single Day M ##
##################

## Animation of indicents throughout the day.
dat %>%
  group_by(Date.Of.Stop) %>%
  tally(sort = T) %>%
  head(1)

## December 20th. Format Data.
bad.day <- as.Date("12/20/2014", format = "%m/%d/%Y")
bad.dat <- dat[dat$Date.Of.Stop == bad.day & !is.na(dat$New.Lat),]

bad.dat$Time <- as.POSIXct(paste(bad.dat$Date.Of.Stop, bad.dat$Time.Of.Stop), format = "%Y-%m-%d %H:%M:%S")
bad.min <- min(bad.dat$Time.Of.Stop)
bad.max <- max(bad.dat$Time.Of.Stop)

frame1 <- data.frame(matrix(0, nrow = 751, ncol = 1))
names(frame1) = c("Time")
t1 <- seq.POSIXt(as.POSIXct("12/20/2014 17:30", format = "%m/%d/%Y %H:%M"),
                         as.POSIXct("12/20/2014 23:59", format = "%m/%d/%Y %H:%M"), by = "min")
t2 <- seq.POSIXt(as.POSIXct("12/20/2014 00:00", format = "%m/%d/%Y %H:%M"),
                 as.POSIXct("12/20/2014 06:00", format = "%m/%d/%Y %H:%M"), by = "min")
frame1$Time <- c(t1, t2)

## Final time data frame.
frame2 <- frame1 %>%
  left_join(unique(bad.dat[c("Time", "New.Lat", "New.Lon", "Personal.Injury")]), by = "Time")

frame2$Personal.Injury <- ifelse(is.na(frame2$Personal.Injury), 0, 1)
frame2[is.na(frame2$New.Lat),c(2,3)] <- 0

map <- get_map(location = c(lon = -77.129074, lat = 39.10359), zoom =10 , maptype = "roadmap")

saveGIF({
  for(i in 1:nrow(frame2)) {
    
    night.map <- ggmap(map, extent="panel") %+%
      frame2[i,] +
      aes(x = New.Lon, y = New.Lat) +
      geom_point(fill="red", shape=21, size = 5) +
      labs(x = "Longitude", y = "Latitude", title = "Montgomery County, Maryland") +
      theme(legend.position = "none") +
      coord_map()
      
    print(night.map)
  }
}, movie.name = "violations.gif", interval = 0.1, ani.width = 400, ani.height = 400)