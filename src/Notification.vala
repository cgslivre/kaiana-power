namespace PowerInstaller.Utils {

    public void show_notification(string body = "", bool error = false) {
        string[] spawn_args = { "bash", "notification.sh", body, error.to_string(), OWNER };
        string[] spawn_env = Environ.get();       
        
        try {
            Process.spawn_async(Constants.PKGDATADIR,
                            spawn_args,
                            spawn_env,
                            SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                            null,
                            null);
        } catch(Error e) { 
            GLib.error("%s\n", e.message);
        }
    }
}    
