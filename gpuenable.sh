#!/bin/bash
sudo su -c 'echo "ON" > /proc/acpi/bbswitch'
sudo modprobe nvidia

# Install cuda the latest version
# In Julia install CuArrays and before that install
# CUDAapi.jl, CUDAdrv.jl and CUDAnative.jl

