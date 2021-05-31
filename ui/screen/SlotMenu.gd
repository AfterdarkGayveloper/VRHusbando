extends GUIBase

signal slot_toggled(is_right, is_toggled)

func _on_RightSlotButton_toggled(button_pressed):
	var is_right = true
	emit_signal("slot_toggled", is_right, button_pressed)


func _on_LeftSlotButton_toggled(button_pressed):
	var is_right = false
	emit_signal("slot_toggled", is_right, button_pressed)
