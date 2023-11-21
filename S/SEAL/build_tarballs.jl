# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "SEAL"
version = v"4.1.1"

# Collection of sources required to complete build
sources = [
    ArchiveSource("https://github.com/microsoft/SEAL/archive/refs/tags/v$(version).tar.gz", "af9bf0f0daccda2a8b7f344f13a5692e0ee6a45fea88478b2b90c35648bf2672")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
ls
cd $WORKSPACE/srcdir/SEAL-*
cmake .     -DCMAKE_INSTALL_PREFIX=$prefix     -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN%.*}_clang.cmake     -DCMAKE_BUILD_TYPE=Release     -DCMAKE_POSITION_INDEPENDENT_CODE=ON     -DBUILD_SHARED_LIBS=OFF     -DSEAL_BUILD_SEAL_C=ON     -DSEAL_USE___BUILTIN_CLZLL=OFF     -DSEAL_USE__ADDCARRY_U64=OFF     -DSEAL_USE__SUBBORROW_U64=OFF
make -j${nproc}
make install
ls
make
cmake .     -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF     -DSEAL_BUILD_SEAL_C=ON
make -j 40
make install
ls ../../destdir
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Platform("x86_64", "linux"; libc = "glibc"),
    Platform("powerpc64le", "linux"; libc = "glibc")
]


# The products that we will ensure are always built
products = [
    LibraryProduct("libsealc", :libsealc)
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6", preferred_gcc_version = v"10.2.0")
