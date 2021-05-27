tool
extends Spatial

const MAX_HORNYNESS = 150.0
const HARD_MULTIPLIER = 1.0
const SOFT_MULTIPLIER = 0.0
const CUM_THREASHOLD = 150.0
const HARD_THREASHOLD = 100.0

export (Material) var material setget _set_material, _get_material
export (Vector3) var soft_scale = Vector3(0.3, 0.3, 0.3)
export (Vector3) var hard_scale = Vector3.ONE
export (float) var hard_stiffness = 2.0
export (float) var soft_stiffness = 0.3

onready var skeleton = $Genitals/Skeleton
onready var cum_timer = $CumTimer
onready var cum_particles = $Genitals/Skeleton/TipBoneAttachment/CumParticles

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
var is_cuming : bool = false
var is_cum_allowed : bool = true
var is_hard_allowed : bool = true

signal touched
signal hardened
signal softened
signal cum_started
signal cum_finished

func _ready():
	if Engine.editor_hint:
		return

	for bone in bones:
		bone.connect("body_entered", self, "_on_body_entered")
		bone.connect("body_exited", self, "_on_body_exited")

	yield(get_tree(), "idle_frame")
	make_soft()

func _set_material(value : Material) -> void:
	$Genitals/Skeleton/Penis.material_override = value

func _get_material() -> Material:
	return $Genitals/Skeleton/Penis.material_override

func toggle(is_toggled):
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
	hornyness = HARD_THREASHOLD
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

func _get_multiplier() -> float:
	return hornyness / HARD_THREASHOLD

func _update_gravity(multiplier):
	var size = bones.size() * multiplier
	for i in size:
		bones[i].use_gravity = false

func _on_HardTimer_timeout():
	if contact_bodies.empty():
		return
	emit_signal("touched")

	for i in contact_bodies.size():
		hornyness += 2.0
		if hornyness > MAX_HORNYNESS:
			hornyness = MAX_HORNYNESS

	if hornyness >= CUM_THREASHOLD and not is_cuming and is_cum_allowed:
		is_cuming = true
		cum_particles.emitting = true
		cum_timer.start()
		emit_signal("cum_started")

	if is_hard_allowed and not is_hard:
		if hornyness >= HARD_THREASHOLD:
			is_hard = true
			emit_signal("hardened")
			return
		var multiplier = _get_multiplier()
		_update_gravity(multiplier)
		change_size(multiplier)

func _on_CumTimer_timeout():
	is_cuming = false
	cum_particles.emitting = false
	emit_signal("cum_finished")
	make_soft()
	emit_signal("softened")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		make_hard()
		is_cuming = true
		cum_particles.emitting = true
		cum_timer.start()
		emit_signal("cum_started")
