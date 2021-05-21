extends PanelContainer

export (String) var text = ""

onready var label = $MarginContainer/VBoxContainer/PanelContainer/Label

signal confirmed
signal canceled

func _ready():
	label.text = text

func _on_OkButton_pressed():
	emit_signal("confirmed")
	hide()

func _on_CancelButton_pressed():
	emit_signal("canceled")
	hide()
