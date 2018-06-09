import java.io.File;
import java.nio.file.Paths;
import java.util.List;
import java.util.Set;

import de.faoc.sijadictionary.gui.controls.ImageProcessor;
import de.faoc.sijadictionary.gui.util.draghandler.GuiDragHandler;
import javafx.scene.image.Image;
import javafx.scene.input.DataFormat;
import javafx.scene.input.DragEvent;
import javafx.scene.input.Dragboard;

public class FSGuiDragHandler implements GuiDragHandler {

	@Override
	public DragReturnType getReturnType() {
		return DragReturnType.IMAGE;
	}

	@Override
	public boolean isValidDragData(DragEvent event) {
		Dragboard dragboard = event.getDragboard();
		Set<DataFormat> dataFormats = dragboard.getContentTypes();
		for (DataFormat dataFormat : dataFormats) {
			// Check if files are valid
			if (dataFormat.equals(DataFormat.FILES)) {
				List<File> draggedFiles = dragboard.getFiles();
				if (draggedFiles != null) {
					for (File draggedFile : dragboard.getFiles()) {
						if (ImageProcessor.isValidImageFile(draggedFile))
							return true;
					}
				}
			}
			if (dataFormat.equals(DataFormat.IMAGE)) {
				if (dragboard.getImage() != null && !dragboard.getImage().isError())
					return true;
			}
			if (dataFormat.equals(DataFormat.PLAIN_TEXT)) {
				// Check if String has image file-ending
				String draggedText = dragboard.getString();
				if (draggedText != null && !draggedText.isEmpty()) {
					if (ImageProcessor.isValidImageFile(draggedText))
						return true;
				}

			}
		}
		return false;
	}

	@Override
	public Image getDraggedImage(DragEvent event) {
		Image image = null;
		Dragboard dragboard = event.getDragboard();

		// Extract from file list
		List<File> draggedFiles = dragboard.getFiles();
		image = ImageProcessor.getFirstImageFromFileList(draggedFiles);
		if (image != null) {
			return image;
		}

		// Extract from image
		if (dragboard.getImage() != null && !dragboard.getImage().isError()) {
			return dragboard.getImage();
		}

		// Extract from text
		String draggedText = dragboard.getString();
		if (draggedText != null && !draggedText.isEmpty()) {
			// Try to get Image if String is treated as file path
			File draggedFile = Paths.get(draggedText).toFile();
			image = ImageProcessor.getImageFromFile(draggedFile);
			if (image != null) {
				return image;
			}
		}
		return image;
	}

	@Override
	public String getDraggedImageUrl(DragEvent event) {
		return null;
	}

}
