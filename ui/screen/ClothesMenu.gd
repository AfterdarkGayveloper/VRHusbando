extends GUIBase

onready var container = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

var current_mesh_arr : Array = []

signal clothes_changed(index, is_toggled)

func update_clothes_list(mesh_arr):
	current_mesh_arr = mesh_arr
	for child in container.get_children():
		child.queue_free()

	for i in mesh_arr.size():
		var button = Button.new()
		button.text = mesh_arr[i].mesh_name.capitalize()
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		button.toggle_mode = true
		button.pressed = mesh_arr[i].visible
		button.connect("button_up", self, "_on_ClothesButton_button_up", [i])
		container.add_child(button)

func _on_ClothesButton_button_up(index):
	emit_signal("clothes_changed", index, container.get_child(index).pressed)

	for i in current_mesh_arr.size():
		container.get_child(i).pressed = current_mesh_arr[i].visible

