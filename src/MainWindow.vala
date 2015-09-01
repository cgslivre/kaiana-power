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

using PowerInstaller.Utils;

namespace PowerInstaller {

    private Gtk.Button prefs_btn;

    public class MainWindow : Gtk.Window {
        public static const string DRAGDROP_ID = "dragdrop";
        public static const string COMMANDS_ID = "commands";
        public static const string ACTIONS_ID = "actions";

        private Gtk.HeaderBar header_bar;
        private Gtk.Image light_img;
        private Gtk.Stack main_stack;
        private Gtk.StackSwitcher stack_switcher;

        private bool quiet;

        public MainWindow.for_quiet () {
            quiet = true;
        }

        public MainWindow() {
            quiet = false;

            this.title = PROGRAM_NAME;
            this.window_position = Gtk.WindowPosition.CENTER;
            this.set_resizable(false);
            this.set_keep_above(settings.get_boolean("keep-above"));
            this.set_default_size(380, 400);

            // Main box
            var main_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            var main_grid = new Gtk.Grid();
            main_grid.margin = 6;

            // Header bar
            header_bar = new Gtk.HeaderBar();
            header_bar.set_title(PROGRAM_NAME);
            header_bar.set_show_close_button(true);
            this.set_titlebar(header_bar);

            // Preferences button
            prefs_btn = new Gtk.Button.from_icon_name("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
            prefs_btn.clicked.connect(run_prefs_dialog);

            // Miniature
            light_img = new Gtk.Image();
            light_img.set_from_file(Constants.PKGDATADIR + "/miniature.svg");
            
            header_bar.pack_end(light_img);
            header_bar.pack_end(prefs_btn);
    
            // Destroy the miniature
            light_img.destroy();

            // Stack
            main_stack = new Gtk.Stack();
            main_stack.set_hexpand(true);
            main_stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT);

            // Stack switcher
            stack_switcher = new Gtk.StackSwitcher();
            stack_switcher.stack = main_stack;
            stack_switcher.halign = Gtk.Align.CENTER;
            stack_switcher.margin_top = 2;

            // Add tabs to dialog
            var dragdrop_tab = new Widgets.DragDropTab();
            dragdrop_tab.expand = true;

            var command_tab = new Widgets.CommandTab();
            command_tab.expand = true;

            var actions_tab = new Widgets.ActionsTab();
            actions_tab.expand = true;

            // Infobar
            var info_bar = new Gtk.InfoBar();
            info_bar.set_message_type(Gtk.MessageType.QUESTION);

            main_stack.add_titled(dragdrop_tab, DRAGDROP_ID, (_("Drag and drop")));
            main_stack.add_titled(command_tab, COMMANDS_ID, (_("Commands")));
            main_stack.add_titled(actions_tab, ACTIONS_ID, (_("Actions")));
            main_stack.visible_child = actions_tab;

            // Tutorial
            var tutorial = new Widgets.Tutorial();
            tutorial.close.connect(() => {
                info_bar.hide();
                Timeout.add (200, (() => {
                    info_bar.destroy ();   
                    return true;             
                }));

                this.switch_tab("dragdrop");
            });
            
            // The content of the tutorial
            var content = info_bar.get_content_area();
            content.add(tutorial);

            // Add stack and stack switcher to the main grid
            main_grid.add(stack_switcher);
            main_grid.attach(main_stack, 0, 1, 1, 1);
            main_stack.show_all();
            
            // On first run add tutorial
            if(get_first_run())
                main_box.add(info_bar);
                
            main_box.add(main_grid);                                      
            this.add(main_box);

            var css_provider = new Gtk.CssProvider();

            try {
                css_provider.load_from_data("@define-color colorPrimary #ea1e36;", -1);
            } catch (Error e) {
                stdout.printf ("%s\n", e.message);
            }


            this.get_style_context().add_provider_for_screen (Gdk.Screen.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            this.show_all();          
        }

            protected override bool delete_event(Gdk.EventAny event) {
                if(working) {   
                    var close_dialog = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL,  Gtk.MessageType.WARNING, Gtk.ButtonsType.NONE, " ");
                    close_dialog.text = _("Are you sure you want to quit?");
	                close_dialog.secondary_text = _("There are still working processes in the background. If you quit Power Installer, active processes will end.");
                    close_dialog.add_button (_("Do not quit"), 0);
                    close_dialog.add_button (_("Quit"), 1);                    	
                    close_dialog.show_all();
			        close_dialog.response.connect((response_id) => {
    			        switch(response_id) {
                            case 0:
                                break;                            
    				        case 1:
    				            handler.pid_list.@foreach ((pid) => {
                                    Posix.kill(pid, Posix.SIGKILL);
                                });

    				            Gtk.main_quit();
    				            break;
			            }

		    	        close_dialog.destroy();
		            });                 
                } else              
                    Gtk.main_quit();  
                                
                return true;    
            }  
        
        // When using gschema and policykit creating dconf key will not work
        private static bool get_first_run() {
            var first_run_file = File.new_for_path(Constants.PKGDATADIR + "/FIRSTRUN.txt");
            if(first_run_file.query_exists()) {
                try {
                    first_run_file.delete();
                } catch(Error e) {
                    stdout.printf("%s\n", e.message);
                    return false;
                }
                return true;
            }
            
            return false;    
        }
        
        public void switch_tab(string name) {
            main_stack.set_visible_child_name(name);         
        }
        
        public void header_set_working(bool status) {
            if(status) {
                working = true;
                show_notification(_("Working... You will be notified after all work will be done!"));
                if (!quiet) {
                    header_bar.set_title(_("Working..."));
                    header_bar.pack_end(light_img);
                }
            } else {
                working = false;
                if (!quiet) {
                    header_bar.set_title(PROGRAM_NAME);
                    light_img.destroy();
                }
            }
            
            if (!quiet)
                this.show_all();
        }

        private void run_prefs_dialog() {
            prefs_btn.set_sensitive(false);
            var prefs_dialog = new Widgets.PreferencesDialog();
            prefs_dialog.show_all();
        }
    }
}
