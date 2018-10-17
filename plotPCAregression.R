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
