library(daai)
library(dautility)
library(tidyr)
library(dplyr)
library(microbenchmark)



# BW7Divergence ~= 1 - distOverlap
res <- array(-1, c(6, 2)); colnames(res)<-c("bw7Div", "distOverlap")
x1 <- rnorm(1000, 1, 5); x2 <- rnorm(1000, 1, 5); res[1, ] <- c(bw7Divergence(x1, x2), distOverlap(x1, x2)); ggplot(gather(tibble(x1, x2), Distribution, Value), aes(x=Value, fill=Distribution)) + geom_density(alpha=0.5)
x1 <- rnorm(1000, 1, 5); x2 <- rnorm(1000, 1, 2); res[2, ] <- c(bw7Divergence(x1, x2), distOverlap(x1, x2)); ggplot(gather(tibble(x1, x2), Distribution, Value), aes(x=Value, fill=Distribution)) + geom_density(alpha=0.5)
x1 <- rnorm(1000, 1, 5); x2 <- rnorm(1000, 1, 1); res[3, ] <- c(bw7Divergence(x1, x2), distOverlap(x1, x2)); ggplot(gather(tibble(x1, x2), Distribution, Value), aes(x=Value, fill=Distribution)) + geom_density(alpha=0.5)
x1 <- rnorm(1000, 1, 5); x2 <- rnorm(1000, 3, 5); res[4, ] <- c(bw7Divergence(x1, x2), distOverlap(x1, x2)); ggplot(gather(tibble(x1, x2), Distribution, Value), aes(x=Value, fill=Distribution)) + geom_density(alpha=0.5)
x1 <- rnorm(1000, 1, 5); x2 <- rnorm(1000, 10, 5); res[5, ] <- c(bw7Divergence(x1, x2), distOverlap(x1, x2)); ggplot(gather(tibble(x1, x2), Distribution, Value), aes(x=Value, fill=Distribution)) + geom_density(alpha=0.5)
x1 <- rnorm(1000, 1, 5); x2 <- rnorm(1000, 100, 5); res[6, ] <- c(bw7Divergence(x1, x2), distOverlap(x1, x2)); ggplot(gather(tibble(x1, x2), Distribution, Value), aes(x=Value, fill=Distribution)) + geom_density(alpha=0.5)
cor(res)

f1 <- function() { x1 <- rnorm(5000, 1, 5); x2 <- rnorm(5000, 5, 5); res <- bw7Divergence(x1, x2); res }
f2 <- function() { x1 <- rnorm(5000, 1, 5); x2 <- rnorm(5000, 5, 5); res <- distOverlap(x1, x2); res }
microbenchmark(f1, f2, times = 10000)


# Create a new environment and add a baby in it: FAKE DATA for NOW
newenv <- rlang::child_env("daai")
assign("mybabe", 324, envir = newenv); ls(newenv)
# Run a non parallel function in the environment
with(newenv, { for(i in 1:10) print(paste("Bla ", mybabe, " and ", i)) } )
# Run a parallel function in the environment
unlist(with(newenv, { parallel::mclapply(1:30, function(x) print(x), mc.cores=4) } ))

