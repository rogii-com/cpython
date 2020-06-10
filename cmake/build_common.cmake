if(
    NOT DEFINED ROOT
    OR NOT DEFINED ARCH
)
    message(
        FATAL_ERROR
        "Assert: ROOT = ${ROOT}; ARCH = ${ARCH}"
    )
endif()

set(
    BUILD
    1
)

if(DEFINED ENV{BUILD_NUMBER})
    set(
        BUILD
        $ENV{BUILD_NUMBER}
    )
endif()

set(
    TAG
    ""
)

if(DEFINED ENV{TAG})
    set(
        TAG
        "$ENV{TAG}"
    )
else()
    find_package(
        Git
    )

    if(Git_FOUND)
        execute_process(
            COMMAND
                ${GIT_EXECUTABLE} rev-parse --short HEAD
            OUTPUT_VARIABLE
                TAG
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        set(
            TAG
            "_${TAG}"
        )
    endif()
endif()

if(WIN32)
    set(
        TOOLSET
        "msvc-14.0"
    )
elseif(UNIX)
    set(
        TOOLSET
        "gcc"
    )
endif()

set(
    PACKAGE_NAME
    "python-3.7.4-${ARCH}-${BUILD}${TAG}"
)

set(
    BUILD_DIRECTORY
    ${CMAKE_CURRENT_LIST_DIR}/../PCBuild
)

set(
    CMAKE_INSTALL_PREFIX
    ${ROOT}/${PACKAGE_NAME}
)

if(WIN32)
    set(
        MSBUILD_PARAMS
        "-v:n"
    )
    message (
        "cmd /C ${BUILD_DIRECTORY}\\build.bat -c Release -p ${BUILD_ARCH}"
    )
    execute_process(
        COMMAND
            cmd /C "${BUILD_DIRECTORY}/build.bat -c Release -p ${BUILD_ARCH} ${MSBUILD_PARAMS}"
        WORKING_DIRECTORY
            "${BUILD_DIRECTORY}"
    )
    execute_process(
        COMMAND
            cmd /C "${BUILD_DIRECTORY}/build.bat -c Debug -p ${BUILD_ARCH} ${MSBUILD_PARAMS}"
        WORKING_DIRECTORY
            "${BUILD_DIRECTORY}"
    )
	
elseif(UNIX)
    set(
        ENV{CFLAGS}
        -O2 -ggdb
    )
    execute_process(
        COMMAND
            ./configure --prefix=${CMAKE_INSTALL_PREFIX} --enable-shared --with-system-expat=no --with-system-ffi=no --with-system-libmpdec=no --with-universal-archs=${BUILD_ARCH}
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
    execute_process(
        COMMAND
            make
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
    execute_process(
        COMMAND
            make install
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
endif()

if(DEFINED ENV{TAG})
    set(
        TAG
        "$ENV{TAG}"
    )
endif()

if(WIN32)
    execute_process(
        COMMAND
            "${BUILD_DIRECTORY}/${FOLDER_ARCH}/python.exe" mkstd.py
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_LIST_DIR}/.."
    )
    file(
        COPY
            python37.zip
        DESTINATION
            "${CMAKE_INSTALL_PREFIX}"
    )
elseif(UNIX)
    message(WARNING "TODO: implement me")
endif()

file(
    COPY
        package.cmake
    DESTINATION
        "${CMAKE_INSTALL_PREFIX}"
)

if(WIN32)
    file(
        COPY
            Include/
            PC/pyconfig.h
        DESTINATION
            "${ROOT}/${PACKAGE_NAME}/include"
    )
    file(
        COPY
            ${BUILD_DIRECTORY}/${FOLDER_ARCH}/
        DESTINATION
            "${ROOT}/${PACKAGE_NAME}/bin"
    )
    file(
        COPY
             externals/tcltk-8.6.9.0/${FOLDER_ARCH}/lib/tcl8.6
             externals/tcltk-8.6.9.0/${FOLDER_ARCH}/lib/tk8.6
             externals/tcltk-8.6.9.0/${FOLDER_ARCH}/lib/tix8.4.3
        DESTINATION
            "${ROOT}/${PACKAGE_NAME}/tcl"
    )

elseif(UNIX)
    execute_process(
        COMMAND
            chmod +w ${ROOT}/${PACKAGE_NAME}/lib/libpython3.7m.so.1.0
        COMMAND
            chmod +w ${ROOT}/${PACKAGE_NAME}/lib/libpython3.so
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_LIST_DIR}"
    )
    execute_process(
        COMMAND
            ./utils/split_debug_info.sh ${ROOT}/${PACKAGE_NAME}/lib/libpython3.7m.so.1.0
        COMMAND
            ./utils/split_debug_info.sh ${ROOT}/${PACKAGE_NAME}/lib/libpython3.so
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_LIST_DIR}"
    )
    execute_process(
        COMMAND
            chmod -w ${ROOT}/${PACKAGE_NAME}/lib/libpython3.7m.so.1.0
        COMMAND
            chmod -w ${ROOT}/${PACKAGE_NAME}/lib/libpython3.so
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_LIST_DIR}"
    )
endif()

execute_process(
    COMMAND
        "${CMAKE_COMMAND}" -E tar cf "${PACKAGE_NAME}.7z" --format=7zip -- "${PACKAGE_NAME}"
    WORKING_DIRECTORY
        "${ROOT}"
)
