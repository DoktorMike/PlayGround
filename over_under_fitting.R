library(ggplot2)
library(dplyr)
library(tidyr)
library(tibble)

mydf <- tibble(x = seq(-30, 30, 1),
               y = 0.5*x + 0.1*x*x+ rnorm(length(x), 0, 15))

mylm1 <- lm(y~x, data=mydf)
# mylm2 <- lm(y~I(x**11)+I(x**10)+I(x**9)+I(x**8)+I(x**7)+I(x**6)+I(x**5)+I(x**4)+I(x**3)+I(x**2)+x, data=mydf)
mylm2 <- lm(y~poly(x, 50, raw = TRUE), data=mydf)
mylm3 <- lm(y~poly(x, 2, raw = TRUE), data=mydf)


resdf <- transmute(mydf, x,
                   underfit=predict(mylm1),
                   overfit=predict(mylm2),
                   correct=predict(mylm3)) %>%
  gather(Model, value, -x)

p1 <- resdf %>% ggplot(aes(y=value, x=x, color=Model)) +
  geom_line(size=1.1) +
  geom_point(aes(y=y, x=x, color="data"), data=mydf) +
  xlab("X") + ylab("Value") +
  theme_classic(base_size = 16) + scale_color_brewer(type="qual", palette = 6) +
  ggtitle("Over and Underfitting")
print(p1)
ggsave("overunderfit.png")
