#Setup
library(tidyverse)
library(sf)

census <- readRDS("data/census_2010.rds")
acs <- readRDS("data/acs_2014.rds")
fema_dd <- readRDS("data/fema_dd.rds")
torn <- readRDS("data/torn.rds")

#joining tornadoes to 2010 geographies using intersection (this example uses the 2010 decennial census)
geo_torn <- st_join(census_2010, torn, join = st_intersects, 
                    suffix = c(.geo, .torn), left = TRUE)
glimpse(geo_torn)

#joining tornadoes to FEMA disaster declarations by date and location of event
geo_torn$date <- as.integer(format(as.Date(geo_torn$date), "%Y%m%d"))
geo_torn$yrmo <- substr(geo_torn$date, start=1, stop=6) #get year-month string (NOTE: move this to tornadoes script to match FEMA)

fema_dd$fips <- as.character(paste(fema_dd$fipsStateCode, fema_dd$fipsCountyCode, sep = "")) #get state-county FIPS string
geo_torn$fips <- as.character(paste(geo_torn$STATEFP, geo_torn$COUNTYFP, sep = "")) #get state-county FIPS string

geo_torn <- merge(geo_torn, fema_dd, by=c("yrmo", "fips"), all.x=TRUE)
glimpse(geo_torn)
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
geo_torn$binaryTx <- as.numeric(ifelse(is.na(geo_torn$om), "0", "1"))
glimpse(geo_torn)

#creating exposure frequency variable for this timeframe (2000-2010)
geo_torn <- geo_torn %>% 
  add_count(GEOID, wt = binaryTx) %>% 
  rename(freq = n)
glimpse(geo_torn)

#creating highest magnitude event variable for this timeframe (2000-2010) and aggregating FEMA vars
agg_df <- geo_torn %>% 
  select(GEOID, mag, IA, PA, DD, binaryTx, freq) %>% 
  filter(binaryTx==1) %>% 
  group_by(GEOID) %>% 
  mutate(IA_agg=max(IA, na.rm=TRUE), PA_agg=max(PA, na.rm=TRUE), DD_agg=max(DD, na.rm=TRUE), mag_agg=max(mag, na.rm=TRUE)) %>% 
  select(-c("IA", "PA", "DD", "mag"))%>% 
  rename(IA=IA_agg, PA=PA_agg, DD=DD_agg, mag=mag_agg)%>%
  filter(duplicated(GEOID)==FALSE)%>% #removing duplicates now that we've aggregated across events by geography
  mutate_all(~replace(., is.na(.), 0))%>% #replacing NA with 0 for the frequency/mag/DD counts
  st_drop_geometry() #we don't need duplicate geometry; merging right back with the other spatial df

glimpse(agg_df)

#filtering main dataset to necessary vars
geo_torn <- geo_torn %>% select(c(GEOID, CENSUSAREA, pop_10, units_10, occ_10,
                               rntd_10, own_10, om, yr, mo, dy, date, time, st,
                               mag, inj, fat, loss, len, wid, binaryTx, freq))

#merging aggregated values back
geo_torn <- geo_torn %>%
  left_join(agg_df, by="GEOID")

glimpse(geo_torn)
