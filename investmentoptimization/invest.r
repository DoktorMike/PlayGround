library(tibble)
library(dplyr)
library(ggplot2)
library(nord)

sigmoid <- function(x, a) 1 / (1 + exp(-(x / a - 5)))
effect <- function(x, a, b) (sigmoid(x, a) - sigmoid(0, a)) * b
profit <- function(x, a, b, m) effect(x, a, b) * m
netprofit <- function(x, a, b, m) profit(x, a, b, m) - x
roi <- function(x, a, b, m) profit(x, a, b, m) / x
mroi <- function(x, a, b, m) profit(x, a, b, m) - profit(x - 1, a, b, m)

mypars <- c(a = 100000, b = 100000, m = 11)
myeffect <- function(x) effect(x, mypars[["a"]], mypars[["b"]]) #+ rnorm(length(x), 10000, 1000)
myprofit <- function(x) myeffect(x) * mypars[["m"]]
mynetprofit <- function(x) myprofit(x) - x
myroi <- function(x) myprofit(x) / x
mymroi <- function(x) myprofit(x) - myprofit(x - 1)

# curve(myroi(x), 0, 10e5)
# curve(mymroi(x), 0, 10e5)
# curve(myprofit(x), 0, 10e5)

mydf <- tibble(
    Investment = seq(0, 1.4e6, 1e4), Sales = myeffect(Investment),
    Profit = myprofit(Investment),
    NetProfit = mynetprofit(Investment),
    ROI = myroi(Investment),
    mROI = mymroi(Investment)
) %>% dplyr::mutate(Optimal = abs(c(0, diff(mROI > 1))))

