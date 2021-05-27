extends GUIBase

const NONE_TEXT = "None"

onready var container = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

signal character_selected

func update_character_list(character_list : Array):
	for child in container.get_children():
		child.queue_free()

	for path in character_list:
		var button = Button.new()
		button.text = (path as String).get_file().get_basename().capitalize()
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		button.connect("pressed", self, "_on_CharacterButton_pressed", [path])
		container.add_child(button)

func _on_CharacterButton_pressed(path):
	emit_signal("character_selected", path)
