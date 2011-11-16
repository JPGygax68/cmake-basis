##############################################################################
# @file  ProjectTools.cmake
# @brief Definition of main project tools.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See https://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
#
# @ingroup CMakeAPI
##############################################################################

# ============================================================================
# meta-data
# ============================================================================

##############################################################################
# @brief Defines project meta-data, i.e., attributes.
#
# Any BASIS project has to call this macro in the file BasisProject.cmake
# located in the top level directory of the source tree in order to define
# the project attributes required by BASIS to setup the build system.
# Moreover, if the BASIS project is a module of another BASIS project, this
# file and the variables set by this macro are used by the super-project to
# identify its modules and the dependencies among them.
#
# @par Project version:
# The version number consists of three components: the major version number,
# the minor version number, and the patch number. The format of the version
# string is "&lt;major&gt;.&lt;minor&gt;.&lt;patch&gt;", where the minor version
# number and patch number default to 0 if not given. Only digits are allowed
# except of the two separating dots.
# @n
# - A change of the major version number indicates changes of the softwares
#   @api (and @abi) and/or its behavior and/or the change or addition of major
#   features.
# - A change of the minor version number indicates changes that are not only
#   bug fixes and no major changes. Hence, changes of the @api but not the @abi.
# - A change of the patch number indicates changes only related to bug fixes
#   which did not change the softwares @api. It is the least important component
#   of the version number.
#
# @par Dependencies:
# Dependencies on other BASIS projects, which can be subprojects of the same
# BASIS super-project, as well as dependencies on external packages such as ITK
# have to be defined here using the DEPENDS argument option. This will be used
# by a super-project to ensure that the dependencies among its subprojects are
# resolved properly. For each external dependency, the BASIS functions
# basis_find_package() and basis_use_package() are invoked by
# basis_project_initialize(). If an external package is not CMake aware and
# additional CMake code shall be executed to include the settings of the external
# package (which is usually done in a so-called Use<Pkg>.cmake file if the
# package would be CMake aware), such code should be added to the Settings.cmake
# file of the project.
#
# @param [in] ARGN This list is parsed for the following arguments:
# @par
# <table border="0">
#   <tr>
#     @tp @b NAME name @endtp
#     <td>The name of the project.</td>
#   </tr>
#   <tr>
#     @tp @b VERSION major[.minor[.patch]] @endtp
#     <td>Project version string. Defaults to "1.0.0"</td>
#   </tr>
#   <tr>
#     @tp @b DESCRIPTION description @endtp
#     <td>Package description, used for packing. If multiple arguments are given,
#         they are concatenated using one space character as delimiter.</td>
#   </tr>
#   <tr>
#     @tp @b PACKAGE_VENDOR name @endtp
#     <td>The vendor of this package, used for packaging. If multiple arguments
#         are given, they are concatenated using one space character as delimiter.
#         Default: "SBIA Group at University of Pennsylvania".</td>
#   </tr>
#   <tr>
#     @tp @b DEPENDS name[, name] @endtp
#     <td>List of dependencies, i.e., either names of other BASIS (sub)projects
#         or names of external packages.</td>
#   </tr>
#   <tr>
#     @tp @b OPTIONAL_DEPENDS name[, name] @endtp
#     <td>List of dependencies, i.e., either names of other BASIS (sub)projects
#         or names of external packages which are used only if available.</td>
#   </tr>
#   <tr>
#     @tp @b TEST_DEPENDS name[, name] @endtp
#     <td>List of dependencies, i.e., either names of other BASIS (sub)projects
#         or names of external packages which are only required by the tests.</td>
#   </tr>
# </table>
#
# @returns Sets the following non-cached CMake variables:
# @retval PROJECT_NAME             @c NAME argument.
# @retval PROJECT_VERSION          @c VERSION argument.
# @retval PROJECT_DESCRIPTION      Concatenated @c DESCRIPTION arguments.
# @retval PROJECT_PACKAGE_VENDOR   Concatenated @c PACKAGE_VENDOR argument.
# @retval PROJECT_DEPENDS          @c DEPENDS arguments.
# @retval PROJECT_OPTIONAL_DEPENDS @c OPTIONAL_DEPENDS arguments.
# @retval PROJECT_TEST_DEPENDS     @c TEST_DEPENDS arguments.

macro (basis_project)
  # clear project attributes of CMake defaults or superproject
  set (PROJECT_NAME)
  set (PROJECT_VERSION)
  set (PROJECT_DESCRIPTION)
  set (PROJECT_DEPENDS)
  set (PROJECT_OPTIONAL_DEPENDS)
  set (PROJECT_TEST_DEPENDS)
  set (PROJECT_PACKAGE_VENDOR)

  # parse arguments and/or include project settings file
  CMAKE_PARSE_ARGUMENTS (
    PROJECT
      ""
      "NAME;VERSION"
      "DESCRIPTION;PACKAGE_VENDOR;DEPENDS;OPTIONAL_DEPENDS;TEST_DEPENDS"
    ${ARGN}
  )

  # check required project attributes or set default values
  if (NOT PROJECT_NAME)
    message (FATAL_ERROR "basis_project(): Project name not specified!")
  endif ()

  if (NOT PROJECT_VERSION)
    message (FATAL_ERROR "basis_project(): Project version not specified!")
  endif ()

  if (PROJECT_DESCRIPTION)
    basis_list_to_delimited_string (PROJECT_DESCRIPTION " " ${PROJECT_DESCRIPTION})
  else ()
    set (PROJECT_DESCRIPTION "")
  endif ()

  if (PROJECT_PACKAGE_VENDOR)
    basis_list_to_delimited_string (PROJECT_PACKAGE_VENDOR " " ${PROJECT_PACKAGE_VENDOR})
  else ()
    set (PROJECT_PACKAGE_VENDOR "SBIA Group at University of Pennsylvania")
  endif ()
endmacro ()

# ============================================================================
# initialization
# ============================================================================

##############################################################################
# @brief Initialize project, calls CMake's project() command.
#
# This macro is called at the beginning of the root CMakeLists.txt file of
# each BASIS (sub-)project. It in particular includes the BasisProject.cmake
# file to set the project attributes and uses these to initialize the project.
#
# As the BasisTest.cmake module has to be included after the project()
# command was used, it is not included by the package use file of BASIS.
# Instead, it is included by this macro.
#
# @par Default documentation:
# Each BASIS project has to have a README.txt file in the top directory of the
# software component. This file is the root documentation file which refers the
# user to the further documentation files in @c PROJECT_DOC_DIR.
# The same applies to the COPYING.txt file with the copyright and license
# notices which must be present in the top directory of the source tree as well.
#
# @par Project finalization:
# At the end of the root CMakeLists.txt file, the counterpart of this macro,
# the macro basis_project_finalize(), has to be invoked to finalize the
# configuration of the project's build system.
#
# @sa basis_project()
# @sa basis_project_finalize()
#
# @returns Sets the following non-cached CMake variables:
# @retval BINARY_*_DIR                     Absolute paths of directories in
#                                          binary tree corresponding to the
#                                          @c PROJECT_*_DIR directories.
#                                          See Settings.cmake file.
# @retval INSTALL_*_DIR                    Configured paths of installation
#                                          relative to INSTALL_PREFIX.
#                                          See Settings.cmake file.
# @retval BASIS_UTILITIES_HEADERS          List of headers of BASIS C++ utilities.
# @retval BASIS_UTILITEIS_PUBLIC_HEADERS   List of public headers of BASIS C++ utilities.
# @retval BASIS_UTILITIES_SOURCES          List of sources of BASIS C++ utilities.
# @retval PROJECT_NAME_LOWER               Project name in all lowercase letters.
# @retval PROJECT_NAME_UPPER               Project name in all uppercase letters.
# @retval PROJECT_NAME_INFIX               Project name used as infix for installation
#                                          directories and namespace identifiers.
#                                          In particular, the project name in either
#                                          all lowercase or mixed case starting with
#                                          an uppercase letter depending on whether
#                                          the @c PROJECT_NAME has mixed case or not.
# @retval PROJECT_REVISION                 Revision number of Subversion controlled
#                                          source tree or 0 if the source tree is
#                                          not under revision control.
# @retval PROJECT_VERSION_AND_REVISION     A string of project version and revision
#                                          that can be used for the output of
#                                          version information.
#
# @ingroup CMakeAPI

macro (basis_project_initialize)
  # --------------------------------------------------------------------------
  # reset

  # These variables need to be properties such that they can be set in
  # subdirectories. Moreover, they have to be assigned with the project's
  # root source directory such that a super-project's properties are restored
  # after this subproject is finalized such that the super-project itself can
  # be finalized properly.
  basis_set_project_property (BASIS_PROJECT_USES_JAVA_UTILITIES   FALSE)
  basis_set_project_property (BASIS_PROJECT_USES_PYTHON_UTILITIES FALSE)
  basis_set_project_property (BASIS_PROJECT_USES_PERL_UTILITIES   FALSE)
  basis_set_project_property (BASIS_PROJECT_USES_BASH_UTILITIES   FALSE)
  basis_set_project_property (BASIS_PROJECT_USES_MATLAB_UTILITIES FALSE)

  set (PROJECT_DEPENDS)
  set (PROJECT_OPTIONAL_DEPENDS)
  set (PROJECT_TEST_DEPENDS)
  set (PROJECT_DESCRIPTION)
  set (PROJECT_NAME)
  set (PROJECT_PACKAGE_VENDOR)
  set (PROJECT_VERSION)

  set (PROJECT_AUTHORS_FILE)
  set (PROJECT_WELCOME_FILE)
  set (PROJECT_README_FILE)
  set (PROJECT_INSTALL_FILE)
  set (PROJECT_LICENSE_FILE)

  # set here such that it can be overwritten in the Settings.cmake file
  set (BASIS_INSTALL_PUBLIC_HEADERS_OF_CXX_UTILITIES FALSE)

  # --------------------------------------------------------------------------
  # project meta-data

  if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/BasisProject.cmake")
    include ("${CMAKE_CURRENT_SOURCE_DIR}/BasisProject.cmake")

    if (NOT PROJECT_NAME)
      message (FATAL_ERROR "Project name not defined! Forgot to call basis_project() "
                           "in the file BasisProject.cmake?")
    endif ()
  else ()
    basis_project (${ARGN})
  endif ()
 
  # --------------------------------------------------------------------------
  # resolve dependencies

  # add project config directory to CMAKE_MODULE_PATH
  set (CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/config" ${CMAKE_MODULE_PATH})

  foreach (P ${PROJECT_DEPENDS})
    if ("${P}" STREQUAL "Slicer")
      if (NOT EXTENSION_NAME)
        set (EXTENSION_NAME "${PROJECT_NAME}")
      endif ()
    endif ()
    basis_find_package ("${P}" REQUIRED)
    string (TOUPPER "${P}" U)
    if (${P}_FOUND OR ${U}_FOUND)
      basis_use_package ("${P}")
    else ()
      message (FATAL_ERROR "Package ${P} not found!")
      return ()
    endif ()
  endforeach ()

  foreach (P ${PROJECT_OPTIONAL_DEPENDS})
    if ("${P}" STREQUAL "Slicer")
      if (NOT EXTENSION_NAME)
        set (EXTENSION_NAME "${PROJECT_NAME}")
      endif ()
    endif ()
    basis_find_package ("${P}" QUIET)
    string (TOUPPER "${P}" U)
    if (${P}_FOUND OR ${U}_FOUND)
      basis_use_package ("${P}")
    endif ()
  endforeach ()

  # Note: Test dependencies are resolved after the inclusion of BasisTest.cmake below.

  unset (P)
  unset (U)

  # --------------------------------------------------------------------------
  # project()

  # start CMake project if not done yet
  #
  # Note that in particular SlicerConfig.cmake will invoke project() by itself.
  if (NOT ${PROJECT_NAME}_SOURCE_DIR)
    project ("${PROJECT_NAME}")
  endif ()

  set (CMAKE_PROJECT_NAME "${PROJECT_NAME}") # variable used by CPack

  # convert project name to upper and lower case only, respectively
  string (TOUPPER "${PROJECT_NAME}" PROJECT_NAME_UPPER)
  string (TOLOWER "${PROJECT_NAME}" PROJECT_NAME_LOWER)

  basis_normalize_name (PROJECT_NAME_INFIX "${PROJECT_NAME}")

  # get current revision of project
  basis_svn_get_revision ("${PROJECT_SOURCE_DIR}" PROJECT_REVISION)

  # extract version numbers from version string
  basis_version_numbers (
    "${PROJECT_VERSION}"
      PROJECT_VERSION_MAJOR
      PROJECT_VERSION_MINOR
      PROJECT_VERSION_PATCH
  )

  # combine version numbers to version strings (also ensures consistency)
  set (PROJECT_VERSION   "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
  set (PROJECT_SOVERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")

  # combine version and revision
  if (PROJECT_REVISION AND PROJECT_REVISION GREATER 0)
    set (PROJECT_VERSION_AND_REVISION "${PROJECT_VERSION} (revision ${PROJECT_REVISION})")
  else ()
    set (PROJECT_VERSION_AND_REVISION "${PROJECT_VERSION}")
  endif ()

  # version number for use in Perl modules
  set (PROJECT_VERSION_PERL "${PROJECT_VERSION_MAJOR}")
  if (PROJECT_VERSION_MAJOR LESS 10)
    set (PROJECT_VERSION_PERL "${PROJECT_VERSION_PERL}.0${PROJECT_VERSION_MINOR}")
  else ()
    set (PROJECT_VERSION_PERL "${PROJECT_VERSION_PERL}.${PROJECT_VERSION_MINOR}")
  endif ()
  if (PROJECT_VERSION_PATCH LESS 10)
    set (PROJECT_VERSION_PERL "${PROJECT_VERSION_PERL}_0${PROJECT_VERSION_PATCH}")
  else ()
    set (PROJECT_VERSION_PERL "${PROJECT_VERSION_PERL}_${PROJECT_VERSION_PATCH}")
  endif ()

  # determine whether this project is a module of another project
  if (PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set (IS_MODULE FALSE)
  else ()
    set (IS_MODULE TRUE)
  endif ()

  # print project information
  if (BASIS_VERBOSE)
    message (STATUS "Project:")
    message (STATUS "  Name      = ${PROJECT_NAME}")
    message (STATUS "  Version   = ${PROJECT_VERSION}")
    message (STATUS "  SoVersion = ${PROJECT_SOVERSION}")
    if (PROJECT_REVISION)
    message (STATUS "  Revision  = ${PROJECT_REVISION}")
    else ()
    message (STATUS "  Revision  = n/a")
    endif ()
  endif ()

  # --------------------------------------------------------------------------
  # settings

  # instantiate project directory structure
  basis_initialize_settings ()
 
  # common options
  if (EXISTS "${PROJECT_DOC_DIR}")
    option (BUILD_DOCUMENTATION "Whether to build and/or install the documentation." ON)
  endif ()

  if (EXISTS ${PROJECT_EXAMPLE_DIR})
    option (BUILD_EXAMPLE "Whether to build and/or install the example." ON)
  endif ()

  # include project specific settings
  #
  # This file gives further more flexibility to find external packages.
  # In particular, the default behavior does not support to look for a
  # specific version or only parts of a package. This can be done in the
  # Settings.cmake file using the basis_find_package() command.
  include ("${PROJECT_CONFIG_DIR}/Settings.cmake" OPTIONAL)

  # enable testing
  include ("${BASIS_MODULE_PATH}/BasisTest.cmake")

  if (BUILD_TESTING)
    foreach (P ${PROJECT_TEST_DEPENDS})
      basis_find_package ("${P}")
      if (${P}_FOUND OR ${U}_FOUND)
        basis_use_package ("${P}")
      else ()
        message (FATAL_ERROR "Could not find package ${P}! It is required by "
                             "the tests of ${PROJECT_NAME}. Either set ${P}_DIR "
                             "manually and try again or disable testing by "
                             "setting BUILD_TESTING to OFF.")
      endif ()
    endforeach ()
    unset (P)
    unset (U)
  endif ()

  # --------------------------------------------------------------------------
  # header files

  # Copy public header files to build tree using the same relative paths
  # as will be used for the installation. We need to use configure_file()
  # here such that the header files in the build tree are updated whenever
  # the source header file was modified. Moreover, this gives us a chance to
  # configure header files with the .in suffix.

  file (
    GLOB_RECURSE
      PROJECT_PUBLIC_HEADERS
    RELATIVE "${PROJECT_INCLUDE_DIR}"
      "${PROJECT_INCLUDE_DIR}/*.h"
      "${PROJECT_INCLUDE_DIR}/*.h.in"
      "${PROJECT_INCLUDE_DIR}/*.hh"
      "${PROJECT_INCLUDE_DIR}/*.hh.in"
      "${PROJECT_INCLUDE_DIR}/*.hpp"
      "${PROJECT_INCLUDE_DIR}/*.hpp.in"
      "${PROJECT_INCLUDE_DIR}/*.hxx"
      "${PROJECT_INCLUDE_DIR}/*.hxx.in"
      "${PROJECT_INCLUDE_DIR}/*.inl"
      "${PROJECT_INCLUDE_DIR}/*.inl.in"
      "${PROJECT_INCLUDE_DIR}/*.txx"
      "${PROJECT_INCLUDE_DIR}/*.txx.in"
  )

  foreach (H ${PROJECT_PUBLIC_HEADERS})
    get_filename_component (D "${H}" PATH)
    if (H MATCHES "\\.in$")
      get_filename_component (F "${H}" NAME_WE)
      set (MODE "@ONLY")
    else ()
      get_filename_component (F "${H}" NAME)
      set (MODE "COPYONLY")
    endif ()
    if (INCLUDE_PREFIX MATCHES "/$")
      configure_file ("${PROJECT_INCLUDE_DIR}/${H}" "${BINARY_INCLUDE_DIR}/${INCLUDE_PREFIX}${D}/${F}" ${MODE})
    else ()
      configure_file ("${PROJECT_INCLUDE_DIR}/${H}" "${BINARY_INCLUDE_DIR}/${D}/${INCLUDE_PREFIX}${F}" ${MODE})
    endif ()
  endforeach ()

  basis_include_directories (BEFORE "${PROJECT_CODE_DIR}")
  basis_include_directories (BEFORE "${BINARY_INCLUDE_DIR}")

  unset (PROJECT_PUBLIC_HEADERS)
  unset (MODE)

  # --------------------------------------------------------------------------
  # authors, readme, install and license files

  # Do this after the inclusion of the Settings.cmake file such that a project
  # can potentially overwrite the defaults even though not recommended.

  if (NOT PROJECT_AUTHORS_FILE)
    if (EXISTS "${PROJECT_SOURCE_DIR}/AUTHORS.txt")
      set (PROJECT_AUTHORS_FILE "${PROJECT_SOURCE_DIR}/AUTHORS.txt")
    elseif (EXISTS "${PROJECT_SOURCE_DIR}/AUTHORS")
      set (PROJECT_AUTHORS_FILE "${PROJECT_SOURCE_DIR}/AUTHORS")
    endif ()
  elseif (NOT EXISTS "${PROJECT_AUTHORS_FILE}")
    message (FATAL_ERROR "Specified project AUTHORS file does not exist.")
  endif ()

  if (NOT PROJECT_README_FILE)
    if (EXISTS "${PROJECT_SOURCE_DIR}/README.txt")
      set (PROJECT_README_FILE "${PROJECT_SOURCE_DIR}/README.txt")
    elseif (EXISTS "${PROJECT_SOURCE_DIR}/README")
      set (PROJECT_README_FILE "${PROJECT_SOURCE_DIR}/README")
    elseif (NOT IS_MODULE)
      message (FATAL_ERROR "Project ${PROJECT_NAME} is missing a README file.")
    endif ()
  elseif (NOT EXISTS "${PROJECT_README_FILE}")
    message (FATAL_ERROR "Specified project README file does not exist.")
  endif ()

  if (NOT PROJECT_INSTALL_FILE)
    if (EXISTS "${PROJECT_SOURCE_DIR}/INSTALL.txt")
      set (PROJECT_INSTALL_FILE "${PROJECT_SOURCE_DIR}/INSTALL.txt")
    elseif (EXISTS "${PROJECT_SOURCE_DIR}/INSTALL")
      set (PROJECT_INSTALL_FILE "${PROJECT_SOURCE_DIR}/INSTALL")
    endif ()
  elseif (NOT EXISTS "${PROJECT_INSTALL_FILE}")
    message (FATAL_ERROR "Specified project INSTALL file does not exist.")
  endif ()

  if (NOT PROJECT_LICENSE_FILE)
    if (EXISTS "${PROJECT_SOURCE_DIR}/COPYING.txt")
      set (PROJECT_LICENSE_FILE "${PROJECT_SOURCE_DIR}/COPYING.txt")
    elseif (EXISTS "${PROJECT_SOURCE_DIR}/COPYING")
      set (PROJECT_LICENSE_FILE "${PROJECT_SOURCE_DIR}/COPYING")
    elseif (NOT IS_MODULE)
      message (FATAL_ERROR "Project ${PROJECT_NAME} is missing a COPYING file.")
    endif ()
  elseif (NOT EXISTS "${PROJECT_LICENSE_FILE}")
    message (FATAL_ERROR "Specified project license file does not exist.")
  endif ()

  get_filename_component (AUTHORS "${PROJECT_AUTHORS_FILE}" NAME_WE)
  get_filename_component (README  "${PROJECT_README_FILE}"  NAME_WE)
  get_filename_component (INSTALL "${PROJECT_INSTALL_FILE}" NAME_WE)
  get_filename_component (LICENSE "${PROJECT_LICENSE_FILE}" NAME_WE)

  get_filename_component (AUTHORS_EXT "${PROJECT_AUTHORS_FILE}" EXT)
  get_filename_component (README_EXT  "${PROJECT_README_FILE}"  EXT)
  get_filename_component (INSTALL_EXT "${PROJECT_INSTALL_FILE}" EXT)
  get_filename_component (LICENSE_EXT "${PROJECT_LICENSE_FILE}" EXT)

  if (WIN32)
    if (NOT AUTHORS_EXT)
      set (AUTHORS_EXT ".txt")
    endif ()
    if (NOT README_EXT)
      set (README_EXT ".txt")
    endif ()
    if (NOT INSTALL_EXT)
      set (INSTALL_EXT ".txt")
    endif ()
    if (NOT LICENSE_EXT)
      set (LICENSE_EXT ".txt")
    endif ()
  else ()
    if (AUTHORS_EXT STREQUAL ".txt")
      set (AUTHORS_EXT "")
    endif ()
    if (README_EXT STREQUAL ".txt")
      set (README_EXT "")
    endif ()
    if (INSTALL_EXT STREQUAL ".txt")
      set (INSTALL_EXT "")
    endif ()
    if (LICENSE_EXT STREQUAL ".txt")
      set (LICENSE_EXT "")
    endif ()
  endif ()

  set (AUTHORS "${AUTHORS}${AUTHORS_EXT}")
  set (README  "${README}${README_EXT}")
  set (INSTALL "${INSTALL}${INSTALL_EXT}")
  set (LICENSE "${LICENSE}${LICENSE_EXT}")

  if (NOT "${PROJECT_BINARY_DIR}" STREQUAL "${PROJECT_SOURCE_DIR}")
    if (PROJECT_README_FILE)
      configure_file ("${PROJECT_README_FILE}" "${PROJECT_BINARY_DIR}/${README}" COPYONLY)
    endif ()
    if (PROJECT_LICENSE_FILE)
      configure_file ("${PROJECT_LICENSE_FILE}" "${PROJECT_BINARY_DIR}/${LICENSE}" COPYONLY)
    endif ()
    if (PROJECT_AUTHORS_FILE)
      configure_file ("${PROJECT_AUTHORS_FILE}" "${PROJECT_BINARY_DIR}/${AUTHORS}" COPYONLY)
    endif ()
    if (PROJECT_INSTALL_FILE)
      configure_file ("${PROJECT_INSTALL_FILE}" "${PROJECT_BINARY_DIR}/${INSTALL}" COPYONLY)
    endif ()
  endif ()

  install (
    FILES       "${PROJECT_README_FILE}"
    DESTINATION "${INSTALL_DOC_DIR}"
    RENAME      "${README}"
    OPTIONAL
  )

  install (
    FILES       "${PROJECT_AUTHORS_FILE}"
    DESTINATION "${INSTALL_DOC_DIR}"
    RENAME      "${AUTHORS}"
    OPTIONAL
  )

  install (
    FILES       "${PROJECT_INSTALL_FILE}"
    DESTINATION "${INSTALL_DOC_DIR}"
    RENAME      "${INSTALL}"
    OPTIONAL
  )

  install (
    FILES       "${PROJECT_LICENSE_FILE}"
    DESTINATION "${INSTALL_DOC_DIR}"
    RENAME      "${LICENSE}"
    OPTIONAL
  )

  unset (AUTHORS)
  unset (README)
  unset (INSTALL)
  unset (LICENSE)

  unset (AUTHORS_EXT)
  unset (README_EXT)
  unset (INSTALL_EXT)
  unset (LICENSE_EXT)

  # --------------------------------------------------------------------------
  # (pre-)configure C++ utilities

  basis_configure_auxiliary_sources (
    BASIS_UTILITIES_SOURCES
    BASIS_UTILITIES_HEADERS
    BASIS_UTILITIES_PUBLIC_HEADERS
  )

  set (BASIS_UTILITIES_INCLUDE_DIRS)
  foreach (H ${BASIS_UTILITIES_HEADERS})
    get_filename_component (D "${H}" PATH)
    list (APPEND BASIS_UTILITIES_INCLUDE_DIRS "${D}")
  endforeach ()
  if (BASIS_UTILITIES_INCLUDE_DIRS)
    list (REMOVE_DUPLICATES BASIS_UTILITIES_INCLUDE_DIRS)
  endif ()
  if (BASIS_UTILITIES_INCLUDE_DIRS)
    basis_include_directories (BEFORE ${BASIS_UTILITIES_INCLUDE_DIRS})
  endif ()

  if (BASIS_UTILITIES_HEADERS)
    source_group ("Default" FILES ${BASIS_UTILITIES_HEADERS})
  endif ()
  if (BASIS_UTILITIES_SOURCES)
    source_group ("Default" FILES ${BASIS_UTILITIES_SOURCES})
  endif ()
endmacro ()

# ============================================================================
# finalization
# ============================================================================

##############################################################################
# @brief Finalize build configuration of project.
#
# This macro has to be called at the end of the root CMakeLists.txt file of
# each BASIS project initialized by basis_project().
#
# The project configuration files are generated by including the CMake script
# PROJECT_CONFIG_DIR/GenerateConfig.cmake when this file exists or using
# the default script of BASIS.
#
# @sa basis_project_initialize()
#
# @returns Finalizes addition of custom build targets, i.e., adds the
#          custom targets which actually perform the build of these targets.
#          See basis_add_custom_finalize() function.
#
# @ingroup CMakeAPI

macro (basis_project_finalize)
  # --------------------------------------------------------------------------
  # install public headers

  install (
    DIRECTORY   "${PROJECT_INCLUDE_DIR}/"
    DESTINATION "${INSTALL_INCLUDE_DIR}/${BASIS_INCLUDE_PREFIX}"
    OPTIONAL
    PATTERN     ".svn" EXCLUDE
    PATTERN     ".git" EXCLUDE
  )

  # "parse" public header files to check if C++ BASIS utilities are included
  set (PUBLIC_HEADERS)
  if (PROJECT_INCLUDE_DIR AND NOT BASIS_INSTALL_PUBLIC_HEADERS_OF_CXX_UTILITIES)
    file (GLOB_RECURSE PUBLIC_HEADERS "${PROJECT_INCLUDE_DIR}/*.h")
  endif ()

  set (REGEX)
  foreach (P ${BASIS_UTILITIES_PUBLIC_HEADERS})
    basis_get_relative_path (H "${BINARY_INCLUDE_DIR}" "${P}")
    if (NOT REGEX)
      set (REGEX "#include +[<\"](${H}")
    else ()
      set (REGEX "${REGEX}|${H}")
    endif ()
  endforeach ()

  if (REGEX AND PUBLIC_HEADERS)
    set (REGEX "${REGEX})[>\"]")
    foreach (P ${PUBLIC_HEADERS})
      file (READ "${P}" C)
      if (C MATCHES "${REGEX}")
        set (BASIS_INSTALL_PUBLIC_HEADERS_OF_CXX_UTILITIES TRUE)
        break ()
      endif ()
    endforeach ()
  endif ()

  # install public headers of C++ utilities
  if (BASIS_INSTALL_PUBLIC_HEADERS_OF_CXX_UTILITIES)
    install (
      FILES       ${BASIS_UTILITIES_PUBLIC_HEADERS}
      DESTINATION "${INSTALL_INCLUDE_DIR}/sbia/${PROJECT_NAME_LOWER}"
      COMPONENT   "${BASIS_LIBRARY_COMPONENT}"
    )
  endif ()

  # --------------------------------------------------------------------------
  # utilities

  # write convenience file to setup MATLAB environment
  if (MATLAB_FOUND)
    basis_create_addpaths_mfile ()
  endif ()

  # configure auxiliary modules
  basis_configure_auxiliary_modules ()

  # configure ExecutableTargetInfo modules
  basis_configure_ExecutableTargetInfo ()

  # --------------------------------------------------------------------------
  # custom targets

  # finalize addition of custom targets
  #
  # Attention: Has to be done after the addition of the BASIS utilities.
  #
  # Note: Should be done for each (sub-)project as the finalize functions
  #       might make use of the PROJECT_* variables.
  basis_add_custom_finalize ()

  # --------------------------------------------------------------------------
  # installation

  # install symbolic links
  if (INSTALL_LINKS)
    basis_install_links ()
  endif ()

  # add uninstall target
  if (NOT IS_MODULE)
    basis_add_uninstall ()
  endif ()

  # --------------------------------------------------------------------------
  # packaging

  # generate configuration files
  if (EXISTS "${PROJECT_CONFIG_DIR}/GenerateConfig.cmake")
    include ("${PROJECT_CONFIG_DIR}/GenerateConfig.cmake")
  else ()
    include ("${BASIS_MODULE_PATH}/GenerateConfig.cmake")
  endif ()

  # package software
  if (NOT IS_MODULE)
    include ("${BASIS_MODULE_PATH}/BasisPack.cmake")
  endif ()
endmacro ()
