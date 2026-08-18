extends Control

@onready var dialog: FileDialog = $FileDialog

signal back_requested

const CONFIG_PATH := ConfigPaths.MOLECULE_PICKER_CONFIG_PATH

var molecule_picker_config: MoleculePickerConfig

func _ready() -> void:
	_load_config()

	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.current_dir = molecule_picker_config.molecule_folder
	dialog.dir_selected.connect(_on_dir_selected)


func _on_dir_selected(dir: String) -> void:
	molecule_picker_config.molecule_folder = dir
	var err := ResourceSaver.save(molecule_picker_config, CONFIG_PATH)
	if err != OK:
		push_error("Failed to save config: %d" % err)


func _on_back_button_pressed() -> void:
	back_requested.emit()


func _on_select_molecule_folder_button_pressed() -> void:
	dialog.visible = true	

func _load_config() -> void:
	if ResourceLoader.exists(CONFIG_PATH):
		var loaded := ResourceLoader.load(CONFIG_PATH, "MoleculePickerConfig", ResourceLoader.CACHE_MODE_REPLACE)
		if loaded is MoleculePickerConfig:
			molecule_picker_config = loaded
			return

	molecule_picker_config = MoleculePickerConfig.new()
	var err := ResourceSaver.save(molecule_picker_config, CONFIG_PATH)
	if err != OK:
		push_error("Failed to save config: %d" % err)
