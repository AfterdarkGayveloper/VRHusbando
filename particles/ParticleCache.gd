extends Spatial

func _ready():
	for child in get_children():
		if child is Particles:
			child.one_shot = true
			child.emitting = true
