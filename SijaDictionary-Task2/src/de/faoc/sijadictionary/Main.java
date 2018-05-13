package de.faoc.sijadictionary;

import de.faoc.sijadictionary.core.database.DatabaseHelper;
import de.faoc.sijadictionary.gui.GuiApplication;
import de.faoc.sijadictionary.gui.displays.MainDisplay;
import javafx.application.Application;
import properties.PropertyManager;

public class Main {

	private static boolean lectionMode;
	private static boolean changeLanguageMode;

	/*
	 * Make sure to delete /db/sijadictionary.db to clear the db after changing the
	 * config / changing the runtime.properties
	 */
	public static void main(String[] args) {
		lectionMode = PropertyManager.getProperty("Lections");
		changeLanguageMode = PropertyManager.getProperty("ChangeLanguage");

		DatabaseHelper.initDatabase();
		Application.launch(GuiApplication.class, args);

	}

	public static boolean isLectionMode() {
		return lectionMode;
	}

	public static boolean isChangeLanguageMode() {
		return changeLanguageMode;
	}
}
