# census-fema-tornadoes
How to pull and integrate data on tornado tracks and FEMA disaster declarations with census data

#Obtaining Census data via API
In order to pull demographic data using `tidycensus`, you'll need a Census API key. You can request one here: https://api.census.gov/data/key_signup.html

Once your key is active, save it to your R environment with `usethis::edit_r_environ()` (you need package `usethis` installed) and add a line in the window that opens that says `CENSUS_API_KEY='YOURKEYHERE'`. Save and restart the R session. Then you will be able to use the API queries to pull ACS/Census data using the scripts here.

#Run scripts in which order

#Harmonizing census data boundaries