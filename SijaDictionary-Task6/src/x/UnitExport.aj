package x;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import de.faoc.sijadictionary.core.database.DataSet;
import de.faoc.sijadictionary.core.database.DatabaseHelper;
import de.faoc.sijadictionary.core.database.DatabaseStatements;
import de.faoc.sijadictionary.core.database.DatabaseTables;
import de.faoc.sijadictionary.core.persistence.Exporter;
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

public privileged aspect UnitExport {
	
	private Button UnitBox.exportButton;
	
	private void UnitBox.exportUnit() {
		if (exportPopupBox == null) {
			exportPopupBox = new VBox(5, new Label("Choose format:"));
			exportPopupBox.getStyleClass().addAll("export-popup-box", "popup-box");
			addExportFormatButtons(exportPopupBox);
			exportPopup.getContent().addAll(exportPopupBox);
		}
		exportPopup.show(getScene().getWindow());
		Bounds boundsInScreen = exportButton.localToScreen(exportButton.getBoundsInLocal());
		exportPopup.setX(boundsInScreen.getMinX());
		exportPopup.setY(boundsInScreen.getMinY());
		exportPopup.show(getScene().getWindow());
	}
	
	private void UnitBox.addExportFormatButtons(VBox exportPopupBox) {
		List<GuiExporter> exporters = getExporters();
		for (GuiExporter exporter : exporters) {
			Button button = new Button(exporter.formatName());
			button.getStyleClass().addAll("export-format-button", "white-button");
			button.setMaxWidth(Double.MAX_VALUE);
			button.setOnAction(new EventHandler<ActionEvent>() {
				@Override
				public void handle(ActionEvent event) {
					exporter.exportToFile(unitId);
				}
			});
			exportPopupBox.getChildren().add(button);
		}
	}
	
	private List<GuiExporter> UnitBox.getExporters(){
		return new ArrayList<>();
	}
	
	after(UnitBox o) : this(o) && execution(void UnitBox.init()){
		o.exportButton = Icons.getIconButton(Icons.EXPORT_IMAGE_PATH, 4);
		o.exportButton.getStyleClass().addAll("export-button", "green-button");
		o.exportButton.setOnAction(event -> {
			o.exportUnit();
		});
		
		o.getChildren().add(2, o.exportButton);
	}
	
	/*
	 * INTEFACE: GuiExporter
	 */
	
	public interface GuiExporter extends Exporter {
		
		public boolean exportToFile(int unitId);
		
		public File getFile();
		
	}
	
	/*
	 * CLASS: BasicGuiExporter
	 */
	
	public abstract class BasicGuiExporter implements GuiExporter {

		Window window;

		private FileChooser fileChooser;

		public BasicGuiExporter(Window window) {
			super();
			this.window = window;

			fileChooser = new FileChooser();
			fileChooser.setTitle("Choose Image");
			fileChooser.setInitialDirectory(new File(System.getProperty("user.home")));
			fileChooser.setInitialFileName("export." + getFileExtension());
		}

		protected abstract String getFileExtension();

		@Override
		public boolean exportToFile(int unitId, File file) {
			DataSet queryResult = DatabaseHelper.query(DatabaseStatements.Query.translation(unitId));
			List<Translation> translations = new ArrayList<>();
			if (!queryResult.isEmpty()) {
				for (HashMap<String, Object> translation : queryResult) {
					int id = (int) translation.get(DatabaseTables.Translation.ID);
					String origin = (String) translation.get(DatabaseTables.Translation.ORIGIN);
					String toTranslation = (String) translation.get(DatabaseTables.Translation.TRANSLATION);
					translations.add(new Translation(id, unitId, origin, toTranslation, null));
				}
			}
			return exportToFile(translations, file);
		}
		
		@Override
		public boolean exportToFile(int unitId) {
			return exportToFile(unitId, getFile());
		}

		@Override
		public boolean exportToFile(List<Translation> translations, File file) {
			if (file == null || translations == null)
				return false;

			if (!file.getParentFile().exists() && !file.getParentFile().mkdirs())
				return false;

			BufferedWriter writer = null;
			try {
				writer = new BufferedWriter(new FileWriter(file));
				for (Translation translation : translations) {
					String formattedTranslation = formatTranslation(translation);
					if (formattedTranslation == null)
						return false;
					writer.write(formattedTranslation);
					writer.newLine();
				}
			} catch (IOException e) {
				return false;
			} finally {
				try {
					if (writer != null)
						writer.close();
				} catch (IOException e) {
				}
			}

			return true;
		}

		protected abstract String formatTranslation(Translation translation);

		@Override
		public File getFile() {
			File file = fileChooser.showSaveDialog(window);
			return file;
		}

		public Window getWindow() {
			return window;
		}

		public FileChooser getFileChooser() {
			return fileChooser;
		}

	}


}
