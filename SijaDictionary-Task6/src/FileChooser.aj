import de.faoc.sijadictionary.gui.controls.TranslationImageButton;

privileged public aspect FileChooser {
	
	after(TranslationImageButton o) : this(o) && execution(void TranslationImageButton.init()){
		o.setOnAction(event -> {
			o.openFile();
		});
		o.getStyleClass().add("clickable");
	}
	
}
