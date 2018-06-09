import de.faoc.sijadictionary.gui.controls.Icons;
import de.faoc.sijadictionary.gui.controls.TranslationImageButton;
import de.faoc.sijadictionary.gui.controls.image.ImportImageButton;
import javafx.geometry.Bounds;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.HBox;
import javafx.scene.layout.StackPane;
import javafx.stage.Popup;

public class UrlImageImportButton implements ImportImageButton {

	@Override
	public Pos getPosition() {
		return Pos.TOP_LEFT;
	}

	private void showUrlPopup(TextField urlTextField, Button urlButton, Popup urlPopup) {
		urlTextField.clear();

		Bounds boundsInScreen = urlButton.localToScreen(urlButton.getBoundsInLocal());
		urlPopup.setX(boundsInScreen.getMinX());
		urlPopup.setY(boundsInScreen.getMinY());
		urlPopup.show(urlButton.getScene().getWindow());

		urlTextField.selectHome();
	}

	@Override
	public Button getButton(TranslationImageButton target) {
		TextField urlTextField = new TextField();
		urlTextField.setPromptText("Enter URL");
		
		Popup urlPopup = new Popup();
		urlPopup.setAutoHide(true);
		urlPopup.setAutoFix(true);
		
		urlTextField.setOnAction(event -> {
			if (!urlTextField.getText().isEmpty())
				target.loadImageFromUrl(urlTextField.getText());
			urlPopup.hide();
		});

		Label urlLabel = new Label("Enter URL:");

		HBox popupBox = new HBox(5, urlLabel, urlTextField);
		popupBox.setAlignment(Pos.CENTER_LEFT);
		popupBox.getStyleClass().addAll("popup-box");

		urlPopup.getContent().addAll(popupBox);

		Button urlButton = Icons.getIconButton(Icons.LINK_IMAGE_PATH, 2);
		urlButton.getStyleClass().addAll("translation-image-url-button", "blue-button", "round");
		urlButton.setOnAction(event -> {
			showUrlPopup(urlTextField, urlButton, urlPopup);
		});
		
		return urlButton;
	}
}
