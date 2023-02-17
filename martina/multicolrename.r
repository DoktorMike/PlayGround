library(tibble)
library(dplyr)

#  ____                                       _       _
# |  _ \ ___ _ __   __ _ _ __ ___   ___    __| | __ _| |_ ___
# | |_) / _ \ '_ \ / _` | '_ ` _ \ / _ \  / _` |/ _` | __/ _ \
# |  _ <  __/ | | | (_| | | | | | |  __/ | (_| | (_| | ||  __/
# |_| \_\___|_| |_|\__,_|_| |_| |_|\___|  \__,_|\__,_|\__\___|
#

mydf1 <- tibble(date_aba = 1:10, A = 1:10, B = 1:10)
mydf2 <- tibble(date_lala = 1:10, D = 1:10, A = 1:10)
mydf3 <- tibble(date_baroma = 1:10, Q = 1:10, B = 1:10)
mylist <- list(mydf1, mydf2, mydf3)

# Define a function to rename all columns of a SINGLE data.frame
renametodate <- function(x) x %>% stats::setNames(gsub("date_.+", "date", names(.)))

# Apply that function to each element in the data frame list
lapply(mylist, renametodate)


#  ____
# |  _ \ ___ _ __   __ _ _ __ ___   ___
# | |_) / _ \ '_ \ / _` | '_ ` _ \ / _ \
# |  _ <  __/ | | | (_| | | | | | |  __/
# |_| \_\___|_| |_|\__,_|_| |_| |_|\___|
#
#                                  _           _
#  _ __  _   _ _ __ ___   ___ _ __(_) ___ __ _| |
# | '_ \| | | | '_ ` _ \ / _ \ '__| |/ __/ _` | |
# | | | | |_| | | | | | |  __/ |  | | (_| (_| | |
# |_| |_|\__,_|_| |_| |_|\___|_|  |_|\___\__,_|_|
#

mydf1 <- tibble(date_aba = LETTERS[1:10], A = letters[1:10], B = 1:10)
mydf2 <- tibble(date_lala = letters[1:10], D = letters[11:20], A = 1:10)
mydf3 <- tibble(date_baroma = LETTERS[1:10], Q = 1:10, B = LETTERS[21:30])
mylist <- list(mydf1, mydf2, mydf3)

# Define a function to rename all columns of a SINGLE data.frame
# mutate(mydf1, across(where(is.numeric), .names = "value"))
renamenumerictovalue2 <- function(x) {
    mycolnames <- colnames(x)
    whichisnumeric <- sapply(x, is.numeric)
    mycolnames[whichisnumeric] <- "value"
    colnames(x) <- mycolnames
    x
}
renamenumerictovalue <- function(x) {
    colnames(x)[sapply(x, is.numeric)] <- "value"
    x
}
# Apply that function to each element in the data frame list
lapply(mylist, renamenumerictovalue2)
