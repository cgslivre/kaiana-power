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
 
    private DataOutputStream stdout_stream;

    public class ExecuteHandler : Object {
        public string body_success;
        public string body_error;
        public int shell_exit;
        public List<Pid> pid_list;

        private const string LOG_FILE = "/tmp/power-installer-log.txt";

        public ExecuteHandler() {
            pid_list = new List<int> ();

            body_success = "";
            body_error = "Something went wrong. Check out: /tmp/pi-log.txt for more information.";
        }

        private static bool process_line(IOChannel channel, IOCondition condition) {
            if(condition == IOCondition.HUP)
                return false;

            try {
                string line;
                channel.read_line(out line, null, null);
                stdout.printf(line);
                try {
                    stdout_stream.put_string(line);
                } catch(IOError e) { stdout.printf("%s\n", e.message); }
            } catch(IOChannelError e) {
                stdout.printf("%s\n", e.message);
                return false;
            } catch(ConvertError e) {
                stdout.printf("%s\n", e.message);
                return false;
            }

            return true;
        }

        
        public void execute_script(string contents, bool link = false, bool remove_dollars = false) {
            if(!link) {
                string new_contents = "";
                if(remove_dollars) {  
                    string[] content_split = contents.split("\n");
                    
                    foreach(string line in content_split) {
                        if(line.slice(0, 1) == "$")
                            new_contents += "\n" + line.splice(0, 1);
                    }
                    
                    if(new_contents != "")
                        contents = new_contents;
                }
                  
                try {
                    FileIOStream iostream;
                    File script = File.new_tmp(".pi-commands-XXXXXX.sh", out iostream);
                    
                    OutputStream ostream = iostream.output_stream;
                    DataOutputStream data_stream = new DataOutputStream(ostream);
                    data_stream.put_string(construct_bash_contents(contents));
                    
                    execute_shell({ "bash", script.get_path() });
                    
                    script.delete();
                } catch(Error e) {
                    error(e.message);
                }
            } else {
                string tmp_dir = "";
                try {
                    tmp_dir = DirUtils.make_tmp(".pi-XXXXXX");
                } catch(FileError e) { stdout.printf("%s\n", e.message); }
                
                execute_shell({ "wget", contents }, true, tmp_dir);
                if(shell_exit == 0) {
                    var dir = File.new_for_path(tmp_dir);
                    try {
                        var enumerator = dir.enumerate_children("", FileQueryInfoFlags.NONE, null);
                        var file_info = enumerator.next_file(null);
                        var downloaded = File.new_for_path(tmp_dir + "/" + file_info.get_name());
                    
                        file_handler.start(downloaded); 
                        
                        if(tmp_dir != "/")
                            dir.delete();                      
                    } catch(Error e) { stdout.printf("%s\n", e.message); }
                } else {
                    show_notification("Something went wrong. The file could not be downloaded, check if your link is vaild.", true);
                }
            }            
        }
        
        private string construct_bash_contents(string contents) {
            return "#!/bin/bash\n# AUTOGENERATED BY POWER INSTALLER
cmd() {
export TERM=xterm
export USER=" + OWNER + "
export HOME=" + HOME_DIR + "\ncd $HOME\n" + 
contents + "\n" +  
"}
(set -e; while true; do echo 'y' 2>/dev/null; sleep 2; done) | cmd
exit \"$?\"";
        }
        
        public void execute_shell(string[] spawn_args, bool dont_notify = false, string directory = "/", bool quiet = false) {
            var loop = new MainLoop();
            try {
                string[] spawn_env = Environ.get ();
                Pid child_pid;

                FileOutputStream file_stream = null;
                var output_file = File.new_for_path(LOG_FILE);
                if(!output_file.query_exists()) {
                    try {
                        file_stream = output_file.create(FileCreateFlags.NONE);
                    } catch(Error e) {
                        error("%s\n", e.message);
                    } 
                } else {
                    try {
                        file_stream = output_file.append_to(FileCreateFlags.NONE);
                    } catch(Error e) {
                        error("%s\n", e.message);
                    } 
                }
                    
                stdout_stream = new DataOutputStream(file_stream);

                int output;
                Process.spawn_async_with_pipes (directory,
                                    spawn_args,
                                    spawn_env,
                                    SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                                    null,
                                    out child_pid,
                                    null,
                                    out output,
                                    null);

                // Stream output live to stdout   
                if(!quiet) {          
                    var output_io = new IOChannel.unix_new(output);
                    output_io.add_watch(IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                        return process_line(channel, condition);
                    });
                }

                pid_list.append(child_pid);

                ChildWatch.add(child_pid, (pid, status) => {
                    Process.close_pid(pid);
                    pid_list.remove(pid);

                    loop.quit ();
                    
                    shell_exit = status;
                    if(dont_notify)
                        return;
                        
                    if(status == 0) {
                        show_notification(body_success, false);
                        if(output_file.query_exists()) {
                            try {
                                output_file.delete();
                            } catch(Error e) { 
                                error("%s\n", e.message);
                            }
                        }
                    } else {
                        show_notification(body_error, true);    
                    }
                });
                
                loop.run();               
            } catch(SpawnError e) {
                error("%s\n", e.message);
            }                           
        }        
    }     
}

