

import java.io.File;

import de.faoc.sijadictionary.gui.controls.TranslationBox;
import de.faoc.sijadictionary.gui.controls.TranslationImageButton;
import de.faoc.sijadictionary.gui.controls.TranslationImageStack;

privileged public aspect AddPictures {
	
	private TranslationImageStack TranslationBox.imageStack;

	after(TranslationBox o) : execution(void TranslationBox.initMainBox()) && this(o){
		o.mainBox.getChildren().add(0, new TranslationImageStack(o.getTranslationId()));
	}
	
}
