library(xkcd)
library(sysfonts)
library(ggplot2)

xrange <- range(mtcars[["mpg"]])
yrange <- range(mtcars[["wt"]])
ggplot(mtcars, aes(x = mpg, y = wt)) +
  geom_point() +
  xkcdaxis(xrange, yrange) +
  theme(text = element_text(size = 16, family = "xkcd")) +
  facet_grid(. ~ vs) +
  geom_smooth()



