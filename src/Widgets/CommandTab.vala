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

/* Commands tab */

using Gtk;
using Gdk;
using GLib;

namespace PowerInstaller.Widgets {

    public class CommandTab : Gtk.EventBox {
        private Gtk.TextView view;
        private Gtk.Entry ppa_entry;
        private Gtk.Entry pkg_entry;
        private Gtk.EntryCompletion pkg_completion;

        private Gtk.CheckButton link_button;

        private string rectext;

        private string? user_input;
        private string? ppa;
        private string? pkg;

        private bool link;
        private static bool entry_changed = false;

        public CommandTab() {
            // Main boxes
            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
            var ppa_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 15);
            var pkg_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 15);

            // PPA entry
            ppa_entry = new Gtk.Entry();
            ppa_entry.set_text("");                  
            ppa_entry.set_placeholder_text(_("Repositories names"));      
            var ppa_label = new Gtk.Label.with_mnemonic(_("Repos to add:"));
            ppa_label.mnemonic_widget = ppa_entry;
            ppa_box.add(ppa_label);
            ppa_box.add(ppa_entry);

            // PKG entry
            pkg_entry = new Gtk.Entry();        
            pkg_entry.set_text("");
            pkg_entry.set_placeholder_text(_("Package names"));
            
            var pkg_label = new Gtk.Label.with_mnemonic(_("Packages to install:"));
            pkg_label.mnemonic_widget = pkg_entry;

            pkg_completion = new Gtk.EntryCompletion();
            pkg_entry.set_completion(pkg_completion);

            var list_store = new Gtk.ListStore (1, typeof(string));
		    pkg_completion.set_model(list_store);
		    pkg_completion.set_text_column(0);

            pkg_box.add(pkg_label);
            pkg_box.add(pkg_entry);

            // Checkbutton
            link_button = new Gtk.CheckButton.with_label(_("Is link to debian, bash or python script file"));
            link_button.toggled.connect(() => { link = set_link_status(); });

            // Textview
            view = new Gtk.TextView();
            view.set_editable(true);
            view.set_wrap_mode(Gtk.WrapMode.WORD);
            view.buffer.text = read_clipboard() ?? "";

            // Go button
            var go_button = new Gtk.Button.with_label(_("Go!"));

            // Using DESTRUCTIVE_ACTION: more consistent interface
#if HAVE_GTK312            
            go_button.get_style_context().add_class("suggested-action");
#endif

            go_button.clicked.connect(() => {
                if(user_input + ppa + pkg != "")
                    on_go_clicked(view.buffer.text, ppa_entry.get_text(), pkg_entry.get_text(), link, settings.get_boolean("remove-dollars"));
            });

            // add scroll to Gtk.TextView
            var scrolled = new Gtk.ScrolledWindow(null, null);
            scrolled.add(view);
            
		    box.pack_start(scrolled, true, true, 0);
            box.add(link_button);
            box.add(ppa_box);
            box.add(pkg_box);
            box.pack_end(go_button, false, false, 0);
            this.add(box);

            /*
             * Create package list after user
             * type something and do it only one time
             */
            pkg_entry.changed.connect(() => {
                Gtk.TreeIter iter;

                if(!entry_changed) {
                    string[] pkg_list = controller.get_package_list();
                    foreach(string package in pkg_list) {
	                    list_store.append(out iter);
		                list_store.set(iter, 0, package);
                    }

                    // Block another creation
                    entry_changed = true;
                }
            });
        }

        // If link is checked
        private bool set_link_status() {
            if(link_button.get_active()) {
                return true;
            } else {
                return false;
            }
        }

        private string read_clipboard() {
            if(settings.get_boolean("auto-paste")) {
                Gdk.Display display = this.get_display();
                var clipboard = Gtk.Clipboard.get_for_display(display, Gdk.SELECTION_CLIPBOARD);
                rectext = clipboard.wait_for_text();
                if(rectext == null)
                    return ""; 

                if(!rectext.contains("\n")) {
                    try {
                        var regex = new Regex("(http|https|www|com|org)");
                        if(regex.match(rectext)) {
                            if(!rectext.contains(" "))
                                link_button.active = true;
                        } else {
                            if(rectext.has_prefix("ppa:")) {
                                ppa_entry.text = rectext;
                                return "";
                            }
                        }
                    } catch (RegexError e) {
                        warning(e.message);
                    }
                }
            } else {
                return "";
            }
 
            return rectext;
        }

        // go has been clicked
        public void on_go_clicked(string user_input, string ppa, string pkg, bool link, bool remove_dollars) {
            window.header_set_working(true);
            if(ppa != "")
                controller.add_repositories(ppa.split(" "));            
            
            if(pkg != "")
                controller.install_packages(pkg.split(" "));            
                    
            if(user_input != "") {
                handler.body_success = _("All commands have been executed successfully!");
                handler.body_error = _("Something went wrong. Check out: /tmp/pi-log.txt for more information.");
                handler.execute_script(user_input, link, remove_dollars);
            }
              
            window.header_set_working(false);                 
        }
    }
}
