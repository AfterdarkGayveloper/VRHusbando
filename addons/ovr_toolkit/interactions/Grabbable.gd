extends RigidBody
class_name Grabbable

export (Vector3) var center_offset = Vector3.ZERO

onready var original_parent = get_parent()
onready var original_mode = mode

signal grabbed
signal released

var on_grabbed_state = false

func grab(new_parent : Node) -> void:
	on_grabbed_state = true
	mode = RigidBody.MODE_KINEMATIC
	_change_parent(new_parent)

	emit_signal("grabbed")

func release() -> void:
	on_grabbed_state = false
	_change_parent(original_parent)
	mode = original_mode
	sleeping = false

	emit_signal("released")

func grabber_entered() -> void:
	pass

func grabber_left() -> void:
	pass

func set_as_closest() -> void:
	pass

func unset_as_closest() -> void:
	pass

func _change_parent(new_parent):
	var original_transform : Transform = global_transform
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_transform = original_transform

func get_center():
	global_transform.origin + center_offset
