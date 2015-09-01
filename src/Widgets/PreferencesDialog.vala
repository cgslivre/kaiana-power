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

/* Preferences dialog */

using Gtk;
using GLib;

namespace PowerInstaller.Widgets {

    public class PreferencesDialog : Gtk.Dialog {
        private Gtk.CheckButton rm_dollar_btn;
        private Gtk.CheckButton keep_above_btn;
        private Gtk.CheckButton auto_paste_btn;

        public PreferencesDialog() {
            this.title = (_("Preferences"));
            this.set_border_width(6);
            this.set_default_size(300, 100);
            this.response.connect(on_response);

            /* Begin rm_dollar_btn */
            rm_dollar_btn = new Gtk.CheckButton.with_label(_("Remove dollar signs from command section"));
            rm_dollar_btn.set_tooltip_text("Remove dollars signs from the beggining of each line, e.g: \"$ apt-get update\"");
            rm_dollar_btn.set_active(settings.get_boolean("remove-dollars"));
            rm_dollar_btn.toggled.connect(() => { set_btn_stat(rm_dollar_btn, "remove-dollars"); });
            /* End rm_dollar_btn */

            /* Begin keep_above_btn */
            keep_above_btn = new Gtk.CheckButton.with_label(_("Window always on top"));
            keep_above_btn.set_active(settings.get_boolean("keep-above"));
            keep_above_btn.toggled.connect(() => { set_btn_stat(keep_above_btn, "keep-above"); });
            /* End keep_above_btn */

            /* Begin auto_paste_btn */
            auto_paste_btn = new Gtk.CheckButton.with_label(_("Automaticly paste contents from clipboard"));
            auto_paste_btn.set_active(settings.get_boolean("auto-paste"));
            auto_paste_btn.toggled.connect(() => { set_btn_stat(auto_paste_btn, "auto-paste"); });
            /* End auto_paste_btn */

            var content = this.get_content_area() as Gtk.Box;
            content.set_spacing(6);
            content.add(rm_dollar_btn);
            content.add(keep_above_btn);
            content.add(auto_paste_btn);

            this.add_button("_Close", Gtk.ResponseType.CLOSE);

            this.show_all();
        }

        private void on_response() {
            this.destroy();
            prefs_btn.set_sensitive(true);
        }

        private void set_btn_stat(Gtk.CheckButton btn, string key) {
            if(btn.active) {
                settings.set_boolean(key, true);
            } else {
                settings.set_boolean(key, false);
            }
        }
    }
}
