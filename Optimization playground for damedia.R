library(ggplot2)
library(scales)
library(nloptr)
f<-function(x) {
  y<-2*sin(0.3*x/pi)+4*cos(0.04*x/pi)+6
  y[x<50] <- 0
  y[x>1200] <- 0
  y
}
fp<-function(x, h=1) (f(x+h)-f(x-h))/(2*h)

x <- -100:1300; qplot(x, f(x), geom="line") + ylab("Bolognese quality f(t)") + xlab("t") + theme_minimal()

a<-numeric(100)
retdf<-data.frame(Optim=a, GN_ISRES=a, LN_COBYLA=a, LN_BOBYQA=a, LD_LBFGS=a,
                  LD_AUGLAG_EQ=a, LN_NELDERMEAD=a, NLOPT_LD_AUGLAG=a)
for(i in 1:length(a)){
  # Optim
  aret<-optim(c(sample(-100:1300, 1)), f, method = "SANN", control = list(fnscale=-1, parscale=500), lower = -100, upper=1300)

  # NLOPT_GN_ISRES
  opts <- list("algorithm"="NLOPT_GN_ISRES", "xtol_rel"=1e-8)
  bret<-nloptr(x0 = as.numeric(sample(-100:1300, 1)), eval_f = function(x) -f(x), opts = opts, lb = -100, ub = 1300)

  # NLOPT_LN_COBYLA
  opts <- list("algorithm"="NLOPT_LN_COBYLA", "xtol_rel"=1e-8)
  cret<-nloptr(x0 = as.numeric(sample(-100:1300, 1)), eval_f = function(x) -f(x), opts = opts, lb = -100, ub = 1300)

  # NLOPT_LN_BOBYQA
  opts <- list("algorithm"="NLOPT_LN_BOBYQA", "xtol_rel"=1e-8)
  dret<-nloptr(x0 = as.numeric(sample(-100:1300, 1)), eval_f = function(x) -f(x), opts = opts, lb = -100, ub = 1300)

  # NLOPT_LD_LBFGS
  opts <- list("algorithm"="NLOPT_LD_LBFGS", "xtol_rel"=1e-8)
  eret<-nloptr(x0 = as.numeric(sample(-100:1300, 1)), eval_f = function(x) -f(x),
               eval_grad_f = function(x) (-f(x+1)+f(x-1))/(2*1), opts = opts, lb = -100, ub = 1300)

  # NLOPT_LD_AUGLAG_EQ
  local_opts <- list( "algorithm" = "NLOPT_LD_MMA", "xtol_rel"  = 1.0e-7 )
  opts <- list("algorithm"="NLOPT_LD_AUGLAG_EQ", "xtol_rel"=1e-8, "local_opts" = local_opts)
  fret<-nloptr(x0 = as.numeric(sample(-100:1300, 1)), eval_f = function(x) -f(x),
               eval_grad_f = function(x) (-f(x+1)+f(x-1))/(2*1), opts = opts, lb = -100, ub = 1300)

  # NLOPT_LN_NELDERMEAD
  opts <- list("algorithm"="NLOPT_LN_NELDERMEAD", "xtol_rel"=1e-8)
  gret<-nloptr(x0 = as.numeric(sample(-100:1300, 1)), eval_f = function(x) -f(x), opts = opts, lb = -100, ub = 1300)

  # NLOPT_LD_AUGLAG
  local_opts <- list( "algorithm" = "NLOPT_LD_MMA", "xtol_rel"  = 1.0e-7 )
  opts <- list("algorithm"="NLOPT_LD_AUGLAG", "xtol_rel"=1e-8, "local_opts" = local_opts)
  hret<-nloptr(x0 = as.numeric(sample(-100:1300, 1)), eval_f = function(x) -f(x),
               eval_grad_f = function(x) (-f(x+1)+f(x-1))/(2*1), opts = opts, lb = -100, ub = 1300)

  retdf[i, 1]<-aret$value
  retdf[i, 2]<-bret$objective*-1
  retdf[i, 3]<-cret$objective*-1
  retdf[i, 4]<-dret$objective*-1
  retdf[i, 5]<-eret$objective*-1
  retdf[i, 6]<-fret$objective*-1
  retdf[i, 7]<-gret$objective*-1
  retdf[i, 8]<-hret$objective*-1
}

gather(retdf) %>% ggplot(aes(y=value, x=key, fill=key)) + geom_boxplot() + theme_minimal() + theme(axis.text.x = element_text(angle = 90, hjust = 1))

gather(retdf) %>% ggplot(aes(x=value, fill=key)) + geom_histogram() + theme_minimal()
