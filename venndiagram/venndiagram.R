# Load library
library(VennDiagram)

# Generate 3 sets of 200 words
set1 <- paste(rep("word_", 200), sample(c(1:1000), 200, replace = F), sep = "")
set2 <- paste(rep("word_", 200), sample(c(1:1000), 200, replace = F), sep = "")
set3 <- paste(rep("word_", 200), sample(c(1:1000), 200, replace = F), sep = "")

set1 <- sample(c(1:80), 1000, replace = T)
set2 <- sample(c(90:150), 500, replace = T)
set3 <- sample(c(60:200), 800, replace = T)
# Prepare a palette of 3 colors with R colorbrewer:
library(RColorBrewer)
myCol <- brewer.pal(3, "Pastel2")
# Chart
venn.diagram(
        x = list(set1, set2, set3),
        category.names = c("Own stores", "External ", "New Sales"),
        filename = "#14_venn_diagramm.png",
        output = TRUE,
        # Output features
        imagetype = "png",
        height = 800,
        width = 800,
        resolution = 300,
        compression = "lzw",
        # Circles
        lwd = 2,
        lty = "blank",
        fill = myCol,
        # Numbers
        cex = .4,
        fontface = "bold",
        fontfamily = "sans",
        # Set names
        cat.cex = 0.4,
        cat.fontface = "bold",
        cat.default.pos = "outer",
        cat.pos = c(-27, 27, 135),
        cat.dist = c(0.055, 0.055, 0.085),
        cat.fontfamily = "sans",
        rotation = 1
)
