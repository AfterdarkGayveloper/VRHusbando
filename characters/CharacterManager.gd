extends Node

export (Array, String, FILE) var character_list

onready var slot = $Slot
onready var character = $Slot/Bakugo

func _ready():
	UIEvents.update_character_list(character_list)
	UIEvents.connect("character_selected", self, "_on_character_selected")

#	$Slot/MainGUI3D/Viewport/MainGUI/CharacterMenu
#	$Slot/MainGUI3D/Viewport/MainGUI/ClothesMenu

func _on_character_selected(path : String) -> void:
	if character:
		character.queue_free()
	character = load(path).instance()
	slot.add_child(character)
