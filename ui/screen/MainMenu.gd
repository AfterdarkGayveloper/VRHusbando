extends GUIBase

signal menu_button_pressed(menu)

onready var menus = {
	MainGUI.CHARACTERS : $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/CharactersButton,
	MainGUI.CLOTHES : $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/ClothesButton,
	MainGUI.MISC : $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MiscButton,
	MainGUI.CREDITS : $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/CreditsButton
}

func _ready():
	for menu in menus:
		menus[menu].connect("pressed", self, "_on_MenuButton_pressed", [menu])

func _on_MenuButton_pressed(menu):
	emit_signal("menu_button_pressed", menu)

