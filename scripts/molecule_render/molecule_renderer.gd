@tool
class_name MoleculeRenderer
extends Node3D

@export var resonance_structure: ResonanceStructure:
	set(value):
		resonance_structure = value
		user_resonance_structure = null
@export var molecule_data: MoleculeData
@export var meshes: Array[MeshBuilder.MeshType]
@export var mesh_config: MeshBuilderConfig

## Resonance structure editable by player 
var user_resonance_structure: ResonanceStructure

const MIN_ATOM_CHARGE := -1
const MAX_ATOM_CHARGE := 1

@export_tool_button("Reload Molecule")
var reload_molecule_action: Callable = render

func _ready() -> void:
	if not Engine.is_editor_hint():
		get_viewport().physics_object_picking = true

func render() -> void:
	_ensure_user_resonance_structure()

	var expected_names: Dictionary = {}
	for mesh_type in meshes:
		_rebuild_mesh(mesh_type)
		expected_names[MeshBuilder.MeshType.keys()[mesh_type] + "_Meshes"] = true

	for child in get_children():
		if child.name.ends_with("_Meshes") and not expected_names.has(child.name):
			remove_child(child)
			child.queue_free()

## Rebuilds a single mesh layer in place, leaving the others (and their colliders) untouched.
func _rebuild_mesh(mesh_type: MeshBuilder.MeshType) -> void:
	var node_name = MeshBuilder.MeshType.keys()[mesh_type] + "_Meshes"
	var existing = get_node_or_null(NodePath(node_name))
	if existing:
		remove_child(existing)
		existing.queue_free()

	var container = MeshBuilder.build(mesh_type, molecule_data, user_resonance_structure, mesh_config)
	if container == null:
		return

	container.name = node_name
	add_child(container)
	if Engine.is_editor_hint():
		_set_owner_recursive(container, get_tree().edited_scene_root)
	if mesh_type == MeshBuilder.MeshType.ATOM:
		_connect_atom_pickables(container)

func _ensure_user_resonance_structure() -> void:
	if resonance_structure == null:
		user_resonance_structure = null
	elif user_resonance_structure == null:
		user_resonance_structure = resonance_structure.duplicate()

func _connect_atom_pickables(atom_meshes: Node3D) -> void:
	for atom_node in atom_meshes.get_children():
		if atom_node is AtomPickable:
			atom_node.atom_clicked.connect(_on_atom_clicked)

func _on_atom_clicked(pickable: AtomPickable) -> void:
	if user_resonance_structure == null:
		return
	var charges = user_resonance_structure.charges
	charges[pickable.atom_index] = wrapi(charges[pickable.atom_index] + 1, MIN_ATOM_CHARGE, MAX_ATOM_CHARGE + 1)
	user_resonance_structure.charges = charges
	if MeshBuilder.MeshType.CHARGE in meshes:
		_rebuild_mesh(MeshBuilder.MeshType.CHARGE)


func _set_owner_recursive(node: Node, scene_owner: Node) -> void:
	if node != scene_owner:
		node.owner = scene_owner
	for child in node.get_children():
		_set_owner_recursive(child, scene_owner)
