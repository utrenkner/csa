#!/bin/sh
###################################################################################################
#
# csa.sh - Shell Script to Compress Static (Web) Assets
#
# This script creates compressed copies of the original file using gzip/zopfli 
# and brotli. Their mdates are set to that of the original file in order to
# detect if the original file has changed. Optionally, .js and .css files are 
# first minified using the Yuicompressor. The original file always 
# remains unchanged.
#
# BACKGROUND - USE WITH H2O WEBSERVER
# As of version 2.0, the h2o webserver includes support for serving 
# static files pre-compressed with the gzip or brotli compression algorithm.
# This allows to serve maximum compressed files without the computation
# overhead for on-the-fly compression, which is also available in h2o.
#
# Author: Uwe Trenkner
# URL: https://github.com/utrenkner/csa
#
# License: BSD (2-Clause)
#
# Version 0.1
#
###################################################################################################

# Enter "/path/to/yuicompressor" if .js and .css 
# shall be minified using Yuicompressor - else leave empty
yuicompressor="/usr/local/bin/yuicompressor"

# Enter either "/path/to/zopfli" or "/path/to/gzip -9" for gzip compression 
gzip="/usr/local/bin/zopfli"

# Enter "/path/to/brotli" - on FreeBSD, you may have to include also 
# the path to the python2 binary: "/usr/local/bin/python2 /usr/local/bin/brotli"
brotli="/usr/local/bin/python2 /usr/local/bin/brotli"

# Don't attempt to compress if original file is smaller than these values
minGzippedSize=22
minBrotlifiedSize=6

# Determine size and mtime of original file
origFile=$1
origFileSize=`stat -f %z $origFile`
origFileTime=`stat -f %m $origFile`

# Determine if .gz file exists already and its mtime
gzippedFile=$origFile".gz"
tmpGzippedFile=$gzippedFile".tmp"
gzippedFileSize=$origFileSize
if [ -f $gzippedFile ]
then
	gzippedFileTime=`stat -f %m $gzippedFile`
else
	gzippedFileTime=1
fi

# Determine if .br file exists already and its mtime
brotlifiedFile=$origFile".br"
tmpBrotlifiedFile=$brotlifiedFile".tmp"
brotlifiedFileSize=$origFileSize
if [ -f $brotlifiedFile ]
then
	brotlifiedFileTime=`stat -f %m $brotlifiedFile`
else
	brotlifiedFileTime=1
fi

# Temporary file to be compressed
tmpFile=$origFile".tmp"
rm -f $tmpFile
tmpFileSize=$origFileSize
fileToCompress=$origFile
fileToCompressSize=$origFileSize

# Attempt compression only of compressed files do not exist
# or if their mdate differs from the original file
if [ $gzippedFileTime -ne $origFileTime ] || [ $brotlifiedFileTime -ne $origFileTime ]
then
	# If Yuicompressor is configured: attempt to minify
	if [ -f "$yuicompressor" ]
	then
		case $origFile in 
		*.css|*.js)
			$yuicompressor -o $tmpFile $origFile
			if [ -f $tmpFile ]
			then
				tmpFileSize=`stat -f %z $tmpFile`
				if [ $tmpFileSize -lt $origFileSize ]
				then
					fileToCompress=$tmpFile
					fileToCompressSize=$tmpFileSize
				fi
			fi
			;;
		esac
	fi
	
	# Gzip compression if needed
	if [ $fileToCompressSize -gt $minGzippedSize ] && [ $gzippedFileTime -ne $origFileTime ]
	then
		$gzip -c $fileToCompress > $tmpGzippedFile
		tmpGzippedFileSize=`stat -f %z $tmpGzippedFile`
		if [ $tmpGzippedFileSize -lt $fileToCompressSize ]
		then
			mv $tmpGzippedFile $gzippedFile
			touch -r $origFile $gzippedFile
			gzippedFileSize=$tmpGzippedFileSize
		else
			rm $tmpGzippedFile
		fi
	fi
	
	# Brotli compression if needed
	if [ $fileToCompressSize -gt $minBrotlifiedSize ] && [ $brotlifiedFileTime -ne $origFileTime ]
	then
		$brotli -q 10 -f -i $fileToCompress -o $tmpBrotlifiedFile
		tmpBrotlifiedFileSize=`stat -f %z $tmpBrotlifiedFile`
		if [ $tmpBrotlifiedFileSize -lt $fileToCompressSize ] && [ $tmpBrotlifiedFileSize -lt $gzippedFileSize ]
		then
			mv $tmpBrotlifiedFile $brotlifiedFile
			touch -r $origFile $brotlifiedFile
			brotlifiedFileSize=$tmpBrotlifiedFileSize
		else
			rm $tmpBrotlifiedFile
		fi
	fi
	
	# Clean up if temporary file exists
	if [ -f $tmpFile ]
	then
		rm -f $tmpFile
	fi
fi
