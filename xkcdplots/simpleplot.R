library(xkcd)
library(sysfonts)
library(ggplot2)
library(patchwork)

xrange <- range(mtcars[["mpg"]])
yrange <- range(mtcars[["wt"]])
ggplot(mtcars, aes(x = mpg, y = wt)) +
  geom_point() +
  xkcdaxis(xrange, yrange) +
  theme(text = element_text(size = 16, family = "xkcd")) +
  facet_grid(. ~ vs) +
  geom_smooth()




library(xkcd)
mydf <- tibble(x = 50:100, y = sin(x / 50) + rnorm(length(x), 0, 0.025))
xrange <- range(mydf[["x"]])
yrange <- range(mydf[["y"]])

p1 <- mydf |> ggplot(aes(x = x, y = y)) +
  geom_point(size = 3) +
  xkcdaxis(xrange, yrange) +
  geom_smooth(method = lm, level = 0.999) +
  theme_xkcd() +
  theme(text = element_text(size = 20, family = "xkcd")) +
  theme(axis.text.x = element_blank()) +
  theme(axis.text.y = element_blank()) +
  ggtitle("Underfit")
p2 <- mydf |> ggplot(aes(x = x, y = y)) +
  geom_point(size = 3) +
  xkcdaxis(xrange, yrange) +
  geom_smooth(method = lm, formula = y ~ poly(x, 15), level = 0.999) +
  #geom_smooth(method = loess, span = 1/100000, n=100, level = 0.999) +
  theme_xkcd() +
  theme(text = element_text(size = 20, family = "xkcd")) +
  theme(axis.text.x = element_blank()) +
  theme(axis.text.y = element_blank()) +
  ggtitle("Overfit")
p3 <- mydf |> ggplot(aes(x = x, y = y)) +
  geom_point(size = 3) +
  xkcdaxis(xrange, yrange) +
  geom_smooth(method = lm, formula = y ~ sin(x / 50), level = 0.999) +
  theme_xkcd() +
  theme(text = element_text(size = 20, family = "xkcd")) +
  theme(axis.text.x = element_blank()) +
  theme(axis.text.y = element_blank()) +
  ggtitle("Perfect")
p1 + p2 + p3

ggsave("overunderfit.png")
