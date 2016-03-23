library(dplyr)
library(ggplot2)

dat <- read.csv("Traffic_Violations.csv", stringsAsFactors = F)

## Accidents by minute.
dat %>%
  mutate(Time = as.POSIXct(Time.Of.Stop, format="%H:%M:%S")) %>%
  group_by(Time) %>%
  tally() %>%
  ggplot() + geom_bar(aes(x=Time, y = n), stat = "identity") +
  theme_bw() + ggtitle("Total Accidents per Hour")

## Accidents by weekday.
dat %>%
  mutate(Time = weekdays(as.Date(Date.Of.Stop, format="%m/%d/%Y"))) %>%
  group_by(Time) %>%
  tally() %>%
  ggplot() + geom_bar(aes(x=Time, y = n), stat = "identity") +
  theme_bw() + ggtitle("Total Accidents per Weekday")

## Accidents by month.
dat %>%
  mutate(Time = months(as.Date(Date.Of.Stop, format="%m/%d/%Y"))) %>%
  group_by(Time) %>%
  tally() %>%
  ggplot() + geom_bar(aes(x=Time, y = n), stat = "identity") +
  theme_bw() + ggtitle("Total Accidents per Month")

## Accidents by race.
dat %>%
  group_by(Race) %>%
  tally() %>%
  ggplot() + geom_bar(aes(x=Race, y = n), stat = "identity") +
  theme_bw() + ggtitle("Total Accidents per Month")

## Geo-mapping.
test.dat <- dat %>%
  select(Latitude, Longitude) %>%
  filter(!is.na(Latitude)) %>%
  head(100)

test.dat <- round(test.dat, 4)

write.csv(test.dat, "test.csv", row.names = F)
