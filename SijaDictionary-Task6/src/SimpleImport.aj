

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;

import de.faoc.sijadictionary.core.persistence.Translation;
import de.faoc.sijadictionary.gui.controls.UnitBox;
import javafx.stage.Window;
import x.UnitImport;
import x.UnitImport.BasicGuiImporter;
import x.UnitImport.GuiImporter;

public privileged aspect SimpleImport {
	
	List<GuiImporter> around(UnitBox o) : this(o) && execution(List<GuiImporter> UnitBox.getImporters()){
		List<GuiImporter> importers = proceed(o);
		Window window = o.getScene().getWindow();
		importers.add(new SimpleFormatGuiImporter(UnitImport.aspectOf(), window));
		return importers;
	}
	
	public class SimpleFormatGuiImporter extends BasicGuiImporter {
		
		public SimpleFormatGuiImporter(UnitImport unitImport, Window window) {
			unitImport.super(window);
		}

		@Override
		protected List<Translation> parseFile(File file) {
			List<Translation> translations = new ArrayList<>();
			try {
				Files.lines(file.toPath()).forEach(line -> {
					String[] splittedLine = line.split(";;");
					if (splittedLine.length != 2)
						translations.add(null);
					else
						translations.add(new Translation(-1, -1, splittedLine[0], splittedLine[1], null));
				});
			} catch (IOException e) {
				return null;
			}
			
			if(translations.contains(null)) return null;
			return translations;
		}

		@Override
		public String formatName() {
			return "Simple Format";
		}

	}


}
