library(rstan)
library(ggplot2)
library(dplyr)
library(tidyr)
library(bayesplot)


mydf <- tibble(x = seq(1, 5, 0.2), y = 2*x+3+rnorm(length(x), 0, 2))
ggplot(mydf, aes(y=y, x=x)) + geom_point() + geom_smooth(method='lm')

modelstringprioronly <- "
/*
*Simple normal regression example
*/
data {
 int K;
}
parameters {
  vector[K] beta; //the regression parameters
  real beta0;
  real<lower=0> sigma; //the standard deviation
}
model {
  beta0 ~ normal(0,5); //prior for the intercept
  for(i in 1:K)
   beta[i] ~ normal(0,5);//prior for the slopes following Gelman 2008
}
"

modelstring <- "
/*
*Simple normal regression example
*/

data {
  int N; //the number of observations
  int K; //the number of columns in the model matrix
  real y[N]; //the response
  matrix[N,K] X; //the model matrix
}
parameters {
  vector[K] beta; //the regression parameters
  real beta0;
  real<lower=0> sigma; //the standard deviation
}
transformed parameters {
  vector[N] linpred;
  linpred = X*beta+beta0;
}
model {
  beta0 ~ normal(0,5); //prior for the intercept

  for(i in 1:K)
   beta[i] ~ normal(0,5);//prior for the slopes following Gelman 2008

  y ~ normal(linpred,sigma);
}
generated quantities {
  vector[N] y_pred;
  y_pred = X*beta+beta0; //the y values predicted by the model
}
"

m0 <- stan_model(model_code = modelstringprioronly, model_name = "linreg0")
m <- stan_model(model_code = modelstring, model_name = "linreg")

doFit <- function(m, d, n=10, priorsOnly=FALSE) {
  tmpdf <- d[sample(1:nrow(d), n),]
  sfit <- sampling(m, iter = 1000, data = list(N=nrow(tmpdf), K=1, y=tmpdf$y, X=tmpdf[,"x"]))
  sfitm <- as.matrix(sfit)
  p <- mcmc_hex(sfitm, regex_pars = "beta") + xlim(-10, 10) + ylim(-10, 10) +
    xlab("β1") + ylab("β0")
  if(priorsOnly) p <- p + ggtitle("Priors only - No data")
  else p <- p + ggtitle(paste0("Priors and ", n, " data points"))
  p <- p + geom_point(aes(y=3, x=2), size=3, color='red')
  p
}

plotList <- list(doFit(m0, mydf, 10, priorsOnly = TRUE), doFit(m, mydf, 2), doFit(m, mydf, 5),
                 doFit(m, mydf, 10), doFit(m, mydf, 15), doFit(m, mydf, 20))
multiplot(plotlist = plotList, cols = 3)


