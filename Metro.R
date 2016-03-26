library(dplyr)
library(ggplot2)
library(ggmap)
library(xlsx)


dat <- read.csv("clean-data/Traffic_Violations_alcohol.csv", stringsAsFactors = F)
## Latitude and longitude coordinates are (sometimes) incorrect...
dat$New.Lat <- pmax(dat$Latitude, dat$Longitude)
dat$New.Lon <- pmin(dat$Latitude, dat$Longitude)
dat$Date.Of.Stop <- as.Date(dat$Date.Of.Stop, format = "%m/%d/%Y")

write.csv(dat, "fixed_violations.csv")

##################
## Geo-mapping. ##
##################

#metro
metro <- read.xlsx('MetroStops.xlsx', sheetIndex = 1, rowIndex = 1:14, colIndex = 1:5)

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
  geom_point(data = metro,
             aes(x = Lon, y = Lat, alpha = Parking, size = Passengers.Daily), fill="black", shape=23) +   
  scale_alpha(range = c(0.4, 0.8)) 


## Zoom Rockville
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
  geom_point(aes(x = New.Lon, y = New.Lat), fill="red", shape=21, alpha=0.3, size = 1) +
  geom_point(data = metro,
             aes(x = Lon, y = Lat, alpha = Parking, size = Passengers.Daily), fill="black", shape=23) + 
  scale_alpha(range = c(0.4, 0.8)) 

## Zoom North Bethesda
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
  geom_point(aes(x = New.Lon, y = New.Lat), fill="red", shape=21, alpha=0.3, size = 1) +
  geom_point(data = metro,
             aes(x = Lon, y = Lat, alpha = Parking, size = Passengers.Daily), fill="black", shape=23) + 
  scale_alpha(range = c(0.4, 0.8)) 
