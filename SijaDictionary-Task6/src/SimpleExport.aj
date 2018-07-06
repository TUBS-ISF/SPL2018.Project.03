import java.util.List;

import de.faoc.sijadictionary.core.persistence.Translation;
import de.faoc.sijadictionary.gui.controls.UnitBox;
import javafx.stage.Window;
import x.UnitExport;
import x.UnitExport.BasicGuiExporter;
import x.UnitExport.GuiExporter;

public privileged aspect SimpleExport {
	
	List<GuiExporter> around(UnitBox o) : this(o) && execution(List<GuiExporter> UnitBox.getExporters()){
		List<GuiExporter> exporters = proceed(o);
		Window window = o.getScene().getWindow();
		exporters.add(new SimpleFormatGuiExporter(UnitExport.aspectOf(), window));
		return exporters;
	}
	
	/*
	 * CLASS: SimpleFormatGuiExporter
	 */
	
	public class SimpleFormatGuiExporter extends BasicGuiExporter {


		public SimpleFormatGuiExporter(UnitExport unitExport, Window window) {
			unitExport.super(window);
		}

		@Override
		public String formatName() {
			return "Simple Format";
		}

		@Override
		protected String formatTranslation(Translation translation) {
			if(translation == null) return null;
			
			return String.format("%s;;%s", translation.getOrigin(), translation.getTranslation());
		}

		@Override
		protected String getFileExtension() {
			return "sija";
		}

	}

}
