#Using SVRGIS wind and hail paths data

#Note that "wind" and "hail" are less specific to FEMA event type categorization
#This means you would want to filter for more than one Incident Type in the Import FEMA script
#It also means the disaster declaration may not be based on the severity of the wind measurement alone (other factors involved)
#For that reason, this script only covers merging with Census data

#Setup
library(tidyverse)
library(sf)

census <- readRDS("data/census_2010.rds")
wind <- readRDS("data/wind.rds")
hail <- readRDS("data/hail.rds")

#joining wind to 2010 geographies using intersection (this example uses the 2010 decennial census)
geo_wind <- st_join(census, wind, join = st_intersects,
                    suffix = c(.geo, .wind), left = TRUE)
glimpse(geo_wind)

#creating binary exposure variable for this timeframe (2000-2010)
geo_wind$Tx_10 <- as.numeric(ifelse(is.na(geo_wind$om), "0", "1"))
glimpse(geo_wind)

#creating exposure frequency variable for this timeframe (2000-2010)
geo_wind <- geo_wind %>%
  add_count(GEOID, wt = Tx_10) %>%
  rename(freq = n)
glimpse(geo_wind)

#creating highest magnitude event variable for this timeframe (2000-2010)
#If there are other EVENT-SPECIFIC items you want to use, aggregate them here first
#We will be removing duplicate tract rows from the main dataset so event data will be lost if not aggregated first
#If you are looking at more than one defined time period, repeat this code block using appropriate year filters
#Then merge all the aggregated dfs with the main df
agg_df <- geo_wind %>%
  select(GEOID, mag, Tx_10, freq) %>%
  filter(Tx_10==1) %>%
  group_by(GEOID) %>%
  mutate(mag_agg=max(mag, na.rm=TRUE)) %>% #for wind, this is max speed in knots reached by any event in the time period
  select(-c("mag"))%>%
  rename(mag_10=mag_agg)%>%
  filter(duplicated(GEOID)==FALSE)%>% #removing duplicates now that we've aggregated across events by geography
  mutate_all(~replace(., is.na(.), 0))%>% #replacing NA with 0 for the frequency/mag counts
  st_drop_geometry() #we don't need duplicate geometry since we are merging right back with the other spatial df

glimpse(agg_df)

#filtering main dataset to just the ID and Census variables (specific to tract, NOT event)
geo_wind <- geo_wind %>% select(c(GEOID, STATE, COUNTY, TRACT, CENSUSAREA,
                                  pop_10, units_10, occ_10, rntd_10, own_10))

#merging aggregated values back into the tract df
geo_wind <- geo_wind %>%
  left_join(agg_df, by="GEOID")

glimpse(geo_wind)

#Saving to folder:
saveRDS(geo_wind, file = "data/merged_wind.rds")


#joining hail to 2010 geographies using intersection (this example uses the 2010 decennial census)
geo_hail <- st_join(census, hail, join = st_intersects,
                    suffix = c(.geo, .hail), left = TRUE)
glimpse(geo_hail)

#creating binary exposure variable for this timeframe (2000-2010)
geo_hail$Tx_10 <- as.numeric(ifelse(is.na(geo_hail$om), "0", "1"))
glimpse(geo_hail)

#creating exposure frequency variable for this timeframe (2000-2010)
geo_hail <- geo_hail %>%
  add_count(GEOID, wt = Tx_10) %>%
  rename(freq = n)
glimpse(geo_hail)

#creating highest magnitude event variable for this timeframe (2000-2010)
#If there are other EVENT-SPECIFIC items you want to use, aggregate them here first
#We will be removing duplicate tract rows from the main dataset so event data will be lost if not aggregated first
#If you are looking at more than one defined time period, repeat this code block using appropriate year filters
#Then merge all the aggregated dfs with the main df
agg_df <- geo_hail %>%
  select(GEOID, mag, Tx_10, freq) %>%
  filter(Tx_10==1) %>%
  group_by(GEOID) %>%
  mutate(mag_agg=max(mag, na.rm=TRUE)) %>% #for hail, this is max size in inches reached by any event in the time period
  select(-c("mag"))%>%
  rename(mag_10=mag_agg)%>%
  filter(duplicated(GEOID)==FALSE)%>% #removing duplicates now that we've aggregated across events by geography
  mutate_all(~replace(., is.na(.), 0))%>% #replacing NA with 0 for the frequency/mag counts
  st_drop_geometry() #we don't need duplicate geometry since we are merging right back with the other spatial df

glimpse(agg_df)

#filtering main dataset to just the ID and Census variables (specific to tract, NOT event)
geo_hail <- geo_hail %>% select(c(GEOID, STATE, COUNTY, TRACT, CENSUSAREA,
                                  pop_10, units_10, occ_10, rntd_10, own_10))

#merging aggregated values back into the tract df
geo_hail <- geo_hail %>%
  left_join(agg_df, by="GEOID")

glimpse(geo_hail)

#Saving to folder:
saveRDS(geo_hail, file = "data/merged_hail.rds")

