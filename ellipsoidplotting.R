library(rgl)
# Ellipsoid
plot3d(ellipse3d(diag(3), centre=c(10,10,6), scale=c(1.0,1.3,1.5)), color="green", axes=FALSE)
# Spheroid
plot3d(ellipse3d(diag(3), centre=c(5,5,5),   scale=c(1.0,1.0,1.5)), color="red",   add = TRUE)
# Sphere
plot3d(ellipse3d(diag(3), centre=c(1,1,1),   scale=c(1.0,1.0,1.0)), color="blue",  add = TRUE)

