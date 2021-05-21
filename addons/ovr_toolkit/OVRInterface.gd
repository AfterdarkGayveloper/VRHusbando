extends Node
class_name OVRInterface

const INTERFACE_NAME = "OVRMobile"
const OS_NAME = "Android"

var arvr_interface : ARVRInterface = null
var ovr_init_config = null
var ovr_performance = null
var ovr_display = null
var ovr_system = null

var ovrVrApiTypes = load("res://addons/godot_ovrmobile/OvrVrApiTypes.gd").new()

func _ready():
	if not is_android():
		set_process(false)
		return

	var arvr_interface = ARVRServer.find_interface(INTERFACE_NAME)
	if arvr_interface:
		ovr_init_config = load("res://addons/godot_ovrmobile/OvrInitConfig.gdns").new()
		ovr_display = load("res://addons/godot_ovrmobile/OvrDisplay.gdns").new()
		ovr_performance = load("res://addons/godot_ovrmobile/OvrPerformance.gdns").new()
		ovr_system = load("res://addons/godot_ovrmobile/OvrSystem.gdns").new()

		ovr_init_config.set_render_target_size_multiplier(1)

		if arvr_interface.initialize():
			var refresh_rate = 72
			if ovr_system.is_oculus_quest_2_device():
				refresh_rate = 90

			ovr_display.set_display_refresh_rate(refresh_rate)

			get_viewport().arvr = true
			Engine.iterations_per_second = refresh_rate

		get_viewport().get_camera().far = 200

func _process(_delta):
	ovr_performance.set_clock_levels(1, 1)
	ovr_performance.set_enable_dynamic_foveation(true)
	if ovr_system.is_oculus_quest_2_device():
		ovr_performance.set_extra_latency_mode(ovrVrApiTypes.OvrExtraLatencyMode.VRAPI_EXTRA_LATENCY_MODE_OFF)
	else:
		ovr_performance.set_extra_latency_mode(ovrVrApiTypes.OvrExtraLatencyMode.VRAPI_EXTRA_LATENCY_MODE_ON)

	set_process(false)

func _notification(what):
	if what == NOTIFICATION_APP_RESUMED:
		set_process(true)

static func is_android():
	return OS.get_name() == OS_NAME
