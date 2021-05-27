extends Node

# From View to Model #
signal character_selected(slot_id, path)
signal clothes_changed(slot_id, index, toggled)
signal hard_toggled(slot_id, is_toggled)
signal stare_toggled(slot_id, is_toggled)
signal thrust_toggled(slot_id, is_toggled)

func select_character(slot_id : int, path : String) -> void:
	emit_signal("character_selected", slot_id, path)

func change_clothes(slot_id : int, index : int, toggled : bool) -> void:
	emit_signal("clothes_changed", slot_id, index, toggled)

func toggle_hard(slot_id : int, is_toggled : bool) -> void:
	emit_signal("hard_toggled", slot_id, is_toggled)

func toggle_stare(slot_id : int, is_toggled : bool) -> void:
	emit_signal("stare_toggled", slot_id, is_toggled)

func toggle_thrust(slot_id : int, is_toggled : bool) -> void:
	emit_signal("thrust_toggled", slot_id, is_toggled)

# From Model to View #
signal character_list_updated(character_list)
signal clothes_list_updated(slot_id, mesh_arr)
signal hard_toggled_updated(slot_id)

func update_character_list(character_list : Array) -> void:
	emit_signal("character_list_updated", character_list)

func update_clothes_list(slot_id : int, mesh_arr : Array) -> void:
	emit_signal("clothes_list_updated", slot_id, mesh_arr)

func update_hard_toggle(slot_id : int) -> void:
	emit_signal("hard_toggled_updated", slot_id)
