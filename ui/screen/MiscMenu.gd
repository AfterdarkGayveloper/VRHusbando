extends GUIBase

onready var hard_toggle = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/HardButton
onready var stare_toggle = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/StareButton
onready var thrust_toggle = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/ThrustButton

func _ready():
	UIEvents.connect("hard_toggled_updated", self, "_on_hard_toggled_updated")

func _on_hard_toggled_updated():
	hard_toggle.pressed = true

func _on_HardButton_button_up():
	UIEvents.toggle_hard(hard_toggle.pressed)

func _on_StareButton_button_up():
	UIEvents.toggle_stare(stare_toggle.pressed)

func _on_ThrustButton_button_up():
	UIEvents.toggle_thrust(thrust_toggle.pressed)
