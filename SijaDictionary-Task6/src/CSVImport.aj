

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import de.faoc.sijadictionary.core.persistence.Translation;
import de.faoc.sijadictionary.gui.controls.UnitBox;
import javafx.stage.Window;
import x.UnitImport;
import x.UnitImport.BasicGuiImporter;
import x.UnitImport.GuiImporter;

public privileged aspect CSVImport{
	
	List<GuiImporter> around(UnitBox o) : this(o) && execution(List<GuiImporter> UnitBox.getImporters()){
		List<GuiImporter> importers = proceed(o);
		Window window = o.getScene().getWindow();
		importers.add(new CsvGuiImporter(UnitImport.aspectOf(), window));
		return importers;
	}
	
	public class CsvGuiImporter extends BasicGuiImporter {
		
		public CsvGuiImporter(UnitImport unitImport, Window window) {
			unitImport.super(window);
		}

		private final Pattern CSV_LINE_PATTERN = Pattern.compile("^\"(.*?)\"\\s*,\\s*\"(.*?)\"$");

		@Override
		public String formatName() {
			return "CSV";
		}

		@Override
		protected List<Translation> parseFile(File file) {
			List<Translation> translations = new ArrayList<>();
			try {
				Files.lines(file.toPath()).forEach(line -> {
					Matcher matcher = CSV_LINE_PATTERN.matcher(line);
					if(matcher.find() && matcher.groupCount() == 2) {
						translations.add(new Translation(-1, -1, matcher.group(1), matcher.group(2), null));
					} else {
						translations.add(null);
					}
				});
			} catch (IOException e) {
				return null;
			}
			
			if(translations.contains(null)) return null;
			return translations;
		}

	}

}
