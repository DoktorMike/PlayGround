library(brms)
library(mgcv)

plotme <- function(myfit, data) {
  n <- nrow(data)
  tmppred <- predict(myfit, probs = c(0.25, 0.75))
  data %>%
    select(y) %>%
    mutate(pred = tmppred[, 1]) %>%
    mutate(lower = tmppred[, 3]) %>%
    mutate(upper = tmppred[, 4]) %>%
    ggplot(aes(x = 1:n, y = pred)) +
    geom_point() +
    geom_line() +
    geom_line(aes(x = 1:n, y = y), data = data, color = "red") +
    geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.5)
}

# simulate data using the mgcv package
dat <- mgcv::gamSim(1, n = 30, scale = 2)

# fit a simple GP model
fit1 <- brm(y ~ gp(x2), dat, chains = 2, cores = 2, backend = "cmdstan")
summary(fit1)
me1 <- conditional_effects(fit1, ndraws = 200, spaghetti = TRUE)
plot(me1, ask = FALSE, points = TRUE)

plotme(fit1, dat)

# fit a more complicated GP model
fit2 <- brm(y ~ gp(x0) + x1 + gp(x2) + x3, dat, chains = 2, cores = 2, backend = "cmdstan")
summary(fit2)
me2 <- conditional_effects(fit2, ndraws = 200, spaghetti = TRUE)
plot(me2, ask = FALSE, points = TRUE)

plotme(fit2, dat)

# fit a multivariate GP model
fit3 <- brm(y ~ gp(x1, x2), dat, chains = 2, cores = 2, backend = "cmdstan")
summary(fit3)
me3 <- conditional_effects(fit3, ndraws = 200, spaghetti = TRUE)
plot(me3, ask = FALSE, points = TRUE)

plotme(fit3, dat)

# compare model fit
LOO(fit1, fit2, fit3)

# simulate data with a factor covariate
dat2 <- mgcv::gamSim(4, n = 90, scale = 2)

# fit separate gaussian processes for different levels of 'fac'
fit4 <- brm(y ~ gp(x2, by = fac), dat2, chains = 2, cores = 2, backend = "cmdstan")
summary(fit4)
plot(conditional_effects(fit4), points = TRUE)

plotme(fit4, dat2)
