set -x
set -e

output=${1:-output}

function required {
    prog=$1
    command -v ${prog} >/dev/null 2>&1 || { echo >&2 "${prog} required.  Aborting."; exit 1; }
}

required git
required wget
required file
required yasm
required gcc
required gfortran
required make

cat > config.mak << EOF
TARGET = x86_64-linux-musl
MUSL_VER = repo
MUSL_CONFIG = "--enable-file-prot"
ISL_VER = 0.15
BINUTILS_VER = 2.27
GCC_VER = 6.3.0
GCC_CONFIG += --enable-languages=c,c++,fortran
EOF

test -n ${SGX_MUSL_VER} && git submodule update --reference ${SGX_MUSL_VER} musl-repo

make extract_all
make -j10
make install

test $output != "output" && mv output ${output} || true
