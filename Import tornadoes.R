#SVRGIS
if(!dir.exists('data')) dir.create('data')
temp_noaa <- tempfile()
torn_shp <- download.file('https://www.spc.noaa.gov/gis/svrgis/zipped/1950-2023-torn-aspath.zip', temp_noaa)
zip::unzip(zipfile = temp_noaa, exdir = "data/", junkpaths = TRUE)
torn_all <- sf::st_read("data/1950-2023-torn-aspath.shp")

#restricting to 1970 to 2020
torn <- torn_all %>%
  filter(yr>=1970 & yr<=2010, na.rm=TRUE)
glimpse(torn)

#restricting to F2 and above
torn <- torn %>%
  filter(mag>=2, na.rm=TRUE)
glimpse(torn)

#fixing coordinate reference system to match census
st_crs(tract_geo)
torn <- st_set_crs(torn, 4269)
torn <- st_transform(torn, 4269)
st_crs(torn)

saveRDS(torn, file = "data/torn.rds")
saveRDS(torn_all, file = "data/torn_all.rds")