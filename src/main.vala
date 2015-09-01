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

/* Main application */

using GLib;
using Gtk;

#if HAVE_GRANITE
    using Granite.Services;
#endif

namespace PowerInstaller {

    /* Settings */
    private GLib.Settings settings;

    private static Backend.ExecuteHandler handler;
    private static Backend.FileHandler file_handler;
    private static Backend.APTController controller;
    
    //private Pid pid;
    private MainWindow? window = null;

    private enum Theme {
        GTK_THEME = 0,
        ICON_THEME = 1,
        PLANK_THEME = 2
    }

    // Options
    private enum Option {
        NORMAL = 'a',
        DEBIAN = 'b',
        THEME = 'c',
        ICON = 'd',
        PLANK = 'e'
    }

    // User info
    private static string HOME_DIR;
    private static string OWNER;
            
    // Program name
    private const string PROGRAM_NAME = N_("Power Installer");
    private const string EXEC_NAME = "power-installer";

    // State
    private bool working = false;

    // A small trick to use granite or GTK to build the app
#if HAVE_GRANITE
    public class AppClass : Granite.Application {
    }
#else
    public class AppClass : Gtk.Application {
    }
#endif    

    public class PowerInstallerApp : AppClass {
        private const string CONFIG_FILE = "/tmp/POWER_INSTALLER_CONFIG.conf";
#if HAVE_GRANITE    
        construct {
            flags |= ApplicationFlags.HANDLES_OPEN;

            program_name = PROGRAM_NAME;
            exec_name = EXEC_NAME;

            build_data_dir = Constants.DATADIR;
            build_pkg_data_dir = Constants.PKGDATADIR;
            build_release_name = Constants.RELEASE_NAME;
            build_version = Constants.VERSION;
            build_version_info = Constants.VERSION_INFO;

            app_years = "2014-2015";
            app_icon = "power-installer";
            app_launcher = "power-installer.desktop";
            application_id = "org.power-installer";

            main_url = "https://launchpad.net/power-installer";
            bug_url = "https://bugs.launchpad.net/power-installer";
            help_url = "https://code.launchpad.net/power-installer";
            translate_url = "https://translations.launchpad.net/power-installer";

            about_authors = { "Adam Bieńkowski <donadigos159@gmail.com>" };
            about_documenters = { "Adam Bieńkowski <donadigos159@gmail.com>" };
            about_artists = { "Adam Bieńkowski <donadigos159@gmail.com>" };
            about_comments = _("Power Installer lets you install things
quickly on Ubuntu based distributions.");
            about_translators = "";

            about_license_type = Gtk.License.GPL_3_0;
        }
#endif        
        
        protected override void open(File[] files, string hint) {
            foreach(var file in files)
                file_handler.execute_drag(file.get_path(), false, false, false);
        }

        public PowerInstallerApp() {
#if HAVE_GRANITE        
            Logger.initialize(PROGRAM_NAME);
            Logger.DisplayLevel = LogLevel.DEBUG;
#endif            
        }

        public static int main(string[] args) {
            Gtk.init(ref args);

            // Initialize settings
            settings = new GLib.Settings("org.pantheon.power-installer");            

            // Handlers
            handler = new Backend.ExecuteHandler();
            file_handler = new Backend.FileHandler();
            controller = new Backend.APTController();

            // Run app
            var app = new PowerInstallerApp();

            var file = File.new_for_path (CONFIG_FILE);
            var key_file = new KeyFile();

            try {
                key_file.load_from_file(CONFIG_FILE, KeyFileFlags.NONE);
                OWNER = key_file.get_string ("POWER_INSTALLER_CONFIG", "POWER_INSTALLER_USER");
                HOME_DIR = key_file.get_string ("POWER_INSTALLER_CONFIG", "POWER_INSTALLER_HOME"); 
            } catch (Error e) {
                error ("%s\n", e.message);
            }

            try {
                file.@delete ();
            } catch (Error e) {
                error ("%s\n", e.message);
            }

            return app.run(args);
        }

        protected override void activate() {
            if(get_windows() != null) {
                get_windows().data.present();
            } else {
                window = new MainWindow();
                window.destroy.connect(Gtk.main_quit);
                window.show_all();
                Gtk.main();
            }
        }      
    }
}
