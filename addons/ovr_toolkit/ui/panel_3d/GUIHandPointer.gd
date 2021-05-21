extends RigidBody

export (NodePath) onready var default_position = get_node(default_position)
var pressed : bool = false
var panel3d : Panel3D = null

func _integrate_forces(state):
	state.transform = default_position.global_transform
	if state.get_contact_count() > 0:
		var contact_object = state.get_contact_collider_object(0)
		if contact_object is Panel3D:
			panel3d = (contact_object as Panel3D)
			var contact_position : Vector3 = state.get_contact_collider_position(0)
			panel3d.pointer_motion(contact_position)
			if not pressed:
				panel3d.pointer_click()
				pressed = true
			return
	if panel3d:
		panel3d.pointer_release()
		panel3d.pointer_hide()
		panel3d = null
		pressed = false
