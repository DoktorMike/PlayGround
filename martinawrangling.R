library(dplyr) # SQL like manipulation of tabular data
library(tibble) # Fancy version of tabular data
library(tidyr) # Convert between long and wide format tabular data
library(readxl) # Read data from Excel
library(readr) # Read data from CSV
library(ggplot2) # Plot all kinds of fancy useful plots
library(scales) # Useful scales like percentage, dollars etc.

# LOAD A BUILTIN DATASET
data("iris")

# CONVERT IT TO TIBBLE
iris <- as.tibble(iris)


# SIMPLE EXAMPLE
simpledf <- tibble(ID = c(1:3), A = c(1:3), B = c(4:6)) # Create a wide data.frame
simpledflong <- gather(simpledf, Column, Value, -ID) # Convert it to long format
simpledfwide <- spread(simpledflong, Column, -ID) # Convert it back to wide format # Convert it back to wide format

# DATA WRANGLING

# PLOTTING - Scatter

iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_point(size = 3) + geom_smooth() + theme_minimal() +
    scale_color_manual(values = dautility::bwsde.colors(3))

martinacolors <- c("#0000FFFF", "#00FF00FF", "#FF0000FF")
martinacolorssoft <- c("#000099FF", "#009900FF", "#990000FF", "#000000FF")

iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_point() + geom_smooth() + theme_minimal() +
    scale_color_manual(values = martinacolorssoft)

# PLOTTING - Lines

# Line thickness
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_line(size = 3) + geom_smooth() + theme_minimal() +
    scale_color_manual(values = martinacolorssoft)

# Bar plot note we use fill instead of color!! + save the plot
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, fill = Species)) +
    geom_bar(stat = "identity") + theme_minimal() +
    scale_fill_manual(values = martinacolorssoft)
ggsave("martinaplot.png", width = 5, height = 5)

# Scale of text
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_line() + geom_smooth() + theme_minimal(base_size = 20) +
    scale_color_manual(values = martinacolorssoft)

# Font family
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_line() + geom_smooth() + theme_minimal(base_family = "Helvetica") +
    scale_color_manual(values = martinacolorssoft)

# Axis control limits only
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_line() + geom_smooth() + theme_minimal(base_family = "Helvetica") +
    scale_color_manual(values = martinacolorssoft) + ylim(0, NA) + xlim(0, 10)

# Axis control limits and intervals
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_line() + geom_smooth() + theme_minimal(base_family = "Helvetica") +
    scale_color_manual(values = martinacolorssoft) +
    scale_y_continuous(
        breaks = seq(0, 5, 0.25),
        limits = c(0, 5)
    )

# Axis predefined scales - percentage
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_line() + geom_smooth() + theme_minimal(base_family = "Helvetica") +
    scale_color_manual(values = martinacolorssoft) +
    scale_y_continuous(labels = scales::percent)

# Move legend to top, bottom etc or remove = none
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_line() + geom_smooth() + theme_minimal(base_family = "Helvetica") +
    scale_color_manual(values = martinacolorssoft) +
    scale_y_continuous(labels = scales::percent) + theme(legend.position = "none")

iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_line() + geom_smooth() + theme_minimal(base_family = "Helvetica") +
    scale_color_manual(values = martinacolorssoft) +
    scale_y_continuous(labels = scales::percent) + theme(legend.position = "top")

# Title
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_line() + geom_smooth() + theme_minimal(base_family = "Helvetica") +
    scale_color_manual(values = martinacolorssoft) +
    scale_y_continuous(labels = scales::percent) + ggtitle("Hello you")

# Labels
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_line() + geom_smooth() + theme_minimal(base_family = "Helvetica") +
    scale_color_manual(values = martinacolorssoft) +
    scale_y_continuous(labels = scales::percent) + ylab("Sepal Width") +
    xlab("Sepal Length Moddafucka!!")

# Facets
iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_line() + geom_smooth() + theme_minimal(base_family = "Helvetica") +
    scale_color_manual(values = martinacolorssoft) + facet_grid(. ~ Species)

iris %>% ggplot(aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_line() + geom_smooth() + theme_minimal(base_family = "Helvetica") +
    scale_color_manual(values = martinacolorssoft) +
    facet_grid(Species ~ ., scales = "free_y") + theme(legend.position = "none")

## Wrangle test

mydf <- expand.grid(
    existing_swap_flag = c(0, 1),
    newsale_swap_flag = c(0, 1),
    product_name = c("pr_yng", "abc", "jabba")
) %>% as_tibble()

mydf %>% mutate(SWAP = ifelse((existing_swap_flag == 1 | newsale_swap_flag == 1) & !(grepl("yng", product_name, ignore.case = T)), 1, 0))
