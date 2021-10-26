library(bammm)
library(tidyverse)
library(brms)

m <- readRDS("model.rds")
summary(m)

# Helper functions
adstock <- function(media, carryover) stats::filter(media, filter = carryover, method = "rec")
filterstupid <- function(x) {
        myfilt <- grepl("adstock", names(x))
        x[myfilt] <- NULL
        myfilt <- grepl("I\\(", names(x))
        x[myfilt] <- NULL
        x
}
standardize <- function(x) (x - min(x)) / (max(x) - min(x))
destandardize <- function(x, minx, maxx) x * (maxx - minx) + minx

# Decomposition
mydecomp <- decompose(m) %>% filterstupid()
mydecompdf <- decomptodf(mydecomp) %>%
        group_by(Variable, Response) %>%
        mutate(Epoch = 1:n())

# Waterfall
mywater <- waterfall(mydecomp)
datools::plot_waterfall(mywater[[1]])
# Evolution
mydecompdf %>% ggplot(aes(x = Epoch, y = Estimate, fill = Variable)) +
        geom_bar(stat = "identity")

# Scenario 0
mydf <- m$data %>% select(-matches("adstock|I\\("))
myscen0 <- decompose(m, data = mydf) %>% filterstupid()
myscen0df <- decomptodf(myscen0) %>%
        group_by(Variable, Response) %>%
        mutate(Epoch = 1:n())
myscen0df <- myscen0df %>% # Destandardize the response
        group_by(Epoch) %>%
        summarise(Effect = sum(Estimate)) %>%
        ungroup() %>%
        mutate(Scenario = "Base") %>%
        mutate(Effect = destandardize(Effect, 27.5, 36.6))

# Scenario 1
mydf <- m$data %>% select(-matches("adstock|I\\("))
mydf[150:nrow(mydf), "paid_media_exposure"] <- 0
myscen1 <- decompose(m, data = mydf) %>% filterstupid()
myscen1df <- decomptodf(myscen1) %>%
        group_by(Variable, Response) %>%
        mutate(Epoch = 1:n())
myscen1df <- myscen1df %>% # Destandardize the response
        group_by(Epoch) %>%
        summarise(Effect = sum(Estimate)) %>%
        ungroup() %>%
        mutate(Scenario = "Cut media") %>%
        mutate(Effect = destandardize(Effect, 27.5, 36.6))

# Scenario 2
mydf <- m$data %>% select(-matches("adstock|I\\("))
mydf[150:nrow(mydf), "paid_media_exposure"] <- 0
mydf[150:nrow(mydf), "online_direct"] <- 0
mydf[150:nrow(mydf), "non_paid_sponsorships"] <- 0
myscen2 <- decompose(m, data = mydf) %>% filterstupid()
myscen2df <- decomptodf(myscen2) %>%
        group_by(Variable, Response) %>%
        mutate(Epoch = 1:n())
myscen2df <- myscen2df %>% # Destandardize the response
        group_by(Epoch) %>%
        summarise(Effect = sum(Estimate)) %>%
        ungroup() %>%
        mutate(Scenario = "Cut marketing") %>%
        mutate(Effect = destandardize(Effect, 27.5, 36.6))

## Scenarios compare
myscendf <- dplyr::bind_rows(myscen1df, myscen0df, myscen2df)
myscendf %>% ggplot(aes(x = Epoch, y = Effect, color = Scenario)) +
        geom_point() +
        geom_line() +
        theme_minimal() +
        xlab("Week number since start") +
        ylab("Preference")

write_csv(myscendf, file="scenarios.csv")
