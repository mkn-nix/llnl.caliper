#!/usr/bin/env bash
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

exec 19>$CWD/.mkn.sh.cmd # set -x redirect
export BASH_XTRACEFD=19  # set -x redirect

set -xe
(
  date

  THREADS=${THREADS:=""}
  DIR="caliper"
  GIT_URL="https://github.com/llnl/$DIR"
  VERSION="master"
  FFF=("include" "lib" "$DIR" "share")
  [ ! -z "$MKN_CLEAN" ] && (( $MKN_CLEAN == 1 )) && for f in ${FFF[@]}; do rm -rf $CWD/$f; done
  [ ! -d "$CWD/$DIR" ] && git clone --depth 1 $GIT_URL -b $VERSION $DIR --recursive

  cd $CWD/$DIR

  rm -rf build && mkdir build && cd build

  cmake \
    -DCMAKE_INSTALL_PREFIX=$CWD                             \
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true             \
    -DCMAKE_CXX_FLAGS="-g0 -O3 -march=native -mtune=native" \
    -DWITH_MPI=ON                                           \
    -DCMAKE_BUILD_TYPE=Release                              \
    ..
  make VERBOSE=1 -j$THREADS && make install
  cd .. && rm -rf build
  find $CWD -maxdepth 1 -size 0 -name ".mkn.sh.*" -delete
  date
) 1> >(tee $CWD/.mkn.sh.out ) 2> >(tee $CWD/.mkn.sh.err >&2 )
