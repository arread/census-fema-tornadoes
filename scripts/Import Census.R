#Setup
library(tidyverse)
library(sf)
library(tidycensus)

#Setting cache option for shapefiles
options(tigris_use_cache = TRUE)

#Creating directory to save the data files
if(!dir.exists('data')) dir.create('data')

#Setting list of states to include
state_codes <- c("AL", "AZ", "AR", "CO", "FL", "GA", "IL",
                 "IN", "IA", "KS", "KY", "LA", "MA", "MI",
                 "MN", "MS", "MO", "MT", "NE", "NY", "NC",
                 "ND", "OH", "OK", "PA", "SC", "SD", "TN",
                 "TX", "VA", "WV", "WI")

#Getting census data with tidycensus
#To explore metadata on available tables/geographies/variables, use the tidycensus function load_variables()

#Example: Fetching decennial census data and geographies
census_2010 <- get_decennial(geography = "tract",
                             variables = c(pop_10 = "P001001", #total pop
                                           units_10 = "H003001", #total housing units
                                           occ_10 = "H003002", #total occupied units
                                           rntd_10 = "H004004", #renter occupied units
                                           own_10 = "H014002"), #owner occupied units
                                            #add other variables from 2010 decennial census as needed
                             state = state_codes,
                             year = 2010,
                             output = "wide",
                             geometry = TRUE, #keep this on; need it for spatial join
                             keep_geo_vars = TRUE) #you want these too

#Example: Fetching ACS data and geographies:
acs_2010_2014 <- get_acs(geography="tract",
                         variables = c(val_10 = "B25107_001", #median house value for all owner-occupied units
                           rent_10 = "B25111_001"),#median gross rent
                         year=2014, #we want the 2010-2014 values
                         state = state_codes,
                         output = "wide",
                         geometry = TRUE,
                         keep_geo_vars = TRUE)

#Saving the census datasets
saveRDS(census_2010, file = "data/census_2010.rds")
saveRDS(acs_2010_2014, file = "data/acs_2014.rds")
