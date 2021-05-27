extends GUIBase

onready var container = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

var buttons : Dictionary = {}

signal misc_selected(key, is_toggled)

func update_misc_list(misc_list):
	buttons.clear()
	for child in container.get_children():
		child.queue_free()

	for option_name in misc_list:
		var key = misc_list[option_name]
		buttons[key] = Button.new()
		buttons[key].text = option_name.capitalize()
		buttons[key].action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		buttons[key].toggle_mode = true
		buttons[key].connect("pressed", self, "_on_MiscButton_pressed", [key])
		container.add_child(buttons[key])

func update_misc_state(key, is_pressed):
	buttons[key].pressed = is_pressed

func _on_MiscButton_pressed(key):
	emit_signal("misc_selected", key, buttons[key].pressed)

