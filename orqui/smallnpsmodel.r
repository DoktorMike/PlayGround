library(tibble)
library(dplyr)
library(ggplot2)
library(tidyr)

vote1 <- as.factor(sample(LETTERS[1:5], 100, replace = T))
vote2 <- as.factor(sample(LETTERS[1:5], 100, replace = T))
x <- -50:49
nps <- tanh(0.7 * sin(x / 25) + 0.5 * cos(x / 10))

mydf <- tibble(NPS = nps, Rating1 = vote1, Rating2 = vote2)
mylm <- lm(NPS ~ Rating1 + Rating2, data = mydf)
summary(mylm)
