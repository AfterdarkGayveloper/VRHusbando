extends Panel3D

export (OVRInput.DeviceID) var device_id = OVRInput.LEFT_DEVICE_ID
export (OVRInput.Buttons) var button = OVRInput.TRIGGER_BUTTON

func _input(event):
	if event is InputEventJoypadButton:
		if not event.device == device_id:
			return
		if event.button_index == button and event.pressed:
			set_disabled(visible)

func _on_MainGUI_close_pressed():
	set_disabled(visible)
