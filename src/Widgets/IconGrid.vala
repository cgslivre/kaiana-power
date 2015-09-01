/* Copyright 2014 Adam Bieńkowski (donadigo)
*
* This file is part of Power Installer.
*
* Power Installer is free software: you can redistribute it
* and/or modify it under the terms of version 3 of the
* GNU General Public License as published by the Free Software Foundation.
*
* Power Installer is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Power Installer. If not, see http://www.gnu.org/licenses/.
*/

namespace PowerInstaller.Widgets {

    public class IconGrid : Gtk.Grid {
    
        public IconGrid() {
            this.row_spacing = 30;
            this.column_spacing = 125;
            this.column_homogeneous = true;
              
            var deb_icon = new Gtk.Image.from_file(Constants.PKGDATADIR + "/debian.svg");
            deb_icon.pixel_size = 85;
            
            var shell_icon = new Gtk.Image.from_file(Constants.PKGDATADIR + "/script.svg");
            shell_icon.pixel_size = 85;
            
            var python_icon = new Gtk.Image.from_file(Constants.PKGDATADIR + "/python.svg");
            python_icon.pixel_size = 85;
            
            var archive_icon = new Gtk.Image.from_file(Constants.PKGDATADIR + "/archive.svg");
            archive_icon.pixel_size = 85;  
            
            this.attach(deb_icon, 0, 0, 1, 1);
            this.attach(python_icon, 0, 2, 1, 1);
            this.attach_next_to(archive_icon, python_icon, Gtk.PositionType.RIGHT, 1, 1);
            this.attach_next_to(shell_icon, deb_icon, Gtk.PositionType.RIGHT, 1, 1);            
            this.show_all();                      
        }
    }
}
