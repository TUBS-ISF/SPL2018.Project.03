package x;


import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.nio.file.Path;
import java.nio.file.Paths;

import de.faoc.sijadictionary.gui.controls.Icons;
import de.faoc.sijadictionary.gui.controls.ImageProcessor;
import de.faoc.sijadictionary.gui.controls.TranslationBox;
import javafx.beans.binding.Bindings;
import javafx.beans.binding.NumberBinding;
import javafx.beans.value.ChangeListener;
import javafx.css.PseudoClass;
import javafx.geometry.Bounds;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.StackPane;
import javafx.scene.shape.Circle;
import javafx.stage.FileChooser;

privileged public aspect AddPictures {
	
	private TranslationImageStack TranslationBox.imageStack;

	after(TranslationBox o) : execution(void TranslationBox.initMainBox()) && this(o){
		o.mainBox.getChildren().add(0, new TranslationImageStack(o.getTranslationId()));
	}
	
	/*
	 * CLASS: TranslationImageButton
	 */
	
	public static class TranslationImageButton extends Button {

		private static final double SQRT_2 = Math.sqrt(2);
		private static final String IMAGE_ROOT = "img" + File.separator;
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
			getStyleClass().addAll("translation-image-button", "round", ".non-clickable");

			fileChooser.setTitle("Choose Image");
			fileChooser.setInitialDirectory(new File(System.getProperty("user.home")));
			fileChooser.getExtensionFilters().addAll(new FileChooser.ExtensionFilter("All Images", "*.*"),
					new FileChooser.ExtensionFilter("JPG", "*.jpg"), new FileChooser.ExtensionFilter("PNG", "*.png"));

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

		private void saveTranslationImage(Image image) {
			File targetFile = Paths.get(IMAGE_ROOT + translationId + IMAGE_SUFFIX).toFile();
			ImageProcessor.saveImageToFile(image, targetFile, IMAGE_SIZE, IMAGE_FORMAT);
		}

		public void deleteImage() {
			File file = new File(IMAGE_ROOT + translationId + IMAGE_SUFFIX);
			if (file.exists())
				file.delete();
			updateImage();
		}

	}
	
	/*
	 * CLASS: TranslationImageStack
	 */
	
	public static class TranslationImageStack extends StackPane {

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

	/*
	 * CLASS: TranslationImageView
	 */
	
	public static class TranslationImageView extends ImageView {
		
		private static final String IMAGE_ROOT = "img/";
		private static final String IMAGE_SUFFIX = ".png";
		
		private int translationId;
		
		private Image image;
		
		private boolean present;
		
		public TranslationImageView(int translationId) {
			super();
			this.translationId = translationId;
			
			init();
		}

		private void init() {
			getStyleClass().addAll("translation-imageview");
			
			initImage();
			setImage(image);
			
			setPreserveRatio(true);
			setSmooth(true);
		}

		private void initImage()  {
			//See if image is present / create path if not present
			String imagePathString = IMAGE_ROOT + translationId + IMAGE_SUFFIX;
			Path imagePath = Paths.get(imagePathString);
			File imageFile = imagePath.toFile();
			if(imageFile.exists()) {
				try {
					image = new Image(new BufferedInputStream(new FileInputStream(imageFile)));
					present = true;
					return;
				} catch (FileNotFoundException e) {
					System.out.println("Couln't load image " + imagePath + "!");
					e.printStackTrace();
				}
			}
			image = Icons.getImage(Icons.IMAGE_IMAGE_PATH);
			present = false;
		}

		public int getTranslationId() {
			return translationId;
		}

		public boolean isPresent() {
			return present;
		}
		
	}
	
}
