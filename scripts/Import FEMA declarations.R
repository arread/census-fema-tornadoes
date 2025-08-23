#Setup
library(tidyverse)
#Install rfema directly from repo using:
#install.packages("rfema", repos = "https://ropensci.r-universe.dev")
library(rfema)

#Fetching OpenFEMA data via API:

#Setting filters
my_filters <- list(state = c("AL", "AZ", "AR", "CO", "FL", "GA", "IL", "IN", "IA",
                                            "KS", "KY", "LA", "MA", "MI", "MN", "MS", "MO", "MT",
                                            "NE", "NY", "NC", "ND", "OH", "OK", "PA", "SC", "SD",
                                            "TN", "TX", "VA", "WV", "WI"), 
                   fyDeclared = "<= 2020", #specify max fiscal year declared
                   fyDeclared = ">=1970", #specify min fiscal year declared
                   incidentType = "Tornado") #specify incident type

#Running the API data call on the DisasterDeclarationsSummaries dataset
fema_dd <- open_fema(data_set = "DisasterDeclarationsSummaries", filters = my_filters)
#R may prompt you that it has to split the API call due to a set max of 1000 records it can pull
#Tell it yes to complete the full data call

#Making adjustments to allow merge with tornado and census data:

#Adjusting incident date format
fema_dd$date <- as.integer(format(as.Date(substr(fema_dd$incidentBeginDate, start=1, stop=10)), "%Y%m%d"))

#Getting year-month and year-only date columns (we will need these later)
fema_dd$yrmo <- substr(fema_dd$date, start=1, stop=6)
fema_dd$yr <- as.numeric(substr(fema_dd$date, start=1, stop=4))

#Adjusting FIPS code format (state and county)
fema_dd$fipsCountyCode <- str_pad(fema_dd$fipsCountyCode, 3, pad = "0")
fema_dd$fipsStateCode <- str_pad(fema_dd$fipsStateCode, 2, pad = "0")

#Apply any additional filters now (example: max incident year)
fema_dd <- fema_dd %>% filter(yr<2010)

#Saving the subset OpenFEMA disaster declarations dataset
saveRDS(fema_dd, file = "data/fema_dd.rds")
