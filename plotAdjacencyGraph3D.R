library(igraph)
library(rgl)
library(magick)

# Generate fake Adjacency matrix
varnames <- paste0("Var", 1:10)
adjm <- matrix(sample(0:1, 100, replace = TRUE, prob = c(0.9, 0.1)), nc = 10)
rownames(adjm) <- varnames
colnames(adjm) <- varnames

# Convert the adjacency matrix to a graph and lay the edges and vertices out on 
# a spherical map and plot it
g <- graph_from_adjacency_matrix(adjm)
coords <- layout_on_sphere(g)
rglplot(g, layout = coords)

# Animate the plot: Rotate 180 degrees along x-axis for 10 seconds
# This is just to see what different rotations would look like
M <- par3d("userMatrix")
play3d(par3dinterp(userMatrix = list(M, rotate3d(M, angle = pi, x = 1, y = 0, z = 0))), duration = 10)
play3d(par3dinterp(userMatrix = list(M, rotate3d(M, angle = pi, x = 0, y = 1, z = 0))), duration = 10)
play3d(par3dinterp(userMatrix = list(M, rotate3d(M, angle = pi, x = 0, y = 0, z = 1))), duration = 10)
play3d(par3dinterp(userMatrix = list(M, rotate3d(M, angle = pi, x = 1, y = 1, z = 1))), duration = 10)

# Animate the plot and save to a gif
M <- par3d("userMatrix")
movie3d(spin3d(), duration = 10)
#usermatrix <- list(M, rotate3d(M, angle = pi, x = 1, y = 1, z = 1))
#movie3d(par3dinterp(userMatrix = usermatrix), duration = 10)
