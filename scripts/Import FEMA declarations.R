
#pulling data via API
my_filters <- list(state = state_codes, fyDeclared = "<= 2020", fyDeclared = ">=1970", incidentType = "Tornado")
fema_dd <- open_fema(data_set = "DisasterDeclarationsSummaries", filters = my_filters)
glimpse(fema_dd)

#filtering to pre-2020 declarations and fixing date columns for merge later
fema_dd$date <- as.integer(format(as.Date(substr(fema_dd$incidentBeginDate, start=1, stop=10)), "%Y%m%d"))
fema_dd$fipsCountyCode <- str_pad(fema_dd$fipsCountyCode, 3, pad = "0")
fema_dd$fipsStateCode <- str_pad(fema_dd$fipsStateCode, 2, pad = "0")
fema_dd$yrmo <- substr(fema_dd$date, start=1, stop=6)
fema_dd$yr <- as.numeric(substr(fema_dd$date, start=1, stop=4))
fema_dd <- fema_dd %>% filter(yr<2010)
glimpse(fema_dd)
saveRDS(fema_dd, file = "data/fema_dd.rds")
