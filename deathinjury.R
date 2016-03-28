library(RColorBrewer)
library(dplyr)
library(ggplot2)

dat <- read.csv("clean-data/Traffic_Violations_alcohol.csv", stringsAsFactors = F)

#dataframe of stops with of fatalities or injuries
dat_fatal <- dat %>%
  filter(Fatal == 'Yes' | Personal.Injury == "Yes")

#Ensure the car makes are uniform
dat_fatal$Make[dat_fatal$Make == "HOND"] = "HONDA"
dat_fatal$Make[dat_fatal$Make == "CHRYS"] = "CHRYSLER"
dat_fatal$Make[dat_fatal$Make == "MITS"] = "MITSUBISHI"
dat_fatal$Make[dat_fatal$Make == "MERC"] = "MERCURY"
dat_fatal$Make[dat_fatal$Make == "ACUR"] = "ACURA"
dat_fatal$Make[dat_fatal$Make == "CHEV"] = "CHEVROLET"
dat_fatal$Make[dat_fatal$Make == "CHEVY"] = "CHEVROLET"
dat_fatal$Make[dat_fatal$Make == "CHRY"] = "CHRYSLER"
dat_fatal$Make[dat_fatal$Make == "DODG"] = "DODGE"
dat_fatal$Make[dat_fatal$Make == "HYUN"] = "HYUNDAI"
dat_fatal$Make[dat_fatal$Make == "MADZA"] = "MAZDA"
dat_fatal$Make[dat_fatal$Make == "VOLV"] = "VOLVO"
dat_fatal$Make[dat_fatal$Make == "TOYT"] = "TOYOTA"
dat_fatal$Make[dat_fatal$Make == "VOLKS"] = "VOLKSWAGON"
dat_fatal$Make[dat_fatal$Make == "TOYO"] = "TOYOTA"
dat_fatal$Make[dat_fatal$Make == "MERCEDEZ"] = "MERCEDES"
dat_fatal$Make[dat_fatal$Make == "HYUNDIA"] = "HYUNDAI"
dat_fatal$Make[dat_fatal$Make == "INFI"] = "INFINITY"
dat_fatal$Make[dat_fatal$Make == "IZUZU"] = "ISUZU"
dat_fatal$Make[dat_fatal$Make == "NISS"] = "NISSAN"
dat_fatal$Make[dat_fatal$Make == "NISSIAN"] = "NISSAN"
dat_fatal$Make[dat_fatal$Make == "TOTY"] = "TOYOTA"

#car make and injuries
make_injury <- ggplot(dat_fatal, aes(factor(Make)))
make_injury + geom_bar() + theme(axis.text.x = element_text(angle = 90))


#car make and injuries, separated by police subagency
make_injury_agency <- ggplot(dat_fatal, aes(factor(Make), fill = SubAgency)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 90))
make_injury_agency

#seatbelts and injury??? This doesn't seem right?
#seatbelts for all alcohol related stops
seatbelt_injury <- ggplot(dat, aes(factor(Belts))) + geom_bar()
seatbelt_injury

#seatbelts for alcohol-related stops with injuries or fatalities
seatbelt_injury2 <- ggplot(dat_fatal, aes(factor(Belts))) + geom_bar()
seatbelt_injury2
