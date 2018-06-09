package de.faoc.sijadictionary.gui.util.draghandler;

import javafx.scene.image.Image;
import javafx.scene.input.DragEvent;

public interface GuiDragHandler {
	
	public enum DragReturnType {
		IMAGE, URL;
	}
	
	public DragReturnType getReturnType();
	
	public boolean isValidDragData(DragEvent event);
	
	public Image getDraggedImage(DragEvent event);
	
	public String getDraggedImageUrl(DragEvent event);

}
