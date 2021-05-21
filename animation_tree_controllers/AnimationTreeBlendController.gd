extends Node
class_name AnimationTreeBlendController

enum Type { BLEND, ADD, SPACE1D }

const SUFIX = {
	Type.BLEND : "blend_amount",
	Type.ADD : "add_amount",
	Type.SPACE1D : "blend_position"
}

export (NodePath) onready var animation_tree = get_node(animation_tree)
export (Type) var type = Type.BLEND
export (String) onready var param = ("parameters/%s/" % param) + SUFIX[type]

export (float) var speed = 1.2
export (float, 0.0, 1.0) var min_value = 0.0
export (float, 0.0, 1.0) var max_value = 1.0

signal max_reached
signal min_reached

signal max_started
signal min_started

func _ready():
	set_process(false)

func _process(delta):
	animation_tree[param] += speed * delta
	if animation_tree[param] > max_value:
		animation_tree[param] = max_value
		set_process(false)
		emit_signal("max_reached")
	elif animation_tree[param] < min_value:
		animation_tree[param] = min_value
		set_process(false)
		emit_signal("min_reached")

func to_max():
	speed = abs(speed)
	set_process(true)
	emit_signal("max_started")

func to_min():
	speed = -abs(speed)
	set_process(true)
	emit_signal("min_started")

func is_at_max():
	return animation_tree[param] >= max_value

func is_at_min():
	return animation_tree[param] <= min_value

