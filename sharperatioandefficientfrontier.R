library(ggplot2)
library(scales)
library(tibble)

softplus <- function(x) log(1+exp(x))

fakereward <- function(x) runif(length(as.vector(x)), 0.2, 2*as.vector(x)+1)

mydf <- tibble(Risk=runif(150, 0.2, 1), Reward=fakereward(Risk), Sharpe=Reward/(Risk+0.5))
mydf %>% arrange(Sharpe) %>% tail
qplot(mydf$Risk, mydf$Reward) + xlab("Risk") + ylab("ROI") +
  ggtitle("Media Mixes") + theme_minimal(base_size = 18) +
  scale_x_continuous(labels = percent, limits = c(min(mydf$Risk), 1)) +
  ylim(0, max(mydf$Reward)+0.2) + geom_point(aes(
    y = mydf$Reward[which.max(mydf$Sharpe)],
    x = mydf$Risk[which.max(mydf$Sharpe)],
    color = "red",
    size = 3
  )) + theme(legend.position = "none")
ggsave("portfolio.png")
