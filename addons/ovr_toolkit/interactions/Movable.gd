extends Node

export (NodePath) onready var gui_pointer = get_node(gui_pointer)
export (NodePath) onready var arvr_controller = get_node(arvr_controller)
export (NodePath) onready var target = get_node(target)

onready var default_scale = target.scale
onready var default_origin = target.global_transform.origin

var offset : Vector3 = Vector3.ZERO
var rotation_delta : float = 0.0
var turn_speed : float = 1.0
var moving_xz : bool = false
var moving_y : bool = false
var scale_step : int = 3

func _input(event):
	if not arvr_controller.get_child(0).visible:
		return
	if event is InputEventJoypadButton:
		if not event.device == OVRInput.RIGHT_DEVICE_ID:
			return
		if event.button_index == OVRInput.GRIP_BUTTON:
			offset = target.global_transform.origin - arvr_controller.global_transform.origin
			moving_xz = event.pressed
		if event.button_index == OVRInput.TRIGGER_BUTTON:
			offset = target.global_transform.origin - arvr_controller.global_transform.origin
			moving_y = event.pressed

	elif event is InputEventJoypadMotion:
		if gui_pointer.is_colliding():
			return
		if event.device == OVRInput.RIGHT_DEVICE_ID and event.axis == OVRInput.HORIZONTAL_AXIS:
			rotation_delta = event.axis_value

func _process(delta):
	if not rotation_delta == 0:
		target.rotate(Vector3.UP, rotation_delta * turn_speed * delta)

	if moving_xz:
		target.global_transform.origin = ((arvr_controller.global_transform.origin + offset) * Vector3(1, 0, 1)) + (target.global_transform.origin * Vector3(0, 1, 0))
	if moving_y and not gui_pointer.is_colliding():
		target.global_transform.origin = ((arvr_controller.global_transform.origin + offset) * Vector3(0, 1, 0)) + (target.global_transform.origin * Vector3(1, 0, 1))
