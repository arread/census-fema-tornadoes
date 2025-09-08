#Setup
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(sf)) install.packages("sf")

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
ds <- "hail"

#Set data type
#Options are paths ("aspath") or initial points ("initpoint")
#This example only shows how to work with paths
type <- "aspath"

#Generating URL for the data file download (example: hail)
dld_url <- paste("https://www.spc.noaa.gov/gis/svrgis/zipped/",
                 year_start,"-", year_end, "-", ds, "-", type, ".zip", sep="")

#Fetching data layer (shapefile)
temp_noaa <- tempfile()
torn_shp <- download.file(dld_url, temp_noaa)
zip::unzip(zipfile = temp_noaa, exdir = "data/", junkpaths = TRUE)

#Reading in the shapefile as spatial dataframe
hail <- sf::st_read(paste("data/", year_start, "-",year_end, "-", ds, "-", type, ".shp", sep=""))

#Removing temp objects
rm(dld_url, temp_noaa, torn_shp, year_end, year_start, ds, type)

glimpse(hail)

#Sample cleaning:

#Subset by year (in this example we look at 2000-2010)
hail <- hail %>%
  filter(yr>=2000 & yr<=2010, na.rm=TRUE)

#Preparing for spatial join with census data:

#Fixing coordinate reference system to match census
#Assuming you will use tigris to load TIGER/Line shapefiles
#TIGER/Line shapefiles typically use NAD83 CRS (ESPG: 4269)
st_crs(hail) #Original SVRGIS download uses WGS 84 instead (ESPG: 4326)
hail <- st_set_crs(hail, 4269)
hail <- st_transform(hail, 4269)
st_crs(hail) #Checking that the CRS transformation applied correctly

#Saving subset, NAD83 version of the hail data
saveRDS(hail, file = "data/hail.rds")
