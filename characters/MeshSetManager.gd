extends Node

export (Array, NodePath) onready var mesh_path
export (NodePath) onready var penis = get_node(penis)

var mesh_arr : Array = []

func _ready():
	for path in mesh_path:
		var mesh = get_node(path)
		mesh_arr.append(mesh)

	update_penis_physics()

	UIEvents.connect("clothes_changed", self, "_on_clothes_changed")

	UIEvents.update_clothes_list(mesh_arr)

func _on_clothes_changed(index, toggled):
	mesh_arr[index].toggle_visibility(toggled)
	update_penis_physics()

func update_penis_physics():
	var is_penis_enabled = true
	for mesh in mesh_arr:
		if mesh.visible and not mesh.has_penis:
			is_penis_enabled = false
			break
	penis.visible = is_penis_enabled
	penis.set_physics_disabled(not is_penis_enabled)
