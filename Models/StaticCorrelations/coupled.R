
###
#  compute morpho and network indicators
#



library(raster)

#setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Synthetic/Density'))

source('morpho.R')

raw <- raster(paste0(Sys.getenv("CN_HOME"),"/Data/PopulationDensity/raw/density_wgs84.tif"))

areasize = 500
factor=0.2
offset = 100

xvals=seq(from=1,to=nrow(raw)-areasize,by=offset)
yvals=seq(from=1,to=ncol(raw)-areasize,by=offset)
#TEST //
#xvals=seq(from=20000,to=20800,by=offset)
#yvals=seq(from=20000,to=20800,by=offset)

# coord matrix
coords = matrix(data=c(rep(xvals,length(yvals)),c(sapply(yvals,rep,length(xvals)))),nrow=length(xvals)*length(yvals))

# create // cluster
library(doParallel)
cl <- makeCluster(20)
registerDoParallel(cl)

startTime = proc.time()[3]

res <- foreach(i=1:nrow(coords)) %dopar% {
  library(raster)
  source('morpho.R')
  x=coords[i,1];y=coords[i,2];
  e<-getValuesBlock(raw,row=x,nrows=areasize,col=y,ncols=areasize)
  if(sum(is.na(e))/length(e)<0.5){
    show("computing indicators...")
    m=simplifyBlock(e,factor,areasize)
    r_pop = raster(m/100)
    r_dens = raster(m/sum(m))
    res=c(x,y,moranIndex(),averageDistance(),entropy(),rankSizeSlope(),cellStats(r_pop,'sum'),cellStats(r_pop,'max'))
  }
  else{res=c(x,y,NA,NA,NA,NA,NA,NA,NA)}
  res
}

stopCluster(cl)


# get results into data frame
vals_mat = matrix(0,length(res),length(res[[1]]))
for(a in 1:length(res)){vals_mat[a,]=res[[a]]}
v = data.frame(vals_mat);colnames(v)=c("x","y","moran","distance","entropy","slope","rsquaredslope","pop","max")


show(paste0("Ellapsed Time : ",proc.time()[3]-startTime))

purpose = '_europe50km_10kmoffset_100x100grid'

# store in data file
write.table(
  v,
  file=paste0(Sys.getenv("CN_HOME"),'/Results/Morphology/Density/Numeric/',format(Sys.time(), "%a-%b-%d-%H:%M:%S-%Y"),purpose,'.csv'),
  sep = ";",
  col.names=colnames(v)
)





