# data
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/svg/miniature.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/power-installer)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/svg/debian.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/power-installer)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/svg/script.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/power-installer)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/svg/python.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/power-installer)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/svg/archive.svg DESTINATION ${CMAKE_INSTALL_PREFIX}/share/power-installer)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/FIRSTRUN.txt DESTINATION ${CMAKE_INSTALL_PREFIX}/share/power-installer)

# icons
set(SYSTEM_DEFAULT_THEME ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/hicolor/16x16/apps/power-installer.svg DESTINATION ${SYSTEM_DEFAULT_THEME}/16x16/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/hicolor/24x24/apps/power-installer.svg DESTINATION ${SYSTEM_DEFAULT_THEME}/24x24/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/hicolor/32x32/apps/power-installer.svg DESTINATION ${SYSTEM_DEFAULT_THEME}/32x32/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/hicolor/48x48/apps/power-installer.svg DESTINATION ${SYSTEM_DEFAULT_THEME}/48x48/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/hicolor/64x64/apps/power-installer.svg DESTINATION ${SYSTEM_DEFAULT_THEME}/64x64/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/hicolor/128x128/apps/power-installer.svg DESTINATION ${SYSTEM_DEFAULT_THEME}/128x128/apps)

# pkexec configuration
configure_file(power-installer-pkexec.cmake ${CMAKE_CURRENT_BINARY_DIR}/power-installer-pkexec)
configure_file(power-installer.desktop.cmake ${CMAKE_CURRENT_BINARY_DIR}/power-installer.desktop)
configure_file(net.launchpad.power-installer.policy.cmake ${CMAKE_CURRENT_BINARY_DIR}/net.launchpad.power-installer.policy)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/power-installer.desktop DESTINATION ${CMAKE_INSTALL_PREFIX}/share/applications)
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/power-installer-pkexec DESTINATION bin)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/net.launchpad.power-installer.policy DESTINATION share/polkit-1/actions/)

# schema
include(GSettings)
add_schema("schemas/org.pantheon.power-installer.gschema.xml")
