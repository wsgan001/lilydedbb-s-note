# caffe 编译

## Common error of compilation：

- OpenBLAS: `'cblas.h' file not found`

    ```
    ./include/caffe/util/mkl_alternate.hpp:14:10: fatal error: 'cblas.h' file not found
    #include <cblas.h>
             ^~~~~~~~~
    1 error generated.
    ```

    solution:

    ```
    $ brew uninstall openblas
    $ brew install --fresh -vd openblas
    ```

    and make sure configure the correct path for `BLAS` in the `Makefile.config`:

    ```
    # BLAS choice:
    # atlas for ATLAS (default)
    # mkl for MKL
    # open for OpenBlas
    BLAS := open
    # Custom (MKL/ATLAS/OpenBLAS) include and lib directories.
    # Leave commented to accept the defaults for your choice of BLAS
    # (which should work)!
    # BLAS_INCLUDE := /path/to/your/blas
    # BLAS_LIB := /path/to/your/blas
    BLAS_INCLUDE := /usr/local/Cellar/openblas/0.2.20/include
    BLAS_LIB := /usr/local/Cellar/openblas/0.2.20/lib
    ```

- `proto/caffe.pb.h`: No such file or directory

    ```
    fatal error: caffe/proto/caffe.pb.h: No such file or directory
    #include "caffe/proto/caffe.pb.h"
    ^
    compilation terminated.
    ```

    ```
    $ protoc src/caffe/proto/caffe.proto --cpp_out=.
    $ mkdir include/caffe/proto
    $ mv src/caffe/proto/caffe.pb.h include/caffe/proto
    ```

- libcudart.so.8.0: cannot open shared object file: No such file or directory

    solution:

    ```
    export PATH=$PATH:/usr/local/cuda-8.0/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-8.0/lib64
    export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/cuda-8.0/lib64
    ```

- py-faster-rcnn cudnn 问题：

    solution:

    ```
    cp caffe/inlude/caffe/layers/cudnn_* caffe-fast-rcnn/include/caffe/layers/
    cp caffe/src/caffe/layers/cudnn_* caffe-fast-rcnn/src/caffe/layers/
    cp caffe/include/caffe/util/cudnn.hpp caffe-fast-rcnn/include/caffe/util/
    ```

    以上路径根据实际情况而定。

    ```
    cd caffe-fast-rcnn
    make clean
    make -j8
    make pycaffe
    ```
