library(damodel)
library(dautility)
library(dplyr)

# Media parameters
lambda <- c(tv = 0.8, radio = 0.2, common = 0.7)
scale <- c(tv = 10, radio = 6, common = 20)
shape <- c(tv = 1, radio = 1, common = 1)

# Campaign parameters
numEpochs <- 300
numDropOuts <- 8
lengthDropOuts <- 20

# Generate data
mydf <- data.frame(
  date = seq(Sys.Date(), by = "day", length.out = nrow(mydf)),
  tv = rbinom(numEpochs, 100, 0.005) * rnorm(numEpochs, 10, 1),
  radio = rbinom(numEpochs, 100, 0.005) * rnorm(numEpochs, 10, 1)
)
mydf <- data.frame(
  date = seq(Sys.Date(), by = "day", length.out = nrow(mydf)),
  tv = rnegbin(numEpochs, 10, 10),
  radio = rnegbin(numEpochs, 10, 10)
)
# Make always on less likely
for(i in sample(1:(nrow(mydf)-lengthDropOuts), numDropOuts)){
  mydf[i:(i+lengthDropOuts), "tv"] <- 0
  mydf[i:(i+lengthDropOuts), "radio"] <- 0
}
# Plot Campaigns
ggplot(gather(mydf, method, value, -date),
       aes(y = value, x = date, fill = method)) +
  geom_bar(stat = "identity") + facet_grid(method ~ .) + theme_minimal()
# Create AdStocked effects according to different methodologies
resdf <- mydf %>%
  transmute(
    date = date,
    outer = fisk(adStock(tv, lambda["tv"]), scale["tv"], shape["tv"]) + fisk(adStock(radio, lambda["radio"]), scale["radio"], shape["radio"]),
    inner = adStock(fisk(tv, scale["tv"], shape["tv"]), lambda["tv"]) + adStock(fisk(radio, scale["radio"], shape["radio"]), lambda["radio"]),
    outerSum = fisk(adStock(tv, lambda["tv"]) + adStock(radio, lambda["radio"]), scale["common"], shape["common"]),
    innerSum = adStock(fisk(tv, scale["tv"], shape["tv"]) + fisk(radio, scale["radio"], shape["radio"]), lambda["common"])
  )
ggplot(gather(resdf, method, value, -date),
       aes(y = value, x = date, fill = method)) +
  geom_bar(stat = "identity") + facet_grid(method ~ .) + theme_minimal()

# Fake campaigns
# Plot Campaigns
s <- (sin(0.04*(1:nrow(mydf)))+1.2)/1
fakedf <- mydf %>% transmute(date=date,
                             tv=sum(tv)/nrow(mydf)*s,
                             radio=sum(radio)/nrow(mydf)*(1/(s)))
p1<-ggplot(gather(mydf, method, value, -date),
           aes(y = value, x = date, fill = method)) +
  geom_bar(stat = "identity") + facet_grid(method ~ .) + theme_minimal() + ggtitle("Human")
p2<-ggplot(gather(fakedf, method, value, -date),
       aes(y = value, x = date, fill = method)) +
  geom_bar(stat = "identity") + facet_grid(method ~ .) + theme_minimal() + ggtitle("Optimal")
tmpdf <- gather(full_join(mutate(mydf, Campaign="Human"), mutate(fakedf, Campaign="Optimal")), Media, Value, -c(date, Campaign))
ggplot(tmpdf, aes(y=Value, x=date, fill=Media)) + geom_bar(stat="identity") + facet_grid(Campaign~.) + theme_minimal()
