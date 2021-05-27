extends Spatial
class_name Character

const CUM_THRUST_TIMESCALE = 2.0

enum MiscOptions { HARD, STARE, THRUST, HARD_ALLOWED, CUM_ALLOWED }

export (String) var nude_expression = ""
export (Dictionary) var expressions = {}
export (NodePath) onready var penis = get_node(penis)

onready var expression_controller = $AnimationTreeControllers/ExpressionController
onready var thrust_controller = $AnimationTreeControllers/TrustController
onready var thrust_timescale_controller = $AnimationTreeControllers/TrustController/TimescaleController
onready var neck_controller = $NeckFollowBone
onready var head_controller = $HeadFollowBone
onready var mesh_manager = $MeshManager

var misc_funcref = {}

signal misc_updated(key, is_toggled)

func _ready():
	penis.connect("visibility_changed", self, "_on_Penis_visibility_changed")
	penis.connect("touched", self, "_on_Penis_touched")
	penis.connect("hardened", self, "_on_Penis_hardened")
	penis.connect("softened", self, "_on_Penis_softened")
	penis.connect("cum_started", self, "_on_cum_started")
	penis.connect("cum_finished", self, "_on_cum_finished")

	misc_funcref[MiscOptions.HARD] = funcref(self, "toggle_hard")
	misc_funcref[MiscOptions.STARE] = funcref(self, "toggle_stare")
	misc_funcref[MiscOptions.THRUST] = funcref(self, "toggle_thrust")
	misc_funcref[MiscOptions.HARD_ALLOWED] = funcref(self, "toggle_hard_allowed")
	misc_funcref[MiscOptions.CUM_ALLOWED] = funcref(self, "toggle_cum_allowed")

func _randomize_expression():
	for key in expressions:
		if randi() % 100 < expressions[key]:
			expression_controller.play(key)

func _on_Penis_touched():
	_randomize_expression()

func _on_Penis_hardened():
	var is_toggled = true
	emit_signal("misc_updated", MiscOptions.HARD, is_toggled)

func _on_Penis_softened():
	var is_toggled = false
	emit_signal("misc_updated", MiscOptions.HARD, is_toggled)

func _on_Penis_visibility_changed():
	if penis.visible and not nude_expression.empty():
		expression_controller.play(nude_expression)

func _on_cum_started():
	var is_toggled = true
	toggle_thrust(is_toggled)
	emit_signal("misc_updated", MiscOptions.THRUST, is_toggled)
	thrust_timescale_controller.scale = CUM_THRUST_TIMESCALE

func _on_cum_finished():
	var is_toggled = false
	toggle_thrust(is_toggled)
	emit_signal("misc_updated", MiscOptions.THRUST, is_toggled)
	thrust_timescale_controller.reset()

func toggle_misc(key, is_toggled):
	misc_funcref[key].call_func(is_toggled)

func get_misc_state():
	var state = {}
	state[MiscOptions.HARD] = penis.is_hard
	state[MiscOptions.HARD_ALLOWED] = penis.is_hard_allowed
	state[MiscOptions.CUM_ALLOWED] = penis.is_cum_allowed
	state[MiscOptions.STARE] = neck_controller.is_processing()
	state[MiscOptions.THRUST] = thrust_controller.is_at_max()
	return state

func toggle_hard(is_toggled):
	penis.toggle(is_toggled)

func toggle_stare(is_toggled):
	neck_controller.toggle(is_toggled)
	head_controller.toggle(is_toggled)

func toggle_thrust(is_toggled):
	if is_toggled:
		thrust_controller.to_max()
	else:
		thrust_controller.to_min()

func toggle_hard_allowed(is_toggled):
	penis.is_hard_allowed = is_toggled

func toggle_cum_allowed(is_toggled):
	penis.is_cum_allowed = is_toggled

func change_clothes(index, toggled):
	mesh_manager.change_clothes(index, toggled)

func get_mesh_arr():
	return mesh_manager.mesh_arr

func get_misc_keys():
	return MiscOptions.keys()
