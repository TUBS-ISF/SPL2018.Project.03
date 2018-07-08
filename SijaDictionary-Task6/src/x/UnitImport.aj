package x;


import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import de.faoc.sijadictionary.core.database.DatabaseHelper;
import de.faoc.sijadictionary.core.database.DatabaseStatements;
import de.faoc.sijadictionary.core.persistence.Importer;
import de.faoc.sijadictionary.core.persistence.Translation;
import de.faoc.sijadictionary.gui.controls.Icons;
import de.faoc.sijadictionary.gui.controls.UnitBox;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Bounds;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;
import javafx.stage.FileChooser;
import javafx.stage.Window;

public privileged aspect UnitImport {
	
	private Button UnitBox.importButton;
	
	private void UnitBox.importUnit(){
		if (importPopupBox == null) {
			importPopupBox = new VBox(5, new Label("Choose format:"));
			importPopupBox.getStyleClass().addAll("import-popup-box", "popup-box");
			addImportFormatButtons(importPopupBox);
			importPopup.getContent().addAll(importPopupBox);
		}
		importPopup.show(getScene().getWindow());
		Bounds boundsInScreen = importButton.localToScreen(importButton.getBoundsInLocal());
		importPopup.setX(boundsInScreen.getMinX());
		importPopup.setY(boundsInScreen.getMinY());
		importPopup.show(getScene().getWindow());
	}
	
	private void UnitBox.addImportFormatButtons(VBox importPopupBox) {
		List<GuiImporter> importers = getImporters();
				//new SimpleFormatGuiImporter(getScene().getWindow()),
				//new CsvGuiImporter(getScene().getWindow())
		for (GuiImporter importer : importers) {
			Button button = new Button(importer.formatName());
			button.getStyleClass().addAll("import-format-button", "white-button");
			button.setMaxWidth(Double.MAX_VALUE);
			button.setOnAction(new EventHandler<ActionEvent>() {
				@Override
				public void handle(ActionEvent event) {
					importer.importFromFile(unitId);
				}
			});
			importPopupBox.getChildren().add(button);
		}
	}
	
	private List<GuiImporter> UnitBox.getImporters(){
		return new ArrayList<>();
	}
	
	after(UnitBox o) : this(o) && execution(void UnitBox.init()){
		o.importButton = Icons.getIconButton(Icons.IMPORT_IMAGE_PATH, 4);
		o.importButton.getStyleClass().addAll("import-button", "green-button");
		o.importButton.setOnAction(event -> {
			o.importUnit();
		});
		
		o.getChildren().add(2, o.importButton);
	}
	
	/*
	 * INTERFACE: GuiImporter
	 */
	
	public static interface GuiImporter extends Importer {
		
		public File getFile();
		
		public boolean importFromFile(int unitId);
		
	}
	
	/*
	 * CLASS: BasicGuiImporter
	 */
	
	public abstract static class BasicGuiImporter implements GuiImporter {

		Window window;

		private FileChooser fileChooser;

		public BasicGuiImporter(Window window) {
			this.window = window;

			fileChooser = new FileChooser();
			fileChooser.setTitle("Choose Image");
			fileChooser.setInitialDirectory(new File(System.getProperty("user.home")));
		}

		@Override
		public boolean importFromFile(int unitId, File file) {
			List<Translation> translations = getFromFile(file);
			if (translations == null)
				return false;

			for (Translation translation : translations) {
				int id = DatabaseHelper.executeInsertSingle(DatabaseStatements.Insert.translation(unitId,
						translation.getOrigin(), translation.getTranslation()));
				if (id == -1)
					return false;
			}

			return true;
		}
		
		@Override
		public boolean importFromFile(int unitId) {
			return importFromFile(unitId, getFile());
		}

		@Override
		public List<Translation> getFromFile(File file) {
			if (file == null)
				return null;

			List<Translation> translations = parseFile(file);

			return translations;
		}

		protected abstract List<Translation> parseFile(File file);

		@Override
		public File getFile() {
			File file = fileChooser.showOpenDialog(window);
			return file;
		}

	}

}
