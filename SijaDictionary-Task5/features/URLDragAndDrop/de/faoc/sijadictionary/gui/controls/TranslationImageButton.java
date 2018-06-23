package de.faoc.sijadictionary.gui.controls;

import java.io.File;
import java.nio.file.Paths;
import java.util.List;
import java.util.Set;

import de.faoc.sijadictionary.gui.controls.URLImage.Status;
import javafx.animation.Animation;
import javafx.animation.FadeTransition;
import javafx.application.Platform;
import javafx.beans.binding.Bindings;
import javafx.beans.binding.NumberBinding;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.css.PseudoClass;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Bounds;
import javafx.scene.control.Button;
import javafx.scene.control.ProgressIndicator;
import javafx.scene.image.Image;
import javafx.scene.input.DataFormat;
import javafx.scene.input.DragEvent;
import javafx.scene.input.Dragboard;
import javafx.scene.input.TransferMode;
import javafx.scene.shape.Circle;
import javafx.stage.FileChooser;
import javafx.util.Duration;

public class TranslationImageButton extends Button {

	private boolean processDraggedImage(DragEvent event) {
		if(original(event)) return true;
		
		Image image = null;
		Dragboard dragboard = event.getDragboard();
		
		// Extract from URL
		String draggedURLString = dragboard.getUrl();
		if (draggedURLString != null && ImageProcessor.isValidImageUrl(draggedURLString)) {
			loadImageFromUrl(draggedURLString);
			return true;
		}

		// Extract from text
		String draggedText = dragboard.getString();
		if (draggedText != null && !draggedText.isEmpty()) {
			// Try to get Image if String is treated as URL
			if (ImageProcessor.isValidImageUrl(draggedText)) {
				loadImageFromUrl(draggedText);
				return true;
			}
		}
		return false;
	}

	private boolean isValidDragData(DragEvent event) {
		if(original(event)) return true;
		
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

}
