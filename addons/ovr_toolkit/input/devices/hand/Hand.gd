extends Spatial

const DEVICE_NAME = {
	OVRInput.LEFT_DEVICE_ID : "Oculus Tracked Left Hand",
	OVRInput.RIGHT_DEVICE_ID : "Oculus Tracked Right Hand"
}

const API_PATH = "res://addons/godot_ovrmobile/OvrHandTracking.gdns"

export (OVRInput.DeviceID) var device_id = OVRInput.RIGHT_DEVICE_ID
export (NodePath) onready var skeleton = get_node(skeleton)
export (NodePath) onready var arvr_controller = get_node(arvr_controller)
export (NodePath) onready var arvr_origin = get_node(arvr_origin)
var api = null
var bone_map : Array = [0, 23, 1, 2, 3, 4, 6, 7, 8, 10, 11, 12, 14, 15, 16, 18, 19, 20, 21];
var bone_orientation : Array = []

func _ready():
	scale = Vector3.ONE * arvr_origin.world_scale
	ARVRServer.connect("tracker_added", self, "_on_tracker_added")
	ARVRServer.connect("tracker_removed", self, "_on_tracker_removed")

	if OVRInterface.is_android():
		api =  load(API_PATH).new()
		bone_orientation.resize(24)
		for i in skeleton.get_bone_count():
			var bone_rest = skeleton.get_bone_rest(i)
			skeleton.set_bone_pose(i, Transform(bone_rest.basis))
			bone_rest.basis = Basis()
			skeleton.set_bone_rest(i, bone_rest)
		set_process(true)
	else:
		set_process(false)

func _process(delta):
	var hand_scale : float = api.get_hand_scale(arvr_controller.controller_id)
	if hand_scale > 0.0:
		scale = Vector3(hand_scale, hand_scale, hand_scale) * arvr_origin.world_scale


	if api.get_hand_pose(arvr_controller.controller_id, bone_orientation) > 0.0:
		visible = true
		for i in bone_map.size():
			skeleton.set_bone_pose(bone_map[i], Transform(bone_orientation[i]))
	else:
		visible = false

func _on_tracker_added(tracker_name: String, type: int, id: int):
	if DEVICE_NAME[device_id] == tracker_name:
		set_process(true)
		show()

func _on_tracker_removed(tracker_name: String, type: int, id: int):
	if DEVICE_NAME[device_id] == tracker_name:
		set_process(false)
		hide()
