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

    public class DragDropTab : Gtk.EventBox {
        private const Gtk.TargetEntry[] targets = {{ "text/uri-list", 0, 0 }};

        private Gtk.CheckButton icon_button;
        private Gtk.CheckButton theme_button;
        private Gtk.CheckButton plank_button;

        private string file;

        private bool gtk_theme;
        private bool icon_theme;
        private bool plank_theme;

        public DragDropTab() {
            this.create_layout();
            Gtk.drag_dest_set(this, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY);
            this.drag_data_received.connect(on_drag_data_received);
        }

        private void create_layout() {
            // Main grid
            var grid = new Gtk.Grid();
            grid.row_spacing = 8;

            // Checkbuttons
            theme_button = new Gtk.CheckButton.with_label(_("Is GTK theme (archived)"));
            theme_button.toggled.connect(() => { gtk_theme = get_gtk_theme_status(); });

            icon_button = new Gtk.CheckButton.with_label(_("Is icon theme (archived)"));
            icon_button.toggled.connect(()  => { icon_theme = get_icon_theme_status(); });

            plank_button = new Gtk.CheckButton.with_label(_("Is plank theme (elementary OS; archived)"));
            plank_button.toggled.connect(() => { plank_theme = get_plank_theme_status(); });

            // Icon grid
            var icon_grid = new IconGrid();

            // Add everything to grid
            grid.attach(icon_button, 0, 2, 1, 1);
            grid.attach(theme_button, 0, 1, 1, 1);
            grid.attach(plank_button, 0, 3, 2, 2);
            grid.attach(icon_grid, 0, 5, 3, 3);
            this.add(grid);
        }

        // If theme is checked
        private bool get_gtk_theme_status() {
            if(theme_button.get_active()) {
                plank_button.set_active(false);
                icon_button.set_active(false);
                return true;
            } else {
                return false;
            }
        }

        // If icon is checked
        private bool get_icon_theme_status() {
            if(icon_button.get_active()) {
                plank_button.set_active(false);
                theme_button.set_active(false);
                return true;
            }
            
            return false;
        }

        private bool get_plank_theme_status() {
            if(plank_button.get_active()) {
                theme_button.set_active(false);
                icon_button.set_active(false);
                return true;
            }
                
            return false;
        }

        // File has been recieved
        private void on_drag_data_received(Gdk.DragContext drag_context, int x, int y,
                                            Gtk.SelectionData data, uint info, uint time) {
            foreach(string uri in data.get_uris()) {
                file = uri.replace("file://", "").replace("file:/", "");
                file = Uri.unescape_string(file);

                Gtk.drag_finish(drag_context, true, false, time);
                file_handler.execute_drag(file, gtk_theme, icon_theme, plank_theme);
            }
        }
    }
}
