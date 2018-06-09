package de.faoc.sijadictionary.gui.controls;

import java.io.File;
import java.nio.file.Paths;
import java.util.List;
import java.util.Set;

import de.faoc.sijadictionary.gui.controls.URLImage.Status;
import de.faoc.sijadictionary.gui.controls.image.ImageButtonClickHandler;
import de.faoc.sijadictionary.gui.util.draghandler.GuiDragHandler;
import de.faoc.sijadictionary.gui.util.draghandler.GuiDragHandler.DragReturnType;
import javafx.animation.Animation;
import javafx.animation.FadeTransition;
import javafx.application.Platform;
import javafx.beans.binding.Bindings;
import javafx.beans.binding.NumberBinding;
import javafx.beans.value.ChangeListener;
import javafx.css.PseudoClass;
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
import loader.PluginLoader;

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

	private List<GuiDragHandler> dragHandlers;
	private ImageButtonClickHandler clickHandler;

	public TranslationImageButton(int translationId, boolean previewMode) {
		super();
		this.translationId = translationId;
		this.previewMode = previewMode;

		init();
	}

	private void init() {
		getStyleClass().addAll("translation-image-button", "round");

		List<ImageButtonClickHandler> clickHandlers = PluginLoader.load(ImageButtonClickHandler.class);
		if (!clickHandlers.isEmpty()) {
			clickHandler = clickHandlers.get(0);
			setOnAction(event -> {
				File file = clickHandler.openFile();
				if (file != null) {
					Image selectedImage = ImageProcessor.getImageFromFile(file);
					if (selectedImage != null) {
						saveTranslationImage(selectedImage);
						updateImage();
					}
				}
			});
		} else {
			previewMode = true;
		}

		updateImage();

		Circle circle = new Circle();
		circle.radiusProperty().bind(widthProperty().divide(2));
		boundsInLocalProperty().addListener((ChangeListener<Bounds>) (observable, oldValue, newValue) -> {
			circle.setCenterX((newValue.getMaxX() - newValue.getMinX()) / 2);
			circle.setCenterY((newValue.getMaxY() - newValue.getMinY()) / 2);
		});
		setClip(circle);

		if (previewMode) {
			pseudoClassStateChanged(PseudoClass.getPseudoClass("preview-mode"), true);
		} else {
			initDragAndDrop();
		}
	}

	private void updateImage() {
		imageView = new TranslationImageView(translationId);
		if (maxBinding == null)
			maxBinding = Bindings.max(widthProperty(), heightProperty());
		if (imageView.isPresent()) {
			maxBinding.addListener((ChangeListener<Number>) (observable, oldValue, newValue) -> {
				fitImage();
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

	private void initDragAndDrop() {
		// Set Drop from File
		dragHandlers = PluginLoader.load(GuiDragHandler.class);

		setOnDragOver(event -> {
			if (event.getGestureSource() != this) {
				for (GuiDragHandler draghandler : dragHandlers) {
					if (draghandler.isValidDragData(event)) {
						event.acceptTransferModes(TransferMode.COPY_OR_MOVE);
						break;
					}
				}
			}
		});
		setOnDragEntered(event -> {
			if (event.getGestureSource() != this) {
				for (GuiDragHandler draghandler : dragHandlers) {
					if (draghandler.isValidDragData(event)) {
						pseudoClassStateChanged(PseudoClass.getPseudoClass("drag"), true);
						break;
					}
				}
			}
			event.consume();
		});
		setOnDragExited(event -> {
			pseudoClassStateChanged(PseudoClass.getPseudoClass("drag"), false);
			event.consume();
		});
		setOnDragDropped(event -> {
			processDraggedImage(event);
		});
	}

	private void processDraggedImage(DragEvent event) {
		// Try to get Image with every dragHandler
		for (GuiDragHandler dragHandler : dragHandlers) {
			handlerLoop: if (dragHandler.isValidDragData(event)) {
				switch (dragHandler.getReturnType()) {
				case IMAGE:
					Image image = dragHandler.getDraggedImage(event);
					if (image != null) {
						saveTranslationImage(image);
						updateImage();
						break handlerLoop;
					}
					break;
				case URL:
					String draggedUrlString = dragHandler.getDraggedImageUrl(event);
					if (draggedUrlString != null) {
						loadImageFromUrl(draggedUrlString);
						break handlerLoop;
					}
					break;
				}
			}
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

			urlImage.statusProperty().addListener((ChangeListener<Status>) (observable, oldValue, status) -> {
				if (status == URLImage.Status.SUCCESSFUL) {
					saveTranslationImage(urlImage);
				}
				Platform.runLater(() -> {
					fadeTransition.stop();
					setOpacity(1);
					updateImage();
				});
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
