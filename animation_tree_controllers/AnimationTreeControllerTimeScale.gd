extends Node

export (NodePath) onready var animation_tree = get_node(animation_tree)
export (String) onready var param = "parameters/%s/scale" % param

onready var default_scale = animation_tree[param]

var scale setget _set_scale, _get_scale


func _set_scale(scale : float):
	animation_tree[param] = scale

func _get_scale() -> float:
	return animation_tree[param]

func reset():
	animation_tree[param] = default_scale
