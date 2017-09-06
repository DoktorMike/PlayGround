library(ggplot2)
library(scales)
library(tibble)

x <- rgamma(5000, 0.5, 1); quantile(x); mean(x); qplot(x)

mydf <- tibble(TV=rnorm(5000, 0.5, 0.2), Radio=rgamma(5000, 0.5, 1)) %>% gather(Media, ROI)
group_by(mydf, Media) %>% summarise(mean(ROI), min(ROI), max(ROI))
ggplot(mydf, aes(x=ROI, group=Media, fill=Media)) + geom_histogram() + theme_minimal() +
  scale_fill_brewer(type = "qual", palette = 6) + facet_grid(.~Media) + geom_vline(xintercept = 0.5) +
  ylab("Probability")
ggplot(mydf, aes(x=ROI, group=Media, fill=Media)) + geom_density(alpha=0.5) + theme_minimal(base_size = 15) +
  scale_fill_brewer(type = "qual", palette = 6) + facet_grid(.~Media) + geom_vline(xintercept = 0.5) +
  ylab("Probability")
