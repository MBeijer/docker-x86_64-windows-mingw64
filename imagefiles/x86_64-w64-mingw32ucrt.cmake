# Toolchain file for building Windows/UCRT binaries from Debian sid.

set(CMAKE_SYSTEM_NAME Windows)
set(TOOLCHAIN_PREFIX x86_64-w64-mingw32ucrt)

# cross compilers to use for C, C++ and Fortran
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_Fortran_COMPILER ${TOOLCHAIN_PREFIX}-gfortran)
set(CMAKE_RC_COMPILER ${TOOLCHAIN_PREFIX}-windres)
set(PKG_CONFIG_EXECUTABLE ${TOOLCHAIN_PREFIX}-pkg-config)

# target environment on the build host system
if(NOT TOOLCHAIN_PATH)
	set(TOOLCHAIN_PATH /usr/${TOOLCHAIN_PREFIX})
endif()

set(CMAKE_FIND_ROOT_PATH
	${TOOLCHAIN_PATH}
)

set(CMAKE_FIND_DLL_PATH
	${TOOLCHAIN_PATH}/lib
	${TOOLCHAIN_PATH}/bin
)

# Optional: locate GCC runtime dir dynamically instead of hardcoding 10-posix.
execute_process(
	COMMAND ${CMAKE_C_COMPILER} -print-libgcc-file-name
	OUTPUT_VARIABLE _libgcc_file
	OUTPUT_STRIP_TRAILING_WHITESPACE
)

get_filename_component(_gcc_runtime_dir "${_libgcc_file}" DIRECTORY)

list(APPEND CMAKE_FIND_DLL_PATH
	${_gcc_runtime_dir}
)

# modify default behavior of FIND_XXX() commands
set(CMAKE_PREFIX_PATH ${TOOLCHAIN_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_INSTALL_PREFIX "${CMAKE_PREFIX_PATH}/usr" CACHE PATH "Use PREFIX path" FORCE)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -static")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
