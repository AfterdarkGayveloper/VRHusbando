extends Control
class_name MainGUI

enum { CHARACTERS, CLOTHES, MISC, CREDITS, SLOT }

onready var main_menu = $MainMenu

onready var menus = {
	CHARACTERS : $CharacterMenu,
	CLOTHES : $ClothesMenu,
	MISC : $MiscMenu,
	SLOT : $SlotMenu,
	CREDITS : $CreditsMenu
}

signal close_pressed

func _ready():
	for menu in menus:
		menus[menu].connect("back_pressed", self, "_on_back_pressed", [menu])
		menus[menu].connect("close_pressed", self, "_on_close_pressed")

	main_menu.connect("close_pressed", self, "_on_close_pressed")

func _on_MainMenu_menu_button_pressed(menu):
	menus[menu].show()
	main_menu.hide()

func _on_back_pressed(menu):
	menus[menu].hide()
	main_menu.show()

func _on_close_pressed():
	emit_signal("close_pressed")
