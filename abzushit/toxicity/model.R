library(readxl)
library(readr)
library(dplyr)
library(purrr)
library(rpart)
library(rpart.plot)
library(yardstick)
library(pROC)
library(nnet)
library(xgboost)
library(equatiomatic)
library(e1071)


mydf <- readxl::read_xls("mmc2.xls")
mydf <- mydf %>%
        dplyr::select(target = region, sequence, design = lnadna, cas_avg, kd_avg) %>%
        dplyr::mutate(target = gsub("\\.\\d\\d", "", target)) %>%
        # Feature engineering
        dplyr::filter(target != "NA") %>%
        dplyr::mutate(
                lna_5p = purrr::map_dbl(design, function(x) {
                        sum(unlist(strsplit(x, ""))[1:5] == "L")
                }),
                lna_3p = purrr::map_dbl(design, function(x) {
                        ii <- nchar(x)
                        sum(unlist(strsplit(x, ""))[(ii - 5):ii] == "L")
                }),
                lna_count = purrr::map_dbl(design, function(x) {
                        sum(unlist(strsplit(x, "")) == "L")
                }),
                aso_len = nchar(design),
                dna_count = aso_len - lna_count,
		lna_5plt = factor(lna_5p < 3),
		lna_3plt = factor(lna_3p < 4),
                too_toxic = factor(cas_avg > 300)
        )

# Training and testing
trndf <- mydf %>% dplyr::filter(target == "A")
tstdf <- mydf %>% dplyr::filter(target == "B")

write_csv(trndf, "trndf.csv")
write_csv(tstdf, "tstdf.csv")

# Model
myglm <- glm(too_toxic ~ lna_5p * lna_3p * lna_count + I(lna_5p**2) + dna_count + aso_len - lna_count+lna_5plt*lna_3plt, family = "binomial", data = trndf)
myglm <- stats::step(myglm)
summary(myglm)

mytree <- rpart(too_toxic ~ lna_5p + lna_3p + lna_count + dna_count + aso_len,
        #control = rpart.control(cp = 0.00001), data = trndf, method = "class"
        control = rpart.control(cp = 0.01), data = trndf, method = "class"
)
rpart.plot(mytree)

mynn <- nnet(too_toxic ~ lna_5p + lna_3p + lna_count + dna_count + aso_len,
        size = 100, decay = 0.15, maxit = 2000, data = trndf
)
abzu <- function(lna5p, lna3p) {
        1 / (3.48212 * exp(-0.910511 * (1 - 0.573756 * lna3p)**2 - 0.704222 * (0.790818 * lna5p - 1)**2) + 1)
}
sr <- function(lna5p, lna3p, lnacount=0, dnacount=0) {
        # 1 / (1 + exp(-0.910511 * (1 - 0.573756 * lna3p)**2 - 0.704222 * (0.790818 * lna5p - 1)**2))
        pow <- function(x, y) x^y
        sigmoid <- function(x) 1 / (1 + exp(-x))
	# V1
        #ret <- pow(sigmoid(lna5p), (pow((9.560665 - (lna3p - -0.36704773)) - (lna3p / lna5p), 1.2517705) - -0.11718671) + -1.0115147)
	# V2
	#pow(-0.08574804 + (0.00920261 * exp(lna5p)), 0.7600297 * (0.8334187 + (-0.10628817 * lnacount)))
	# V3
	#pow(-0.02170809 * exp(0.7944211 * x2), pow(0.92395115, exp(lna5p)) + (1.3228008 * pow(0.6741113, dnacount)))
	# V4
	ret <- pow(-0.8376513 / lna5p, exp(sigmoid(-0.41052407 - cos(lna3p)) - lnacount) * ((lna3p / 0.018587874) / lna5p))
	ret
}

mytrninds <- sample(1:nrow(trndf), 0.7*nrow(trndf), replace = FALSE)
xgbtrndat <- xgb.DMatrix(as.matrix(trndf[mytrninds, c("lna_5p", "lna_3p", "lna_count", "dna_count", "aso_len")]),
        label = as.integer(trndf$too_toxic[mytrninds] == TRUE)
)
xgbvaldat <- xgb.DMatrix(as.matrix(trndf[-mytrninds, c("lna_5p", "lna_3p", "lna_count", "dna_count", "aso_len")]),
        label = as.integer(trndf$too_toxic[-mytrninds] == TRUE)
)
watchlist <- list(train=xgbtrndat, eval=xgbvaldat)
xgbtstdat <- xgb.DMatrix(as.matrix(tstdf[, c("lna_5p", "lna_3p", "lna_count", "dna_count", "aso_len")]),
        label = as.integer(tstdf$too_toxic == TRUE)
)
#myxgb <- xgboost(
#        data = xgbtrndat,
#        objective = "binary:logistic",
#        eval_metric = "ndcg",
#        nrounds = 200
#)
myxgb <- xgb.train(params = list(objective = "binary:logistic", eval_metric = "auc"), data = xgbtrndat,
		   nrounds = 200, watchlist = watchlist, early_stopping_rounds = 10)

mysvm <- svm(too_toxic ~ lna_5p + lna_3p + lna_count + dna_count + aso_len,
        kernel = "radial",
        degree = 10,
        gamma = 0.01,
        # gamma = "auto",
        probability = TRUE,
        data = trndf
)
# obj <- tune(svm, too_toxic ~ lna_5p * lna_3p * lna_count + dna_count + aso_len,
#        data = trndf,
#        kernel = "radial",
#        # ranges = list(gamma = 2^(-2:1), cost = 2^(-5:4), degree = seq(0, 2, 0.1)),
#        ranges = list(gamma = 2^(-5:1), cost = 2^(-5:4), degree = seq(0, 2, 0.1)),
#        tunecontrol = tune.control(sampling = "fix")
# )
# obj
# mysvm <- svm(too_toxic ~ lna_5p * lna_3p * lna_count + dna_count + aso_len,
#        kernel = "radial",
#        degree = 0,
#        gamma = 0.03125,
#        cost = 0.125,
#        coef0 = 1r 
#        # gamma = "auto",
#        probability = TRUE,
#        data = trndf
# )


## REMOVE
#pow <- function(x, y) x^y
#sigmoid <- function(x) 1 / (1 + exp(-x))
#lna5p <- 1
#lna3p <- 5
#mybase <- (9.560665 - (lna3p - -0.36704773)) - (lna3p / lna5p)
#mypow <- (pow(mybase, 1.2517705) - -0.11718671) + -1.0115147
#pow(sigmoid(lna5p), mypow)
## REMOVE

# Test on holdout
glmresdf <- predict(myglm, newdata = tstdf, type = "resp") %>%
        as_tibble() %>%
        dplyr::transmute(glmpred = value)
treeresdf <- predict(mytree, newdata = tstdf) %>%
        as_tibble() %>%
        dplyr::transmute(treepred = `TRUE`)
nnresdf <- predict(mynn, newdata = tstdf) %>%
        as_data_frame() %>%
        dplyr::transmute(nnpred = V1)
abzuresdf <- abzu(tstdf$lna_5p, tstdf$lna_3p) %>%
        as_tibble() %>%
        dplyr::transmute(abzupred = value)
xgbresdf <- tibble::tibble(xgbpred = predict(myxgb, newdata = xgbtstdat))
svmresdf <- predict(mysvm, newdata = tstdf, probability = TRUE)
svmresdf <- attr(svmresdf, "probabilities") %>%
        as_tibble() %>%
        dplyr::transmute(svmpred = `TRUE`)
srresdf <- sr(tstdf$lna_5p, tstdf$lna_3p, tstdf$lna_count, tstdf$dna_count) %>%
        as_tibble() %>%
        dplyr::transmute(srpred = value)
resdf <- bind_cols(tstdf, glmresdf, treeresdf, nnresdf, abzuresdf, xgbresdf, svmresdf, srresdf)
rocs <- list(
        GLM = roc(resdf[["too_toxic"]], resdf[["glmpred"]]),
        Tree = roc(resdf[["too_toxic"]], resdf[["treepred"]]),
        NN = roc(resdf[["too_toxic"]], resdf[["nnpred"]]),
        Abzu = roc(resdf[["too_toxic"]], resdf[["abzupred"]]),
        XGBoost = roc(resdf[["too_toxic"]], resdf[["xgbpred"]]),
        SVM = roc(resdf[["too_toxic"]], resdf[["svmpred"]]),
        SR = roc(resdf[["too_toxic"]], resdf[["srpred"]])
)
ggroc(rocs) + theme_minimal()
sapply(rocs, auc)

resdf %>% ggplot2::ggplot(aes(x = too_toxic, y = treepred, colour = "red")) +
        ggplot2::geom_point() +
        ggplot2::geom_jitter() +
        ggplot2::ggtitle("GLM")

extract_eq(myglm, use_coefs = T, var_colors = T)
