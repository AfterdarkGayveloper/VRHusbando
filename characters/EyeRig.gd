tool
extends Spatial

export (NodePath) var target_path
export (NodePath) var skeleton_path
export (String) var bone_name

var skeleton : Skeleton
var target : Spatial


func _process(delta):
	if not skeleton is Skeleton:
		if skeleton_path.is_empty():
			return
		skeleton = get_node(skeleton_path)
		return

	if not target is Spatial:
		if target_path.is_empty():
			return
		target = get_node(target_path)
		return

	if not bone_name:
		return

	var bone_id = skeleton.find_bone(bone_name)

	if bone_id == -1:
		return

	var bone_id_parent = skeleton.get_bone_parent(bone_id)

	var bone_transf_obj = skeleton.get_bone_global_pose(bone_id)
	var bone_transf_world = skeleton.global_transform * bone_transf_obj

	var bone_transf_rest_local = skeleton.get_bone_rest(bone_id)
	var bone_transf_rest_obj = skeleton.get_bone_global_pose(bone_id_parent) * bone_transf_rest_local
	var bone_transf_rest_world = skeleton.global_transform * bone_transf_rest_obj
	global_transform = bone_transf_rest_world

	$Pivot.global_transform.origin = global_transform.origin + Vector3.FORWARD * 1.1

	$Pivot.look_at(target.global_transform.origin, Vector3.UP)
	$Pivot/Eye.global_transform = $Pivot.global_transform.translated(Vector3.FORWARD * 2)
	$Pivot/Eye.global_transform.basis = bone_transf_rest_world.basis

	var l_transform = skeleton.global_transform.affine_inverse() *  $Pivot/Eye.global_transform
	skeleton.set_bone_global_pose_override(bone_id, l_transform, 0.5, true)
