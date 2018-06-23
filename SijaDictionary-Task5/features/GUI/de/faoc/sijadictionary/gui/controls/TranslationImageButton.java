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

	private static final double SQRT_2 = Math.sqrt(2);
	private static final String IMAGE_ROOT = "img/";
	private static final String IMAGE_SUFFIX = ".png";
	private static final String IMAGE_FORMAT = "png";
	private static final int IMAGE_SIZE = 400;
	private static final long IMAGE_LOADING_TIMEOUT = 7000;

	private int translationId;
	private boolean previewMode;

	private TranslationImageView imageView;

	private NumberBinding maxBinding;

	private final FileChooser fileChooser = new FileChooser();

	public TranslationImageButton(int translationId, boolean previewMode) {
		super();
		this.translationId = translationId;
		this.previewMode = previewMode;

		init();
	}

	private void init() {
		getStyleClass().addAll("translation-image-button", "round");

		fileChooser.setTitle("Choose Image");
		fileChooser.setInitialDirectory(new File(System.getProperty("user.home")));
		fileChooser.getExtensionFilters().addAll(new FileChooser.ExtensionFilter("All Images", "*.*"),
				new FileChooser.ExtensionFilter("JPG", "*.jpg"), new FileChooser.ExtensionFilter("PNG", "*.png"));
		updateImage();

		Circle circle = new Circle();
		circle.radiusProperty().bind(widthProperty().divide(2));
		boundsInLocalProperty().addListener(new ChangeListener<Bounds>() {
			@Override
			public void changed(ObservableValue<? extends Bounds> observable, Bounds oldValue, Bounds newValue) {
				circle.setCenterX((newValue.getMaxX() - newValue.getMinX()) / 2);
				circle.setCenterY((newValue.getMaxY() - newValue.getMinY()) / 2);
			}
		});
		setClip(circle);

		if (previewMode) {
			pseudoClassStateChanged(PseudoClass.getPseudoClass("preview-mode"), true);
		} 
	}

	private void openFile() {
		File file = fileChooser.showOpenDialog(getScene().getWindow());
		if (file != null) {
			Image selectedImage = ImageProcessor.getImageFromFile(file);
			if (selectedImage != null) {
				saveTranslationImage(selectedImage);
				updateImage();
			}
		}
	}

	private void updateImage() {
		imageView = new TranslationImageView(translationId);
		if (maxBinding == null)
			maxBinding = Bindings.max(widthProperty(), heightProperty());
		if (imageView.isPresent()) {
			maxBinding.addListener(new ChangeListener<Number>() {
				@Override
				public void changed(ObservableValue<? extends Number> observable, Number oldValue, Number newValue) {
					fitImage();
				}
			});
			fitImage();
		} else {
			imageView.fitWidthProperty().bind(widthProperty().divide(SQRT_2));
			imageView.fitHeightProperty().bind(heightProperty().divide(SQRT_2));
		}

		setGraphic(imageView);
	}

	private void fitImage() {
		if (imageView.getImage().getWidth() > imageView.getImage().getHeight()) {
			imageView.setFitHeight(maxBinding.doubleValue());
			imageView.setFitWidth(-1);
		} else {
			imageView.setFitHeight(-1);
			imageView.setFitWidth(maxBinding.doubleValue());
		}
	}

	private void saveTranslationImage(Image image) {
		File targetFile = Paths.get(IMAGE_ROOT + translationId + IMAGE_SUFFIX).toFile();
		ImageProcessor.saveImageToFile(image, targetFile, IMAGE_SIZE, IMAGE_FORMAT);
	}

	public void loadImageFromUrl(String urlString) {
		URLImage urlImage = ImageProcessor.getImageFromUrl(urlString, IMAGE_LOADING_TIMEOUT, true);
		if (urlImage != null) {
			FadeTransition fadeTransition = new FadeTransition(Duration.seconds(1), this);
			fadeTransition.setFromValue(0.8);
			fadeTransition.setToValue(0.2);
			fadeTransition.setAutoReverse(true);
			fadeTransition.setCycleCount(Animation.INDEFINITE);
			fadeTransition.play();

			ProgressIndicator progressIndicator = new ProgressIndicator(-1);

			setGraphic(progressIndicator);

			urlImage.statusProperty().addListener(new ChangeListener<Status>() {
				@Override
				public void changed(ObservableValue<? extends Status> observable, Status oldValue, Status status) {
					if (status == URLImage.Status.SUCCESSFUL) {
						saveTranslationImage(urlImage);
					}
					Platform.runLater(new Runnable() {
						@Override
						public void run() {
							fadeTransition.stop();
							setOpacity(1);
							updateImage();
						}
					});
				}
			});
		}
	}

	public void deleteImage() {
		File file = new File(IMAGE_ROOT + translationId + IMAGE_SUFFIX);
		if (file.exists())
			file.delete();
		updateImage();
	}

}
