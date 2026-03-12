if(MSVC)
    add_compile_definitions(_ENABLE_ATOMIC_ALIGNMENT_FIX)
    set(CMAKE_C_FLAGS "/O2 /EHsc /GS /Zi /utf-8")
    set(CMAKE_CXX_FLAGS "/O2 /EHsc /GS /Zi /utf-8")
    set(CMAKE_SHARED_LINKER_FLAGS "/DEBUG ${SECURE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS}")
    set(CMAKE_EXE_LINKER_FLAGS "/DEBUG ${SECURE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS}")
else()
    string(REPLACE "-g" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
    string(REPLACE "-g" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

    # GCC 12+ with glibc 2.31+ automatically enables FORTIFY_SOURCE=3
    # Explicitly defining FORTIFY_SOURCE=2 causes conflicts and disables protection
    # Solution: Don't explicitly define for GCC 12+, let system use default
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "12.0")
        # GCC 12+: Use system default FORTIFY_SOURCE=3
        set(FORTIFY_FLAGS "")
    else()
        # GCC 11 and earlier: Explicitly define FORTIFY_SOURCE=2
        set(FORTIFY_FLAGS "-D_FORTIFY_SOURCE=2")
    endif()

    set(CMAKE_C_FLAGS "${FORTIFY_FLAGS} -O2 -Wall -Werror -Wno-attributes -Wno-deprecated-declarations \
        -Wno-missing-braces  ${SECURE_C_FLAGS} ${CMAKE_C_FLAGS}")
    set(CMAKE_CXX_FLAGS "${FORTIFY_FLAGS} -O2 -Wall -Werror -Wno-attributes -Wno-deprecated-declarations \
        -Wno-missing-braces ${SECURE_CXX_FLAGS} ${CMAKE_CXX_FLAGS}")

    set(CMAKE_C_FLAGS_DEBUG "-DDebug -g -fvisibility=default")
    set(CMAKE_CXX_FLAGS_DEBUG "-DDebug -g -fvisibility=default")

    if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        string(REPLACE "-O2" "-O0" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
        string(REPLACE "-O2" "-O0" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
        string(REPLACE "-D_FORTIFY_SOURCE=2" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
        string(REPLACE "-D_FORTIFY_SOURCE=2" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    endif()
    set(CMAKE_SHARED_LINKER_FLAGS "${SECURE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS}")
    set(CMAKE_EXE_LINKER_FLAGS "${SECURE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS}")
endif()
