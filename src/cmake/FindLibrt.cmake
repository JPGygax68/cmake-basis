# Try to find librt
# Once done this will define
#
#  LIBRT_FOUND - system has librt
#  Librt_INCLUDE_DIR - the librt include directory
#  Librt_LIBRARIES - the libraries needed to use librt
#  Librt_STATIC_LIBRARIES - static libraries of librt
#
	
	FIND_PATH(Librt_INCLUDE_DIR NAMES time.h PATHS
	        ${LIBRTDIR}/include/
                /usr/include/
	)
	
	FIND_LIBRARY(Librt_LIBRARIES rt)
	FIND_FILE(Librt_STATIC_LIBRARIES librt.a PATHS
	        ${LIBRTDIR}/lib/
	        /usr/local/lib64/
	        /usr/local/lib/
	        /usr/lib/i386-linux-gnu/
	        /usr/lib/x86_64-linux-gnu/
	        /usr/lib64/
	        /usr/lib/
	)
	
	#if(Librt_INCLUDE_DIR AND (Librt_LIBRARIES OR ${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
	#        set(LIBRT_FOUND TRUE CACHE INTERNAL "librt found")
	#        if(NOT Librt_FIND_QUIETLY)
	#                message(STATUS "Found librt: ${Librt_INCLUDE_DIR}, ${Librt_LIBRARIES}, ${Librt_STATIC_LIBARIES}")
	#        endif(NOT Librt_FIND_QUIETLY)
	#else(Librt_INCLUDE_DIR AND (Librt_LIBRARIES OR ${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
	#        set(LIBRT_FOUND FALSE CACHE INTERNAL "librt not found")
	#        if(NOT Librt_FIND_QUIETLY)
	#                message(STATUS "librt not found.")
	#        endif(NOT Librt_FIND_QUIETLY)
	#endif(Librt_INCLUDE_DIR AND (Librt_LIBRARIES OR ${CMAKE_SYSTEM_NAME} MATCHES "Darwin"))
	
	MARK_AS_ADVANCED(Librt_INCLUDE_DIR Librt_LIBRARIES Librt_STATIC_LIBRARIES)
	
  # handle the QUIETLY and REQUIRED arguments and set LIBRT_FOUND to TRUE if 
  # all listed variables are TRUE
  INCLUDE(FindPackageHandleStandardArgs)
  FIND_PACKAGE_HANDLE_STANDARD_ARGS(Librt DEFAULT_MSG Librt_LIBRARIES Librt_STATIC_LIBRARIES Librt_INCLUDE_DIR)

  MARK_AS_ADVANCED(Librt_INCLUDE_DIR Librt_LIBRARIES )
	if(LIBRT_FOUND)
	  set(Librt_LIBRARIES_OPTIONAL ${Librt_LIBRARIES})
	else(LIBRT_FOUND)
	  set(Librt_LIBRARIES_OPTIONAL "")
	endif(LIBRT_FOUND)
