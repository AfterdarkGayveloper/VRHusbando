extends StaticBody
class_name Panel3D

export (bool) var propagate_joypad_event = false
export (bool) var disabled = false

onready var collision_shape : CollisionShape = $CollisionShape
onready var viewport : Viewport = $Viewport
onready var pointer : Control = $Viewport/Pointer
var viewport_point : Vector2
onready var _original_collision_layer : int = collision_layer

var _scroll_direction : int

func set_disabled(is_disabled):
	collision_shape.disabled = is_disabled
	visible = not is_disabled


func pointer_hide() -> void:
	pointer.rect_position = Vector2(-10,10)
	_release_focus()

func pointer_motion(collision_point : Vector3) -> void:
	if global_transform.xform_inv(global_transform.origin).z < 0:
		return

	# Convert the collision to a relative position
	var shape_size = collision_shape.shape.extents * 2
	var collider_scale = global_transform.basis.get_scale()
	var local_point = global_transform.xform_inv(collision_point)
	local_point /= (collider_scale * collider_scale)
	local_point /= shape_size
	# X is about 0 to 1, Y is about 0 to -1.
	local_point += Vector3(0.5, -0.5, 0)

	# Find the viewport position by scaling the relative position by the viewport size. Discard Z.
	viewport_point = Vector2(local_point.x, -local_point.y) * viewport.size
	pointer.rect_position = viewport_point - (pointer.rect_size / 2)

	var motion_event = InputEventMouseMotion.new()
	motion_event.position = viewport_point
	viewport.input(motion_event)

func pointer_click() -> void:
	var is_pressed = true
	_mouse_button_event(is_pressed, BUTTON_LEFT)

func pointer_release() -> void:
	var is_pressed = false
	_mouse_button_event(is_pressed, BUTTON_LEFT)

func scroll_pressed(scroll_direction : int) -> void:
	if not _scroll_direction == scroll_direction:
		scroll_release()
		_scroll_direction = scroll_direction

	var is_pressed = true
	_mouse_button_event(is_pressed, _scroll_direction)

func scroll_release() -> void:
	if not _scroll_direction:
		return

	var is_pressed = false
	_mouse_button_event(is_pressed, _scroll_direction)

func _ready():
	set_disabled(disabled)

func _input(event):
	if not propagate_joypad_event:
		return
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		viewport.input(event)

func _mouse_button_event(is_pressed : bool, button_index : int) -> void:
	var event = InputEventMouseButton.new()
	event.pressed = is_pressed
	event.button_index = button_index
	event.position = viewport_point
	viewport.input(event)

func _release_focus() -> void:
	if pointer.get_focus_owner():
		pointer.get_focus_owner().release_focus()

