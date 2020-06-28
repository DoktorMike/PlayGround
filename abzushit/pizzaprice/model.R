library(ggplot2)
library(tidyverse)
library(readr)
library(datools)
library(car)
library(brms)

mydf <- read_csv("pizza_dataset.csv") %>%
    mutate(size = factor(size)) %>%
    mutate(type = factor(type)) %>%
    separate(ingredients, paste0("Ingredient", 1:9)) %>%
    mutate(Ingredient1 = factor(naToVal(Ingredient1, "none"))) %>%
    mutate(Ingredient2 = factor(naToVal(Ingredient2, "none"))) %>%
    mutate(Ingredient3 = factor(naToVal(Ingredient3, "none"))) %>%
    mutate(Ingredient4 = factor(naToVal(Ingredient4, "none"))) %>%
    mutate(Ingredient5 = factor(naToVal(Ingredient5, "none"))) %>%
    mutate(Ingredient6 = factor(naToVal(Ingredient6, "none"))) %>%
    mutate(Ingredient7 = factor(naToVal(Ingredient7, "none"))) %>%
    mutate(Ingredient8 = factor(naToVal(Ingredient8, "none"))) %>%
    mutate(Ingredient9 = factor(naToVal(Ingredient9, "none")))
mydf

myfit <- lm(price ~ type+size+vegetarian+dairy+fish+ingredient_count+
            Ingredient1+Ingredient2+Ingredient3+Ingredient4+Ingredient5+Ingredient6+Ingredient7+Ingredient8+Ingredient9,
        data = mydf)
myfit <- step(myfit)
summary(myfit)
preddf <- predict(myfit, interval = "pred") %>%
    as_tibble() %>%
    transmute(date = seq(as.Date("2020-01-01"),
                         length.out = nrow(mydf),
                         by = "1 day"),
              observed=mydf$price,
              estimate=fit,
              lower=lwr,
              upper=upr)
plotPrediction(preddf)

ggplot(preddf, aes(y = observed, x = estimate)) +
    geom_point() +
    geom_abline(slope = 1)

badinds <- c(164, 166, 2, 28, 31, 33, 46)
mydf[badinds,]

# BAYESIAN

myfitb <- brm(price ~ type+size+vegetarian+dairy+fish+ingredient_count, data = mydf)
# 166, 31, 46

preddf <- predict(myfitb) %>%
    as_tibble() %>%
    transmute(date = seq(as.Date("2020-01-01"),
                         length.out = nrow(mydf),
                         by = "1 day"),
              observed=mydf$price,
              estimate=Estimate,
              lower=`Q2.5`,
              upper=`Q97.5`)
plotPrediction(preddf)


