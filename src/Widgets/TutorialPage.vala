namespace PowerInstaller.Widgets {

    public class TutorialPage : Gtk.Box {
        public signal void close_from_page();  
	    private int index;
    	private Tutorial stack;	
    	private Gtk.Button next_button;
    
    	public TutorialPage(Tutorial _stack, string description, int _index) {
    	    this.spacing = 10;
    		this.index = _index;
    		this.stack = _stack;
    		
    		var main_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
    		var content_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
    		
    		var desc = new Gtk.Label ("");
    		desc.selectable = true;
    		desc.set_line_wrap(true);		
    		desc.set_markup(description);
    		content_box.pack_start(desc);
    
    		var close_button = new Gtk.Button.from_icon_name("close-symbolic", Gtk.IconSize.BUTTON);
    		next_button = new Gtk.Button.from_icon_name("go-next-symbolic", Gtk.IconSize.BUTTON);
		
    		var button_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
    		button_box.pack_end(next_button, false, false, 0);		
    		button_box.pack_end(close_button, false, false, 0);
    		
    		main_box.pack_start(content_box, false, false, 0);
    		this.pack_end(button_box, false, false, 0);
    		this.add(main_box);
	
    		if(index == 8)
			    next_button.no_show_all = true;

    		next_button.clicked.connect(on_next_clicked);
	    	close_button.clicked.connect (() => {
	    		this.close_from_page();
	    	});
	    }

	    private void on_next_clicked() {
	        int next_index = index + 1;
	    	stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT);
	    	stack.new_page(next_index);
	    	if(next_index == 4)
	    	    window.switch_tab("commands");		
	    	else if(next_index == 7)
	    	    window.switch_tab("actions");
	    }

	    public void success () {
		    next_button.set_image(new Gtk.Image.from_icon_name("dialog-ok", Gtk.IconSize.BUTTON));
	    }
    }
}    
