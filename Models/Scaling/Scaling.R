
#########
# Result Synthesis for Scaling Sensitivity
#########


# source functions
setwd(paste0(Sys.getenv("CN_HOME"),'/Models/Scaling'))
source('ScalingSensitivity.R')
source('ScalingAnal.R')

# libraries
#library(ggplot2)


# Parameters
WorldWidth = 1000
Pmax = 10000
d0=100 # in case constant
r0=6 # idem
alpha=0.5
lambda=1
beta=0.8
theta=0.05
N=15
kernel_type = "gaussian"

# single run
#d=spatializedExpMixtureDensity(WorldWidth,N,r0,r0,Pmax,alpha,theta,kernel_type)
#persp3D(z=d)
#emp = empScalExp(theta,lambda,beta,d)
#th = scalExp(theta,beta)
#emp
#th

# Multiple curves


thetas = 10^(seq(from=-3,to=-1,by=0.1))
#betas = seq(from=1.05,to=1.5,by=0.05)
betas = seq(from=0.5,to=1.5,by=0.1)

Nrep_emp = 10

theta=c();emp=c();empsd=c();th=c();beta=c();
for(b in betas){
  show(b)
  beta=append(beta,rep(b,length(thetas)));
  theta=append(theta,thetas);
  th=append(th,sapply(thetas,scalExp,b));
  # compute empirical
  empvals=matrix(0,Nrep_emp,length(thetas))
  for(k in 1:Nrep_emp){
   show(k)
   d=spatializedExpMixtureDensity(WorldWidth,N,r0,r0,Pmax,alpha,0.001,kernel_type);
   empvals[k,]=sapply(thetas,empScalExp,lambda,b,d)
  }
  emp=append(emp,apply(empvals,2,mean));empsd=append(empsd,apply(empvals,2,sd))
}



# save data
d = data.frame(theta,emp,empsd,th,beta)
write.csv(d,file=paste0("res/emp-th_expl_",kernel_type,"_",format(Sys.time(), "%a-%b-%d-%H:%M:%S-%Y"),".csv"))

# draw the plot using ggplot

#d = read.csv('res/emp-th_expl_Tue May 26 16:01:41 2015.csv')
d = read.csv('res/emp-th_expl_gaussian_ven.-juin-12-07:55:25-2015.csv')


# 1) Th/emp
library(ggplot2)
p = ggplot(d,aes(x=theta,y=th))+ geom_point(aes(x=theta,y=emp,colour=beta,group=beta))#+ geom_line(aes(x=theta,y=th,colour=beta,group=beta)) 
    p + geom_errorbar(aes(y=emp,ymin=emp-empsd, ymax=emp+empsd,colour=beta),width=0.001) 

#ggplot(data.frame(theta,th,beta),aes(x=theta,y=th,colour=beta)) + geom_line(aes(group=beta))



#+ ggtitle("")
     #+ xlab("") + ylab("")


# 2) Idem with varying density and radius - th not needed
#ggplot(data.frame(theta,emp,empsd,beta))
#+ geom_points(aes(x=theta,y=emp,colour=beta,group=beta))
#+ geom_errorbar(aes(ymin=emp-empsd, ymax=emp+empsd,colour=beta), width=.01) + 
#  + ggtitle("")
#+ xlab("") + ylab("")


# 3) same as 1) but data with different kernels

# 4) TODO : two params phase diagram -> superpose two fields, actives density and employment.








