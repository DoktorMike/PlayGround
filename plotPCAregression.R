library(tibble)
library(dplyr)
library(tidyr)

if(!require(ggbiplot)){
  install.packages('devtools')
  library(devtools)
  devtools::install_github('vqv/ggbiplot')
}

plotPCAComponent <- function(mytibble, classes=NULL) {
  mypca <- prcomp(mytibble, center = TRUE, scale. = TRUE)
  if(all(!missing(classes), length(classes)==nrow(mytibble)))
    ret <- ggbiplot::ggbiplot(mypca, groups = classes, circle = TRUE, ellipse = TRUE)
  else
    ret <- ggbiplot::ggbiplot(mypca, circle = TRUE)
  ret
}


# Generate data -----------------------------------------------------------

mydf <- tibble(Flower=rnorm(100, 0, 10),
               Brand=1:100+rnorm(100,0,15),
               Style=sin(1:100))

# Plot data ---------------------------------------------------------------

plotPCAComponent(mydf) + theme_minimal()
plotPCAComponent(mydf, classes=mydf$Brand>50) + theme_minimal()
plotPCAComponent(iris[,-5], iris$Species) + theme_minimal()


# Load raw data -----------------------------------------------------------

library(readr)
macrorawdata <- read_csv("~/Downloads/macrorawdata.csv",
                         col_types = cols(`Row Labels` = col_date(format = "%Y-%m-%d")),
                         locale = locale()) %>% setNames(c('Date', 'Confidence', 'Price', 'Unemployment', 'Inflation', 'Interest'))
grouping <- factor(lubridate::year(macrorawdata$`Date`))
mydf <- macrorawdata[,-c(1,6)]
p1 <- plotPCAComponent(mydf, grouping) + theme_minimal() +
  theme(legend.position = "top") +
  scale_color_manual(values = dautility::bwsde.colors(3))

p2 <- ggbiplot::ggscreeplot(prcomp(mydf, center = TRUE, scale. = TRUE), type = 'cev') +
  theme_minimal() +
  scale_x_continuous(breaks = c(0,1,2,3,4)) +
  scale_y_continuous(limits = c(0,1), breaks = seq(0, 1, 0.1), labels = percent)

dautility::multiplot(p1, p2, cols = 2)

ggsave(filename = "pcaspace.png", plot = p1)
ggsave(filename = "pcascree.png", plot = p2)
