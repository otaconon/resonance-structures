extends Node3D

@onready var molecule_picker = $MoleculePicker
@onready var molecule_renderer = $MoleculeRenderer
@onready var camera = $Camera3D

var molecules: Array[MoleculeData]

func _ready() -> void:
	camera.current = true
	_load_molecules()
	molecule_picker.molecules = molecules
	molecule_picker.molecule_selected.connect(_on_molecule_selected)

func _on_molecule_selected(molecule: MoleculeData):
	molecule_renderer.molecule_data = molecule
	molecule_renderer.render()

func _load_molecules() -> void:
	if not ResourceLoader.exists(ConfigPaths.MOLECULE_PICKER_CONFIG_PATH):
		print("WARNING: No molecule picker config found")
		return

	var config := ResourceLoader.load(ConfigPaths.MOLECULE_PICKER_CONFIG_PATH, "MoleculePickerConfig") as MoleculePickerConfig
	if config == null:
		print("WARNING: Failed to load molecule picker config")
		return

	var molecule_paths = _scan_for_molecules(config.molecule_folder)
	for mol_path in molecule_paths:
		molecules.append(load(mol_path))

func _scan_for_molecules(dir_path: String) -> Array[String]:
	var molecule_paths: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		print("WARNING: No molecules at ", dir_path)
		return molecule_paths
	for f in dir.get_files():
		if f.get_extension() == "sdf":
			molecule_paths.append(dir_path.path_join(f))
	return molecule_paths
