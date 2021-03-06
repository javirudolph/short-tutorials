library("extraDistr")
library("MASS")


bbnegllike <- function(guess, Yvec, ntrials=20){
  
  pos.guess <- exp(guess)
  a <- pos.guess[1]
  b <- pos.guess[2]
  
  bbnegll.vec <- dbbinom(x=Yvec, size=ntrials, alpha=a, beta=b, log=TRUE)
  
  return(-sum(bbnegll.vec))
  
}

n <- 30
a <- 2 #trute value of a
b <- 5 # true value of b
ntrials <- 20

P <- rbeta(n=n, shape1=a, shape2=b)
YgP <- rbinom(n=n, size=ntrials, prob=P)


myguess <- log(c(1.5,4))
opt.samp <- optim(par=myguess, fn=bbnegllike, method="Nelder-Mead", Yvec=YgP, ntrials=ntrials)
a.hat <- exp(opt.samp$par[1])
b.hat <- exp(opt.samp$par[2])
print(a.hat)
print(b.hat)

####  Now, using MCMC:  first a Bayesian approach.  Then Data Cloning which includes
####  the Bayesian results as a special case

library("MASS")
library(rjags)
library(parallel)
library(dclone)
library(abind)
library(R2WinBUGS)
library(RCurl)

#####  The first thing to do is to put together a function with the posterior
#####  calculations that needs to be sent to JAGS.  This function is written in 
#####  JAGS language
beta.binom <- function(){
  
  # needs:
  # a vector of counts (Y) 
  # the length of this vector (len)
  # the number of binomial trials (ntrials)
  
  # priors for a and b
  log.a~dnorm(mu.prior,precis.prior)
  a <- exp(log.a)
  
  log.b~dnorm(mu.prior,precis.prior)
  b <- exp(log.b)
  
  # Random effects model  
  for(i in 1:len){
    Prand[i] ~ dbeta(a,b)
  }

  # Likelihood (conditioned on the random effect)
  for(i in 1:len){
    Y[i] ~ dbinom(Prand[i],ntrials)
  }  

}



out.parms <- c("a","b", "Prand")
jags.list <- list(Y=YgP, len=n, ntrials=ntrials, mu.prior=0, precis.prior=0.00001)

bayesian.fit <- jags.fit(jags.list, params=out.parms, model=beta.binom, 
                         n.chains=3, n.adapt=3000, n.update=1000, n.iter=30000, thin=10)

quartz()
plot(bayesian.fit)

summary(bayesian.fit)

#####  Wed 14th October 2020
#####  Now implementing "Data Cloning", use uniform priors #######
#####  The key difference is entering the replicated (cloned) data ######
#####  How do you do that, well, you simply copy the data 'K' times #####
#####  If K=1, the results correspond to a Bayesian analysis, and   #####
#####  as K grows large, the resulting posterior converges to a MVNorm #####
#####  whose mean is equal to the MLEs and variance is equal to (1/K)*Inverse(Fisher's info) #####

DC.beta.binom <- function(){
  
  # needs:
  # a vector of counts (Y) 
  # the length of this vector (len)
  # the number of binomial trials (ntrials)
  
  # priors for a and b
  a~dunif(low.prior,high.prior)
  b~dunif(low.prior,high.prior)

 
    # Random effects model  
  for(i in 1:len){
    for(k in 1:K){    
      Prand[i,k] ~ dbeta(a,b)
    }
  }
   
   # Likelihood (conditioned on the random effect)
  for(i in 1:len){
    for(k in 1:K){
      Y[i,k] ~ dbin(Prand[i,k],ntrials)
    }  
  }
    
}


##### Simulating data:
n <- 30
a <- 2
b <- 5
ntrials <- 20

P <- rbeta(n=n, shape1=a, shape2=b)
YgP <- rbinom(n=n, size=ntrials, prob=P)

######  Bayesian fit ######
K <- 1
prior.low <- 0
prior.high <- 100
out.parms <- c("a", "b")
Ymat <- matrix(rep(YgP, K), nrow=n,ncol=K, byrow=FALSE)
dc.list <- list(Y=Ymat, len=n, ntrials=ntrials, low.prior=prior.low, high.prior=prior.high, K=K)
bayesian.fit <- jags.fit(dc.list, params=out.parms, model=DC.beta.binom, 
                         n.chains=3, n.adapt=3000, n.update=1000, n.iter=30000, thin=10)
summary(bayesian.fit)[[1]]
quartz();
plot(bayesian.fit)

Cred.Ints <- apply(bayesian.fit[[1]], 2,FUN=function(x){quantile(x,probs=c(0.025,0.5,0.975))})


#> summary(bayesian.fit)[[1]]
#Mean       SD  Naive SE Time-series SE
#a 15.17232 11.52577 0.1214923      0.9771369
#b 27.64400 20.80529 0.2193070      1.7889511

###### STRAIGHT UP NUMERICAL OPTIMIZATION MLE ESTIMATION ######
myguess <- log(c(1.5,4))
opt.samp <- optim(par=myguess, fn=bbnegllike, method="Nelder-Mead", Yvec=YgP, ntrials=ntrials)
a.hat <- exp(opt.samp$par[1])
b.hat <- exp(opt.samp$par[2])
print(a.hat)
print(b.hat)

#> print(a.hat)
#[1] 5.284635
#> print(b.hat)
#[1] 9.650745
#####################################

K <- 32
prior.low <- 0
prior.high <- 100
out.parms <- c("a", "b")
Ymat <- matrix(rep(YgP, K), nrow=n,ncol=K, byrow=FALSE)
dc.list <- list(Y=Ymat, len=n, ntrials=ntrials, low.prior=prior.low, high.prior=prior.high, K=K)
ml.fit <- jags.fit(dc.list, params=out.parms, model=DC.beta.binom, 
                         n.chains=3, n.adapt=4000, n.update=1000, n.iter=50000, thin=10)
summary(ml.fit)[[1]]
quartz();
plot(ml.fit)

#> summary(ml.fit)[[1]]
#Mean        SD    Naive SE Time-series SE
#a 5.381547 0.4683129 0.003823759     0.01139962
#b 9.828958 0.8579340 0.007005002     0.02080979

########  Wald Confidence Intervals ########

kth.post <- ml.fit[[1]]
mles <- apply(kth.post, 2,mean)
fish.inv <- K*var(kth.post)
alpha <- 0.05
z.alpha.half <- qnorm(p=(1-alpha/2))
a.std.error <- z.alpha.half*sqrt(fish.inv[1,1])
b.std.error <- z.alpha.half*sqrt(fish.inv[2,2])
a.cis <- c(mles[1]-a.std.error,mles[1], mles[1]+a.std.error)
b.cis <- c(mles[2]-b.std.error,mles[2], mles[2]+b.std.error)

CIs.mat <- rbind(a.cis,b.cis);
colnames(CIs.mat) <- c("LCL", "MLE", "UCL")
rownames(CIs.mat) <- c("a","b")
print(CIs.mat) # Compare to 
print(Cred.Ints)

#######################  ASSIDE: TO UNDERSTAND THE REST, I NEED MONTE CARLO INTEGRATION######
########  Numerical Integration example #########

#####  \int h(x)dx  = \int h(x) (f(x)/f(x)) dx
#####               = \int (h(x)/f(x))*f(x) dx
#####              == E[(h(x)/f(x))] with respect of the distribution f(x)


# Example of Monte Carlo integration
# Say I need to compute Var(Y), where Y~exp(lambda=3).
# Var(Y) = I = int_{0}^{Infty} (y-(1/lambda))^2 *lambda*exp(-y*lambda) dy

# First, set the value of lambda
lam <- 3
nsamps <- 1000000

# Now sample from another distribution with support in (0,Infty), say an exp(theta=4)
theta <- 4
y.samps <- rexp(n=nsamps, rate=theta)

mc.integrand <- (((y.samps-(1/lam))^2)*lam*exp(-y.samps*lam))/(theta*exp(-y.samps*theta))

real.var <- 1/(lam^2)
real.var
mean(mc.integrand)# LLN
##########################################################


######  Now, obtaining MCMC samples from the distribution of the hidden process
######  given the observations.  If f(y|x) is the likelihood and g(x;theta) is the
######  hidden process, then this posterior distribution is
######  h(x|y;theta) \propto f(y|x)g(x;theta)
######  which we can sample from using a simple MCMC run.


Kalman.beta.binom <- function(){
  
  # needs:
  # a vector of counts (Y) 
  # the length of this vector (len)
  # the number of binomial trials (ntrials)
  # The values of a and b = the MLES  

  # Random effects model  
  for(i in 1:len){
      Prand[i] ~ dbeta(a,b)
  }
  
  # Likelihood (conditioned on the random effect)
  for(i in 1:len){
      Y[i] ~ dbin(Prand[i],ntrials)
  }
  
}


out.parms <- c("Prand")
kalman.list <- list(Y=YgP, len=n, ntrials=ntrials, a=mles[1], b=mles[2])
kalman.samps <- jags.fit(kalman.list, params=out.parms, model=Kalman.beta.binom, 
                   n.chains=3, n.adapt=4000, n.update=1000, n.iter=50000, thin=10)
summary(kalman.samps)
quartz();
plot(kalman.samps)

save.image("BetaBinom-Up2Kalman.RData")


bo <- 1.5
b1 <- 2
sigsq <- 0.3
sig <- sqrt(sigsq)
N <- 300
x  <- runif(n=N, min=-3,max=3)
mu.x <- bo+b1*x
y  <- rnorm(n=N,mean=mu.x,sd=sqrt(sigsq))


my.lm <- function(guess,y,x){
  
  bo <- guess[1]
  b1 <- guess[2]
  sig<- exp(guess[3])
  
  mu.x <- bo+b1*x
  nllike <- -sum(dnorm(x=y,mean=mu.x,sd=sig, log=TRUE))
  return(nllike)  
  
}

lm.fit <- optim(par=c(1.5,3,log(sqrt(0.2))), fn=my.lm, method="BFGS", y=y,x=x)

bo.h <- lm.fit$par[1]
b1.h <- lm.fit$par[2]
sig.h <- exp(lm.fit$par[3])
sig.h^2

my.loglik <- -lm.fit$value

rlm.fit <- lm(y~1+x)
anova(rlm.fit)
print(logLik(rlm.fit))



binom.Ho <- function(m1,p1){
  
  n.guilds <- length(m1)
  N.vec <- m1+p1
  
  llike <- dbinom()
  
  
  
}































