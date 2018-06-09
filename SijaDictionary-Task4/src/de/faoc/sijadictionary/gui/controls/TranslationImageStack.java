package de.faoc.sijadictionary.gui.controls;

import de.faoc.sijadictionary.gui.controls.image.ImportImageButton;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.layout.StackPane;
import loader.PluginLoader;

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

		for (ImportImageButton importButton : PluginLoader.load(ImportImageButton.class)) {
			Button newButton = importButton.getButton(translationButton);
			if (newButton != null) {
				StackPane.setAlignment(newButton, importButton.getPosition());
				getChildren().add(newButton);
			}
		}
	}

}
