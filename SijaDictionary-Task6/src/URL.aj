import de.faoc.sijadictionary.gui.controls.TranslationImageButton;
import de.faoc.sijadictionary.gui.controls.URLImage;
import de.faoc.sijadictionary.gui.controls.URLImage.Status;
import javafx.animation.Animation;
import javafx.animation.FadeTransition;
import javafx.application.Platform;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.scene.control.ProgressIndicator;
import javafx.util.Duration;
import de.faoc.sijadictionary.gui.controls.ImageProcessor;

privileged public aspect URL {
	
	public void TranslationImageButton.loadImageFromUrl(String urlString) {
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
					Platform.runLater(() -> {
						fadeTransition.stop();
						setOpacity(1);
						updateImage();
					});
				}
			});
		}
	}
	
}
