package de.faoc.sijadictionary.gui.controls;

import de.faoc.sijadictionary.core.database.DatabaseHelper;
import de.faoc.sijadictionary.core.database.DatabaseStatements;
import de.faoc.sijadictionary.gui.displays.VocabDisplay;
import javafx.application.Platform;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.StackPane;

public class TranslationBox extends StackPane {

	private VocabDisplay vocabDisplay;

	private int translationId;
	private String fromOrigin;
	private String toTranslation;

	private TextField fromTextField;
	private TextField toTextField;
	private Button deleteButton;
	private TranslationImageStack imageStack;

	private HBox mainBox;

	public TranslationBox(VocabDisplay vocabDisplay, int translationId, String fromOrigin, String toTranslation) {
		super();
		this.vocabDisplay = vocabDisplay;
		this.translationId = translationId;
		this.fromOrigin = fromOrigin;
		this.toTranslation = toTranslation;

		init();
	}

	private void init() {
		getStyleClass().addAll("translation-box");

		mainBox = new HBox();

		initMainBox();
		initTopBox();

		getChildren().addAll(mainBox, deleteButton);
	}

	private void initMainBox() {
		mainBox.setAlignment(Pos.CENTER_LEFT);

		fromTextField = new TextField(fromOrigin);
		fromTextField.getStyleClass().add("translation-text");
		fromTextField.setAlignment(Pos.CENTER_RIGHT);
		HBox.setHgrow(fromTextField, Priority.ALWAYS);
		fromTextField.setOnAction(new EventHandler<ActionEvent>() {
			@Override
			public void handle(ActionEvent event) {
				if (fromTextField.getText() != fromOrigin) {
					updateTranslation();
				}
				toTextField.requestFocus();
			}
		});
		fromTextField.focusedProperty().addListener(new ChangeListener<Boolean>() {
			@Override
			public void changed(ObservableValue<? extends Boolean> observable, Boolean oldValue, Boolean newValue) {
				if (!newValue && fromTextField.getText() != fromOrigin)
					updateTranslation();
				else if (newValue) {
					Platform.runLater(new Runnable() {
						@Override
						public void run() {
							fromTextField.selectAll();
						}
					});
				}
			}
		});

		toTextField = new TextField(toTranslation);
		toTextField.getStyleClass().add("translation-text");
		toTextField.setAlignment(Pos.CENTER_LEFT);
		HBox.setHgrow(toTextField, Priority.ALWAYS);
		toTextField.setOnAction(new EventHandler<ActionEvent>() {
			@Override
			public void handle(ActionEvent event) {
				if (toTextField.getText() != toTranslation) {
					updateTranslation();
				}
				clearFocus();
			}
		});
		toTextField.focusedProperty().addListener(new ChangeListener<Boolean>() {
			@Override
			public void changed(ObservableValue<? extends Boolean> observable, Boolean oldValue, Boolean newValue) {
				if (!newValue && toTextField.getText() != toTranslation)
					updateTranslation();
				else if (newValue) {
					Platform.runLater(new Runnable() {
						@Override
						public void run() {
							toTextField.selectAll();
						}
					});
				}
			}
		});

		imageStack = new TranslationImageStack(translationId);

		Label seperator = new Label("\u2014");
		seperator.getStyleClass().addAll("seperator");

		mainBox.getChildren().addAll(imageStack, fromTextField, seperator, toTextField);

	}

	private void initTopBox() {
		deleteButton = Icons.getIconButton(Icons.DELETE_IMAGE_PATH, 0);
		deleteButton.getStyleClass().addAll("translation-delete-button");
		deleteButton.setOnAction(new EventHandler<ActionEvent>() {
			@Override
			public void handle(ActionEvent event) {
				delete();
			}
		});

		StackPane.setAlignment(deleteButton, Pos.TOP_RIGHT);

	}

	private void delete() {
		if(DatabaseHelper.executeUpdate(DatabaseStatements.Delete.translation(translationId))) {
			vocabDisplay.removeBox(this);
		}
		
	}

	private void updateTranslation() {
		DatabaseHelper.executeUpdate(
				DatabaseStatements.Update.translation(translationId, fromTextField.getText(), toTextField.getText()));
	}
	
	private void clearFocus() {
		this.requestFocus();
	}
	
	public void editTranslations() {
		fromTextField.requestFocus();
	}

}
