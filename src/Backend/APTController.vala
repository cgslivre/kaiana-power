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

    public class APTController : Object {
        public string[] install_packages_args;
        public string[] add_repositories_args;
        public string[] get_package_list_args;

        public string[] update_repositories;
        public string[] configure_packages;
        public string[] repair_packages;
        public string[] remove_packages;

        public APTController() {
            this.update_repositories = { "apt-get", "update" };
            this.configure_packages = { "dpkg", "--configure", "-a" };
            this.repair_packages = { "apt-get", "install", "-y", "-f" };
            this.remove_packages = { "apt-get", "autoremove", "-y" };
            this.install_packages_args = { "apt-get", "install", "-y" };
            this.add_repositories_args = { "add-apt-repository", "-y" };
            this.get_package_list_args = { "apt-cache", "search", "." };         
        }

        // Install packages 
        public void install_packages(string[] packages) {
            string[] args = { "apt-get", "install", "-y" };
            
            foreach(string package in packages)
                args += package;

            handler.body_success = "Succesfully installed packages:" + " " + string.joinv(" ", packages)  + "!";
            handler.body_error = "Something went wrong. Check names of the packages and try again.";            
            handler.execute_shell(args);
        }    
        
        // Add repositories and update them        
        public void add_repositories(string[] repos) {
            string[] args = { "add-apt-repository", "-y" };
            
            foreach(string repo in repos) {
                args += repo;
         
            handler.execute_shell(args, true); 
            if(handler.shell_exit == 0) {
                handler.body_success = "Succesfully added PPA's:" + " " + string.joinv(" ", repos) + "!";
                handler.body_error = "'Something went wrong. The repositories could not be updated properly!";   
                handler.execute_shell({ "apt-get", "update" });
            } else {
                show_notification("Something went wrong. Check the syntax of the repostiories and try again.", true);  
            }    
                args = { "add-apt-repository", "-y" };         
            }          
        }


        /*
         * Spawn command to list all packages avalible
         * Example: package - description
         */       
        public string[] get_package_list() {
            string output;
            try {
                string[] spawn_env = Environ.get();
		        Process.spawn_sync("/",
			              			    { "apt-cache", "search", "." },
			              			    spawn_env,
			               				SpawnFlags.SEARCH_PATH,
			              				null,
			               			    out output,
			               			    null,
			               			    null);
		    } catch (SpawnError e) {
	            stdout.printf ("Error: %s\n", e.message);
	        }

            return output.split("\n");
        }
    }
}
