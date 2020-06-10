if(TARGET Python::library)
	return()
endif()

add_library(
	Python::library
	SHARED
	IMPORTED
)
add_library(
	Python::legacy
	SHARED
	IMPORTED
)

if(WIN32)
	set_target_properties(
		Python::library
		PROPERTIES
			IMPORTED_LOCATION
				"${CMAKE_CURRENT_LIST_DIR}/bin/python37.dll"
			IMPORTED_LOCATION_DEBUG
				"${CMAKE_CURRENT_LIST_DIR}/bin/python37.dll"
			IMPORTED_IMPLIB
				"${CMAKE_CURRENT_LIST_DIR}/bin/python37.lib"
			IMPORTED_IMPLIB_DEBUG
				"${CMAKE_CURRENT_LIST_DIR}/bin/python37.lib"
			INTERFACE_INCLUDE_DIRECTORIES
				"${CMAKE_CURRENT_LIST_DIR}/include"
	)

	link_directories(${CMAKE_CURRENT_LIST_DIR}/bin)
	set (PYTHON_BINDIR ${CMAKE_CURRENT_LIST_DIR}/bin/)
	set (PYTHON_LIB ${CMAKE_CURRENT_LIST_DIR}/python37.zip)

	install(
		FILES
			${PYTHON_LIB}
			${PYTHON_BINDIR}/python37.dll
			${PYTHON_BINDIR}/python3.dll
			${PYTHON_BINDIR}/pyexpat.pyd
			${PYTHON_BINDIR}/select.pyd
			${PYTHON_BINDIR}/unicodedata.pyd
			${PYTHON_BINDIR}/winsound.pyd
			${PYTHON_BINDIR}/xxlimited.pyd
			${PYTHON_BINDIR}/_asyncio.pyd
			${PYTHON_BINDIR}/_bz2.pyd
			${PYTHON_BINDIR}/_ctypes.pyd
			${PYTHON_BINDIR}/_elementtree.pyd
			${PYTHON_BINDIR}/_hashlib.pyd
			${PYTHON_BINDIR}/_lzma.pyd
			${PYTHON_BINDIR}/_msi.pyd
			${PYTHON_BINDIR}/_multiprocessing.pyd
			${PYTHON_BINDIR}/_overlapped.pyd
			${PYTHON_BINDIR}/_socket.pyd
			${PYTHON_BINDIR}/_sqlite3.pyd
			${PYTHON_BINDIR}/_ssl.pyd
			${PYTHON_BINDIR}/_tkinter.pyd
			${PYTHON_BINDIR}/_queue.pyd
			${PYTHON_BINDIR}/pyshellext.dll
			${PYTHON_BINDIR}/sqlite3.dll
			${PYTHON_BINDIR}/tcl86t.dll
			${PYTHON_BINDIR}/tk86t.dll
			${PYTHON_BINDIR}/libcrypto-1_1.dll
			${PYTHON_BINDIR}/libssl-1_1.dll
			${PYTHON_BINDIR}/python.exe
		DESTINATION
			.
		COMPONENT
			CNPM_RUNTIME
		EXCLUDE_FROM_ALL
	)
	install(
		DIRECTORY
			tcl
		DESTINATION
			python
		COMPONENT
			CNPM_RUNTIME
		EXCLUDE_FROM_ALL
	)

elseif(UNIX)
	set_target_properties(
		Python::library
		PROPERTIES
			IMPORTED_LOCATION
				"${CMAKE_CURRENT_LIST_DIR}/lib/libpython3.7m.so.1.0"
			INTERFACE_INCLUDE_DIRECTORIES
				"${CMAKE_CURRENT_LIST_DIR}/include/python3.7m"
	)
	set(
		COMPONENT_NAMES

		CNPM_RUNTIME_Python_lybrary
		CNPM_RUNTIME_Python
		CNPM_RUNTIME
	)

	foreach(COMPONENT_NAME ${COMPONENT_NAMES})
		install(
			FILES
				$<TARGET_FILE:Python::library>
			DESTINATION
				.
			COMPONENT
				${COMPONENT_NAME}
			EXCLUDE_FROM_ALL
		)
    endforeach()

	set_target_properties(
		Python::legacy
		PROPERTIES
			IMPORTED_LOCATION
				"${CMAKE_CURRENT_LIST_DIR}/lib/libpython3.so"
			INTERFACE_INCLUDE_DIRECTORIES
				"${CMAKE_CURRENT_LIST_DIR}/include/python3.7m"
	)
	set(
		COMPONENT_NAMES

		CNPM_RUNTIME_Python_legacy
		CNPM_RUNTIME_Python
		CNPM_RUNTIME
	)

	foreach(COMPONENT_NAME ${COMPONENT_NAMES})
		install(
			FILES
				$<TARGET_FILE:Python::library>
				$<TARGET_FILE:Python::legacy>
			DESTINATION
				.
			COMPONENT
				${COMPONENT_NAME}
			EXCLUDE_FROM_ALL
		)
	endforeach()

endif()
