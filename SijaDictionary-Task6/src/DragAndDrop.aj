

import javafx.css.PseudoClass;
import javafx.event.EventHandler;
import javafx.scene.input.DragEvent;
import javafx.scene.input.TransferMode;
import x.AddPictures.TranslationImageButton;

privileged public aspect DragAndDrop {
	
	after(TranslationImageButton o) : this(o) && execution(void TranslationImageButton.init()){
		if(!o.previewMode) {
			o.initDragAndDrop();
		}
	}
	
	private void TranslationImageButton.initDragAndDrop() {
		// Set Drop from File
		setOnDragOver(new EventHandler<DragEvent>() {
			@Override
			public void handle(DragEvent event) {
				if (event.getGestureSource() != this && isValidDragData(event)) {
					event.acceptTransferModes(TransferMode.COPY_OR_MOVE);
				}
			}
		});
		setOnDragEntered(new EventHandler<DragEvent>() {
			@Override
			public void handle(DragEvent event) {
				if (event.getGestureSource() != this && isValidDragData(event)) {
					pseudoClassStateChanged(PseudoClass.getPseudoClass("drag"), true);
				}
				event.consume();
			}
		});
		setOnDragExited(new EventHandler<DragEvent>() {
			@Override
			public void handle(DragEvent event) {
				pseudoClassStateChanged(PseudoClass.getPseudoClass("drag"), false);
				event.consume();
			}
		});
		setOnDragDropped(new EventHandler<DragEvent>() {
			@Override
			public void handle(DragEvent event) {
				processDraggedImage(event);
			}
		});
	}
	
	private boolean TranslationImageButton.processDraggedImage(DragEvent event) {
		return false;
	}
	
	private boolean TranslationImageButton.isValidDragData(DragEvent event) {
		return false;
	}
}
