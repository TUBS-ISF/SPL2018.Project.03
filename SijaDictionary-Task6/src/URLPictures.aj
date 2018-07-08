import java.net.MalformedURLException;
import java.net.URL;
import java.util.Timer;
import java.util.TimerTask;

import de.faoc.sijadictionary.gui.controls.ImageProcessor;
import javafx.animation.Animation;
import javafx.animation.FadeTransition;
import javafx.application.Platform;
import javafx.beans.property.ReadOnlyBooleanProperty;
import javafx.beans.property.ReadOnlyBooleanWrapper;
import javafx.beans.property.ReadOnlyObjectProperty;
import javafx.beans.property.ReadOnlyObjectWrapper;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.scene.control.ProgressIndicator;
import javafx.scene.image.Image;
import javafx.util.Duration;
import x.AddPictures.TranslationImageButton;

privileged public aspect URLPictures {
	
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

			urlImage.statusProperty().addListener(new ChangeListener<URLPictures.URLImage.Status>() {
				@Override
				public void changed(ObservableValue<? extends URLPictures.URLImage.Status> observable, URLPictures.URLImage.Status oldValue, URLPictures.URLImage.Status status) {
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
	
	public static URLImage ImageProcessor.getImageFromUrl(URL url, long timeout, boolean resetOnProgress) {
		try {
			if (url.toString().matches(IMAGE_ENDING_REGEX))
				return new URLImage(url, timeout, resetOnProgress);
		} catch (NullPointerException | IllegalArgumentException e) {
		}
		return null;
	}

	public static URLImage ImageProcessor.getImageFromUrl(URL url, long timeout) {
		return getImageFromUrl(url, timeout, false);
	}

	public static URLImage ImageProcessor.getImageFromUrl(URL url) {
		return getImageFromUrl(url, -1, false);
	}

	public static URLImage ImageProcessor.getImageFromUrl(String urlString, long timeout, boolean resetOnProgress) {
		try {
			return getImageFromUrl(new URL(urlString), timeout, resetOnProgress);
		} catch (MalformedURLException e) {
		}

		return null;
	}

	public static URLImage ImageProcessor.getImageFromUrl(String urlString, long timeout) {
		return getImageFromUrl(urlString, timeout, false);
	}

	public static URLImage ImageProcessor.getImageFromUrl(String urlString) {
		return getImageFromUrl(urlString, -1, false);
	}

	
	/*
	 * CLASS: URLImage
	 */
	
	/**
	 * An extension of the JavaFX Image class, loading images from a given URL with
	 * the additional option so set a timeout for the loading process.
	 * 
	 * @author Fabian Ochmann
	 *
	 */
	public static class URLImage extends Image {

		public enum Status {
			PENDING, SUCCESSFUL, UNSUCCESSFUL
		}

		private Image instance = this;

		private URL url;
		private long timeout;
		private boolean resetOnProgress;

		private Timer timer;
		private TimerTask timerTask;
		private ReadOnlyBooleanWrapper timedout;
		private ReadOnlyObjectWrapper<URLImage.Status> status;

		public URLImage(URL url, long timeout, boolean resetOnProgress) {
			super(url.toString(), true);
			this.url = url;
			this.timeout = timeout;
			this.resetOnProgress = resetOnProgress;

			// Init timer
			if (timeout > 0) {
				resetTimer();
			}

			// Init Properties
			timedout = new ReadOnlyBooleanWrapper(false);
			status = new ReadOnlyObjectWrapper<URLImage.Status>(URLImage.Status.PENDING);

			// Listen on image properties
			progressProperty().addListener((ChangeListener<Number>) (observable, oldValue, progress) -> {
				if (progress.doubleValue() < 1) {
					if (resetOnProgress)
						resetTimer();
				} else {
					if (status.get() != URLImage.Status.UNSUCCESSFUL && !isTimedout()) {
						if (timer != null)
							timer.cancel();
						status.set(URLImage.Status.SUCCESSFUL);
					}
				}
			});

			errorProperty().addListener((ChangeListener<Boolean>) (observable, oldValue, error) -> {
				if (error)
					status.set(URLImage.Status.UNSUCCESSFUL);
			});
		}

		private void resetTimer() {
			if (timer != null)
				timer.cancel();

			timer = new Timer();
			timerTask = new TimerTask() {
				@Override
				public void run() {
					status.set(URLImage.Status.UNSUCCESSFUL);
					timedout.set(true);
					instance.cancel();
				}
			};
			timer.schedule(timerTask, timeout);
		}

		/*
		 * GETTERS & SETTERS
		 */

		public ReadOnlyBooleanProperty timedoutProperty() {
			return timedout.getReadOnlyProperty();
		}

		public ReadOnlyObjectProperty<URLImage.Status> statusProperty() {
			return status.getReadOnlyProperty();
		}

		public URL getUrl() {
			return url;
		}

		public long getTimeout() {
			return timeout;
		}

		public boolean isResetOnProgress() {
			return resetOnProgress;
		}

		public boolean isTimedout() {
			return timedout.get();
		}

	}

	
}
