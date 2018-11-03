using TestImages, Images, ImageView

# Get images from TestImages
img = testimage("mandrill")
imshow(img)

using FileIO

# Get images from disk
img = FileIO.load("/home/michael/Dropbox/Photos/valentinesday.png")
imshow(img)

# Interpret images from 2d array
img = rand(1000, 1000)
imshow(img)

# Interpret grayscale movie of 100 frames from 3d array
img = rand(1000, 1000, 100)
imshow(img)

# Interpret 3d array as RGB image
img = colorview(RGB, rand(3, 1000, 1000))
imshow(img)

