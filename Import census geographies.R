#other setup
options(tigris_use_cache = TRUE)

#setting list of states to include

state_codes <- c("AL", "AZ", "AR", "CO", "FL", "GA", "IL", "IN", "IA", "KS", "KY", "LA", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NY", "NC", "ND", "OH", "OK", "PA", "SC", "SD", "TN", "TX", "VA", "WV", "WI")


# Load census tract geographies ---------------------------------------------------------------


#GEOGRAPHIES (2010 census tracts, counties, states)
tract_geo <- map_df(state_codes, ~tracts(state=.x, cb=TRUE, year=2010))
glimpse(tract_geo)
saveRDS(tract_geo, file = "data/tract_geo.rds")