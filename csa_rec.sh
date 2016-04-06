#!/bin/sh
###################################################################################################
#
# csa_rec.sh - Shell Script to Recursively Compress Static (Web) Assets
#
# This script looks for compressible files and uses the csa.sh script to 
# create gzipped (.gz) and brotlified (.br) copies of the original file.
#
# Author: Uwe Trenkner
# URL: https://github.com/utrenkner/csa
#
# License: BSD (2-Clause)
#
# Version 0.1
#
###################################################################################################

# Enter "/path/to/csa.sh" script
csa="/path/to/csa.sh"

# Define, which files are to be compressed
compressible="css|js|svg|htm[l]?|xml"

# Enter directory to start (recursively) looking for compressible files
dir="/usr/local/www/data"

find -E $dir -regex ".*\.($compressible)" -exec sh -x $csa {} \; 
