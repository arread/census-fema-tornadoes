#Setup
library(sf)
library(tidyverse)

#Creating directory to save the data files
if(!dir.exists('data')) dir.create('data')

#Set end year
#As of August 2025 the available end years for datasets are 2019-2024
year_end <- "2024" #this is the most recent year

#Set start year
#Start year is 1950 for all tornado datasets, and 1955 for hail and wind
year_start <- "1955"

#Set dataset
#Options are "torn", "wind" or "hail"
ds <- "wind"

#Set data type
#Options are paths ("aspath") or initial points ("initpoint")
#This example only shows how to work with paths
type <- "aspath"

#Generating URL for the data file download (example: wind)
dld_url <- paste("https://www.spc.noaa.gov/gis/svrgis/zipped/", 
                 year_start,"-", year_end, "-", ds, "-", type, ".zip", sep="")

#Fetching data layer (shapefile)
temp_noaa <- tempfile()
torn_shp <- download.file(dld_url, temp_noaa)
zip::unzip(zipfile = temp_noaa, exdir = "data/", junkpaths = TRUE)

#Reading in the shapefile as spatial dataframe
wind <- sf::st_read(paste("data/", year_start, "-",year_end, "-", ds, "-", type, ".shp", sep=""))

#Removing temp objects
rm(dld_url, temp_noaa, torn_shp, year_end, year_start, ds, type)

glimpse(wind)

#Sample cleaning:

#Subset by year (in this example we look at 2000-2010)
wind <- wind %>%
  filter(yr>=2000 & yr<=2010, na.rm=TRUE)

#Preparing for spatial join with census data:

#Fixing coordinate reference system to match census
#Assuming you will use tigris to load TIGER/Line shapefiles
#TIGER/Line shapefiles typically use NAD83 CRS (ESPG: 4269)
st_crs(wind) #Original SVRGIS download uses WGS 84 instead (ESPG: 4326)
wind <- st_set_crs(wind, 4269)
wind <- st_transform(wind, 4269)
st_crs(wind) #Checking that the CRS transformation applied correctly

#Saving subset, NAD83 version of the wind data
saveRDS(wind, file = "data/wind.rds")
