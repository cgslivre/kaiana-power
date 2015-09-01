namespace PowerInstaller.Widgets {
    public class Tutorial : Gtk.Stack {	
    public signal void close();
    private bool found = false;

	public Tutorial() {
		var page0 = new TutorialPage (this, 
			"Hi %s, thank you for using Power Installer!
Power Installer is an ultimate tool
for installing things faster.".printf(OWNER), 0);
		this.add_named(page0, "0");
		
		var page1 = new TutorialPage (this,
	    "In the General tab you can drag and drop files
to perform specific actions.", 1);
		this.add_named(page1, "1");

		var page2 = new TutorialPage (this,
	    "For example if you want to install debian file
just drag and drop it onto this window.", 2);
		this.add_named(page2, "2");

		var page3 = new TutorialPage (this,
	    "The same goes for the bash and python scripts.
You can also install archived GTK, icon and plank themes
by checking corresponding fields.", 3);
		this.add_named(page3, "3");

		var page4 = new TutorialPage (this,
	    "In the Commands tab you can execute multiple
commands at once, add repositories and install packages.", 4);
		this.add_named(page4, "4");					

		var page5 = new TutorialPage (this,
	    "In packages section try typing for example:
gimp and Power Installer will automaticly help
you complete the name of the package.", 5);
		this.add_named(page5, "5");		
		
		var page6 = new TutorialPage (this,
	    "You can also paste here links to the 
debian files, bash and python scripts to execute them
by checking the following checkbox.", 6);
		this.add_named(page6, "6");	
		
		var page7 = new TutorialPage (this,
	    "In the Actions tab you have the daily
actions you can execute. Here you can also install
AMD and NVIDIA graphic card drivers.", 7);
		this.add_named(page7, "7");							

		var page8 = new TutorialPage (this,
	    "Good job! Now you can use the Power Installer!
Enjoy!", 8);
		this.add_named(page8, "8");							

		foreach(var tp in this.get_children()) {
			(tp as TutorialPage).close_from_page.connect (() => {
				timer = -1;
				this.close();
			});
		}
		
		set_visible_child_name("0");
		this.show_all();

	}

	    uint timer = -1;
	    int check_timer = 500;
	    int success_timer = 1000;
	    public void new_page (int index) {
		    this.set_visible_child_name("%d".printf(index));
		    var old_page = this.visible_child as TutorialPage;
		    if (timer != -1) {
		    	Source.remove (timer);
		    	timer = -1;
		    }

		    timer = GLib.Timeout.add (check_timer, () => {
		    	found = false;
		    	if(found) {
		    		old_page.success();
		    		GLib.Timeout.add (success_timer, () => {
		    			new_page(index + 1);
		    			return false;
		    		});
		    		timer = -1;
		    		return false;
		    	}
		    	
				return true;
			});    
	    }	
    }
}
