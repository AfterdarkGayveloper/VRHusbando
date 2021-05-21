extends GUIBase

onready var container = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

func _ready():
	UIEvents.connect("character_list_updated", self, "_on_character_list_updated")

func _on_character_list_updated(character_list : Array):
	for child in container.get_children():
		child.queue_free()

	for path in character_list:
		var button = Button.new()
		button.text = (path as String).get_file().get_basename().capitalize()
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		button.connect("pressed", self, "_on_CharacterButton_pressed", [path])
		container.add_child(button)

func _on_CharacterButton_pressed(path):
	UIEvents.select_character(path)
