library(tibble)
library(dplyr)
library(brms)
library(tidybayes)
library(ggplot2)
library(nord)

# Setup
if ("wideScreen" %in% ls()) wideScreen()
set.seed(42)
options(mc.cores = parallel::detectCores())

# Dependencies
source("data.r")

# Load data
mydata <- load_data()
# => list(
# =>   population = tibble(age, seniority, cell_size),
# =>   sample = tibble(age, seniority, cell_size,
# =>                   cell_counts = (detractors, neutrals, promoters))
# => )

# Modeling
priors <- c(
    prior("student_t(5, 0, 1)", class = "Intercept", dpar = "muneutral"),
    prior("student_t(5, 0, 1)", class = "Intercept", dpar = "mupromoter"),
    prior("student_t(5, 0, 1)", class = "sd", dpar = "muneutral"),
    prior("student_t(5, 0, 1)", class = "sd", dpar = "mupromoter")
)
formula <- brmsformula(
    cell_counts | trials(cell_size) ~ (1 | age) + (1 | seniority)
)
model <- brm(formula, mydata$sample, multinomial(), priors,
    control = list(adapt_delta = 0.99), seed = 42
)

# Poststratification
prediction <- mydata$population %>%
    add_predicted_draws(model) %>%
    spread(.category, .prediction) %>%
    group_by(age, .draw) %>%
    summarize(score = 100 * sum(promoter - detractor) / sum(cell_size)) %>%
    mean_hdi()

