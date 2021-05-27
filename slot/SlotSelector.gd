extends RayCast

var selection_body : SlotSelectionBody = null

func _process(delta):
	if is_colliding():
		var collider = get_collider()
		if selection_body:
			if selection_body.get_instance_id() == collider.get_instance_id():
				return
			selection_body.unselect()
		if collider is SlotSelectionBody:
			selection_body = (collider as SlotSelectionBody)
			selection_body.select()
			return
	if selection_body:
		selection_body.unselect()
		selection_body = null
