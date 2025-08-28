#About
This code example shows how to pull and integrate data on tornado tracks (from NOAA/NWS SVRGIS database) and FEMA disaster declarations (from OpenFEMA) with demographic data from the Decennial Census and American Community Survey.

#Obtaining Census data via API
In order to pull demographic data using `tidycensus`, you'll need a Census API key. You can request one here: https://api.census.gov/data/key_signup.html

Once your key is active, save it to your R environment with `usethis::edit_r_environ()` (you need package `usethis` installed) and add a line in the window that opens that says `CENSUS_API_KEY='YOURKEYHERE'`. Save and restart the R session. Then you will be able to use the API queries to pull ACS/Census data using the scripts here.

#Scripts
The import scripts can be run in any order, but the spatial merge script must be run last. The scripts included in this example are:
1. `Import tornadoes.R`: Accesses, downloads, filters, and saves tornado tracks (paths) data from the SVRGIS database. These can also be downloaded manually from https://www.spc.noaa.gov/gis/svrgis/. Other SVRGIS data can be accessed the same way, including their wind and hail datasets.
2. `Import FEMA declarations.R`: Accesses, downloads, and saves FEMA Disaster Declarations data from OpenFEMA using the R package `rfema` to access the API. These can also be downloaded from https://www.fema.gov/openfema-data-page/disaster-declarations-summaries-v2. Other OpenFEMA can be accessed the same way.
3. `Import Census.R`: Accesses, downloads, and saves Census and ACS data using the `tidycensus` package. Example tables/variables are used, but users should modify the code to include variables of interest.

#Harmonizing census data boundaries