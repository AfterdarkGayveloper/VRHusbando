extends Spatial

export (bool) var is_main = false

onready var character_menu = $MainGUI3D/Viewport/MainGUI/CharacterMenu
onready var clothes_menu = $MainGUI3D/Viewport/MainGUI/ClothesMenu
onready var misc_menu = $MainGUI3D/Viewport/MainGUI/MiscMenu
onready var slot_menu = $MainGUI3D/Viewport/MainGUI/SlotMenu
onready var main_menu = $MainGUI3D/Viewport/MainGUI/MainMenu
onready var container = $CharacterContainer

var character : Character = null

signal slot_toggled(is_right, is_toggled)

func _ready():
	main_menu.set_button_visibility(MainGUI.CREDITS, is_main)
	main_menu.set_button_visibility(MainGUI.SLOT, is_main)

	if container.get_child_count() > 0:
		character = container.get_children().back()
		_update_clothes_list()
		_update_misc_list()
	else:
		set_menu_visibility(false)

	character_menu.connect("character_selected", self, "_on_character_selected")
	clothes_menu.connect("clothes_changed", self, "_on_clothes_changed")
	misc_menu.connect("misc_selected", self, "_on_misc_selected")
	slot_menu.connect("slot_toggled", self, "_on_slot_toggled")

	character.connect("misc_updated", self, "_on_misc_updated")

func _on_character_selected(path : String):
	if character:
		character.queue_free()

	character = load(path).instance()
	container.add_child(character)
	_update_clothes_list()
	_update_misc_list()

	set_menu_visibility(true)

func _on_clothes_changed(index, is_toggled):
	character.change_clothes(index, is_toggled)

func _on_misc_selected(key, is_toggled):
	character.toggle_misc(key, is_toggled)

func _on_slot_toggled(is_right, is_toggled):
	emit_signal("slot_toggled", is_right, is_toggled)

func _update_misc_list():
	misc_menu.update_misc_list(character.MiscOptions)
	var misc_state = character.get_misc_state()
	for key in misc_state:
		_on_misc_updated(key, misc_state[key])

func _update_clothes_list():
	var mesh_arr = character.get_mesh_arr()
	clothes_menu.update_clothes_list(mesh_arr)

func _on_misc_updated(key, is_toggled):
	misc_menu.update_misc_state(key, is_toggled)

func set_character_list(character_list):
	character_menu.update_character_list(character_list)

func set_menu_visibility(is_visible):
	main_menu.set_button_visibility(MainGUI.CLOTHES, is_visible)
	main_menu.set_button_visibility(MainGUI.MISC, is_visible)
