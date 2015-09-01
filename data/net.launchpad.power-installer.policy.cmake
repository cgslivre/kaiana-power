<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1.0/policyconfig.dtd">
<policyconfig>
  <vendor>elementary</vendor>
  <vendor_url>http://launchpad.net/power-installer</vendor_url>
  <icon_name>power-installer</icon_name>
  <action id="org.freedesktop.policykit.pkexec.power-installer">
   <description>Run Power Installer as Administrator</description>
   <message>Authentication is required to run Power Installer as Administrator</message>
   <defaults>
     <allow_any>auth_admin</allow_any>
     <allow_inactive>auth_admin</allow_inactive>
     <allow_active>auth_admin</allow_active>
   </defaults>
     <annotate key="org.freedesktop.policykit.exec.path">@CMAKE_INSTALL_PREFIX@/bin/power-installer</annotate>
     <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
   </action>
</policyconfig>
