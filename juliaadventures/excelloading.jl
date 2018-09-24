using ExcelReaders
using ExcelFiles
using DataFrames
using Query

# ExcelReaders & Arrays
mydata = readxl("hammer.xlsx", "Inputs!A1:DA573")
mydata = readxlsheet("hammer.xlsx", "Inputs")

# ExcelFiles & DataFrames
mydata = DataFrame(load("hammer.xlsx", "Inputs"))
mydata = load("hammer.xlsx", "Inputs") |> DataFrame

