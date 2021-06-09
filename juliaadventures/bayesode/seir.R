# remotes::install_github("seananderson/covidseir", build_vignettes = TRUE)

library(tidyverse)
library(covidseir)
library(tidybayes)
library(lubridate)
library(ggplot2)
library(datools)

owiddf <- read_csv("owid-covid-data-2021-02-07.csv") %>%
    filter(location=="Denmark") %>%
    select(date,
           new_cases, total_cases,
           new_deaths, total_deaths,
           new_tests, total_tests) %>%
    identity()
covdf <- read_csv("csse_covid_19_time_series - 2021-02-07.csv") %>%
    filter(Country=="Denmark") %>%
    filter(is.na(State)) %>%
    mutate(date=Date) %>%
    select(-Date)

mydf <- full_join(owiddf, covdf) %>%
    setNames(tolower(names(.))) %>%
    select(date, matches("new_"), matches("total_"), active, recovered) %>%
    mutate(across(where(is.numeric), naToZero)) %>%
    arrange(date) %>% filter(total_cases > 0)
# Add Sampling fraction to be 25%
mydf <- mydf %>% mutate(sampfrac = 0.25)
# Events lockdowns etc 
evdf <- tibble(date = ymd(c("2020-03-16", "2020-05-11", "2020-05-18", "2020-06-01",
                            "2020-12-16")),
               event = c("lockdown1", "opening1phase1", "opening1phase2", "opening1phase3",
                         "lockdown2"),
               value=1)
mydf <- left_join(mydf, evdf) %>%
    mutate(events=cumsum(naToZero(value))) %>%
    select(-value)

myfit <- covidseir::fit_seir(
  daily_cases = mydf$new_cases,
  samp_frac_fixed = mydf$sampfrac, 
  N_pop = 5.1e6, # DK population
  iter = 500, # number of posterior samples
  fit_type = "optimizing" # for speed only
)

obs_dat <- data.frame(day = seq_along(mydf$new_cases), value = mydf$new_cases)

p <- project_seir(myfit)

tidy_seir(p) %>% plot_projection(obs_dat = obs_dat)
