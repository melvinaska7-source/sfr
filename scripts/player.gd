extends CharacterBody3D

const SPEED: float = 3.2
const JUMP_VELOCITY: float = 4.5
const GRAVITY: float = 9.8
const LOOK_SENSITIVITY: float = 0.0035
const MAX_PITCH: float = 1.4 # ~80 degrees

var _pitch: float = 0.0
var camera: Camera3D

func _ready() -> void:
	camera = get_node("Camera3D")

func _physics_process(delta: float) -> void:
	if GameManager.is_running:
		_handle_look()
		_handle_move(delta)
	else:
		velocity = Vector3.ZERO
	move_and_slide()

func _handle_look() -> void:
	var look := TouchInput.consume_look_delta()
	if look == Vector2.ZERO:
		return
	rotate_y(-look.x * LOOK_SENSITIVITY)
	_pitch = clamp(_pitch - look.y * LOOK_SENSITIVITY, -MAX_PITCH, MAX_PITCH)
	camera.rotation.x = _pitch

func _handle_move(delta: float) -> void:
	var input_vec: Vector2 = TouchInput.move_vector
	var direction := (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
	if direction.length() > 0.01:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0

	if is_on_floor():
		if TouchInput.consume_jump():
			velocity.y = JUMP_VELOCITY
	else:
		velocity.y -= GRAVITY * delta
