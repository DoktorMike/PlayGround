library(damodel)
library(dautility)
library(dplyr)

mydf<-data.frame(tv=rbinom(300, 100, 0.005)*rnorm(300, 10, 1),
                 radio=rbinom(300, 100, 0.005)*rnorm(300, 10, 1))

resdf<-mydf %>% transmute(outer=fisk(adStock(tv, 0.5)+adStock(radio, 0.5), 10, 1),
                          inner=adStock(fisk(tv, 10, 1), 0.5) + )
