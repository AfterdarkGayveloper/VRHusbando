extends RayCast
class_name GUIRayCast

export (OVRInput.DeviceID) var device_id : int = OVRInput.RIGHT_DEVICE_ID
export (OVRInput.Buttons) var button : int = OVRInput.TRIGGER_BUTTON
onready var scroll_rate_timer = $ScrollRateTimer

var panel3d : Panel3D = null
var is_pointing : bool = false
var scroll_direction : int = BUTTON_WHEEL_UP

signal point_started
signal point_stopped

func _process(_delta : float) -> void:
	if is_colliding():
		var raycast_collider = get_collider()
		if raycast_collider is Panel3D:
			panel3d = (raycast_collider as Panel3D)
			var collision_point : Vector3 = get_collision_point()
			panel3d.pointer_motion(collision_point)
			if not is_pointing:
				is_pointing = true
				emit_signal("point_started")
			return
	if panel3d:
		scroll_rate_timer.stop()
		panel3d.scroll_release()
		panel3d.pointer_release()
		panel3d.pointer_hide()
		panel3d = null

		is_pointing = false
		emit_signal("point_stopped")

func _input(event) -> void:
	if not panel3d:
		return
	if not event.device == device_id:
		return

	if event is InputEventJoypadButton:
		if event.button_index == button:
			if event.pressed:
				button_pressed()
			else:
				button_released()
	if event is InputEventJoypadMotion:
		if event.axis == OVRInput.VERTICAL_AXIS:
			scroll_direction = BUTTON_WHEEL_UP if event.axis_value > 0 else BUTTON_WHEEL_DOWN
			if event.axis_value == 0.0:
				scroll_released()
				scroll_rate_timer.stop()
			elif scroll_rate_timer.is_stopped():
				scroll_rate_timer.start()

func button_pressed() -> void:
	if not panel3d:
		return
	panel3d.pointer_click()

func button_released() -> void:
	if not panel3d:
		return
	panel3d.pointer_release()

func scroll_pressed(direction : int) -> void:
	if not panel3d:
		return
	panel3d.scroll_pressed(direction)

func scroll_released() -> void:
	if not panel3d:
		return
	panel3d.scroll_release()

func _on_ScrollRateTimer_timeout():
	if not panel3d:
		scroll_rate_timer.stop()
		return
	scroll_pressed(scroll_direction)
