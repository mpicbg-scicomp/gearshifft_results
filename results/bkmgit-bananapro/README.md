##Command history to setup tests from a fresh minimal Fedora 28 installation on a [Banana Pro](http://www.lemaker.org/product-bananapro-index.html)

sudo dnf update

sudo dnf install wget

sudo dnf install clpeak ocl-icd clinfo pocl mesa-libOpenCL mesa-libOpenCL-devel libclc

sudo dnf install opencl-headers opencl-utils opencl-utils-devel gromacs-opencl

sudo dnf install fftw fftw-libs fftw-devel fftw-libs-single fftw-libs-double

sudo dnf install gcc clang

sudo dnf install glew glew-devel libGLEW

sudo dnf install git

mkdir fft_bench

cd fft_bench/

sudo dnf install pocl pocl-devel

wget https://dl.bintray.com/boostorg/release/1.68.0//source/boost_1_68_0.tar.gz

git clone https://github.com/clMathLibraries/clFFT

cd clFFT/

git checkout ce107c4

cd src/

mkdir build

cd ..

cd ..

sudo dnf install tar

tar -xvf boost_1_68_0.tar.gz 

cd boost_1_68_0

./bootstrap.sh --with-toolset=clang --prefix=/home/bkm/fft_bench/boostinstall --with-libraries=program_options,filesystem,system,test

./b2 install --variant=release

cd ..

wget https://cmake.org/files/v3.12/cmake-3.12.1.tar.gz

tar -xvf cmake-3.12.1.tar.gz 

cd cmake-3.12.1

sudo dnf install make

./bootstrap --prefix=/home/bkm/fft_bench/cmakeinstall

make

make install

cd clFFT

cd src/build/

../../../cmakeinstall/bin/cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/home/bkm/fft_bench/clfftinstall -DCMAKE_SHARED_LINKER_FLAGS="-L/home/bkm/fft_bench/boostinstall/lib -lboost_program_options -L/lib -lpthread -lm"

make

export LD_LIBRARY_PATH=/home/bkm/fft_bench/boostinstall/lib/:$LD_LIBRARY_PATH

make install

cd ..

cd ..

cd ..

git clone https://github.com/mpicbg-scicomp/gearshifft

cd gearshifft/

export CMAKE_PREFIX_PATH=/home/bkm/fft_bench/boostinstall/:/home/bkm/fft_bench/boostinstall/lib/

git checkout 367cc1b

mkdir build

cd build/

../../cmakeinstall/bin/cmake  .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_SHARED_LINKER_FLAGS="-L/home/bkm/fft_bench/boostinstall/lib -lboost_program_options -L/lib -lpthread -lm" -D_CLFFT_INCLUDE_DIRS="/home/bkm/fft_bench/clfftinstall/include" -D_CLFFT_ROOT_DIR="/home/bkm/fft_bench/clfftinstall" -D_CLFFT_LIBRARY="/home/bkm/fft_bench/clfftinstall/lib64/libclFFT.so" -DCMAKE_BUILD_TYPE=Release -DBOOST_DIR="/home/bkm/fft_bench/boostinstall" -DBoost_ADDITIONAL_VERSIONS=1.67.0 -DCMAKE_INSTALL_PREFIX=/home/bkm/fft_bench/gearshifftinstall -DGEARSHIFFT_INSTALL_CONFIG_PATH="/home/bkm/fft_bench/gearshifftinstall/share/gearshifft" -DCMAKE_CXX_FLAGS="-Wno-c++11-narrowing"  -DCMAKE_EXE_LINKER_FLAGS="-L/home/bkm/fft_bench/boostinstall/lib -lboost_program_options -L/lib -lpthread -lm"

make -j2

make install

cd ..

cd ..

cd gearshifftinstall/

cd bin/

cp ../share/gearshifft/extents_1d_publication.conf .

#### edit to have FFT lengths less than one million

vi extents_1d_publication.conf 

export LD_LIBRARY_PATH=/home/bkm/fft_bench/clfftinstall/lib64/:$LD_LIBRARY_PATH

./gearshifft_clfft -f extents_1d_publication.conf -o result_clfft_cpu.csv -d cpu

./gearshifft_fftw -f extents_1d_publication.conf -o result_fftw_cpu.csv -d cpu
