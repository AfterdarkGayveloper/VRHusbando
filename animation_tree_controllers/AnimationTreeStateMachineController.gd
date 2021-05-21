extends Node

export (String) var state_machine
export (NodePath) onready var animation_tree = get_node(animation_tree)

onready var playback : AnimationNodeStateMachinePlayback = animation_tree["parameters/%s/playback" % state_machine]
onready var blend_controller : AnimationTreeBlendController = $BlendController
onready var timer = $Timer

func play(node):
	playback.start(node)
	blend_controller.to_max()
	timer.wait_time = rand_range(2, 3)
	timer.start()

func _on_Timer_timeout():
	blend_controller.to_min()
