#joining tornadoes to 2010 geographies

geo_torn <- st_join(tract_geo, torn, join = st_intersects, 
                    suffix = c(.geo, .torn), left = TRUE)
glimpse(geo_torn)
rm(torn, tract_geo)

#coding binary yes/no experienced tornado

geo_torn$binaryTx <- as.numeric(ifelse(is.na(geo_torn$om), "0", "1"))
glimpse(geo_torn)


#merging tornadoes and census data
#in geo_torn, GEO ID is 1400000USSTCTYTRACT# where ST is 2-digit state code, CTY is 3 digit county code, and TRACT# is 6 digit tract code
geo_torn$Geo_FIPS <- as.numeric(substr(geo_torn$GEO_ID, start=10, stop=20))
final_data <- left_join(geo_torn, census, by="Geo_FIPS")

rm(census, geo_torn)

#getting exposure by decade

#time period of exposure
final_data$Tx_80 <- ifelse(final_data$binaryTx == 1 & final_data$yr <= 1989, 1, 0)
final_data$Tx_90 <- ifelse(final_data$binaryTx == 1 & final_data$yr >= 1990 & final_data$yr <= 1999, 1, 0)
final_data$Tx_00 <- ifelse(final_data$binaryTx == 1 & final_data$yr >= 2000 & final_data$yr <= 2009, 1, 0)


#frequency of exposure

final_data <- final_data %>% 
  add_count(Geo_FIPS, wt = Tx_80) %>% 
  rename(freq_80 = n)


final_data <- final_data %>% 
  add_count(Geo_FIPS, wt = Tx_90) %>% 
  rename(freq_90 = n)


final_data <- final_data %>% 
  add_count(Geo_FIPS, wt = Tx_00) %>% 
  rename(freq_00 = n)
