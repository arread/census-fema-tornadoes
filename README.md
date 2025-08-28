# census-fema-tornadoes
How to pull and integrate data on tornado tracks and FEMA disaster declarations with census data

#census API key
In order to pull demographic data from tidycensus you'll need a Census API key. You can request one here: https://api.census.gov/data/key_signup.html

Once your key is active, save it to your R environment with `usethis::edit_r_environ()` and add a line in the window that opens that says `CENSUS_API_KEY='YOURKEYHERE'`. Save and restart the R session. Then you will be able to use the API queries to pull ACS/Census data using the scripts here.

#run scripts in which order

#harmonizing census data boundaries