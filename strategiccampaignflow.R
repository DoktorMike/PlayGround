library(tibble)
library(ggplot2)
library(dplyr)
library(tidyr)
library(dautility)
library(scales)


x<-rep(50, 100)
a<-100

campprof <- function(p, budget=3000, lookback=10){
  rollprof <- function(y) tanh(tail(y, 1)/a) - sum(adStock(tanh(y/a), 0.8))
  tmpprof <- 0
  for(i in 3:length(p)) tmpprof <- tmpprof + rollprof(p[ifelse((i-lookback)>0, i-lookback, 1):i])
  penalty <- ifelse(any(p<0), 10000, 0)
  tmpprof - budget - penalty # - sum(adStock(p, 0.9))
}

res<-optim(par = x, fn = function(p) -campprof(p), gr = NULL, method = "SANN")
res<-optim(par = x, fn = function(p) -campprof(p), gr = NULL)

pop<-function(myt, x0=2, r=2, K=100) {
  if(myt == 0) return(x0)
  else {
    x<-pop(myt-1, x0, r, K)
    return(x*r*(1-x/K))
  }

}

# Fake campaign with flow
mypos<-function(x) {x[x<=5000]<-0; x}; x<-1:100;
p1<-qplot(seq(Sys.Date(), length.out = 100, by = "1 week"), mypos(30000*sin(x/5)+1)) + geom_line() + theme_minimal() +
  ylab("Net investment") + xlab("Weeks") + scale_y_continuous(labels = dollar)

p2<-qplot(seq(Sys.Date(), length.out = 100, by = "1 week"), (10000*(sin(x/5)+cos(x/15))+40000)/2) + geom_line() + theme_minimal() +
  ylab("Net investment") + xlab("Weeks") + scale_y_continuous(labels = dollar, limits = c(0, 30000))

mypos<-function(x) {x[x<=17000]<-0; x}; x<-1:100;
p3<-qplot(seq(Sys.Date(), length.out = 100, by = "1 week"), mypos((10000*(sin(x/5)+cos(x/15))+40000)/2)) + geom_line() + theme_minimal() +
  ylab("Net investment") + xlab("Weeks") + scale_y_continuous(labels = dollar, limits = c(0, 30000))

multiplot(p1, p2, p3, cols = 1)

