package de.faoc.sijadictionary.gui.controls;

import java.net.URL;
import java.util.Timer;
import java.util.TimerTask;

import javafx.beans.property.ReadOnlyBooleanProperty;
import javafx.beans.property.ReadOnlyBooleanWrapper;
import javafx.beans.property.ReadOnlyObjectProperty;
import javafx.beans.property.ReadOnlyObjectWrapper;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.scene.image.Image;

/**
 * An extension of the JavaFX Image class, loading images from a given URL with
 * the additional option so set a timeout for the loading process.
 * 
 * @author Fabian Ochmann
 *
 */
public class URLImage extends Image {

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
		progressProperty().addListener(new ChangeListener<Number>() {
			@Override
			public void changed(ObservableValue<? extends Number> observable, Number oldValue, Number progress) {
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
			}
		});

		errorProperty().addListener(new ChangeListener<Boolean>() {
			@Override
			public void changed(ObservableValue<? extends Boolean> observable, Boolean oldValue, Boolean error) {
				if (error)
					status.set(URLImage.Status.UNSUCCESSFUL);
			}
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
