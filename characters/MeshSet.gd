extends Spatial
class_name MeshSet

export (String) var mesh_name
export (NodePath) var default_mesh_path
export (bool) var has_penis = true
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
		node.hide()

