@tool
extends MeshInstance3D

@export_global_file("*.sdf") var molecule_data_path: String

@export var reload_molecule: bool = false:
	set(value):
		if value == true:
			print("set value")
			load_and_render()
		reload_molecule = false

func load_and_render():
	print("Start load and render")
	var molecule = SDFParser.load_sdf(molecule_data_path)
	print("Loaded sdf")
	render_molecule_sdf(molecule)

func render_molecule_sdf(molecule: MoleculeData) -> void:
	print("Start rendering molecule")
	var atom_count = molecule.atom_positions.size()
	if atom_count == 0:
		print("Warning: tried to render molecule with atom_count=0")
		return

	var image = Image.create(atom_count, 2, false, Image.FORMAT_RGBAF)

	var min_bounds = Vector3(INF, INF, INF)
	var max_bounds = Vector3(-INF, -INF, -INF)

	for atom_idx in range(atom_count):
		var pos = molecule.atom_positions[atom_idx]
		var element_data = ElementsDB.elements_data[molecule.atom_elements[atom_idx]]
		var radius = element_data["radius"]
		var color = element_data["color"].srgb_to_linear()
		print("Color: " + color.to_html())
		image.set_pixel(atom_idx, 0, Color(pos.x, pos.y, pos.z, radius))
		image.set_pixel(atom_idx, 1, color)

		min_bounds = min_bounds.min(pos - Vector3(radius, radius, radius))
		max_bounds = max_bounds.max(pos + Vector3(radius, radius, radius))

	var padding = Vector3(2, 2, 2)
	var size = max_bounds - min_bounds + padding
	var center = min_bounds + (max_bounds - min_bounds) / 2

	mesh.size = size
	position = center

	var texture = ImageTexture.create_from_image(image)
	var mat = get_surface_override_material(0)

	mat.set_shader_parameter("atom_data", texture)
	mat.set_shader_parameter("atom_count", atom_count)

	print("Rendering molecule")
