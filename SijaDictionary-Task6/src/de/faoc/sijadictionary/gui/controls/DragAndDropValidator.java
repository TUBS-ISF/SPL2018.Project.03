package de.faoc.sijadictionary.gui.controls;

import javafx.scene.input.DragEvent;

public interface DragAndDropValidator {
	public boolean isValidDragData(DragEvent event);
	public boolean processDraggedImage(DragEvent event);
}
