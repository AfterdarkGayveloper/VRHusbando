extends Node

export (float) var deadzone = 0.1
export (OVRInput.Axis) var axis = OVRInput.HORIZONTAL_AXIS
export (OVRInput.DeviceID) var device = OVRInput.LEFT_DEVICE_ID

var is_allowed = true

signal pressed(is_positive)

func _input(event):
	if event is InputEventJoypadMotion:
		if not event.device == device:
			return
		if not event.axis == axis:
			return

		if event.axis_value == 0:
			is_allowed = true
		elif is_allowed:
			if abs(event.axis_value) >= deadzone:
				is_allowed = false
				emit_signal("pressed", event.axis_value > 0)

