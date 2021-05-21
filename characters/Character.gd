extends Spatial

onready var penis = $PenisTypeA
onready var expression_controller = $AnimationTreeControllers/ExpressionController
onready var thrust_controller = $AnimationTreeControllers/TrustController

const EXPRESSIONS = {
	angry=15
}


func _ready():
	penis.connect("visibility_changed", self, "_on_PenisTypeA_visibility_changed")
	UIEvents.connect("thrust_toggled", self, "_on_thrust_toggled")

func _randomize_expression():
	for key in EXPRESSIONS:
		if randi() % 100 < EXPRESSIONS[key]:
			expression_controller.play(key)

func _on_thrust_toggled(is_toggled):
	if is_toggled:
		thrust_controller.to_max()
	else:
		thrust_controller.to_min()

func _on_PenisTypeA_touched():
	_randomize_expression()

func _on_PenisTypeA_visibility_changed():
	if penis.visible:
		expression_controller.play("angry")

