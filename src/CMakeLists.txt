find_package(PkgConfig)

add_definitions(-DGETTEXT_PACKAGE="${CMAKE_PROJECT_NAME}")

add_definitions(${DEPS_CFLAGS})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.22.0" MINIMUM)

include(ValaPrecompile)

configure_file(${CMAKE_SOURCE_DIR}/src/config.vala.cmake ${CMAKE_SOURCE_DIR}/src/config.vala)

# add all your vala files and requires packages to the list below to include them in the build
vala_precompile(VALA_C ${CMAKE_PROJECT_NAME}
    Notification.vala
    Backend/ExecuteHandler.vala
    Backend/FileHandler.vala
    Backend/APTController.vala
    Widgets/DragDropTab.vala
    Widgets/CommandTab.vala
    Widgets/ActionsTab.vala
    Widgets/Tutorial.vala
    Widgets/TutorialPage.vala    
    Widgets/IconGrid.vala
    Widgets/PreferencesDialog.vala
    MainWindow.vala
    main.vala
    config.vala
PACKAGES
    gtk+-3.0
    ${GRANITE_DEPS}
    libarchive
    posix
OPTIONS
    --thread
    ${GRANITE_OPTIONS}
    ${GTK312_OPTIONS}
)

# install notification script
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/notification.sh DESTINATION ${CMAKE_INSTALL_PREFIX}/share/power-installer)

# executable
add_executable(power-installer ${VALA_C})

# installation
install(TARGETS power-installer RUNTIME DESTINATION bin)
