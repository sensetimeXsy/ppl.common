option(PPLCOMMON_ENABLE_NCCL "" OFF)

if (PPLCOMMON_ENABLE_NCCL)
    hpcc_populate_dep(nccl)

    if(NOT PPLCOMMON_CUDA_ARCHITECTURES)
        set(PPLCOMMON_CUDA_ARCHITECTURES "80;86;87")
    endif()

    set(__NVCC_GENCODE__ )
    foreach(arch ${PPLCOMMON_CUDA_ARCHITECTURES})
        set(__NVCC_GENCODE__ "${__NVCC_GENCODE__} -gencode arch=compute_${arch},code=sm_${arch}")
    endforeach()

    set(NCCL_INCLUDE_DIRS ${nccl_BINARY_DIR}/include)
    set(NCCL_LIBRARIES ${nccl_BINARY_DIR}/lib/libnccl_static.a)
    execute_process(COMMAND make NVCC_GENCODE=${__NVCC_GENCODE__} BUILDDIR=${nccl_BINARY_DIR} -j16 -C ${HPCC_DEPS_DIR}/nccl src.build)

    unset(__NVCC_GENCODE__)

    list(APPEND PPLCOMMON_INCLUDES ${NCCL_INCLUDE_DIRS})
    list(APPEND PPLCOMMON_LINK_LIBRARIES ${NCCL_LIBRARIES})
    list(APPEND PPLCOMMON_DEFINITIONS PPLCOMMON_ENABLE_NCCL)

    if(PPLCOMMON_INSTALL)
        file(GLOB __NCCL_HEADERS__ ${NCCL_INCLUDE_DIRS}/*.h)
        install(FILES ${__NCCL_HEADERS__} DESTINATION include)
        unset(__NCCL_HEADERS__)
    endif()
endif()

if(PPLCOMMON_INSTALL)
    file(GLOB PPLCOMMON_CUDA_HEADERS src/ppl/common/cuda/*.h)
    install(FILES ${PPLCOMMON_CUDA_HEADERS} DESTINATION include/ppl/common/cuda)
endif()
