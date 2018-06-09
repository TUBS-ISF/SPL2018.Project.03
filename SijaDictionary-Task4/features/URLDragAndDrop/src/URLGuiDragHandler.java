import java.util.Set;

import de.faoc.sijadictionary.gui.controls.ImageProcessor;
import de.faoc.sijadictionary.gui.util.draghandler.GuiDragHandler;
import javafx.scene.image.Image;
import javafx.scene.input.DataFormat;
import javafx.scene.input.DragEvent;
import javafx.scene.input.Dragboard;

public class URLGuiDragHandler implements GuiDragHandler {

	@Override
	public DragReturnType getReturnType() {
		return DragReturnType.URL;
	}

	@Override
	public boolean isValidDragData(DragEvent event) {
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

	@Override
	public Image getDraggedImage(DragEvent event) {
		return null;
	}

	@Override
	public String getDraggedImageUrl(DragEvent event) {
		Dragboard dragboard = event.getDragboard();

		// Extract from URL
		String draggedURLString = dragboard.getUrl();
		if (draggedURLString != null && ImageProcessor.isValidImageUrl(draggedURLString)) {
			return draggedURLString;
		}

		// Extract from text
		String draggedText = dragboard.getString();
		if (draggedText != null && !draggedText.isEmpty()) {
			// Try to get Image if String is treated as URL
			if (ImageProcessor.isValidImageUrl(draggedText)) {
				return draggedText;
			}
		}
		return null;
	}

}
