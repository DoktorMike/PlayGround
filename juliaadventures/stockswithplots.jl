using PlotlyJS
using DataFrames
using CSV

mypath = "/home/michael/Dropbox/Datasets/matrix/finance/data/sp500/csv";
csvfile = mypath * "/A.csv"; adf = CSV.read(csvfile)
csvfile = mypath * "/NFLX.csv"; ndf = CSV.read(csvfile)
csvfile = mypath * "/FB.csv"; fdf = CSV.read(csvfile)
csvfile = mypath * "/MSFT.csv"; mdf = CSV.read(csvfile)

# Plot close price as a function of time
plot(scatter(x=adf.Index, y=adf.close))

# Plot OHLC plots
plot(candlestick(open=adf.open, high=adf.high, low=adf.low, close=adf.close))
plot(candlestick(date=[today()+Day(i-1) for i in 1:nrow(adf)], 
                 open=adf.open, high=adf.high, low=adf.low, close=adf.close))

# Box plots horizontal stack
function pricecomparisonplot(p1, p2, p3, p4)
    b1 = box(; y=p1, name="Price 1")
    b2 = box(; y=p2)
    b3 = box(; y=p3)
    b4 = box(; y=p4)
    p = [b1, b2, b3, b4]
    layout = Layout(;title="Da Box Plot")
    plot(p, layout)
end
pricecomparisonplot(adf.close, ndf.close, fdf.close, mdf.close)

# Box plots vertical stack
function pricecomparisonverticalplot(p1, p2, p3, p4)
    b1 = box(; x=p1, name="Price 1")
    b2 = box(; x=p2, marker_color="#000000")
    b3 = box(; x=p3, jitter=1.0, boxpoints="all")
    b4 = box(; x=p4)
    p = [b1, b2, b3, b4]
    layout = Layout(;title="Da Box Plot", 
                    xaxis=attr(title="Prices", zeroline=false))
    plot(p, layout)
end
pricecomparisonverticalplot(adf.close, ndf.close, fdf.close, mdf.close)

# Violin plot
function pricecomparisonviolinplot(p1, p2, p3, p4)
    b1 = violin(; y=p1, name="Price 1")
    b2 = violin(; y=p2)
    b3 = violin(; y=p3)
    b4 = violin(; y=p4)
    p = [b1, b2, b3, b4]
    layout = Layout(;title="Da Box Plot")
    plot(p, layout)
end
pricecomparisonviolinplot(adf.close, ndf.close, fdf.close, mdf.close)

# ROI plot EU
function roimap(sales::Array{<:Number,1}, roi::Array{<:Number,1},
                locations::Array{String})
    marker = attr(size=sales, 
                  color=roi, 
                  cmin=0, 
                  cmax=maximum(roi),
                  #colorscale="Greens",
                  #colorscale="Hot",
                  colorscale="Bluered",
                  colorbar=attr(title="ROI Scale",
                                ticksuffix="ROI",
                                showticksuffix="last"),
                  line_color="black")
    trace = scattergeo(;mode="markers", locations=locations,
                        marker=marker, name="ROI in Europe")
    layout = Layout(geo_scope="europe", geo_resolution=50, width=500, height=550,
                    margin=attr(l=0, r=0, t=10, b=0))
    plot(trace, layout)
end
roimap([20, 30, 15, 10], [1.5, 0.5, 2.4, 1.0], ["SWE", "NOR", "DNK", "GBR"])
#roimap([20, 30, 15, 10], [10, 20, 40, 50], ["FRA", "DEU", "RUS", "ESP"])

