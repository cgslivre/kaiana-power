project(power-installer)

cmake_minimum_required(VERSION 2.8)
cmake_policy(VERSION 2.8)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set(DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set(PKGDATADIR "${DATADIR}/power-installer")
set(RELEASE_NAME "Power Installer")
set(GETTEXT_PACKAGE "power-installer")
set(VERSION "0.4")
set(VERSION_INFO "Release")
set(PREFIX "${CMAKE_INSTALL_PREFIX}")
set(DOLLAR "$")

FILE(GLOB_RECURSE sources src/*.vala)

configure_file(${CMAKE_SOURCE_DIR}/src/config.vala.cmake ${CMAKE_SOURCE_DIR}/src/config.vala)

find_package(PkgConfig)

pkg_check_modules(GTK312 QUIET gtk+-3.0>=3.12)
if(GTK312_FOUND)
    message("-- GTK >= 3.12 integration enabled")
    set(GTK312_OPTIONS --define=HAVE_GTK312)
endif()    

pkg_check_modules(GRANITE QUIET granite)
if(GRANITE_FOUND)
    message("-- Granite integration enabled")
    set(GRANITE_DEPS granite)
    set(GRANITE_OPTIONS --define=HAVE_GRANITE)
    set(DESKTOP_ABOUT_DIALOG "[Desktop Action AboutDialog]
Name=About Power Installer
Exec=power-installer --about")
endif()    

pkg_check_modules(DEPS REQUIRED "${GRANITE_DEPS}" gthread-2.0 gtk+-3.0 libarchive)

add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)

add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

add_subdirectory(po)
add_subdirectory(src)
add_subdirectory(data)
