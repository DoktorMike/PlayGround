library(gridExtra)

money <- 10000
n <- 10
# space <- 0:36
space <- c(0, rep(c(-1, 1), 18))

# Play a game
play <- function(cash, bet_money, take_profit = cash * 2, stop_loss = cash / 2, space = c(0, rep(c(-1, 1), 18)), debug = TRUE) {
        bet_money_orig <- bet_money
        orig_cash <- cash
        done <- FALSE
        cntr <- 1
        while (!done) {
                bet_outcome <- 1
                # Take bet money out of cash
                cash <- cash - bet_money
                # Did we bust or soar past take_profit?
                if (any(cash < stop_loss, cash > take_profit)) {
                        done <- TRUE
                } else {
                        outcome <- sample(space, 1)
                        if (outcome == bet_outcome) { # If we win get double the investment back
                                cash <- cash + bet_money * 2
                                # if (bet_money > bet_money_orig) bet_money <- bet_money_orig # bet_money / 2
                                if (bet_money > bet_money_orig) bet_money <- bet_money / 2
                                # if (cash > take_profit) done <- TRUE
                        } else {
                                # cash <- cash - bet_money
                                bet_money <- bet_money * 2
                        }
                        if (debug) print(paste0("Played ", cntr, " games Cash: ", cash, " Bet: ", bet_money, "\n"))
                }
                cntr <- cntr + 1
        }
        c(Rounds = cntr, Cash = cash + bet_money, LastBet = bet_money, Profit = cash + bet_money - orig_cash, Win = cash > take_profit)
}

play(10000, 100, debug = FALSE)

# Play 50000 games
myplay <- function(x) {
        play(
                cash = 10000, bet_money = 50,
                take_profit = 1.1 * 10000,
                stop_loss = 10000 / 2,
                debug = FALSE
        )
}
adf <- data.frame(t(sapply(1:1000, myplay))) %>% as_tibble()
sum(adf$Win) / nrow(adf)
mean(adf$Rounds)
table(adf$LastBet)
qplot(adf$Cash)
sum(adf$Cash) - nrow(adf) * 10000
adf %>%
        mutate(Epoch = 1:n()) %>%
        ggplot(aes(x = Epoch, y = cumsum(Profit))) +
        geom_point()
