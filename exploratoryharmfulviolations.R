library(RColorBrewer)
library(dplyr)
library(ggplot2)
library(plyr)
library(scales)

dat <- read.csv("clean-data/Traffic_Violations_alcohol.csv", stringsAsFactors = F)

#dataframe of stops with of fatalities or injuries
dat_fatal <- dat %>%
  filter(Fatal == 'Yes' | Personal.Injury == "Yes")

#Violations by Year
dat_fatal %>%
  mutate(Year = as.numeric(format(as.POSIXct(Date.Of.Stop, format="%m/%d/%Y"),"%Y"))) %>%
  group_by(Year) %>%
  tally() %>%
  ggplot(aes(x=Year,y=n,fill=Year)) + geom_bar(stat = "identity") +
  xlab('Year')+ylab('Number of violations')+
  theme_light()+theme(legend.position = "none",plot.title = element_text(size=15),
                      axis.text.x = element_text(angle = 45, hjust = 1))+
  ggtitle("Total Harmful and Fatal Violations by Year")

#Violations by hour
dat_fatal %>%
  mutate(Time = format(as.POSIXct(dat_fatal$Time.Of.Stop, format="%H"),"%H")) %>%
  group_by(Time) %>%
  tally() %>%
  ggplot(aes(fill=n)) + geom_bar(aes(x=Time, y = n), stat = "identity") +
  ggtitle("Total Injurious and Fatal Violations per Hour")+
  xlab('Time')+ylab('Number of violations')+
  theme_light()+theme(legend.position = "none",plot.title = element_text(size=15),
                      axis.text.x = element_text(angle = 0, hjust = 1))


## Violations by weekday.
dat_fatal %>%
  mutate(Time = weekdays(as.Date(Date.Of.Stop, format="%m/%d/%Y"))) %>%
  mutate(Weekday = as.numeric(format(as.POSIXct(Date.Of.Stop, format="%m/%d/%Y"),"%w"))) %>%
  group_by(Time,Weekday) %>%
  tally() %>%
  ggplot(aes(x=reorder(Time,Weekday),y=n,fill=Time)) + geom_bar(stat = "identity") +
  xlab('Weekday')+ylab('Number of violations')+
  theme_light()+theme(legend.position = "none",plot.title = element_text(size=15),
                      axis.text.x = element_text(angle = 45, hjust = 1))+
  ggtitle("Total Harmful and Fatal Violations by Weekday")


dat_fatal %>%
  mutate(Time = months(as.Date(Date.Of.Stop, format="%m/%d/%Y"))) %>%
  mutate(Month = as.numeric(format(as.POSIXct(Date.Of.Stop, format="%M"),"%M"))) %>%
  group_by(Time,Month) %>%
  tally() %>%
  ggplot(aes(x=reorder(Time,Month),y=n,fill=Time)) + geom_bar(stat = "identity") +
  xlab('Month')+ylab('Number of violations')+
  theme_light()+theme(legend.position = "none",plot.title = element_text(size=15),
                      axis.text.x = element_text(angle = 45, hjust = 1))+
  ggtitle("Total Harmful and Fatal Violations by Month")

## Violations by race.
race = ddply(dat_fatal,.(Race),summarize,count=length(Race))
race$percent = race$count / sum(race$count) 
ggplot(data=race,aes(x=reorder(Race, -percent),y=percent,fill=factor(percent)))+
  geom_bar(stat="identity")+geom_text(aes(label=paste(round(percent*100,1),"%"),y=percent+0.012), size=5,vjust=-0.2)+
  scale_y_continuous(labels=percent)+
  xlab('Race')+ylab('percent')+
  theme_light()+theme(legend.position = "none",plot.title = element_text(size=15))+
  ggtitle("% Harmful and Fatal Violations by Race")

## Violations by Gender
gender = ddply(dat_fatal,.(Gender),summarize,count=length(Gender))
gender$percent = gender$count / sum(gender$count) 
ggplot(data=gender,aes(x=Gender,y=percent,fill=factor(percent)))+
  geom_bar(stat="identity")+geom_text(aes(label=paste(round(percent*100,1),"%"),y=percent+0.012), size=5,vjust=-0.5)+
  scale_y_continuous(labels=percent)+
  xlab('Gender')+ylab('percent')+
  theme_light()+theme(legend.position = "none",plot.title = element_text(size=15))+
  ggtitle("% Harmful and Fatal Violations by Gender")
