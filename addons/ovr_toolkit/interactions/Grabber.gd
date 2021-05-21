extends Area
class_name Grabber

export (OVRInput.DeviceID) var device_id : int = OVRInput.RIGHT_DEVICE_ID
export (OVRInput.Buttons) var button : int = OVRInput.TRIGGER_BUTTON

export (NodePath) onready var arvr_controller = get_node(arvr_controller)

var grabbable : Grabbable = null
var is_grabbing : bool = false
var bodies : Array = []

signal grabbed
signal released

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_existe")

func _on_body_entered(body : Node) -> void:
	if not body is Grabbable or body in bodies:
		return

	bodies.append(body)
	(body as Grabbable).grabber_entered()


func _on_body_existe(body : Node) -> void:
	if not body is Grabbable or bodies.empty() or not body in bodies:
		return
	if body.on_grabbed_state:
		return

	bodies.erase(body)
	body.unset_as_closest()
	(body as Grabbable).grabber_left()

func _process(delta):
	_update_closest()

func _update_closest():
	if is_grabbing or bodies.empty():
		return
	var closest_distance = 1000
	var global_origin = global_transform.origin
	for body in bodies:
		body.unset_as_closest()
		var body_center = body.global_transform.origin + body.center_offset
		var body_distance = global_origin.distance_to(body_center)
		if closest_distance > body_distance:
			closest_distance = body_distance
			grabbable = body
	grabbable.set_as_closest()

func _input(event) -> void:
	if bodies.empty():
		return
	if not event.device == device_id:
		return

	if event is InputEventJoypadButton:
		if event.button_index == button:
			if event.pressed:
				grab()
			else:
				release()

func grab() -> void:
	if is_grabbing:
		return
	if not grabbable is Grabbable:
		return

	is_grabbing = true
	grabbable.grab(arvr_controller)
	emit_signal("grabbed")

func release() -> void:
	if not is_grabbing:
		return
	if not grabbable is Grabbable:
		return

	grabbable.release()
	is_grabbing = false

	emit_signal("released")
