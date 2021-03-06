

## Test on real data

library(dplyr)
library(sp)
library(GA)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/NetworkNecessity/InteractionGibrat'))

source('functions.R')


# load ined file
raw <- as.tbl(read.csv(paste0(Sys.getenv('CN_HOME'),'/Data/INED/VIL1831.csv'),sep=";",stringsAsFactors = FALSE))

# filter on continuity of data
rows=rep(TRUE,nrow(raw));for(j in 19:49){rows = rows&(!is.na(as.numeric(raw[[colnames(raw)[j]]])))}
raw = raw[rows,]
for(j in 19:49){raw[,j]<-as.numeric(raw[[colnames(raw)[j]]])}

raw = raw %>% arrange(desc(P1999))

Ncities = 50

cities = raw[1:Ncities,c(5:7,19:49)]
dates = c(seq(from=1831,to=1866,by=5),1872,seq(from=1876,to=1911,by=5),1912,seq(from=1921,to=1936,by=5),1946,1954,1955,1962,1968,1975,1982,1990,1999)

# quick viz
#pops=c();citynames=c();times=c();for(i in 2:nrow(cities)){pops=append(pops,unlist(cities[i,4:ncol(cities)]));citynames=append(citynames,rep(unlist(cities[i,1]),ncol(cities)-3));times=append(times,dates)}
#g=ggplot(data.frame(pops,citynames,times),aes(x=times,y=pops,colour=citynames))
#g+geom_line()
#plot(x=unlist(cities[,2]),y=unlist(cities[,3]))

## distance matrix
distances = spDists(as.matrix(cities[,2:3]))/10
## pop matrix
#real_populations = as.matrix(cities[,4:ncol(cities)])

##
#gammaGravity = 1.027532
#decayGravity = 462.5228
#growthRate = 0.0679694
#potentialWeight = 4.420431

#testModel = interactionModel(real_populations,distances,gammaGravity,decayGravity,growthRate,potentialWeight)

#g=ggplot(testModel$df[32:nrow(testModel$df),])
#g+geom_point(aes(x=times,y=populations,colour=cities),shape=2)+
#  geom_point(aes(x=times,y=gibrat_populations,colour=cities),shape=3)+
#  geom_line(aes(x=times,y=real_populations,colour=cities,group=cities))


for(t0 in seq(1,21,by=5)){
  current_dates = t0:(t0+10)
  show(current_dates)
  real_populations = as.matrix(cities[,current_dates+3])
  f =function(params){
    pops=interactionModel(real_populations,distances,params[1],params[2],params[3],params[4])$df;
    return(-sum((pops$populations-pops$real_populations)^2))}
  optim = ga(type="real-valued",fitness = f,min = c(0.75,25,0.01,0.5),max=c(2,500,0.1,5),maxiter = 50000,parallel = 10)
  save(optim,file=paste0('res/fitTw_t0',t0,'.RData'))
}


