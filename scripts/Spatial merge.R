#Setup
library(tidyverse)
library(sf)

census <- readRDS("data/census_2010.rds")
acs <- readRDS("data/acs_2014.rds")
fema_dd <- readRDS("data/fema_dd.rds")
torn <- readRDS("data/torn.rds")

#joining tornadoes to 2010 geographies using intersection

#if using the decennial census data
geo_torn <- st_join(census_2010, torn, join = st_intersects, 
                    suffix = c(.geo, .torn), left = TRUE)
glimpse(geo_torn)

#creating binary exposure variable for this timeframe (2000-2010)
geo_torn$binaryTx <- as.numeric(ifelse(is.na(geo_torn$om), "0", "1"))
glimpse(geo_torn)


#creating exposure frequency variable for this timeframe (2000-2010)
geo_torn <- geo_torn %>% 
  add_count(GEOID, wt = binaryTx) %>% 
  rename(freq = n)
glimpse(geo_torn)


#creating highest magnitude event variable for this timeframe (2000-2010)
