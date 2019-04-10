#*****************************************************************************
#
# Copyright (c) 2000 - 2019, Lawrence Livermore National Security, LLC
# Produced at the Lawrence Livermore National Laboratory
# LLNL-CODE-442911
# All rights reserved.
#
# This file is  part of VisIt. For  details, see https://visit.llnl.gov/.  The
# full copyright notice is contained in the file COPYRIGHT located at the root
# of the VisIt distribution or at http://www.llnl.gov/visit/copyright.html.
#
# Redistribution  and  use  in  source  and  binary  forms,  with  or  without
# modification, are permitted provided that the following conditions are met:
#
#  - Redistributions of  source code must  retain the above  copyright notice,
#    this list of conditions and the disclaimer below.
#  - Redistributions in binary form must reproduce the above copyright notice,
#    this  list of  conditions  and  the  disclaimer (as noted below)  in  the
#    documentation and/or other materials provided with the distribution.
#  - Neither the name of  the LLNS/LLNL nor the names of  its contributors may
#    be used to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT  HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR  IMPLIED WARRANTIES, INCLUDING,  BUT NOT  LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND  FITNESS FOR A PARTICULAR  PURPOSE
# ARE  DISCLAIMED. IN  NO EVENT  SHALL LAWRENCE  LIVERMORE NATIONAL  SECURITY,
# LLC, THE  U.S.  DEPARTMENT OF  ENERGY  OR  CONTRIBUTORS BE  LIABLE  FOR  ANY
# DIRECT,  INDIRECT,   INCIDENTAL,   SPECIAL,   EXEMPLARY,  OR   CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT  LIMITED TO, PROCUREMENT OF  SUBSTITUTE GOODS OR
# SERVICES; LOSS OF  USE, DATA, OR PROFITS; OR  BUSINESS INTERRUPTION) HOWEVER
# CAUSED  AND  ON  ANY  THEORY  OF  LIABILITY,  WHETHER  IN  CONTRACT,  STRICT
# LIABILITY, OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE)  ARISING IN ANY  WAY
# OUT OF THE  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.
#
# Modifications:
#   Kathleen Biagas, Thu June 14 15:48:01 MST 2012
#   Add support for pyside 1.1.1 on windows, which no longer has a separate 
#   generatorrunner module.  For PYSIDE_ADD_MODULE function, change the 
#   target's output location on windows to the exe dir, explanation for this
#   is within the code below.  Change gen_pathsep on windows to "\;".
#
#   Gunther H. Weber, Thu Nov 21 18:28:56 PST 2013
#   Allow user to set Shiboken_FOUND and PySide_FOUND to set up relevant
#   CMake variables manually (necessary for MacPorts PySide install).
#   Use ${PYSIDE_PYTHONPATH} instead of ${VISIT_PYSIDE_DIR}/lib/site-packages
#   to support using system PySide.
#
#   Kathleen Biagas, Wed Dec 18 08:05:38 PST 2013
#   Exclude '.svn' from INSTALL command, probably a rare case, but a
#   developer did run into an issue.
#
#   Kathleen Biagas, Tue Jan 24 11:13:05 PST 2017
#   Add support for Qt5, PySide2.
#
#   Kevin Griffin, Wed Jan 10 10:46:43 PST 2018
#   Changes are for OSX and PySide2: Added the capability to optionally append 
#   a 'v' to the Python version when creating the library names. Also 
#   expanded the list of libraries for pyside and shiboken to include the 
#   different naming schemes for the same library.
#
#****************************************************************************/

include(${VISIT_SOURCE_DIR}/CMake/SetUpThirdParty.cmake)






if(VISIT_PYSIDE_DIR)
    #option(PYSIDE_LIBNAMES_AFFIX_V "Whether PySide and Shiboken base names end with v" OFF)


    # find_package will fail if cmake build type isn't set to what was used to
    # build PySide2, assuming Release here
    set(cmake_btype ${CMAKE_BUILD_TYPE})
    set(CMAKE_BUILD_TYPE "Release")

    if(NOT TARGET Shiboken2::shiboken2 AND NOT TARGET Shiboken2::libshiboken)
        find_package(Shiboken2 ${PYSIDE_VERSION}
                     PATHS ${VISIT_PYSIDE_DIR}/lib/cmake/Shiboken2-${PYSIDE_VERSION}
                     NO_DEFAULT_PATH
                     )
        if(NOT TARGET Shiboken2::shiboken2)
            message(WARNING "PySide2 requested, but could not find shiboken executable")
            return()
        endif()
        if(NOT TARGET Shiboken2::libshiboken)
            message(WARNING "PySide2 requested, but could not find shiboken library")
            return()
        endif()

        get_target_property(SHIBOKEN_EXECUTABLE Shiboken2::shiboken2 IMPORTED_LOCATION_RELEASE)
        get_target_property(SHIBOKEN_INCLUDE_DIRS Shiboken2::libshiboken INTERFACE_INCLUDE_DIRECTORIES)
    endif()

    if (NOT TARGET PySide2::pyside2)
        find_package(PySide2 ${PYSIDE_VERSION}
                    PATHS ${VISIT_PYSIDE_DIR}/lib/cmake/PySide2-${PYSIDE_VERSION}
                    NO_DEFAULT_PATH)
        if(NOT TARGET PySide2::pyside2)
            message(WARNING "PySide2 requested, but could not find pyside library")
            return()
        endif()
        get_target_property(PYSIDE_INCLUDE_DIR PySide2::pyside2 INTERFACE_INCLUDE_DIRECTORIES)
    endif()

    set(pyside_qt_includes 
        ${Qt5Core_INCLUDE_DIRS}
        ${Qt5Gui_INCLUDE_DIRS}
        ${Qt5Widgets_INCLUDE_DIRS}
        ${Qt5OpenGL_INCLUDE_DIRS}
        ${PYSIDE_INCLUDE_DIR}/QtCore
        ${PYSIDE_INCLUDE_DIR}/QtGui
        ${PYSIDE_INCLUDE_DIR}/QtOpenGL
        ${PYSIDE_INCLUDE_DIR}/QtWidgets
    )

    set(CMAKE_BUILD_TYPE ${cmake_btype})
    unset(cmake_btype)
endif()

if(TARGET PySide2::pyside2 AND TARGET Shiboken2::libshiboken AND TARGET Shiboken2::shiboken2)
    #IF(NOT APPLE)
    #    SET_UP_THIRD_PARTY(PYSIDE lib include 
    #            pyside2-python${PYTHON_VERSION} shiboken2-python${PYTHON_VERSION})
    #ELSE(NOT APPLE)
    #    IF(PYSIDE_LIBNAMES_AFFIX_V)
    #            SET(PYTHON_VERSION_V ${PYTHON_VERSION}v)
    #    ELSE(PYSIDE_LIBNAMES_AFFIX_V)
    #            SET(PYTHON_VERSION_V ${PYTHON_VERSION})
    #    ENDIF(PYSIDE_LIBNAMES_AFFIX_V)
#
#        SET(PySide2_LIBRARIES
#                pyside2-python${PYTHON_VERSION_V}
#                pyside2-python${PYTHON_VERSION_V}.${PYSIDE_VERSION}
#                pyside2-python${PYTHON_VERSION_V}.${PYSIDE_SHORT_VERSION})
#
#        SET(Shiboken2_LIBRARIES
#                shiboken2-python${PYTHON_VERSION_V}
#                shiboken2-python${PYTHON_VERSION_V}.${PYSIDE_VERSION}
#                shiboken2-python${PYTHON_VERSION_V}.${PYSIDE_SHORT_VERSION})
#        SET_UP_THIRD_PARTY(PYSIDE lib include ${PySide2_LIBRARIES} ${Shiboken2_LIBRARIES})
#    ENDIF(NOT APPLE)
    # The PySide module is symlinked into the python install VisIt uses for 
    # dev builds.  For 'make install' and 'make package' we need to actually 
    # install the PySide SOs.
    set(PYSIDE_MODULE_SRC  ${PYSIDE_PYTHONPATH}/PySide2)
    set(PYSIDE_MODULE_INSTALLED_DIR ${VISIT_INSTALLED_VERSION_LIB}/site-packages/PySide2)

    file(GLOB pysidelibs ${PYSIDE_MODULE_SRC}/*)
    install(FILES ${pysidelibs}
            DESTINATION ${PYSIDE_MODULE_INSTALLED_DIR}
            PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE 
                        GROUP_READ GROUP_WRITE GROUP_EXECUTE 
                        WORLD_READ WORLD_EXECUTE
            CONFIGURATIONS "" None Debug Release RelWithDebInfo MinSizeRel
            PATTERN ".svn" EXCLUDE
            )

    unset(PYSIDE_MODULE_SRC)
    unset(PYSIDE_MODULE_INSTALLED_DIR)
    unset(pysidelibs)
endif(PySide_FOUND)


#****************************************************************************
# PYSIDE_ADD_GENERATOR_TARGET
# Defines a new PySide generator target.
#****************************************************************************
function(PYSIDE_ADD_GENERATOR_TARGET 
            target_name gen_sources gen_include_paths gen_global gen_typesystem)

    set(PYSIDE_GENERATOR_EXTRA_FLAGS 
                                     --generator-set=shiboken 
                                     --enable-parent-ctor-heuristic 
                                     --enable-return-value-heuristic 
                                     --avoid-protected-hack)

    #
    # Create string for --include-paths arg from gen_include_paths list.
    #

    if(WIN32)
        set(gen_pathsep "\;")
    else(WIN32)
        set(gen_pathsep ":")
    endif(WIN32)

    set(gen_include_paths_arg "${CMAKE_CURRENT_SOURCE_DIR}")

    foreach(itm ${PYSIDE_INCLUDE_DIR})
        set(gen_include_paths_arg "${gen_include_paths_arg}${gen_pathsep}${itm}")
    endforeach()

    foreach(itm ${${gen_include_paths}})
        set(gen_include_paths_arg "${gen_include_paths_arg}${gen_pathsep}${itm}")
    endforeach(itm ${gen_include_paths})

    #
    # On macOS, Qt install uses frameworks, we have to use
    # --framework-include-paths=
    # or else shiboken  + clang can't find the headers
    #

    set(gen_framework_include_paths "")
    if(APPLE)
        set(gen_framework_include_paths "--framework-include-paths=${QT_LIBRARY_DIR}")
    endif()

    add_custom_command(OUTPUT ${${gen_sources}}
        COMMAND ${CMAKE_COMMAND} -E env CLANG_INSTALL_DIR=${VISIT_LLVM_DIR}
        ${SHIBOKEN_EXECUTABLE} ${PYSIDE_GENERATOR_EXTRA_FLAGS}
        ${gen_global}
        ${gen_framework_include_paths}
        --include-paths=${gen_include_paths_arg}
        --typesystem-paths=${PYSIDE_TYPESYSTEMS}
        --output-directory=${CMAKE_CURRENT_BINARY_DIR}
        ${gen_typesystem}
        DEPENDS  ${gen_global} ${gen_typesystem}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Running generator for ${${gen_sources}}...")

    add_custom_target(${target_name} DEPENDS ${${gen_sources}})

    #cleanup
    unset(PYSIDE_GENERATOR_EXTRA_FLAGS)
    unset(gen_pathsep)
    unset(gen_include_paths_arg)

endfunction(PYSIDE_ADD_GENERATOR_TARGET)





#****************************************************************************
# PYSIDE_ADD_MODULE
# Defines a new PySide module and creates a dependent generator target and
# distutils setup call.
#****************************************************************************
function(PYSIDE_ADD_MODULE module_name
                           dest_dir
                           mod_sources
                           mod_gen_sources
                           mod_gen_include_paths
                           mod_gen_link_libs
                           mod_gen_global
                           mod_gen_typesystem)

    message(STATUS "Configuring PySide module: ${module_name}")


    PYSIDE_ADD_GENERATOR_TARGET("${module_name}_gen"
                                ${mod_gen_sources}
                                ${mod_gen_include_paths}
                                ${mod_gen_global}
                                ${mod_gen_typesystem})

    include_directories(${CMAKE_CURRENT_SOURCE_DIR}
                        ${SHIBOKEN_INCLUDE_DIRS}
                        ${PYSIDE_INCLUDE_DIR}
                        ${CMAKE_CURRENT_BINARY_DIR}/${module_name}
                        ${${mod_gen_include_paths}})

    add_library(${module_name} MODULE ${${mod_sources}} ${${mod_gen_sources}})

    set_target_properties(${module_name} PROPERTIES PREFIX "")

    if(UNIX)
        set_target_properties(${module_name} PROPERTIES
            LIBRARY_OUTPUT_DIRECTORY ${VISIT_LIBRARY_DIR}/${dest_dir})
    else()
        # set the appropriate suffix 
        set_target_properties(${module_name} PROPERTIES SUFFIX ".pyd")

        # Since cmake will append $(Configuration) to output directories, we need
        # to override that by specifying LIBRARY_OUTPUT_DIRECTORY_${Configuration}
        # for each configuration.
        foreach(cfg ${CMAKE_CONFIGURATION_TYPES})
            string(TOUPPER ${cfg} UCFG)
            set_target_properties(${module_name} PROPERTIES
                LIBRARY_OUTPUT_DIRECTORY_${UCFG} ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${cfg}/${dest_dir})
        endforeach()
    endif()

    target_link_libraries(${module_name}
                          Shiboken2::libshiboken
                          PySide2::pyside2
                          ${${mod_gen_link_libs}})

    add_dependencies(${module_name} "${module_name}_gen")

    VISIT_INSTALL_TARGETS_RELATIVE(${dest_dir} ${module_name})

endfunction(PYSIDE_ADD_MODULE)

#****************************************************************************
# PYSIDE_ADD_HYBRID_MODULE
# Defines a new PySide module and creates a dependent generator target and
# distutils setup call.
#****************************************************************************
function(PYSIDE_ADD_HYBRID_MODULE module_name
                                  dest_dir
                                  mod_py_setup
                                  mod_py_sources
                                  mod_sources
                                  mod_gen_sources
                                  mod_gen_include_paths
                                  mod_gen_link_libs
                                  mod_gen_global
                                  mod_gen_typesystem)

    message(STATUS "Configuring PySide module: ${module_name}")

    PYTHON_ADD_DISTUTILS_SETUP("${module_name}_py_setup"
                                ${dest_dir}
                                ${mod_py_setup}
                                ${mod_py_sources})

    PYSIDE_ADD_MODULE(${module_name}
                      ${dest_dir}/${module_name}
                      ${mod_sources}
                      ${mod_gen_sources}
                      ${mod_gen_include_paths}
                      ${mod_gen_link_libs}
                      ${mod_gen_global}
                      ${mod_gen_typesystem})

    add_dependencies(${module_name} "${module_name}_py_setup")
    add_dependencies(${module_name} "${module_name}_gen")

endfunction(PYSIDE_ADD_HYBRID_MODULE)


