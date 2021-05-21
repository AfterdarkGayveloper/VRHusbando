tool
extends Spatial

const MAX_HORNYNESS = 100.0
const HARD_MULTIPLIER = 1.0
const SOFT_MULTIPLIER = 0.0

export (Material) var material setget _set_material, _get_material
export (Vector3) var soft_scale = Vector3(0.3, 0.3, 0.3)
export (Vector3) var hard_scale = Vector3.ONE
export (float) var hard_stiffness = 2.0
export (float) var soft_stiffness = 0.3

onready var skeleton = $Genitals/Skeleton
onready var balls = $Balls
onready var bones = [
	$Bone5,
	$Bone4,
	$Bone3,
	$Bone2,
	$Bone1,
]

var contact_bodies : Array = []
var scale_speed : float = 1.0
var hornyness : float = 0.0
var disabled : bool = false
var is_hard : bool = false

signal touched

func _ready():
	if Engine.editor_hint:
		return

	for bone in bones:
		bone.connect("body_entered", self, "_on_body_entered")
		bone.connect("body_exited", self, "_on_body_exited")

	yield(get_tree(), "idle_frame")
	make_soft()

	UIEvents.connect("hard_toggled", self, "_on_hard_toggled")

func _set_material(value : Material) -> void:
	$Genitals/Skeleton/Penis.material_override = value

func _get_material() -> Material:
	return $Genitals/Skeleton/Penis.material_override

func _on_hard_toggled(is_toggled):
	if is_toggled:
		make_hard()
	else:
		make_soft()

func set_physics_disabled(is_disabled):
	if disabled == is_disabled:
		return
	for bone in bones:
		bone.set_shape_disabled(is_disabled)
	balls.set_shape_disabled(is_disabled)
	disabled = is_disabled

func change_size(multiplier):
	var target_scale : Vector3 = ((hard_scale - soft_scale) * multiplier) + soft_scale
	bones.back().set_target_scale(target_scale)
	var shape_multiplier = (target_scale.x / hard_scale.x)
	shape_multiplier += shape_multiplier * (0.5 - (0.5 * multiplier))
	var stiffness = (hard_stiffness - soft_stiffness) * multiplier + soft_stiffness
	for bone in bones:
		bone.stiffness = stiffness
		var radius = bone.default_shape_radius * shape_multiplier
		var height = bone.default_shape_height * shape_multiplier
		bone.set_shape_size(radius, height)

func make_hard():
	hornyness = 100.0
	for bone in bones:
		bone.use_gravity = false
	change_size(HARD_MULTIPLIER)
	is_hard = true

func make_soft():
	hornyness = 0.0
	for bone in bones:
		bone.use_gravity = true
	change_size(SOFT_MULTIPLIER)
	is_hard = false

func _on_body_entered(body : Node) -> void:
	if not body in contact_bodies:
		contact_bodies.append(body)

func _on_body_exited(body : Node) -> void:
	if body in contact_bodies:
		contact_bodies.erase(body)

func _update_multiplier() -> void:
	var multiplier : float = hornyness / MAX_HORNYNESS
	var use_gravity_size = bones.size() * multiplier
	for i in use_gravity_size:
		bones[i].use_gravity = false
	change_size(multiplier)

func _on_UpdateTimer_timeout():
	if not contact_bodies.empty():
		emit_signal("touched")

	if hornyness >= MAX_HORNYNESS:
		if not is_hard:
			UIEvents.update_hard_toggle()
			is_hard = true
		return

	for i in contact_bodies.size():
		hornyness += 2.0
		if hornyness > MAX_HORNYNESS:
			hornyness = MAX_HORNYNESS

	_update_multiplier()
