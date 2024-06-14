export CFLAGS="-fPIC"
export CPPFLAGS=$CFLAGS
export CXXFLAGS=$CFLAGS
cd src/torcs
./configure --prefix=$(pwd)/BUILD  # local install dir
make
make install
make datainstall