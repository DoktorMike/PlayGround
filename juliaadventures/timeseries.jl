using TimeSeries
using Glob
using ProgressMeter
using CSV
using DataFrames

csvfile = "/home/michael/Dropbox/Datasets/matrix/finance/data/sp500/csv/A.csv";
adata = readtimearray(csvfile, format="yyyy-mm-dd", delim=',');

mypath = "/home/michael/Dropbox/Datasets/matrix/finance/data/sp500/csv";
myfilelist = glob("*.csv", mypath);

alldata = Array{TimeArray}(undef, length(myfilelist));
function loadalldata(files::Array)
    n = length(files)
    p = Progress(n, 1)
    for i in 1:n
        alldata[i] = readtimearray(files[i], format="yyyy-mm-dd", delim=',')
        next!(p)
    end
    alldata
end

alldata = Array{DataFrame}(undef, length(myfilelist));
function loadalldata(files::Array)::Array{DataFrame}
    n = length(files)
    p = Progress(n, 1)
    for i in 1:n
        alldata[i] = CSV.read(myfilelist[i])
        next!(p)
    end
    alldata
end
