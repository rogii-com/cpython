message(
    STATUS
    "ENV{ENV_INSTALL} = $ENV{ENV_INSTALL}"
)

if(NOT DEFINED ENV{ENV_INSTALL})
    message(
        FATAL_ERROR
        "You have to specify an install path via `ENV_INSTALL' variable."
    )
endif()

file(
    TO_CMAKE_PATH
    "$ENV{ENV_INSTALL}"
    ROOT
)

set(
    ARCH
    x86
)

if(WIN32)
    set(
        BUILD_ARCH
        win32
    )
elseif(UNIX)
    set(
        BUILD_ARCH
        32-bit
    )
endif()

set(
	FOLDER_ARCH
	win32
)

include(
    "${CMAKE_CURRENT_LIST_DIR}/build_common.cmake"
)
