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
#
#****************************************************************************/

#-----------------------------------------------------------------------------
# Runtime loading of Mesa relies on having OSMesa in a known path.
#
# For development builds we create symlink to libOSMesa along side
# VisIt's libraries.
#
# I (Cyrus) am not sure how this will work on windows - there may be a
# more general solution.
#
# For a 'make install'ed version libOSMesa should be properly installed
# by our install targets.
#
# Modifications:
#    Jeremy Meredith, Wed Jan 20 11:27:30 EST 2010
#    I added a command to put a symlink to python in the lib directory.
#    We need this to set python-related environment variables in
#    internallauncher.  I don't know if this is a good solution, as I
#    don't know the implication for an installed setup -- this is only
#    intended to fix running inside a development build.
#
#    Cyrus Harrison, Wed Feb  3 10:10:22 PST 2010
#    Add symlinks to allow us to locate the vtk python wrapper module.
#
#    Kathleen Bonnell, Wed Mar 17 10:08:17 MST 2010 
#    Use FILE(COPY ...) on windows, as windows doesn't support symlinks.
#    Handled python filters on windows differently, as the VTK directory 
#    structure is different.
#
#    Cyrus Harrison, Wed Jul  7 10:09:07 PDT 2010
#    Remove any existing symlinks before attempting to create new ones.
#
#    Kathleen Biagas, Thu May 10 10:58:39 MST 2012 
#    Change how python is handled on Windows to reflect recent changes.
#
#    Kathleen Biagas, Thu June 14 15:53:12 MST 2012 
#    Add target for pyside on windows.
#
#    Gunther H. Weber, Thu Nov 21 18:26:51 PST 2013
#    Use ${PYSIDE_PYTHONPATH} (set by findpackage PySide) instead of 
#    ${VISIT_PYSIDE_DIR}/lib/site-packages to support system PySide installs
#
#----------------------------------------------------------------------------

if(VISIT_PYTHON_DIR)
  if(NOT WIN32)
    execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f
                            ${CMAKE_CURRENT_BINARY_DIR}/python)
    execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
                            ${VISIT_PYTHON_DIR}
                            ${CMAKE_CURRENT_BINARY_DIR}/python)
  else()

    # because you don't need to choose your configuration up-front
    # on windows, make this a custom target so they are copied to the
    # correct lib/${CFG} directory
    add_custom_target(python_lib ALL
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${VISIT_PYTHON_DIR}/Lib
            ${VISIT_LIBRARY_DIR}/python/Lib
        COMMENT "Copying ${VISIT_PYTHON_DIR}/Lib/ ${VISIT_LIBRARY_DIR}/python/Lib")
    if(VISIT_NO_ALLBUILD)
        add_dependencies(visit_special_builds python_lib)
    endif()
  endif()
endif()

# prepare site-packages
if(VISIT_PYTHON_FILTERS OR (VISIT_PYTHON_SCRIPTING AND ( TARGET PySide2::pyside2
   AND TARGET Shiboken2::shiboken2 AND TARGET Shiboken2::libshiboken) ))

    if(NOT WIN32)
        execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory
                        ${CMAKE_CURRENT_BINARY_DIR}/site-packages
                        RESULT_VARIABLE LIB_SITE_PKGS_MKDIR)
        #
        # make sure lib/site-packages exists before we try to
        # symlink or copy the vtk python wrappers
        #
        if(NOT "${LIB_SITE_PKGS_MKDIR}" STREQUAL "0")
            message(WARNING "Failed to create lib/site-packages/")
        endif()
    endif()
ENDIF()

if(VISIT_PYTHON_FILTERS)
# We need to be able to locate the vtk python wrapper lib at run time.
# Place symlinks to its components in lib/site-packages/
    message(STATUS "Adding VTK python wrappers to lib/site-packages/")
    if(NOT WIN32)
        file(GLOB VTK_PYTHON_MODULE_ITEMS "${VISIT_VTK_DIR}/lib/python${PYTHON_VERSION}/site-packages/*")
        foreach(ITM ${VTK_PYTHON_MODULE_ITEMS})
            get_filename_component(ITM_ABS ${ITM} ABSOLUTE)
            get_filename_component(ITM_BASE ${ITM_ABS} NAME)
            message(STATUS "Symlinking ${ITM_ABS} to ${CMAKE_CURRENT_BINARY_DIR}/site-packages/${ITM_BASE}")
            execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f
                                    ${CMAKE_CURRENT_BINARY_DIR}/site-packages/${ITM_BASE}
                                    RESULT_VARIABLE VTK_MODULE_SYM_RM)
            execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
                                    ${ITM_ABS}
                                    ${CMAKE_CURRENT_BINARY_DIR}/site-packages/${ITM_BASE}
                                    RESULT_VARIABLE VTK_MODULE_SYM_CREATE)
            if(NOT "${VTK_MODULE_SYM_CREATE}" STREQUAL "0")
                message(WARNING "Failed to create VTK Python module symlink in lib/site-packages/ for ${ITM_ABS}")
            endif()
        endforeach()
        unset(VTK_PYTHON_MODULE_ITEMS)
        unset(ITM_ABS)
        unset(ITM_BASE)
        unset(VTK_MODULE_SYM_CREATE)
    else()
        file(GLOB VTK_EGG_FILE "${VTK_PY_WRAPPERS_DIR}/site-packages/*egg*")
        # because you don't need to choose your configuration up-front
        # on windows, make this a custom target so they are copied to the
        # correct lib/${CFG} directory
        add_custom_target(vtk_python_modules ALL
            COMMAND ${CMAKE_COMMAND} -E copy_directory
                    ${VTK_PY_WRAPPERS_DIR}/site-packages/vtk
                    ${VISIT_LIBRARY_DIR}/site-packages/vtk
            COMMENT "Copying ${VTK_PY_WRAPPERS_DIR}/site-packages to ${VISIT_LIBRARY_DIR}/site-packages/vtk"
        )
        if(VISIT_NO_ALLBUILD)
            add_dependencies(visit_special_builds vtk_python_modules)
        endif()
    endif()
endif(VISIT_PYTHON_FILTERS)

if(VISIT_PYTHON_SCRIPTING AND (TARGET PySide2::pyside2 AND TARGET Shiboken2::shiboken2 AND TARGET Shiboken2::libshiboken))
    message(STATUS "Adding PySide to lib/site-packages/")
    # may want to check if shibokenlib_location is found, may need to use IMPORTED_LOCATION_DEBUG
    get_target_property(shibokenlib_location Shiboken2::libshiboken IMPORTED_LOCATION_RELEASE)
    # may want to check if shibokenlib_soname is found, may need to use IMPORTED_SONAME_DEBUG
    get_target_property(shibokenlib_soname   Shiboken2::libshiboken IMPORTED_SONAME_RELEASE)
    execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f
                    ${CMAKE_CURRENT_BINARY_DIR}/site-packages/${shibokenlib_soname}
                    RESULT_VARIABLE SHIBOKEN_LIB_SYM_RM)
    execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
                    ${shibokenlib_location}
                    ${CMAKE_CURRENT_BINARY_DIR}/site-packages/${shibokenlib_soname}
                    RESULT_VARIABLE SHIBOKEN_LIB_SYM_CREATE)
    if(NOT "${SHIBOKEN_LIB_SYM_CREATE}" STREQUAL "0")
        message(WARNING "Failed to create Shiboken lib symlink in lib/site-packages/ for PySide2")
    endif()
    unset(shibokenlib_location)
    unset(shibokenlib_soname)
    unset(SHOBKEN_LIB_SYM_RM)
    unset(SHOBKEN_LIB_SYM_CREATE)
    if(NOT WIN32)
        message(STATUS "Symlinking PySide2 to ${CMAKE_CURRENT_BINARY_DIR}/site-packages")
        execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f
                      ${CMAKE_CURRENT_BINARY_DIR}/site-packages/PySide2
                      RESULT_VARIABLE PYSIDE_MODULE_SYM_RM)
        execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
                      ${PYSIDE_PYTHONPATH} 
                      ${CMAKE_CURRENT_BINARY_DIR}/site-packages/PySide2
                      RESULT_VARIABLE PYSIDE_MODULE_SYM_CREATE)
        if(NOT "${PYSIDE_MODULE_SYM_CREATE}" STREQUAL "0")
            message(WARNING "Failed to create PySide module symlink in lib/site-packages/ for PySide2")
        endif()
        unset(PYSIDE_MODULE_SYM_RM)
        unset(PYSIDE_MODULE_SYMCREATE)
        message(STATUS "Symlinking shiboken2 to ${CMAKE_CURRENT_BINARY_DIR}/site-packages")
        execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f
                      ${CMAKE_CURRENT_BINARY_DIR}/site-packages/shiboken2
                      RESULT_VARIABLE SHIBOKEN_MODULE_SYM_RM)
        execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
                      ${SHIBOKEN_PYTHON_MODULE_DIR} 
                      ${CMAKE_CURRENT_BINARY_DIR}/site-packages/shiboken2
                      RESULT_VARIABLE SHIBOKEN_MODULE_SYM_CREATE)
        if(NOT "${SHIBOKEN_MODULE_SYM_CREATE}" STREQUAL "0")
            message(WARNING "Failed to create shiboken module symlink in lib/site-packages/ for PySide2")
        endif()
        unset(SHIBOKEN_MODULE_SYM_RM)
        unset(SHIBOKEN_MODULE_SYMCREATE)
    else()
        add_custom_target(pyside_modules ALL
            COMMAND ${CMAKE_COMMAND} -E copy_directory
                    ${PYSIDE_PYTHONPATH}/PySide2
                    ${VISIT_LIBRARY_DIR}/site-packages/PySide2
            COMMENT "Copying ${PYSIDE_PYTHONPATH}/PySide2 to ${VISIT_LIBRARY_DIR}/site-packages/PySide2"
        )
        if(VISIT_NO_ALLBUILD)
            add_dependencies(visit_special_builds pyside_modules)
        endif()
    endif()
endif()

