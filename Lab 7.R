



setwd('/net/nfs1/s/grad/dnv2/Desktop')
data=read.table('hier.txt')
dim(data)


Y = as.matrix(na.omit(data[,2:11]))
X = 1:10 - mean(1:10)

#looking at some data, which is technically cheating
plot(X,Y[1,])
plot(X,Y[2,])
plot(X,Y[67,])

install.packages('pscl')
library(pscl)
hist(invGammaDraws<-rigamma(10000,5,4))

#setting hyperparameters
a=5
lambda=4
m0 = 12
m1 = 1
s0.sq = 1
s1.sq = 1



N=nrow(Y)
T=ncol(Y)
M=5000


beta1 = beta0 = matrix(nrow=M, ncol=nrow(Y))

##setting starting values
tau=tau0=tau1=mu0=mu1=rep(NA,M)

beta1[1,]=1
beta0[1,]=10
tau[1] = tau0[1]=tau1[1]= mu1[1] = .3; mu0[1] = 11
mui0 = mui1 = rep(NA,N)
SUMX.sq = sum(X^2)


for(k in 2:M){
  
  
  sum.for.lambda =0
  for(i in 1:N){
    sum.for.lambda = sum.for.lambda + sum(Y[i,] - beta0[k-1,i]-beta1[k-1,i]*X)^2
  }
  #sum.for.lambda
  tau[k] =rigamma(1, N*T/2+a, 1/2*sum.for.lambda+lambda)
  
  
  
  sum.for.lambda0 =0
  for(i in 1:N){
    sum.for.lambda0 = sum.for.lambda0 + sum(beta0[k-1,i] - mu0[k-1])^2
  }
  tau0[k] =rigamma(1, N/2+a, 1/2*sum.for.lambda0+lambda)
  
  
  sum.for.lambda1 =0
  for(i in 1:N){
    sum.for.lambda1 = sum.for.lambda1 + sum(beta1[k-1,i] - mu1[k-1])^2
  }
  tau1[k] =rigamma(1, N/2+a, 1/2*sum.for.lambda1+lambda) 
  
  
  sigstar<-(N/tau0[k] + 1/s0.sq)^(-1/2)
  mustar<- (sum(beta0[k-1,])/tau0[k] + m0/s0.sq )*sigstar^2
  mu0[k] = rnorm(1, mustar, sigstar)
  
  
  sigstar<-(N/tau1[k] + 1/s1.sq)^(-1/2)
  mustar<- (sum(beta1[k-1,])/tau1[k] + m1/s1.sq )*sigstar^2
  mu1[k] = rnorm(1, mustar, sigstar)
  
  
  
  ### Fill in the blanks  
  
  sigmai0= (10/tau[k] + 1/tau0[k])^(-1/2)
  for(i in 1:N){
    mui0[i] = (sum(Y[i,])/tau[k] + mu0[k]/tau0[k])
  }
  beta0[k,] = rnorm(N, mui0*sigmai0^2, sigmai0)
  
  sigmai1 = (SUMX.sq/tau[k] + 1/tau1[k])^(-1/2)
  # SUMX.sq = sum(X^2) is defined above (outside of loop)
  for(i in 1:N){
    mui1[i] = (sum(Y[i,]*X)/tau[k] + mu1[k]/tau1[k])
  }
  beta1[k,] = rnorm(N, mui1*sigmai1^2, sigmai1)
  
  if(k%%1000==0){print(k)}
}

#Remove burn-ins
plot(seq(1, 5000), mu1, type = 'l', main = "Trace plot for mu1", xlab = "iteration")
plot(seq(1, 5000), tau1, type = 'l', main = "Trace plot for tau1", xlab = "iteration")

#Tau has high autocorrelation
plot(seq(1, 5000), tau, type = 'l', main = "Trace plot for tau", xlab = "iteration")

#Prob that a new patient will have a slope exceeding 0.5
beta1.74 = sapply(seq(11, 5000), function(i, mu1, tau1) {
  return(rnorm(1, mu1[i], sqrt(tau1[i])))
}, mu1 = mu1, tau1 = tau1)
mean(beta1.74 > 0.5)
