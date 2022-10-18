library(brms)
library(ggplot2)
library(tibble)

# MORE FUN!
N <- 100
ts <- seq(0.1, 10, 0.1)
dat <- tibble(x1 = sin(ts) + rnorm(N, 0, 0.5), y = 1 + 2 * sin(ts) + rnorm(N, 0, 0.5))
dat %>% ggplot(aes(x = ts, y = y)) +
  geom_point() +
  geom_smooth(formula = y ~ sin(x))

# Fit a model without measurement error
fit3.1 <- brm(y ~ x1,
  data = dat,
  backend = "cmdstan",
  cores = 4,
  chains = 4,
  save_pars = save_pars(latent = TRUE)
)
summary(fit3.1)
plot(fit3.1)

# Fit a model WITH the measurement error handled
fit3.2 <- brm(y ~ me(x1, 0.5),
  data = dat,
  backend = "cmdstan",
  cores = 4,
  chains = 4,
  save_pars = save_pars(latent = TRUE)
)
summary(fit3.2)
plot(fit3.2)

mutate(dat,
  ts = ts,
  pred = predict(fit3.1)[, 1], # Prediction from simple model
  mepred = predict(fit3.2)[, 1] # Prediction using the measurement error model
) %>%
  pivot_longer(c(-x1, -ts), names_to = "type") %>%
  ggplot(aes(x = ts, y = value, color = type)) +
  geom_point() +
  geom_line() +
  theme_minimal()
