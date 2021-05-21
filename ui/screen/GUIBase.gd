extends PanelContainer
class_name GUIBase

signal back_pressed
signal close_pressed

func _on_BackButton_pressed():
	hide()
	emit_signal("back_pressed")


func _on_CloseButton_pressed():
	emit_signal("close_pressed")
