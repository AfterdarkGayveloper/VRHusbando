extends Spatial
class_name MeshSet

export (String) var mesh_name
export (NodePath) var default_mesh_path
export (bool) var has_penis = true
export (Array, NodePath) var exception_mesh

onready var groups = get_groups()

func toggle_visibility(is_visibled):
	if not groups.empty():
		hide_group()
	visible = is_visibled
	if not visible and not default_mesh_path.is_empty():
		var default_mesh = get_node(default_mesh_path)
		default_mesh.show()

func hide_group():
	var group_name = groups.back()
	var nodes_in_group = get_tree().get_nodes_in_group(group_name)
	for node in nodes_in_group:
		if node.get_parent() == get_parent():
			node.hide()

	for exception_path in exception_mesh:
		get_node(exception_path).hide()

