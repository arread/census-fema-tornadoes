#Setup
library(tidyverse)
library(tigris)
library(sf)

#Creating directory to save the data files
if(!dir.exists('data')) dir.create('data')

#Telling tigris to use the cache
options(tigris_use_cache = TRUE)

#Setting list of states to include
state_codes <- c("AL", "AZ", "AR", "CO", "FL", "GA", "IL", 
                 "IN", "IA", "KS", "KY", "LA", "MA", "MI", 
                 "MN", "MS", "MO", "MT", "NE", "NY", "NC", 
                 "ND", "OH", "OK", "PA", "SC", "SD", "TN", 
                 "TX", "VA", "WV", "WI")

#Load census tract geographies into a spatial dataframe (can be done similarly for other geographies)
#I use generalized cartographic boundaries (cb=TRUE) because I want faster rendering and 
#I do not need a high level of detail to count intersections with tornado tracks
tract_geo <- map_df(state_codes, 
                    ~tracts(state=.x, 
                            cb=TRUE,
                            year=2010))

#saving the tract geography data
saveRDS(tract_geo, file = "data/tract_geo.rds")
