library(bnlearn)
library(Rgraphviz)

boot.strength(learning.test, algorithm = "hc")
nets <- bn.boot(learning.test, statistic = arcs, algorithm = "hc", R = 2)
nets <- bn.boot(learning.test, statistic = function(x) x, algorithm = "hc", R = 2)
nets[[1]]
plot(nets[[1]])
all.equal(nets[[1]], nets[[2]])
score(nets[[2]], data=learning.test)

# Visual comparison
par(mfrow = c(1, 2))
graphviz.compare(nets[[1]], nets[[2]])

# Data
data(lizards)
lizards %>% head
ci.test("Height", "Diameter", "Species", data = lizards, test = "mi")
ci.test("Height", "Species", "Diameter", data = lizards, test = "mi")
ci.test("Diameter", "Height", "Species", data = lizards, test = "mi")
ci.test("Diameter", "Species", "Height", data = lizards, test = "mi")

# Data Gaussian case
data(gaussian.test)
gaussian.test %>% head
gauss.net = empty.graph(names(gaussian.test))
modelstring(gauss.net) = "[A][B][E][G][C|A:B][D|B][F|A:D:E:G]"
gauss.net
plot(gauss.net)

nets <- bn.boot(gaussian.test, statistic = function(x) x, algorithm="hc", R=5)
par(mfrow = c(2, 3))
graphviz.compare(gauss.net, nets[[1]], nets[[2]], nets[[3]], nets[[4]], nets[[5]])
score(gauss.net, data=gaussian.test)
score(nets[[1]], data=gaussian.test)
score(nets[[2]], data=gaussian.test)
score(nets[[3]], data=gaussian.test)
sapply(1:10, function(x) score(nets[[x]], data=gaussian.test))


# Iris test : Score function should be as high as possible
data(iris)
nets <- bn.boot(iris, statistic = function(x) x, algorithm="hc", R=5)
nets <- bn.boot(iris, statistic = function(x) score(x, data=iris), algorithm="hc", R=5)
myscores <- sapply(1:length(nets), function(x) score(nets[[x]], data=iris))
myorder <- order(myscores, decreasing=TRUE)
par(mfrow = c(2, 3))
graphviz.compare(nets[[myorder[1]]], nets[[myorder[2]]], nets[[myorder[3]]], nets[[myorder[4]]], nets[[myorder[5]]])
arcs(nets[[myorder[1]]])


