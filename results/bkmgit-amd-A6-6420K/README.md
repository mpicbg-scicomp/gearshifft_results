# Command history to install and run benchmark tests
## GPU tests start to run but fail as Mesa OpenCL support is lacking, see [here](https://www.x.org/wiki/RadeonFeature/)

cd Projects/

cd Gearshifft/

cd amd

tar -xvf fftw-3.3.8.tar.gz 

wget https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.gz

tar -xvf boost_1_68_0.tar.gz 

cd boost_1_68_0/

./bootstrap.sh --with-toolset=clang --prefix=/home/benson/Projects/Gearshifft/amd/boost_1_68_0_clang_install --with-libraries=program_options,filesystem,system,test

./b2 install --variant=release

cd ..

cd fftw-3.3.8/

./configure CC=/usr/bin/clang --enable-static --enable-shared --enable-avx2 --enable-sse2 --prefix=/home/benson/Projects/Gearshifft/amd/fftw-3.3.8-clang-install --enable-float --disable-fortran

make

make install

make clean

./configure CC=/usr/bin/clang --enable-static --enable-shared --enable-avx2 --enable-sse2 --prefix=/home/benson/Projects/Gearshifft/amd/fftw-3.3.8-clang-install --disable-fortran

make

make install

cd ..

git clone https://github.com/clMathLibraries/clFFT

cd clFFT/

git checkout ce107c4

cd ..

wget https://cmake.org/files/v3.12/cmake-3.12.1.tar.gz

tar -xvf cmake-3.12.1.tar.gz 

cd cmake-3.12.1/

./bootstrap --prefix=/home/benson/Projects/Gearshifft/amd/cmakeinstall

make

make install

cd ..

cd clFFT/

cd src/

mkdir build

cd build/

../../../cmakeinstall/bin/cmake ..  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/home/benson/Projects/Gearshifft/amd/clfftinstall

make

make clean

../../../cmakeinstall/bin/cmake ..  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/home/benson/Projects/Gearshifft/amd/clfftinstall -DCMAKE_SHARED_LINKER_FLAGS="-L/home/benson/Projects/Gearshifft/amd/boost_1_68_0_clang_install/lib -lboost_program_options -L/lib64 -lpthread -lm" -DOpenCL_INCLUDE_DIR="/usr/include" -DOpenCL_LIBRARY="/usr/lib64/libOpenCL.so.1" 

make

make install

cd ..

cd ..

git clone https://github.com/mpicbg-scicomp/gearshifft/

cd gearshifft/

mkdir build

cd build/

../../cmakeinstall/bin/cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DFFTW_LIBRARY_DIR="/home/benson/Projects/Gearshifft/amd/fftw-3.3.8-clang-install/lib" -DCMAKE_SHARED_LINKER_FLAGS="-L/home/benson/Projects/Gearshift/amd/fftw3-3.3.8-clang-install/lib -lfftw3 -lfftw3f -L/home/benson/Projects/Gearshifft/amd/boost_1_68_0_clang_install/lib -lboost_program_options -L/lib64 -lpthread -lm" -DBOOST_DIR=/home/benson/Projects/Gearshifft/amd/boost_1_68_0_clang_install -DBOOST_INCLUDEDIR=/home/benson/Projects/Gearshifft/amd/boost_1_68_0_clang_install/include -DBoost_ADDITIONAL_VERSIONS=1.67.0 -DCMAKE_INSTALL_PREFIX=/home/benson/Projects/Gearshifft/amd/gearshifftinstall -DCMAKE_EXE_LINKER_FLAGS="-L/home/benson/Projects/Gearshift/amd/fftw3-3.3.8-clang-install/lib -lfftw3 -lfftw3f -L/home/benson/Projects/Gearshifft/amd/boost_1_68_0_clang_install/lib -lboost_program_options -L/lib64 -lpthread -lm" -D_CLFFT_INCLUDE_DIRS="/home/benson/Projects/Gearshifft/amd/clfftinstall/include" -DOpenCL_INCLUDE_DIR="/usr/include" -DOpenCL_LIBRARY="/usr/lib64/libOpenCL.so.1" -D_CLFFT_LIBRARY="/home/benson/Projects/Gearshifft/amd/clfftinstall/lib64/libclFFT.so" -DCLFFT_ROOT_DIR="/home/benson/Projects/Gearshifft/amd/clfftinstall" -DFFTW_INCLUDES="/home/benson/Projects/Gearshifft/amd/fftw-3.3.8-clang-install/include" -DFFTW_LIBRARIES=/home/benson/Projects/Gearshifft/amd/fftw-3.3.8-clang-install/lib -DCMAKE_BUILD_TYPE=Release -DGEARSHIFFT_INSTALL_CONFIG_PATH=/home/benson/Projects/Gearshifft/amd/gearshifftinstall/share/gearshifft
export CMAKE_PREFIX_PATH=/home/benson/Projects/Gearshifft/amd/fftw-3.3.8-clang-install:/home/benson/Projects/Gearshifft/amd/boost_1_68_0_clang_install:/home/benson/Projects/Gearshifft/amd/boost_1_68_0_clang_install/lib
export LD_LIBRARY_PATH=/home/benson/Projects/Gearshifft/amd/clfftinstall/lib64/:/home/benson/Projects/Gearshifft/amd/fftw-3.3.8-clang-install/lib/:/home/benson/Projects/Gearshifft/amd/boost_1_68_0_clang_install/lib

make

make install

cd ..

cd gearshifftinstall/

cd bin/

cp ../share/gearshifft/extents_1d_publication.conf  .

cp extents_1d_publication.conf extents_1d_publication_short.conf 

### remove tests on more than 10^6 points

vi extents_1d_publication_short.conf 

./gearshifft_fftw -f extents_1d_publication_short.conf  -o result_fftw.csv -d cpu

./gearshifft_clfft -f extents_1d_publication_short.conf  -o result_clfft_cpu.csv -d cpu

### This part not working as Mesa does not fully support OpenCL gpu execution

./gearshifft_clfft -f extents_1d_publication_short.conf  -o result_clfft_cpu.csv -d gpu
