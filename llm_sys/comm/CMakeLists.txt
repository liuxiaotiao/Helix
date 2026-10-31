cmake_minimum_required(VERSION 3.22)
project(ZMQ_Comm)

set(CMAKE_CXX_STANDARD 17)

# Find PythonLibs to get the include directories
# Note: "sudo apt install python3.10-dev" if not found
find_package(Python3 REQUIRED COMPONENTS Interpreter Development)
include_directories(${Python3_INCLUDE_DIRS})
link_libraries(${Python3_LIBRARIES})

# Find the pybind11 package
# Note: "sudo apt-get install pybind11-dev" if not found
find_package(pybind11 REQUIRED)

# Find the PyTorch package
# Note: This is torch.utils.cmake_prefix_path in python.
list(APPEND CMAKE_PREFIX_PATH "~/miniconda3/envs/runtime/lib/python3.10/site-packages/torch/share/cmake")
find_package(Torch REQUIRED)

# Find libtorch_python.so, this is not included in the torch package by default
find_library(torch_python_LIBRARY torch_python PATHS "${TORCH_INSTALL_PREFIX}/lib")

# Find cppzmq: an installed CMake package if there is one, otherwise the vendored header-only copy
# (third_party/cppzmq) on top of libzmq's own CMake package (tools/install_node.sh installs it)
find_package(cppzmq QUIET)
if(NOT TARGET cppzmq)
    find_package(ZeroMQ REQUIRED)
    add_library(cppzmq INTERFACE IMPORTED)
    set_target_properties(cppzmq PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}/third_party/cppzmq"
            INTERFACE_LINK_LIBRARIES libzmq)
    message(STATUS "cppzmq: using vendored headers in third_party/cppzmq")
endif()
# src/poller.h uses zmq::poller_t, part of ZeroMQ's DRAFT API: libzmq must be built with
# ENABLE_DRAFTS=ON (tools/install_node.sh does this) and the headers need this macro.
add_compile_definitions(ZMQ_BUILD_DRAFT_API)

# --------------------------------------------- Targets --------------------------------------------- #

# for verification of communication
add_executable(packed_server tests/test_packed_server.cpp)
add_executable(packed_client tests/test_packed_client.cpp)
target_link_libraries(packed_server cppzmq)
target_link_libraries(packed_client cppzmq)

# for verification of msg encoding & decoding
add_executable(test_msg tests/test_msg.cpp)
target_link_libraries(test_msg cppzmq)

# llm worker
pybind11_add_module(llm_worker MODULE src/sys_worker_api.cpp)
target_include_directories(llm_worker PRIVATE ${TORCH_INCLUDE_DIRS} ${PYTHON_INCLUDE_DIRS})
target_link_libraries(llm_worker PRIVATE cppzmq)
target_link_libraries(llm_worker PRIVATE ${PYTHON_LIBRARIES})
target_link_libraries(llm_worker PRIVATE ${TORCH_LIBRARIES})
target_link_libraries(llm_worker PRIVATE ${torch_python_LIBRARY})
target_link_libraries(llm_worker PRIVATE pybind11::pybind11)
target_link_libraries(llm_worker PRIVATE pybind11::embed)

# llm host
pybind11_add_module(llm_host MODULE src/sys_host_api.cpp)
target_include_directories(llm_host PRIVATE ${TORCH_INCLUDE_DIRS} ${PYTHON_INCLUDE_DIRS})
target_link_libraries(llm_host PRIVATE cppzmq)
target_link_libraries(llm_host PRIVATE ${PYTHON_LIBRARIES})
target_link_libraries(llm_host PRIVATE ${TORCH_LIBRARIES})
target_link_libraries(llm_host PRIVATE ${torch_python_LIBRARY})
target_link_libraries(llm_host PRIVATE pybind11::pybind11)
target_link_libraries(llm_host PRIVATE pybind11::embed)
