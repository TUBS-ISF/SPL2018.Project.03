import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import de.faoc.sijadictionary.gui.GuiApplicationController;
import de.faoc.sijadictionary.gui.controls.HeaderBar;
import de.faoc.sijadictionary.gui.controls.Icons;
import javafx.scene.control.Button;
import javafx.stage.FileChooser;
import javafx.stage.Window;

privileged public aspect FullImport {
	
	private Button HeaderBar.importButton;
	
	private void HeaderBar.importClicked() {
	    FullImporter.importData(getScene().getWindow());
	    GuiApplicationController.getInstance().setMainDisplay();
	}
	
	after(HeaderBar o) : this(o) && execution( void HeaderBar.init()){
		o.importButton = Icons.getIconButton(Icons.IMPORT_IMAGE_PATH, 4);
		o.importButton.getStyleClass().addAll("import-button", "green-button");
		o.importButton.setOnAction(event -> {
			o.importClicked();
		});
		
		o.getChildren().add(2, o.importButton);
	}
	
	static class FullImporter {

	    private static final String IMG_DIR = "img/";
	    private static final String DB_DIR = "db/";

	    private static FileChooser fileChooser;

	    private static FileChooser getFileChooser() {
	        if (fileChooser == null) {
	            fileChooser = new FileChooser();
	            fileChooser.setTitle("Choose import File");
	            fileChooser.setInitialDirectory(new File(System.getProperty("user.home")));
	            FileChooser.ExtensionFilter extFilter = new FileChooser.ExtensionFilter("ZIP Archive (*.zip)", "*.zip");
	            fileChooser.getExtensionFilters().add(extFilter);
	        }
	        return fileChooser;
	    }

	    public static boolean importData(Window window) {
	        File selectedFile = getFileChooser().showOpenDialog(window);
	        if (selectedFile != null && selectedFile.exists()) {
	            byte[] buffer = new byte[1024];
	            ZipInputStream zis = null;
	            try {
	                zis = new ZipInputStream(new FileInputStream(selectedFile));
	                ZipEntry zipEntry;
	                while ((zipEntry = zis.getNextEntry()) != null) {
	                    File newFile = new File(zipEntry.getName());

	                    if (zipEntry.isDirectory() && !newFile.exists())
	                        Files.createDirectories(Paths.get(newFile.getPath()));
	                    else if (!zipEntry.isDirectory()) {
	                        if (newFile.getParentFile() != null && !newFile.getParentFile().exists())
	                            Files.createDirectories(Paths.get(newFile.getParentFile().getPath()));
	                        //Write file
	                        FileOutputStream fos = null;
	                        try {
	                            fos = new FileOutputStream(newFile, false);
	                            int len;
	                            while ((len = zis.read(buffer)) > 0) {
	                                fos.write(buffer, 0, len);
	                            }
	                            fos.close();
	                        } finally {
	                            if (fos != null)
	                                fos.close();
	                        }
	                    }
	                    zis.closeEntry();
	                    
	                }
	                return true;
	            } catch (IOException e) {
	                e.printStackTrace();
	            } finally {
	                if (zis != null)
	                    try {
	                        zis.close();
	                    } catch (IOException e) {
	                    }
	            }

	        }
	        return false;
	    }

	}
}
