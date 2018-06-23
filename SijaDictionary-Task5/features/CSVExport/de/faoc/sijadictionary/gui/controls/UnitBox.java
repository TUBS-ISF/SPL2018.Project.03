package de.faoc.sijadictionary.gui.controls;

import java.util.Arrays;
import java.util.List;

import de.faoc.sijadictionary.core.database.DatabaseHelper;
import de.faoc.sijadictionary.core.database.DatabaseStatements;
import de.faoc.sijadictionary.gui.GuiApplicationController;
import de.faoc.sijadictionary.gui.displays.UnitDisplay;
import de.faoc.sijadictionary.gui.displays.VocabDisplay;
import de.faoc.sijadictionary.gui.util.exporter.CsvGuiExporter;
import de.faoc.sijadictionary.gui.util.exporter.GuiExporter;
import de.faoc.sijadictionary.gui.util.exporter.SimpleFormatGuiExporter;
import de.faoc.sijadictionary.gui.util.importer.CsvGuiImporter;
import de.faoc.sijadictionary.gui.util.importer.GuiImporter;
import de.faoc.sijadictionary.gui.util.importer.SimpleFormatGuiImporter;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Bounds;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Popup;
import javafx.stage.Window;

public class UnitBox extends HBox {
	
	private GuiExporter[] getExporters() {
		GuiExporter[] origImp = original();
		GuiExporter[] newImp = new GuiExporter[origImp.length + 1];
		System.arraycopy(origImp, 0, newImp, 0, origImp.length);
		Window window = (getScene() == null) ? null : getScene().getWindow();
		newImp[newImp.length - 1] = new CsvGuiExporter(window);
		return newImp;
	}
}
