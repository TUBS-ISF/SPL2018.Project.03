
import de.faoc.sijadictionary.gui.controls.Icons;
import javafx.geometry.Bounds;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.HBox;
import javafx.scene.layout.StackPane;
import javafx.stage.Popup;
import x.AddPictures.TranslationImageStack;

privileged public aspect EnterURL {
	
	private Button TranslationImageStack.urlButton;
	private Popup TranslationImageStack.urlPopup;
	private TextField TranslationImageStack.urlTextField;
	
	after(TranslationImageStack o) : this(o) && execution( void TranslationImageStack.init()){
		o.urlTextField = new TextField();
		o.urlTextField.setPromptText("Enter URL");
		o.urlTextField.setOnAction(event -> {
			if (!o.urlTextField.getText().isEmpty())
				o.translationButton.loadImageFromUrl(o.urlTextField.getText());
			o.urlPopup.hide();
		});

		Label urlLabel = new Label("Enter URL:");

		HBox popupBox = new HBox(5, urlLabel, o.urlTextField);
		popupBox.setAlignment(Pos.CENTER_LEFT);
		popupBox.getStyleClass().addAll("popup-box");

		o.urlPopup = new Popup();
		o.urlPopup.setAutoHide(true);
		o.urlPopup.setAutoFix(true);
		o.urlPopup.getContent().addAll(popupBox);

		o.urlButton = Icons.getIconButton(Icons.LINK_IMAGE_PATH, 2);
		o.urlButton.getStyleClass().addAll("translation-image-url-button", "blue-button", "round");
		StackPane.setAlignment(o.urlButton, Pos.TOP_LEFT);
		o.urlButton.setOnAction(event -> {
			o.showUrlPopup();
		});
		
		o.getChildren().add(o.urlButton);
	}
	
	private void TranslationImageStack.showUrlPopup() {
		urlTextField.clear();

		Bounds boundsInScreen = urlButton.localToScreen(urlButton.getBoundsInLocal());
		urlPopup.setX(boundsInScreen.getMinX());
		urlPopup.setY(boundsInScreen.getMinY());
		urlPopup.show(getScene().getWindow());

		urlTextField.selectHome();
	}


}
