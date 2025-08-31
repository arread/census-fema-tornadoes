# About
This code provides examples of how to access (via API), download, filter, prepare, and merge data from the NOAA/NWS Severe Weather GIS Database (SVRGIS) Tornado Tracks paths dataset, the OpenFEMA Disaster Declarations Summaries dataset, and data from the Decennial Census and American Community Survey (ACS). 

Walkthroughs are provided for 

- Merging FEMA disaster declarations to SVRGIS tornado paths data based on incident date and location to determine which tornado events were eventually declared as major disasters
- Performing a spatial join between tornado paths and Census geographies (intersection of line and polygon) to identify geographic areas that were exposed to tornadoes during the user-specified timeframe.
- Accessing wind and hail paths data from SVRGIS and performing a spatial join between those datasets and Census data.

This template can be extended to access and merge other OpenFEMA datasets based on incident (such as Public Assistance or Individual Assistance summary data), and any other geographic level of Census boundaries of interest to the researcher. 

This is a revised, streamlined, and more generalizable version of the code used to access, merge, and clean the data for the manuscript [Read, A. (2025). Repeated disaster and the economic valuation of place: Temporal dynamics of tornado effects on housing prices in the United States, 1980–2010. Population and Environment, 47(3), 29](https://doi.org/10.1007/s11111-025-00502-w). The actual code used for analysis of that paper is available in a dedicated repository [here](https://github.com/arread/2025-repeated-disaster-economic-valuation).

# Scripts
The import scripts can be run in any order, but the spatial merge script must be run last. The scripts included in this example are:
1. `Import tornadoes.R`: Accesses, downloads, filters, and saves tornado tracks (paths) data from the SVRGIS database. These can also be downloaded manually from https://www.spc.noaa.gov/gis/svrgis/. Other SVRGIS data can be accessed the same way, including their wind and hail datasets.
2. `Import FEMA declarations.R`: Accesses, downloads, and saves FEMA Disaster Declarations data from OpenFEMA using the R package `rfema` to access the API. These can also be downloaded from https://www.fema.gov/openfema-data-page/disaster-declarations-summaries-v2. Other OpenFEMA can be accessed the same way.
3. `Import Census.R`: Accesses, downloads, and saves Census and ACS data using the `tidycensus` package. Example tables/variables are used, but users should modify the code to include variables of interest.
4. `Merge tornadoes.R`: Shows how to do spatial join and merge on census geography to combine the tornadoes, declarations, and census datasets.
5. `Import hail.R` and `Import wind.R`: Shows how to obtain wind and hail data from SVRGIS in the same way as obtaining the tornado data.
6. `Merge wind and hail.R`: A simplified version of the merge code in script 4. This one, due to limitations in identifying declared disasters due to wind/hail alone, does not merge the FEMA data the same way we do with tornadoes. Instead, this script shows only how to perform the spatial join between the Census data and the wind/hail paths.

# Obtaining Census data via API
In order to pull demographic data using `tidycensus`, you'll need a Census API key. You can request one here: https://api.census.gov/data/key_signup.html

Once your key is active, save it to your R environment with `usethis::edit_r_environ()` (you need package `usethis` installed) and add a line in the window that opens that says `CENSUS_API_KEY='YOURKEYHERE'`. Save and restart the R session. Then you will be able to use the API queries to pull ACS/Census data using the scripts here.

# Obtaining SVRGIS data with this code
There is currently no API for the SVRGIS data, and other packages aimed at helping researchers access it have been deprecated. This code uses an approach that relies on a consistent URL and file storage structure. If that changes, I will try to catch that and edit this code, but the best backup option is to go to https://www.spc.noaa.gov/gis/svrgis/ and manually download the dataset(s) you need.

I have included examples showing the download, filter, and merge with the wind and hail paths in addition to the tornado paths from SVRGIS; however, I have used the wind and hail datasets much less extensively for personal work, so the examples are not as detailed.

# Harmonizing census data boundaries
In this example, we only use one geography year (2010 Decennial Census and 2010-2014 ACS on the same 2010 geographic boundaries). If you are using Census data from other years, you must use harmonized boundaries so that the spatial join is correct for all years being investigated. One option is to use already-harmonized datasets, such as those from Social Explorer or the Longitudinal Tract Database (LTDB) which provide estimates for past years' data within 2010 boundaries. You can also do the harmonization yourself if you are so inclined. See https://s4.ad.brown.edu/projects/diversity/researcher/Bridging.htm for a brief overview of some harmonization methods and the options available.

# Tornado rating and damage levels in the SVRGIS database
Tornado ratings on the Enhanced Fujita (EF) scale are based on observed physical damage post-hoc rather than on wind speed measurements during the event. This means that the ratings themselves are a good measure of the relative level of damage that was *actually* done, not just the damage that *could* have been done. The Enhanced Fujita scale replaced the older Fujita scale in 2007. The Fujita scale contained no damage indicators and did not account for variation in construction, which in some cases led to overestimates of wind speed. The EF-scale ratings improve on this limitation and more closely align wind speed estimates with damage. These new EF-scale ratings are correlated with the older F-scale ratings in order to preserve the historical record and comparability between the two, with the primary difference being the adjusted wind speed estimates. As such, wind speed estimates from each scale are not directly comparable pre- and post-2007, but the rating numbers (e.g., F2 vs EF2) generally are. The SVRGIS dataset `mag` column uses F-scale ratings for pre-2007 events and EF-scale ratings for post-2007 events. The `fc` column in the dataset provides a flag for where unknown F-scale ratings for some tornadoes 1953-1982 were later estimated in the database in 2016 based on property loss. See the documentation at https://www.spc.noaa.gov/gis/svrgis/ for details.

For descriptions of damage indicators and wind estimates by EF-rating, see [McDonald and Mehta, 2006](https://digitalcommons.unl.edu/usdeptcommercepub/602/) or Summary Table 1 in [Read, 2025](https://doi.org/10.1007/s11111-025-00502-w).

For the wind dataset, `mag` refers to wind speed in knots (1 knot = 1.15 mph). In the hail dataset, `mag` refers to the hail size in inches.

# FEMA Disaster Declarations and assistance
Documentation on the OpenFEMA Disaster Declarations Summaries dataset (V2) can be found on [the OpenFEMA site](https://www.fema.gov/openfema-data-page/disaster-declarations-summaries-v2). This dataset contains raw, unedited data from the National Emergency Management Information System (NEMIS). Disaster declarations are determined by state and county. As such, it is difficult to get more granular estimates of where the damage occurred within the declared counties without also obtaining the geospatial data on storm/event exposure. Part of what this code demonstrates is how to link geospatial data on disaster events (like tornadoes) to FEMA event-specific data by matching location (county, state) with the timeframe (year, month, and day) of the incident.

This distinction is important because although disaster declarations and federal funding for recovery are disbursed at the county level, it is far more likely that those funds will be directed toward Public Assistance projects in the directly affected locations (cities, tracts) or Individual Assistance grants for people living in the affected areas. Essentially, combining data in this way provides a proxy measure for a tract-level dataset of where federal disaster funds are intended to go after events.

**A note on program types:** If you are interested in Individual Assistance declarations, you should use *both* the data on IHP (Individuals and Households Program) and IA (Individual Assistance), since both are included when a county is declared eligible for IA. These are two separate columns in the Disaster Declarations Summaries datasets, and researchers should check if either of them is flagged in order to get the full count of IA declared eligible counties. Public Assistance (PA) and Hazard Mitigation (HM) are each only one column in this dataset.

