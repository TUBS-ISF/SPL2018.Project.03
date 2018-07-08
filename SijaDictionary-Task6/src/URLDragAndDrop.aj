
import java.util.Set;

import de.faoc.sijadictionary.gui.controls.ImageProcessor;
import javafx.scene.image.Image;
import javafx.scene.input.DataFormat;
import javafx.scene.input.DragEvent;
import javafx.scene.input.Dragboard;
import x.AddPictures.TranslationImageButton;

privileged public aspect URLDragAndDrop {
	
	
	boolean around(DragEvent event, TranslationImageButton o) : execution( boolean TranslationImageButton.isValidDragData(DragEvent)) && this(o) && args(event) {
		if(proceed(event, o)) return true;
		Dragboard dragboard = event.getDragboard();
		Set<DataFormat> dataFormats = dragboard.getContentTypes();
		for (DataFormat dataFormat : dataFormats) {
			if (dataFormat.equals(DataFormat.PLAIN_TEXT)) {
				// Check if String has image file-ending
				String draggedText = dragboard.getString();
				if (draggedText != null && !draggedText.isEmpty()) {
					if (ImageProcessor.isValidImageUrl(draggedText))
						return true;
				}

			}
			if (dataFormat.equals(DataFormat.URL)) {
				String draggedURLString = dragboard.getUrl();
				if (draggedURLString != null) {
					if (ImageProcessor.isValidImageUrl(draggedURLString))
						return true;
				}
			}
		}
		return false;
	}
	
	boolean around(DragEvent event, TranslationImageButton o) : execution( boolean TranslationImageButton.processDraggedImage(DragEvent)) && this(o) && args(event) {
		if(proceed(event, o)) return true;
		Image image = null;
		Dragboard dragboard = event.getDragboard();
		// Extract from URL
		String draggedURLString = dragboard.getUrl();
		if (draggedURLString != null && ImageProcessor.isValidImageUrl(draggedURLString)) {
			o.loadImageFromUrl(draggedURLString);
			return true;
		}

		// Extract from text
		String draggedText = dragboard.getString();
		if (draggedText != null && !draggedText.isEmpty()) {
			// Try to get Image if String is treated as URL
			if (ImageProcessor.isValidImageUrl(draggedText)) {
				o.loadImageFromUrl(draggedText);
				return true;
			}
		}

		return false;
	}

}
