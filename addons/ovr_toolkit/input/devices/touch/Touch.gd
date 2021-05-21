extends Spatial

const DEVICE_NAME = {
	OVRInput.LEFT_DEVICE_ID : "Oculus Touch Left Controller",
	OVRInput.RIGHT_DEVICE_ID : "Oculus Touch Right Controller"
}

const BLEND_PARAM = "parameters/%s/blend_amount"
const BLENDSPACE_PARAM = "parameters/%s/blend_position"

export (OVRInput.DeviceID) var device_id = OVRInput.RIGHT_DEVICE_ID
export (NodePath) onready var arvr_origin = get_node(arvr_origin)

onready var animation_tree = $AnimationTree

var button_map = {
	OVRInput.AX_BUTTON : {OVRInput.LEFT_DEVICE_ID:"XBlend", OVRInput.RIGHT_DEVICE_ID:"ABlend"},
	OVRInput.BY_BUTTON : {OVRInput.LEFT_DEVICE_ID:"YBlend", OVRInput.RIGHT_DEVICE_ID:"BBlend"},
	OVRInput.MENU_BUTTON : {OVRInput.LEFT_DEVICE_ID:"MenuBlend", OVRInput.RIGHT_DEVICE_ID:"MenuBlend"},
	OVRInput.GRIP_BUTTON : {OVRInput.LEFT_DEVICE_ID:"GripBlend", OVRInput.RIGHT_DEVICE_ID:"GripBlend"},
	OVRInput.TRIGGER_BUTTON : {OVRInput.LEFT_DEVICE_ID:"TriggerBlend", OVRInput.RIGHT_DEVICE_ID:"TriggerBlend"}
}

var axis_map = {
	OVRInput.HORIZONTAL_AXIS : "ThumbstickBlendSpace",
	OVRInput.VERTICAL_AXIS : "ThumbstickBlendSpace"
}

var thumbstick_axis : Vector2 = Vector2.ZERO

func _ready():
	ARVRServer.connect("tracker_added", self, "_on_tracker_added")
	ARVRServer.connect("tracker_removed", self, "_on_tracker_removed")
	scale = Vector3.ONE * arvr_origin.world_scale

func _input(event):
	if event is InputEventJoypadButton:
		if not event.device == device_id:
			return
		if event.button_index in button_map:
			var blend = button_map[event.button_index][event.device]
			var animation_tree_parameter = BLEND_PARAM % blend
			animation_tree[animation_tree_parameter] = 1.0 if event.pressed else 0.0
	elif event is InputEventJoypadMotion:
		if not event.device == device_id:
			return
		if event.axis in axis_map:
			var blendspace = axis_map[event.axis]
			var animation_tree_parameter = BLENDSPACE_PARAM % blendspace
			if event.axis == OVRInput.HORIZONTAL_AXIS:
				thumbstick_axis.x = event.axis_value
			elif event.axis == OVRInput.VERTICAL_AXIS:
				thumbstick_axis.y = event.axis_value
			animation_tree[animation_tree_parameter] = thumbstick_axis

func _on_tracker_added(tracker_name: String, type: int, id: int):
	if DEVICE_NAME[device_id] == tracker_name:
		show()

func _on_tracker_removed(tracker_name: String, type: int, id: int):
	if DEVICE_NAME[device_id] == tracker_name:
		hide()
