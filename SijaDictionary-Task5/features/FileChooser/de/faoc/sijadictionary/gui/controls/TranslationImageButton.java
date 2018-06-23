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

public  class  TranslationImageButton  extends Button {
	
	private void init() {
		original();
		setOnAction(new EventHandler<ActionEvent>() {
			@Override
			public void handle(ActionEvent event) {
				openFile();
			}
		});
	}
	
}
