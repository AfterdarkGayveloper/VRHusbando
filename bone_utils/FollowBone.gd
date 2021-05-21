extends Node

enum Type { STARE }

export (NodePath) onready var skeleton = get_node(skeleton)

export (String) var group_name
export (String) var bone_name

export (float) var angle_limit = 1.0
export (float) var follow_speed = 5.0

export (bool) var relative = false

export (Vector3) var target_offset = Vector3(0, 0, 0)
export (Vector3) var bone_forward_local = Vector3.FORWARD

export (Type) var type

onready var bone_id : int = skeleton.find_bone(bone_name)
onready var bone_id_parent : int = skeleton.get_bone_parent(bone_id)
onready var target : Spatial = get_tree().get_nodes_in_group(group_name).back()

var relative_offset : Vector3 = Vector3.ZERO

func _ready():
	if relative:
		var bone_transf_obj = skeleton.get_bone_global_pose(bone_id)
		var bone_transf_world = skeleton.global_transform * bone_transf_obj
		var bone_transf_rest_local = skeleton.get_bone_rest(bone_id)
		var bone_transf_rest_obj = skeleton.get_bone_global_pose(bone_id_parent) * bone_transf_rest_local
		var bone_transf_rest_world = skeleton.global_transform * bone_transf_rest_obj

		var vector_forward = -bone_transf_rest_world.basis.xform(bone_forward_local).normalized()
		relative_offset = (bone_transf_world.origin - vector_forward) - (target.global_transform.origin+target_offset)

	if type == Type.STARE:
		UIEvents.connect("stare_toggled", self, "_on_toggle_toggled")

func _on_toggle_toggled(is_toggled):
	if is_toggled:
		enable()
	else:
		disable()

func disable():
	skeleton.set_bone_global_pose_override(bone_id, Transform(), 0.0, false)
	set_process(false)

func enable():
	set_process(true)

func _process(delta):
	var bone_transf_obj = skeleton.get_bone_global_pose(bone_id)
	var bone_transf_world = skeleton.global_transform * bone_transf_obj

	var follow_target = target.global_transform.origin + target_offset + relative_offset

	var diff_vec_local = bone_transf_world.affine_inverse().xform(follow_target).normalized()
	var bone_rotate_axis = bone_forward_local.cross(diff_vec_local)
	var bone_rotate_angle = acos(bone_forward_local.dot(diff_vec_local))

	if bone_rotate_angle > angle_limit:
		return
	if bone_rotate_axis.length() < 1e-3:
		return

	bone_rotate_axis = bone_rotate_axis.normalized()
	var bone_rotate_axis_obj = bone_transf_obj.basis.xform(bone_rotate_axis).normalized()
	var bone_new_transf_obj = Transform(bone_transf_obj.basis.rotated(bone_rotate_axis_obj, bone_rotate_angle), bone_transf_obj.origin)

	if is_nan(bone_new_transf_obj[0][0]):
		bone_new_transf_obj = Transform()

	skeleton.set_bone_global_pose_override(bone_id, bone_new_transf_obj, 0.5, true)

