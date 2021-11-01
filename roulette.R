library(gridExtra)

money <- 10000
n <- 10
# space <- 0:36
space <- c(0, rep(c(-1, 1), 18))

# Play a game
play <- function(cash, bet_money, take_profit=cash*2, space=c(0, rep(c(-1, 1), 18)), debug=TRUE){
  bet_money_orig <- bet_money
  done <- FALSE
  cntr <- 1
  while(!done){
    bet_outcome <- 1
    outcome <- sample(space, 1)
    if(outcome == bet_outcome){
      cash <- cash + bet_money*2
      if(bet_money > bet_money_orig) bet_money <- bet_money_orig # bet_money / 2
      if(cash > take_profit) done <- TRUE
    } else{
      cash <- cash - bet_money
      bet_money <- bet_money * 2
    }

    if(debug) print(paste0("Played ", cntr, " games Cash: ", cash, " Bet: ", bet_money, "\n"))
    if(cash < bet_money){
      done <- TRUE
    }
    cntr <- cntr + 1
  }
  c(Rounds=cntr, Cash=cash, LastBet=bet_money, Win=cash>take_profit)
}

play(10000, 100, debug = FALSE)

# Play 50000 games
adf <- data.frame(t(sapply(1:10000, function(x) play(cash = 10000, bet_money = 100, take_profit = 1.5*10000, debug = FALSE))))
sum(adf$Win)/nrow(adf)
mean(adf$Rounds)
qplot(adf$Cash)
qplot(adf$LastBet)

# Play 50000 games
adf <- data.frame(t(sapply(1:10000, function(x) play(cash = 10000, bet_money = 50, take_profit = 1.5*10000, debug = FALSE))))
sum(adf$Win)/nrow(adf)
mean(adf$Rounds)
qplot(adf$Cash)
qplot(adf$LastBet)
