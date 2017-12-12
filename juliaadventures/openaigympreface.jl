ENV["PYTHON"] = "/usr/bin/python3"
Pkg.build("PyCall")

using PyCall

gym = pyimport("gym")

