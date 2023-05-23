library(ggplot2)
library(tibble)
library(lubridate)
library(nord)
library(bammm)

mydf <- tibble(
    Year = c(ymd("1870-01-01"), ymd("1973-01-01"), ymd("2004-01-01"), ymd("2012-01-01"), ymd("2022-01-01")),
    Invention = factor(
        c("Telephone", "Mobile Phone", "Facebook", "Candy Crush Saga", "ChatGPT"),
        levels = c("Telephone", "Mobile Phone", "Facebook", "Candy Crush Saga", "ChatGPT")
    ),
    Time = c(70, 16, 5, 3, 0.166)
)

mydf %>% ggplot(aes(x = Invention, y = Time)) +
    geom_bar(stat = "identity", fill = nord("frost")[4]) +
    # geom_bar(stat = "identity") +
    # scale_y_log10() +
    ylab("Years to reach 100 million users") +
    geom_label(aes(label = paste(year(Year), "-", Time, "years")),
        nudge_y = 3
    ) +
    #theme_minimal(base_size = 20) +
    theme_dracula()
ggsave("100million.png")
