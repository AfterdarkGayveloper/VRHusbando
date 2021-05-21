extends Node
class_name AnimationTreeBlendControllerTimer

export (bool) var autostart = true

export (float) var start_min = 4
export (float) var start_max = 7
export (float) var end_min = 0.3
export (float) var end_max = 0.5

onready var start_timer = $StartTimer
onready var end_timer = $EndTimer
onready var controller : AnimationTreeBlendController = get_parent()

func _ready():
	start_timer.wait_time = rand_range(start_min, start_max)
	if autostart:
		start_timer.start()

	controller.connect("min_reached", self, "_on_Controller_min_reached")
	controller.connect("max_reached", self, "_on_Controller_max_reached")

func _on_StartTimer_timeout():
	controller.to_max()

func _on_EndTimer_timeout():
	controller.to_min()

func _on_Controller_min_reached():
	start_timer.wait_time = rand_range(start_min, start_max)
	start_timer.start()

func _on_Controller_max_reached():
	end_timer.wait_time = rand_range(end_min, end_max)
	end_timer.start()

func start():
	start_timer.start()
