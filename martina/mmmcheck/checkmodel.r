library(readr)
library(ggplot2)
library(dplyr)
library(car)

wideScreen()

modeldf <- readr::read_csv("./model-fit.csv")
modeldf

res <- modeldf[["Residual"]]
pacf(res)


resdf <- tibble(
    Test = c("Durbin-Watson", "Shapiro-Wilks", "PACF", "Box-Pierce", "Correlation test"),
    Purpose = c("Autocorrelation", "Normality", "Autocorrelation", "Autocorrelation", "Heteroskedasticity"),
    # Value = NA,
    Pass = c(
        all(abs(car::dwt(res, max.lag = 20) - 2) < 1),
        shapiro.test(res)$p.value > 0.05,
        all(abs(pacf(res, plot = FALSE)$acf[, , 1]) < 0.2),
        all(sapply(1:20, FUN = \(x) Box.test(res, lag = x)$p.value) > 0.05),
        cor.test(modeldf$Actual, modeldf$Residual)$p.value > 0.05
    )
)
resdf

modeldf %>% ggplot(aes(Residual)) +
    ggplot2::geom_histogram(aes(y = after_stat(density)), fill = nord::nord("frost")[4]) +
    ## ggplot2::geom_density() +
    stat_function(
        fun = dnorm,
        args = list(mean = mean(0), sd = sd(res)),
        lwd = 2,
        col = nord::nord("frost")[1]
    ) +
    ggplot2::theme_minimal() +
    ggplot2::scale_x_continuous(labels = scales::comma)
