#Setup
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(sf)) install.packages("sf")

library(tidyverse)
library(sf)

census <- readRDS("data/census_2010.rds")
fema_dd <- readRDS("data/fema_dd.rds")
torn <- readRDS("data/torn.rds")

#joining tornadoes to 2010 geographies using intersection (this example uses the 2010 decennial census)
geo_torn <- st_join(census, torn, join = st_intersects,
                    suffix = c(.geo, .torn), left = TRUE)
glimpse(geo_torn)

#joining tornadoes to FEMA disaster declarations by date and location of event
geo_torn$date <- as.integer(format(as.Date(geo_torn$date), "%Y%m%d"))
geo_torn$yrmo <- substr(geo_torn$date, start=1, stop=6) #get year-month string (NOTE: move this to tornadoes script to match FEMA)

fema_dd$fips <- as.character(paste(fema_dd$fipsStateCode, fema_dd$fipsCountyCode, sep = "")) #get state-county FIPS string
geo_torn$fips <- as.character(paste(geo_torn$STATEFP, geo_torn$COUNTYFP, sep = "")) #get state-county FIPS string

geo_torn <- merge(geo_torn, fema_dd, by=c("yrmo", "fips"), all.x=TRUE)
geo_torn <- geo_torn %>%
  select(-c("NAME.x", "NAME.y")) %>%
  rename(torn_yr = yr.x, torn_date = date.x, fema_yr = yr.y, fema_date = date.y)
glimpse(geo_torn)

#declaration status binary variables (by event-geography pair at this state; we'll aggregate in a moment)
#both IA and IHP ("ihProgramDeclared") are part of Individual Assistance
# PA = Public Assistance
# DD = Major Disaster Declaration

geo_torn$IA <- as.numeric(ifelse(is.na(geo_torn$iaProgramDeclared) & is.na(geo_torn$ihProgramDeclared), "0",
                                  ifelse(geo_torn$iaProgramDeclared==1 | geo_torn$ihProgramDeclared==1, "1", "0")))


geo_torn$PA <- as.numeric(ifelse(is.na(geo_torn$paProgramDeclared), "0",
                                  ifelse(geo_torn$paProgramDeclared==1, "1", "0")))


geo_torn$DD <- as.numeric(ifelse(is.na(geo_torn$femaDeclarationString), "0", "1"))

glimpse(geo_torn)

#creating binary exposure variable for this timeframe (2000-2010)
geo_torn$Tx_10 <- as.numeric(ifelse(is.na(geo_torn$om), "0", "1"))
glimpse(geo_torn)

#creating exposure frequency variable for this timeframe (2000-2010)
geo_torn <- geo_torn %>%
  add_count(GEOID, wt = Tx_10) %>%
  rename(freq = n)
glimpse(geo_torn)

#creating highest magnitude event variable for this timeframe (2000-2010) and aggregating the FEMA vars I want
#If there are other EVENT-SPECIFIC items you want to use, aggregate them here first
#We will be removing duplicate tract rows from the main dataset so event data will be lost if not aggregated first
#If you are looking at more than one defined time period, repeat this code block using appropriate year filters
#Then merge all the aggregated dfs with the main df
agg_df <- geo_torn %>%
  select(GEOID, mag, IA, PA, DD, Tx_10, freq) %>%
  filter(Tx_10==1) %>%
  group_by(GEOID) %>%
  mutate(IA_agg=max(IA, na.rm=TRUE), PA_agg=max(PA, na.rm=TRUE), DD_agg=max(DD, na.rm=TRUE), mag_agg=max(mag, na.rm=TRUE)) %>%
  select(-c("IA", "PA", "DD", "mag"))%>%
  rename(IA_10=IA_agg, PA_10=PA_agg, DD_10=DD_agg, mag_10=mag_agg)%>%
  filter(duplicated(GEOID)==FALSE)%>% #removing duplicates now that we've aggregated across events by geography
  mutate_all(~replace(., is.na(.), 0))%>% #replacing NA with 0 for the frequency/mag/DD counts
  st_drop_geometry() #we don't need duplicate geometry since we are merging right back with the other spatial df

glimpse(agg_df)

#filtering main dataset to just the ID and Census variables (specific to tract, NOT event)
geo_torn <- geo_torn %>% select(c(GEOID, STATE, COUNTY, TRACT, CENSUSAREA,
                                  pop_10, units_10, occ_10, rntd_10, own_10))

glimpse(geo_torn)

#merging aggregated values back into the tract df
geo_torn <- geo_torn %>%
  left_join(agg_df, by="GEOID")

glimpse(geo_torn)

#You now have a merged, filtered spatial dataframe for your defined time period(s) that can be used in analysis.
#Saving to folder:
saveRDS(geo_torn, file = "data/merged_torn.rds")
