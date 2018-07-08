
import java.io.File;

import de.faoc.sijadictionary.gui.controls.ImageProcessor;
import javafx.scene.image.Image;
import x.AddPictures.TranslationImageButton;

privileged public aspect Filesystem {
	
	private void TranslationImageButton.openFile() {
		File file = fileChooser.showOpenDialog(getScene().getWindow());
		if (file != null) {
			Image selectedImage = ImageProcessor.getImageFromFile(file);
			if (selectedImage != null) {
				saveTranslationImage(selectedImage);
				updateImage();
			}
		}
	}

}
