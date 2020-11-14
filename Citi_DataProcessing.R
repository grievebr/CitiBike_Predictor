library(mgcv); library(dplyr)

load("C:/Users/griev/Documents/TDI/citibike/bikes2017.RData")
bikes$ride = 1;

# Remove stations with inadequate data
nanstation_init = c(395, 3148, 3155, 3040, 3245, 3485, 3197, 3636, 3596,  153, 3464, 3239, 3550);

# Fall subset
bikes_fall = bikes[which(bikes$month>=9 & bikes$month<=11),]
bikes_fall = bikes_fall[-which(is.element(bikes_fall$Start.Station.ID,nanstation_init)),]
stations = aggregate(bikes_fall$ride,by=list(bikes_fall$Start.Station.ID),FUN=sum); names(stations) = c('Start.Station.ID','rides')
totalrides = aggregate(bikes_fall$ride,by=list(bikes_fall$Start.Station.ID, bikes_fall$jday),FUN=sum); names(totalrides) = c('ID','jday','rides')
stationmean = aggregate.data.frame(bikes_fall,by=list(bikes_fall$Start.Station.ID, bikes_fall$jday),FUN=mean)
stationmean$totalrides = totalrides$rides;
stationmean = stationmean[-which(stationmean$Start.Station.Latitude>40.83375 | stationmean$Start.Station.Longitude>-73.9),]

# Set Julian Day and weekend flag
names(stationmean)[1:2] = c('ID','jday')
stationmean$weekend = 0;
stationmean[stationmean$weekday==1 | stationmean$weekday==2,'weekend'] = 1;

# Get unique stations
u_stid = unique(data.frame(Start.Station.ID=stationmean$Start.Station.ID, Start.Station.Latitude=stationmean$Start.Station.Latitude, Start.Station.Longitude = stationmean$Start.Station.Longitude))
u_stid = left_join(u_stid,stations)

# Model each station
nanstation = c();
gamlist = c();
for (i in 1:nrow(u_stid)){
  id = u_stid[i,1]
  datasub = subset.data.frame(stationmean,stationmean$Start.Station.ID==id)
  if (nrow(datasub)<=14){
    nanstation[length(nanstation)+1] = i;
    next
  }
  gamlist[[i]] = gam(totalrides~factor(weekend)+s(TMAX,k=5)+s(PRCP,k=5)+s(AWND,k=5),data=datasub,family='poisson', select = TRUE)}

