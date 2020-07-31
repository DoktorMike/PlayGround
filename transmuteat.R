library(tidyverse)
library(dplyr)
library(magrittr)


mydf <- tibble(Name=LETTERS[1:10], A=1:10, B=11:20, C=21:30) %>% 
    mutate(Total=rowSums(.[-1]))
mydf

mydf %>% mutate_at(.vars=colnames(mydf)[-1], .funs=function(x) x/sum(x))
