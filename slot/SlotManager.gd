extends Node

enum Slots { RIGHT, LEFT }

export (Array, String, FILE) var character_list
export (PackedScene) var slot_scene

onready var main_slot = $MainSlot

onready var slot_transform = {
	Slots.RIGHT : $RightSpawnPoint.transform,
	Slots.LEFT : $LeftSpawnPoint.transform
}
var slot_instances = {}
var right_slot = null
var left_slot = null

func _ready():
	main_slot.connect("slot_toggled", self, "_on_slot_toggled")
	main_slot.set_character_list(character_list)

func _on_slot_toggled(is_right, is_toggled):
	var key = Slots.RIGHT if is_right else Slots.LEFT

	if is_toggled:
		slot_instances[key] = slot_scene.instance()
		add_child(slot_instances[key])
		slot_instances[key].transform = slot_transform[key]
		slot_instances[key].set_character_list(character_list)
	else:
		slot_instances[key].queue_free()

