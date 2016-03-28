library(dplyr)
library(ggplot2)
library(ggmap)
library(animation)

#################
## Exploratory ##
#################

## YELP DATA.
yelp <- read.csv("yelp api/yelp.csv")
yelp_rating <- read.csv("yelp api/yelp_rating.csv")
yelp_distance <- read.csv("yelp api/yelp_distance.csv")

## METRO DATA.
metro <- read.csv('MetroStops.csv')
metro$Parking <- as.numeric(metro$Parking)
metro$Passengers.Daily <- as.numeric(metro$Passengers.Daily)

dat <- read.csv("clean-data/Traffic_Violations_alcohol.csv", stringsAsFactors = F)
## Latitude and longitude coordinates are (sometimes) incorrect...
dat$New.Lat <- pmax(dat$Latitude, dat$Longitude)
dat$New.Lon <- pmin(dat$Latitude, dat$Longitude)
dat$Date.Of.Stop <- as.Date(dat$Date.Of.Stop, format = "%m/%d/%Y")

write.csv(dat, "fixed_violations.csv")

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

## General map.
map <- get_map(location = c(lon = -77.129074, lat = 39.10359), zoom =11, maptype = "roadmap")

alcohol.map <- ggmap(map,  extent="panel") %+%
  unique(dat[!is.na(dat$New.Lat),c("New.Lat", "New.Lon")]) +
  aes(x = New.Lon, y = New.Lat) +
  stat_density2d(aes(fill = ..level..), alpha = 0.1, geom = "polygon") +
  scale_fill_gradient(low = "orange", high = "red") +
  #scale_alpha(range = c(0.1, 0.3)) +
  labs(x = "Longitude", y = "Latitude", title = "Montgomery County, Maryland") +
  theme(legend.position = "none") +
  coord_map()

alcohol.map +
  geom_point(aes(x = New.Lon, y = New.Lat), fill="red", shape=21, alpha=0.3, size = 1) +
  geom_point(data = unique(yelp_rating[yelp_rating$rating >= 3.5,]),
             aes(x = longitude, y = latitude, alpha = 6**rating, size = 2**rating),
             fill="black", shape=23) + 
  geom_point(data = metro,
             aes(x = Lon, y = Lat, size = 15), alpha = 0.8, col="blue", shape=16) +
  scale_alpha(range = c(0.4, 0.8))


## Zoom 1 (Germantown).
map <- get_map(location = c(lon = -77.26, lat = 39.18), zoom =13, maptype = "roadmap")

alcohol.map <- ggmap(map,  extent="panel") %+%
  unique(dat[!is.na(dat$New.Lat),c("New.Lat", "New.Lon")]) +
  aes(x = New.Lon, y = New.Lat) +
  stat_density2d(aes(fill = ..level..), alpha = 0.2, geom = "polygon") +
  scale_fill_gradient(low = "orange", high = "red") +
  #scale_alpha(range = c(0.1, 0.3)) +
  labs(x = "Longitude", y = "Latitude", title = "Germantown, Maryland") +
  theme(legend.position = "none") +
  coord_map()

alcohol.map +
  geom_point(aes(x = New.Lon, y = New.Lat), fill="red", shape=21, alpha=0.5, size = 1) +
  geom_point(data = unique(yelp_rating[yelp_rating$rating >= 0,]),
             aes(x = longitude, y = latitude, size = 2*rating),
             fill="black", shape=23, alpha = 0.8) + 
  geom_point(data = metro,
             aes(x = Lon, y = Lat, size = 15), alpha = 0.8, col="blue", shape=16) +
  scale_alpha(range = c(0.4, 0.8))

## Zoom 2 (Rockville).
map <- get_map(location = c(lon = -77.15, lat = 39.09), zoom =14, maptype = "roadmap")

alcohol.map <- ggmap(map,  extent="panel") %+%
  unique(dat[!is.na(dat$New.Lat),c("New.Lat", "New.Lon")]) +
  aes(x = New.Lon, y = New.Lat) +
  stat_density2d(aes(fill = ..level..), alpha = 0.2, geom = "polygon") +
  scale_fill_gradient(low = "orange", high = "red") +
  #scale_alpha(range = c(0.1, 0.3)) +
  labs(x = "Longitude", y = "Latitude", title = "Rockville, Maryland") +
  theme(legend.position = "none") +
  coord_map()

alcohol.map +
  geom_point(aes(x = New.Lon, y = New.Lat), fill="red", shape=21, alpha=0.5, size = 1) +
  geom_point(data = unique(yelp_rating[yelp_rating$rating >= 0,]),
             aes(x = longitude, y = latitude, size = 2*rating),
             fill="black", shape=23, alpha = 0.8) + 
  geom_point(data = metro,
             aes(x = Lon, y = Lat, size = 15), alpha = 0.8, col="blue", shape=16) +
  scale_alpha(range = c(0.4, 0.8))

## Zoom 3 (North Bethesda).
map <- get_map(location = c(lon = -77.1, lat = 39.06), zoom =13, maptype = "roadmap")

alcohol.map <- ggmap(map,  extent="panel") %+%
  unique(dat[!is.na(dat$New.Lat),c("New.Lat", "New.Lon")]) +
  aes(x = New.Lon, y = New.Lat) +
  stat_density2d(aes(fill = ..level..), alpha = 0.2, geom = "polygon") +
  scale_fill_gradient(low = "orange", high = "red") +
  #scale_alpha(range = c(0.1, 0.3)) +
  labs(x = "Longitude", y = "Latitude", title = "North Bethesda, Maryland") +
  theme(legend.position = "none") +
  coord_map()

alcohol.map +
  geom_point(aes(x = New.Lon, y = New.Lat), fill="red", shape=21, alpha=0.5, size = 1) +
  geom_point(data = unique(yelp_rating[yelp_rating$rating >= 0,]),
             aes(x = longitude, y = latitude, size = 2*rating),
             fill="black", shape=23, alpha = 0.8) + 
  geom_point(data = metro,
             aes(x = Lon, y = Lat, size = 15), alpha = 0.8, col="blue", shape=16) +
  scale_alpha(range = c(0.4, 0.8))

## Zoom 4 (Bethesda).
map <- get_map(location = c(lon = -77.07, lat = 38.985), zoom =13, maptype = "roadmap")

alcohol.map <- ggmap(map,  extent="panel") %+%
  unique(dat[!is.na(dat$New.Lat),c("New.Lat", "New.Lon")]) +
  aes(x = New.Lon, y = New.Lat) +
  stat_density2d(aes(fill = ..level..), alpha = 0.2, geom = "polygon") +
  scale_fill_gradient(low = "orange", high = "red") +
  #scale_alpha(range = c(0.1, 0.3)) +
  labs(x = "Longitude", y = "Latitude", title = "Bethesda, Maryland") +
  theme(legend.position = "none") +
  coord_map()

alcohol.map +
  geom_point(aes(x = New.Lon, y = New.Lat), fill="red", shape=21, alpha=0.5, size = 1) +
  geom_point(data = unique(yelp_rating[yelp_rating$rating >= 0,]),
             aes(x = longitude, y = latitude, size = 2*rating),
             fill="black", shape=23, alpha = 0.8) + 
  geom_point(data = metro,
             aes(x = Lon, y = Lat, size = 15), alpha = 0.8, col="blue", shape=16) +
  scale_alpha(range = c(0.4, 0.8))

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
  left_join(unique(bad.dat[c("Time", "New.Lat", "New.Lon", "Personal.Injury")]), by = "Time") %>%
  mutate(Impact = 0)

frame2$Personal.Injury <- ifelse(is.na(frame2$Personal.Injury), 0, 1)
frame2[is.na(frame2$New.Lat),c(2,3)] <- 0

i <- which(frame2$New.Lat != 0)

## Add a "size" component.
frame2[i,]$Impact <- 5
frame2[i+1,c("New.Lat", "New.Lon")] <- frame2[i,c("New.Lat", "New.Lon")]
frame2[i+1,]$Impact <- 3
frame2[i+2,c("New.Lat", "New.Lon")] <- frame2[i,c("New.Lat", "New.Lon")]
frame2[i+2,]$Impact <- 1

## Make final GIF!!!
map <- get_map(location = c(lon = -77.129074, lat = 39.10359), zoom =10 , maptype = "roadmap")

saveGIF({
  for(i in 1:nrow(frame2)) {
    
    night.map <- ggmap(map, extent="panel") %+%
      frame2[i,] +
      aes(x = New.Lon, y = New.Lat, size = "Impact") +
      geom_point(fill="red", shape=21) +
      labs(x = "Longitude", y = "Latitude") +
      theme(legend.position = "none") +
      coord_map() + ggtitle(paste("Montgomery County, MD - ", frame2[i,]$Time))
      
    print(night.map)
  }
}, movie.name = "violations.gif", interval = 0.1, ani.width = 400, ani.height = 400)