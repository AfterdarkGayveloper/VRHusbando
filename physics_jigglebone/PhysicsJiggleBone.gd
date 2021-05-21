tool
extends RigidBody

export (NodePath) var skeleton_path
export (String) var bone_name
export (float, 0.1, 100, 0.1) var stiffness = 1
export (float, 0, 100, 0.1) var damping = 0
export (float) var scale_speed = 1.0
export (bool) var use_gravity = false
export (Vector3) var gravity = Vector3(0, -9.81, 0)
export (Vector3) var bone_forward_local = Vector3.FORWARD
export (Vector3) var target_scale = Vector3.ONE setget set_target_scale
export (Vector3) var gravity_shape_offset = Vector3.ZERO

onready var initial_translate = translation
onready var default_shape_radius : float = 0.0
onready var default_shape_height : float = 0.0
onready var default_shape_transform : Transform = shape_owner_get_transform(0)

var prev_pos = Vector3()
var skeleton : Skeleton
var current_scale = Vector3.ONE

# Rest length of the distance constraint
var rest_length = 1

func _ready():
	set_as_toplevel(true)
	prev_pos = global_transform.origin
	set_process(Engine.editor_hint)

	if Engine.editor_hint:
		return

	var shape : CapsuleShape = shape_owner_get_shape(0, 0)
	default_shape_radius = shape.radius
	default_shape_height = shape.height

func set_shape_disabled(is_disabled):
	shape_owner_set_disabled(0, is_disabled)

func set_shape_size(radius, height):
	var shape : CapsuleShape = shape_owner_get_shape(0, 0)
	shape.radius = radius
	shape.height = height

func set_target_scale(value : Vector3):
	target_scale = value

func _update_shape_origin():
	if not default_shape_transform:
		return
	var shape_transform : Transform = default_shape_transform
	if use_gravity:
		shape_transform.origin += gravity_shape_offset

	$CollisionShape.transform = shape_transform
#	shape_owner_set_transform(0, shape_transform)

func _process(delta):
	if not initial_translate:
		initial_translate = translation

	if not skeleton is Skeleton:
		if skeleton_path.is_empty():
			return
		skeleton = get_node(skeleton_path)
		return

	if not bone_name:
		return

	var bone_id = skeleton.find_bone(bone_name)

	if bone_id == -1:
		return

	var bone_id_parent = skeleton.get_bone_parent(bone_id)

	# Note:
	# Local space = local to the bone
	# Object space = local to the skeleton (confusingly called "global" in get_bone_global_pose)
	# World space = global

	# See https://godotengine.org/qa/7631/armature-differences-between-bones-custom_pose-transform

	# Object space bone pose
	var bone_transf_obj = skeleton.get_bone_global_pose(bone_id)
	var bone_transf_world = skeleton.global_transform * bone_transf_obj

	var bone_transf_rest_local = skeleton.get_bone_rest(bone_id)
	var bone_transf_rest_obj = skeleton.get_bone_global_pose(bone_id_parent) * bone_transf_rest_local
	var bone_transf_rest_world = skeleton.global_transform * bone_transf_rest_obj

	current_scale = current_scale.linear_interpolate(target_scale, delta * scale_speed)
	bone_transf_obj = bone_transf_obj.scaled(current_scale)
	skeleton.set_bone_global_pose_override(bone_id, bone_transf_obj, 0.5, true)

	############### Integrate velocity (Verlet integration) ##############

	# If not using gravity, apply force in the direction of the bone (so it always wants to point "forward")
	var grav = bone_transf_rest_world.basis.xform(Vector3(0, 0, -1)).normalized() * 9.81
	var vel = (global_transform.origin - prev_pos) / delta

	if use_gravity:
		grav = gravity

	_update_shape_origin()

	grav *= stiffness
	vel += grav
	# Damping
	vel -= vel * damping * delta

	prev_pos = global_transform.origin
	global_transform.origin = global_transform.origin + vel * delta

	if is_nan(translation.x) or is_inf(translation.x):
		translation.x = initial_translate.x
	if is_nan(translation.y) or is_inf(translation.y):
		translation.y = initial_translate.y
	if is_nan(translation.z) or is_inf(translation.z):
		translation.z = initial_translate.z

	############### Solve distance constraint ##############

	var goal_pos = skeleton.to_global(skeleton.get_bone_global_pose(bone_id).origin)
	var new_pos_clamped = goal_pos + (global_transform.origin - goal_pos).normalized() * rest_length
	global_transform.origin = new_pos_clamped

	############## Rotate the bone to point to this object #############

	var diff_vec_local = bone_transf_world.affine_inverse().xform(global_transform.origin).normalized()

	# The axis+angle to rotate on, in local-to-bone space
	var bone_rotate_axis = bone_forward_local.cross(diff_vec_local)
	var bone_rotate_angle = acos(bone_forward_local.dot(diff_vec_local))

	# Already aligned, no need to rotate
	if bone_rotate_axis.length() < 1e-3:
		return

	bone_rotate_axis = bone_rotate_axis.normalized()

	# Bring the axis to object space, WITHOUT translation (so only the BASIS is used) since vectors shouldn't be translated
	var bone_rotate_axis_obj = bone_transf_obj.basis.xform(bone_rotate_axis).normalized()
	var bone_new_transf_obj = Transform(bone_transf_obj.basis.rotated(bone_rotate_axis_obj, bone_rotate_angle), bone_transf_obj.origin)

	# Corrupted somehow
	if is_nan(bone_new_transf_obj[0][0]):
		bone_new_transf_obj = Transform()

	skeleton.set_bone_global_pose_override(bone_id, bone_new_transf_obj, 0.5, true)

	# Orient this object to the jigglebone
	var basis = (skeleton.global_transform * skeleton.get_bone_global_pose(bone_id)).basis
	global_transform.basis = Basis(basis.get_rotation_quat())




func _integrate_forces(state):
	if not skeleton is Skeleton:
		if skeleton_path.is_empty():
			return
		skeleton = get_node(skeleton_path)
		return

	if not bone_name:
		return

	var bone_id = skeleton.find_bone(bone_name)

	if bone_id == -1:
		return

	var bone_id_parent = skeleton.get_bone_parent(bone_id)

	# Note:
	# Local space = local to the bone
	# Object space = local to the skeleton (confusingly called "global" in get_bone_global_pose)
	# World space = global

	# See https://godotengine.org/qa/7631/armature-differences-between-bones-custom_pose-transform

	# Object space bone pose
	var bone_transf_obj = skeleton.get_bone_global_pose(bone_id)
	var bone_transf_world = skeleton.global_transform * bone_transf_obj

	var bone_transf_rest_local = skeleton.get_bone_rest(bone_id)
	var bone_transf_rest_obj = skeleton.get_bone_global_pose(bone_id_parent) * bone_transf_rest_local
	var bone_transf_rest_world = skeleton.global_transform * bone_transf_rest_obj

	current_scale = current_scale.linear_interpolate(target_scale, state.step * scale_speed)
	bone_transf_obj = bone_transf_obj.scaled(current_scale)
	skeleton.set_bone_global_pose_override(bone_id, bone_transf_obj, 0.5, true)

	############### Integrate velocity (Verlet integration) ##############

	# If not using gravity, apply force in the direction of the bone (so it always wants to point "forward")
	var grav = bone_transf_rest_world.basis.xform(Vector3(0, 0, -1)).normalized() * 9.81
	var vel = (state.transform.origin - prev_pos) / state.step

	if use_gravity:
		grav = gravity

	_update_shape_origin()

	grav *= stiffness
	vel += grav
	# Damping
	vel -= vel * damping * state.step

	prev_pos = state.transform.origin
	state.transform.origin = state.transform.origin + vel * state.step

	if is_nan(translation.x) or is_inf(translation.x):
		translation.x = initial_translate.x
	if is_nan(translation.y) or is_inf(translation.y):
		translation.y = initial_translate.y
	if is_nan(translation.z) or is_inf(translation.z):
		translation.z = initial_translate.z
	############### Solve distance constraint ##############

	var goal_pos = skeleton.to_global(skeleton.get_bone_global_pose(bone_id).origin)
	var new_pos_clamped = goal_pos + (state.transform.origin - goal_pos).normalized() * rest_length
	state.transform.origin = new_pos_clamped

	############## Rotate the bone to point to this object #############

	var diff_vec_local = bone_transf_world.affine_inverse().xform(state.transform.origin).normalized()

	# The axis+angle to rotate on, in local-to-bone space
	var bone_rotate_axis = bone_forward_local.cross(diff_vec_local)
	var bone_rotate_angle = acos(bone_forward_local.dot(diff_vec_local))

	# Already aligned, no need to rotate
	if bone_rotate_axis.length() < 1e-3:
		return

	bone_rotate_axis = bone_rotate_axis.normalized()

	# Bring the axis to object space, WITHOUT translation (so only the BASIS is used) since vectors shouldn't be translated
	var bone_rotate_axis_obj = bone_transf_obj.basis.xform(bone_rotate_axis).normalized()
	var bone_new_transf_obj = Transform(bone_transf_obj.basis.rotated(bone_rotate_axis_obj, bone_rotate_angle), bone_transf_obj.origin)

	# Corrupted somehow
	if is_nan(bone_new_transf_obj[0][0]):
		bone_new_transf_obj = Transform()

	skeleton.set_bone_global_pose_override(bone_id, bone_new_transf_obj, 0.5, true)

	# Orient this object to the jigglebone
	var basis = (skeleton.global_transform * skeleton.get_bone_global_pose(bone_id)).basis
	state.transform.basis = Basis(basis.get_rotation_quat())

	state.linear_velocity = Vector3.ZERO
	state.angular_velocity = Vector3.ZERO
