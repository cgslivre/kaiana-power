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

namespace PowerInstaller.Backend {

    public class FileHandler : Object {
        private string type;
        
        private enum Interpreter {
            SHELL = 0,
            PYTHON = 1
        }
        
        public FileHandler() { 

        }
     
        public void start(File file, string extract_dir = "default") {
            try {
                type = file.query_info("*", FileQueryInfoFlags.NONE).get_content_type();
            } catch(Error e) {
                error("%s\n", e.message);
            }
            
            string filepath = file.get_path();       
            switch(type) {
                case "application/x-deb":
                    install_debian(file.get_path(), file.get_basename());
                    break; 
                case "application/x-shellscript":
                    launch_interpreter(Interpreter.SHELL, filepath);   
                    break;     
                case "text/x-python":
                    launch_interpreter(Interpreter.PYTHON, filepath);  
                    break;
                case "application/zip": 
                case "application/x-compressed-tar":  
                case "application/x-bzip-compressed-tar":
                case "application/x-tar":                      
                case "application/x-xz":  
                    if(extract_dir != "default")
                        extract_theme(filepath, extract_dir);   
                    else 
                        show_notification("The file you opened could be an archive and none of the options were checked.", true);
                    break;                                   
                default:
                    try {
                        string extension = "." + file.query_info("*", FileQueryInfoFlags.NONE).get_name().split(".")[1];
                        if(extension == "." || extension == ". ")
                            show_notification("Could not detect file extension.", true);
                        else    
                            show_notification(@"Sorry, but $extension files are not supported by Power Installer.", true);
                    } catch(Error e) { 
                        error("%s\n", e.message);
                    }

                    break;            
            } 
        }

        public void extract_theme(string file, string extract_dir) {
            var extract_dir_file = File.new_for_path(file);
            if(!extract_dir_file.query_exists()) {
                show_notification(@"The $extract_dir directory does not exist. The files could not be extracted.", true);
                return;
            }
                    
            var read = new Archive.Read();
            read.support_format_all();
            read.support_compression_all();

            Posix.chdir(extract_dir);
            var stream = FileStream.open(file, "r");
            var res = read.open_FILE(stream);
            if(res == Archive.Result.OK) {
                unowned Archive.Entry entry;
                while(read.next_header(out entry) == Archive.Result.OK)
                    read.extract(entry);
            } else {
                show_notification("Could not open file for reading. The files could not be extracted.", true);
                return;
            }
            
            show_notification(@"Successfully extracted contents of file: $file to $extract_dir!");
            Posix.chdir(HOME_DIR);
        }

        public void execute_drag(string file, bool gtk_theme, bool icon_theme, bool plank_theme) {
            if (window == null) {
                window = new MainWindow.for_quiet ();
                window.header_set_working(true);
                window.@unref ();
            }

            string sys_data_dir = Environment.get_system_data_dirs()[1];
            string extract_dir = "default";
            if(gtk_theme)
                extract_dir = sys_data_dir + "themes/";
            else if(icon_theme)    
                extract_dir = sys_data_dir + "icons/";
            else if(plank_theme)  
                extract_dir = sys_data_dir + "plank/themes/";  
                
            var dragged = File.new_for_path(file);
            file_handler.start(dragged, extract_dir);
            
            window.header_set_working(false);
        }      
               
        private void debian_notify_success(string filename) {
            show_notification(@"Successfully installed debian file: $filename!");
        }
        
        private void install_debian(string file, string filename) {
            handler.execute_shell({ "dpkg", "-i", file }, true);
            if(handler.shell_exit == 0) {
                debian_notify_success(filename);
                return;
            } else {
                handler.execute_shell({ "apt-get", "install", "-y", "-f" }, true);
                handler.execute_shell({ "dpkg", "-i", file }, true);
                if(handler.shell_exit == 0)
                    debian_notify_success(filename);
                else
                    show_notification("Something went wrong. Check out: /tmp/pi-log.txt for more information.", true);
            } 
        }
        
        private void launch_interpreter(Interpreter interpreter, string file) {
            string str_inter = "";
            if(interpreter == 0)
                str_inter = "bash";
            else if(interpreter == 1)
                str_inter = "python";
            
            string arg = str_inter + " " + file;
            handler.body_success = @"Successfully executed $str_inter file: $file";
            handler.body_error = "Something went wrong. The file could not exist.";    
            handler.execute_shell({ "x-terminal-emulator", "-e", arg }); 
        }
    }
}  
