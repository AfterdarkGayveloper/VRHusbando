extends Node

# From View to Model #
signal character_selected(path)
signal clothes_changed(index, toggled)
signal hard_toggled(is_toggled)
signal stare_toggled(is_toggled)
signal thrust_toggled(is_toggled)

func select_character(path : String) -> void:
	emit_signal("character_selected", path)

func change_clothes(index : int, toggled : bool) -> void:
	emit_signal("clothes_changed", index, toggled)

func toggle_hard(is_toggled : bool) -> void:
	emit_signal("hard_toggled", is_toggled)

func toggle_stare(is_toggled : bool) -> void:
	emit_signal("stare_toggled", is_toggled)

func toggle_thrust(is_toggled : bool) -> void:
	emit_signal("thrust_toggled", is_toggled)

# From Model to View #
signal character_list_updated(character_list)
signal clothes_list_updated(mesh_arr)
signal hard_toggled_updated

func update_character_list(character_list : Array) -> void:
	emit_signal("character_list_updated", character_list)

func update_clothes_list(mesh_arr : Array) -> void:
	emit_signal("clothes_list_updated", mesh_arr)

func update_hard_toggle() -> void:
	emit_signal("hard_toggled_updated")
