library(lubridate)
library(tibble)

# Get iso week which will be financial week number 1 for a given single date
# mydate
getweek1 <- function(mydate) {
    july1 <- paste0(year(mydate), "-07-01")
    if (wday(july1, week_start = 1) <= 4) {
        week1 <- isoweek(july1)
    } else {
        week1 <- isoweek(july1) + 1
    }
    week1
}

# OMFG this is hacky but this takes a single date and figures out where it
# is located compared to the financial year
finisoweekhack <- function(mydate) {
    # mydate <- ymd("2020-07-01")
    # How many weeks this year
    nweeksthisyear <- max(isoweek(seq(ymd(paste0(year(mydate), "-12-01")),
        ymd(paste0(year(mydate), "-12-31")),
        by = "1 day"
    )))
    # How many weeks last year
    nweeksprevyear <- max(isoweek(seq(ymd(paste0(year(mydate) - 1, "-12-01")),
        ymd(paste0(year(mydate) - 1, "-12-31")),
        by = "1 day"
    )))
    # Which ISO week is week 1 in the Financial Year
    week1 <- getweek1(mydate)
    tmpdf1 <- tibble(
        fy = year(mydate), iw = week1:nweeksthisyear,
        fw = seq_along(iw)
    )
    tmpdf2 <- tibble(
        fy = year(mydate) - 1, iw = 1:(week1 - 1),
        fw = rev(nweeksprevyear - seq_along(iw))
    )
    tmpdf <- bind_rows(tmpdf2, tmpdf1)
    i <- which(isoweek(mydate) == tmpdf$iw)
    paste0(tmpdf[i, "fy"], "-", tmpdf[i, "fw"])
}

# This function takes a vector of dates which can be used in tibbles and
# dataframes etc.
finisoweek <- function(dates) sapply(dates, finisoweekhack)

## Example usage where we create dummy sales file with weekly sales
tmpdf <- tibble(
    Date = seq(ymd("2020-06-20"), ymd("2020-07-20"), by = "1 day"),
    Sales = round(rnorm(length(Date), 10000, 3000))
)
tmpdf %>% dplyr::mutate(FinWeek = finisoweek(Date), IsoWeek = isoweek(Date))
