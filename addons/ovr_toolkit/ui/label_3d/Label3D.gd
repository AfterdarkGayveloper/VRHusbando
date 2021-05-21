extends Spatial
class_name Label3D

onready var label = $Viewport/Label

var text setget set_text, get_text

func set_text(text : String) -> void:
	label.text = text

func get_text() -> String:
	return label.text
