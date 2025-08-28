#Setup
library(sf)
library(tidyverse)

#Creating directory to save the data files
if(!dir.exists('data')) dir.create('data')

#Set end year
#As of August 2025 the available end years for datasets are 2019-2024
#Start year is 1950 for all tornado datasets
year_end <- "2024"

#Generating URL for the data file download
dld_url <- paste("https://www.spc.noaa.gov/gis/svrgis/zipped/1950-", year_end, "-torn-aspath.zip", sep="")

#Fetching SVRGIS tornado tracks data layer (shapefile)
temp_noaa <- tempfile()
torn_shp <- download.file(dld_url, temp_noaa)
zip::unzip(zipfile = temp_noaa, exdir = "data/", junkpaths = TRUE)

#Reading in the shapefile as spatial dataframe
torn <- sf::st_read(paste("data/1950-",year_end, "-torn-aspath.shp", sep=""))

#Removing temp objects
rm(dld_url, temp_noaa, torn_shp, year_end)

#Sample cleaning:

#Subset by year
torn <- torn %>%
  filter(yr>=1970 & yr<=2010, na.rm=TRUE)

#Subset by magnitude
torn <- torn %>%
  filter(mag>=2, na.rm=TRUE)

#Preparing for spatial join with census data:

#Fixing coordinate reference system to match census
#Assuming you will use tigris to load TIGER/Line shapefiles
#TIGER/Line shapefiles typically use NAD83 CRS (ESPG: 4269)
st_crs(torn) #Original SVRGIS download uses WGS 84 instead (ESPG: 4326)
torn <- st_set_crs(torn, 4269)
torn <- st_transform(torn, 4269)
st_crs(torn) #Checking that the CRS transformation applied correctly

#Saving subset, NAD83 version of the tornado data
saveRDS(torn, file = "data/torn.rds")
