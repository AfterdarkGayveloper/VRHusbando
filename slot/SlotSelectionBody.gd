extends StaticBody
class_name SlotSelectionBody

export (NodePath) onready var gui_3d = get_node(gui_3d)

func select():
	gui_3d.is_selected = true

func unselect():
	gui_3d.is_selected = false
