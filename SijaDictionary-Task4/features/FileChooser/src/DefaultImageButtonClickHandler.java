import java.io.File;

import de.faoc.sijadictionary.gui.controls.image.ImageButtonClickHandler;
import javafx.stage.FileChooser;

public class DefaultImageButtonClickHandler implements ImageButtonClickHandler {

	private FileChooser fileChooser;

	@Override
	public File openFile() {
		if (fileChooser == null) {
			fileChooser = new FileChooser();
			fileChooser.setTitle("Choose Image");
			fileChooser.setInitialDirectory(new File(System.getProperty("user.home")));
			fileChooser.getExtensionFilters().addAll(new FileChooser.ExtensionFilter("All Images", "*.*"),
					new FileChooser.ExtensionFilter("JPG", "*.jpg"), new FileChooser.ExtensionFilter("PNG", "*.png"));
		}
		fileChooser.setInitialDirectory(new File(System.getProperty("user.home")));
		File file = fileChooser.showOpenDialog(null);
		return file;
	}

}
