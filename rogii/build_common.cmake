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

include(
    "${CMAKE_CURRENT_LIST_DIR}/Version.cmake"
)

set(
    PACKAGE_NAME
    "python-${Python_VERSION}-${ARCH}-${BUILD}${TAG}"
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
    # PCbuild/find_python.bat takes externals/pythonx86 first and otherwise installs the latest
    # pythonx86 from nuget; pythonx86 3.15 can no longer run the 3.12 regen scripts.
    set(
        HOST_PYTHON_VERSION
        3.14.7
    )
    set(
        HOST_PYTHON_DIR
        "${CMAKE_CURRENT_LIST_DIR}/../externals/pythonx86"
    )
    set(
        HOST_PYTHON_ARCHIVE
        "${CMAKE_CURRENT_LIST_DIR}/../externals/pythonx86.${HOST_PYTHON_VERSION}.nupkg"
    )
    file(
        DOWNLOAD
            "https://api.nuget.org/v3-flatcontainer/pythonx86/${HOST_PYTHON_VERSION}/pythonx86.${HOST_PYTHON_VERSION}.nupkg"
            "${HOST_PYTHON_ARCHIVE}"
        EXPECTED_HASH
            SHA512=d2bb139210513ab54821e82969131cadde68a86d8e2ed7d27cb747cf8aeb855e4e6d34261f5e86d1a7d7e68e773760e8a14970d6e426a67a3a4df27a89e341e5
        TLS_VERIFY
            ON
    )
    file(
        REMOVE_RECURSE
            "${HOST_PYTHON_DIR}"
    )
    file(
        ARCHIVE_EXTRACT
        INPUT
            "${HOST_PYTHON_ARCHIVE}"
        DESTINATION
            "${HOST_PYTHON_DIR}"
    )
    if(NOT EXISTS "${HOST_PYTHON_DIR}/tools/python.exe")
        message(
            FATAL_ERROR
            "pythonx86 ${HOST_PYTHON_VERSION} has no tools/python.exe"
        )
    endif()

    set(
        MSBUILD_PARAMS
        "-v:n"
    )
    message (
        "cmd /C ${BUILD_DIRECTORY}\\build.bat -c Release -p ${BUILD_ARCH}"
    )
    foreach(
        CONFIGURATION
        Release
        Debug
    )
        execute_process(
            COMMAND
                cmd /C "${BUILD_DIRECTORY}/build.bat -c ${CONFIGURATION} -p ${BUILD_ARCH} ${MSBUILD_PARAMS}"
            WORKING_DIRECTORY
                "${BUILD_DIRECTORY}"
            RESULT_VARIABLE
                BUILD_RESULT
        )
        if(NOT BUILD_RESULT EQUAL 0)
            message(
                FATAL_ERROR
                "build.bat -c ${CONFIGURATION} -p ${BUILD_ARCH} failed: ${BUILD_RESULT}"
            )
        endif()
    endforeach()
	
elseif(UNIX)
    set(
        ENV{CFLAGS}
        -O2 -ggdb
    )
    set(
        ENV{LDFLAGS}
        "-Wl,--enable-new-dtags -Wl,-rpath,\\$\$ORIGIN/ -Wl,-rpath,\\$\$ORIGIN/../lib"
    )
    execute_process(
        COMMAND
         ./configure --prefix=${CMAKE_INSTALL_PREFIX} --enable-shared --with-system-expat=no --with-system-ffi=no --with-system-libmpdec=no --with-universal-archs=${BUILD_ARCH}
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_SOURCE_DIR}"
    )
    execute_process(
        COMMAND
            make -j
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
            "${CMAKE_CURRENT_LIST_DIR}"
    )
    execute_process(
        COMMAND
            7z.exe a -r -tzip ../python${Python_VERSION_MAJOR}${Python_VERSION_MINOR}.zip *.pyc -x!__pycache__ -x!test -x!ensurepip -x!idlelib -x!venv -x!tests -x!turtle* -aou
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_LIST_DIR}/../Lib"
    )
    file(
        COPY
            python${Python_VERSION_MAJOR}${Python_VERSION_MINOR}.zip
        DESTINATION
            "${CMAKE_INSTALL_PREFIX}"
    )
elseif(UNIX)
    message(WARNING "TODO: implement me")
endif()

file(
    COPY
        rogii/package.cmake
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
    # Copy Tcl\Tk scripts
    file(
        COPY
            "${CMAKE_CURRENT_LIST_DIR}/../externals/tcltk-8.6.15.2/amd64/lib/tcl8.6"
        DESTINATION
            "${ROOT}/${PACKAGE_NAME}/tcl"
    )
    file(
        COPY
            "${CMAKE_CURRENT_LIST_DIR}/../externals/tcltk-8.6.15.2/amd64/lib/tk8.6"
        DESTINATION
            "${ROOT}/${PACKAGE_NAME}/tcl"
    )
elseif(UNIX)
    execute_process(
        COMMAND
            chmod +w ${ROOT}/${PACKAGE_NAME}/lib/libpython${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}.so.1.0
        COMMAND
            chmod +w ${ROOT}/${PACKAGE_NAME}/lib/libpython3.so
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_LIST_DIR}"
    )
    execute_process(
        COMMAND
            ./utils/split_debug_info.sh ${ROOT}/${PACKAGE_NAME}/lib/libpython${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}.so.1.0
        COMMAND
            ./utils/split_debug_info.sh ${ROOT}/${PACKAGE_NAME}/lib/libpython3.so
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_LIST_DIR}"
    )
    execute_process(
        COMMAND
            chmod -w ${ROOT}/${PACKAGE_NAME}/lib/libpython${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}.so.1.0
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
