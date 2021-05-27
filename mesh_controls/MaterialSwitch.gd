extends MeshSet

export (Material) var show_material
export (Material) var hide_material
export (Array, NodePath) var mesh_path
export (int) var material_index = 0

var mesh_arr : Array = []

func _ready():
	for path in mesh_path:
		mesh_arr.append(get_node(path))

	set_material(show_material if visible else hide_material)

func toggle_visibility(is_visibled):
	.toggle_visibility(is_visibled)
	set_material(show_material if visible else hide_material)

func set_material(material : Material) -> void:
	for mesh in mesh_arr:
		(mesh as MeshInstance).set_surface_material(material_index, material)
