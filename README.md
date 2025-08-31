# About
This code example shows how to pull and integrate data on tornado tracks (from NOAA/NWS SVRGIS database) and FEMA disaster declarations (from OpenFEMA) with demographic data from the Decennial Census and American Community Survey.

# Obtaining Census data via API
In order to pull demographic data using `tidycensus`, you'll need a Census API key. You can request one here: https://api.census.gov/data/key_signup.html

Once your key is active, save it to your R environment with `usethis::edit_r_environ()` (you need package `usethis` installed) and add a line in the window that opens that says `CENSUS_API_KEY='YOURKEYHERE'`. Save and restart the R session. Then you will be able to use the API queries to pull ACS/Census data using the scripts here.

# Scripts
The import scripts can be run in any order, but the spatial merge script must be run last. The scripts included in this example are:
1. `Import tornadoes.R`: Accesses, downloads, filters, and saves tornado tracks (paths) data from the SVRGIS database. These can also be downloaded manually from https://www.spc.noaa.gov/gis/svrgis/. Other SVRGIS data can be accessed the same way, including their wind and hail datasets.
2. `Import FEMA declarations.R`: Accesses, downloads, and saves FEMA Disaster Declarations data from OpenFEMA using the R package `rfema` to access the API. These can also be downloaded from https://www.fema.gov/openfema-data-page/disaster-declarations-summaries-v2. Other OpenFEMA can be accessed the same way.
3. `Import Census.R`: Accesses, downloads, and saves Census and ACS data using the `tidycensus` package. Example tables/variables are used, but users should modify the code to include variables of interest.
4. `Spatial merge.R`: Shows how to do spatial join and merge on census geography to combine the 3 datasets.

# Harmonizing census data boundaries
In this example, we only use one geography year (2010 Decennial Census and 2010-2014 ACS on the same 2010 geographic boundaries). If you are using Census data from other years, you must use harmonized boundaries so that the spatial join is correct for all years being investigated. One option is to use already-harmonized datasets, such as those from Social Explorer or the Longitudinal Tract Database (LTDB) which provide estimates for past years' data within 2010 boundaries. You can also do the harmonization yourself if you are so inclined. See https://s4.ad.brown.edu/projects/diversity/researcher/Bridging.htm for a brief overview of some harmonization methods and the options available.

# Tornado rating and damage levels in the SVRGIS database
Tornado ratings on the Enhanced Fujita (EF) scale are based on observed physical damage post-hoc rather than on wind speed measurements during the event. This means that the ratings themselves are a good measure of the relative level of damage that was *actually* done, not just the damage that *could* have been done. The Enhanced Fujita scale replaced the older Fujita scale (Fujita, 1971) in 2007. The Fujita scale contained no damage indicators and did not account for variation in construction, which in some cases led to overestimates of wind speed. The EF-scale ratings improve on this limitation and more closely align wind speed estimates with damage. These new EF-scale ratings are correlated with the older F-scale ratings in order to preserve the historical record and comparability between the two, with the primary difference being the adjusted wind speed estimates. As such, wind speed estimates from each scale are not directly comparable pre- and post-2007, but the rating numbers (e.g., F2 vs EF2) generally are. The SVRGIS dataset `mag` column uses F-scale ratings for pre-2007 events and EF-scale ratings for post-2007 events. The `fc` column in the dataset provides a flag for where unknown F-scale ratings for some tornadoes 1953-1982 were later estimated in the database in 2016 based on property loss. See the documentation at https://www.spc.noaa.gov/gis/svrgis/ for details.

# FEMA Disaster Declarations and assistance
