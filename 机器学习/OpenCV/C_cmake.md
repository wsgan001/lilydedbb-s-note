# CMake

示例目录结构如下：

```
.
├── CMakeCache.txt
├── CMakeLists.txt
├── main.cpp
└── utils
    ├── CMakeLists.txt
    ├── computeTime.cpp
    ├── logger.cpp
    └── plotting.cpp
```

root 目录下 `CMakeList.txt` 文件：

```
cmake_minimum_required(VERSION 3.6)
cmake_policy(SET CMP0012 NEW)  # 告诉 cmake 使用新行为，以便正确识别数字和布尔常数而无需使用名称而解引用变量

project(CV)

FIND_PACKAGE(OpenCV 3.0.0 REQUIRED)  # 需要 OpenCV 3.0
MESSAGE("OpenCV version: ${OpenCV_VERSION}")  # 显示 OpenCV 版本信息

# 添加 OpenCV 的头文件和目录
include_directories(${OpenCV_INCLUDE_DIRS})
link_directories(${OpenCV_LIB_DIR})

add_subdirectory(utils)

# 添加预编译器可选日志
option(WITH_LOG "Build with output logs and image in tmp" OFF)
if (WITH_LOG)
    add_definitions(-DLOG)
endif(WITH_LOG)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(SRC main.cpp)

add_executable(${PROJECT_NAME} ${SRC})  # 创建可执行文件
target_link_libraries(${PROJECT_NAME} ${OpenCV_LIBS} Utils)  # 链接库
```

`utils` 文件夹下 `CMakeLists.txt` 文件：

```
SET(UTILS_LIB_SRC
    computeTime.cpp
    logger.cpp
    plotting.cpp
)

# 创建 Utils 库
add_library(Utils ${UTILS_LIB_SRC})
# 确保编译器可以找到库中的文件
target_link_libraries(Utils PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
```


