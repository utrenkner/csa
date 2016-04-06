# csa- Compress Static (Web) Assets Using gzip/zopfli and brotli
This consists of two scripts to create compressed copies of the original files using gzip/zopfli and brotli. Their mdates are set to that of the original file in order to detect if the original file has changed. Optionally, .js and .css files are first minified using the Yuicompressor. The original files always remain unchanged.

# Usage
Please first check and adapt the configuration of the scripts to your needs.
Then, to compress an individual file: `csa.sh /file/to/compress`
Or, to recursively compress files in a directory tree: `csa_rec.sh`

# Background - use with h2o webserver
As of version 2.0, the h2o webserver includes support for serving static files pre-compressed with the gzip or brotli compression algorithm. This allows to serve maximum compressed files without the computation overhead for on-the-fly compression, which is also available in h2o.

# Caveat
The scripts were written with portability in mind. However, version 0.1 has only been tested on FreeBSD. Addtional tests on GNU/Linux will follow.

# License
csa is licensed under the 2-clause BSD license. Please feel free to contribute patches.
