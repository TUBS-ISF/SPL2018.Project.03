package de.faoc.sijadictionary.gui.controls;

import javafx.geometry.Bounds;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.HBox;
import javafx.scene.layout.StackPane;
import javafx.stage.Popup;

public class TranslationImageStack extends StackPane {

	private int translationId;

	private TranslationImageButton translationButton;
	private Button deleteButton;

	public TranslationImageStack(int translationId) {
		super();
		this.translationId = translationId;

		init();
	}

	private void init() {
		getStyleClass().addAll("translation-image-stack");

		translationButton = new TranslationImageButton(translationId, false);

		deleteButton = Icons.getIconButton(Icons.DELETE_IMAGE_PATH, 5);
		deleteButton.getStyleClass().addAll("translation-image-delete-button", "red-button", "round");
		StackPane.setAlignment(deleteButton, Pos.TOP_RIGHT);

		deleteButton.setOnAction(event -> {
			translationButton.deleteImage();
		});

		

		getChildren().addAll(translationButton, deleteButton);
	}

}
