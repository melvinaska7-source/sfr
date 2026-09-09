extends CharacterBody3D

enum State { PATROL, INVESTIGATE, CHASE }

@export var patrol_speed: float = 1.6
@export var chase_speed: float = 2.6
@export var vision_range: float = 9.0
@export var vision_angle_deg: float = 70.0
@export var hear_range: float = 4.0
@export var catch_distance: float = 1.0

var player: CharacterBody3D
var patrol_points: Array = []

var state: State = State.PATROL
var _patrol_index: int = 0
var _investigate_target: Vector3 = Vector3.ZERO
var _state_timer: float = 0.0

var vision_ray: RayCast3D

const GRAVITY: float = 9.8

func _ready() -> void:
	vision_ray = get_node("VisionRay")

func _physics_process(delta: float) -> void:
	if not GameManager.is_running:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	match state:
		State.PATROL:
			_do_patrol(delta)
		State.INVESTIGATE:
			_do_investigate(delta)
		State.CHASE:
			_do_chase(delta)

	_check_catch()
	move_and_slide()

func _do_patrol(delta: float) -> void:
	if patrol_points.is_empty():
		return
	var target: Vector3 = patrol_points[_patrol_index]
	_move_towards(target, patrol_speed)
	if global_position.distance_to(target) < 0.5:
		_patrol_index = (_patrol_index + 1) % patrol_points.size()

	if _can_see_player():
		_enter_chase()
	elif _can_hear_player():
		_enter_investigate(player.global_position)

func _do_investigate(delta: float) -> void:
	_move_towards(_investigate_target, patrol_speed)
	_state_timer -= delta
	if _can_see_player():
		_enter_chase()
		return
	if global_position.distance_to(_investigate_target) < 0.6 or _state_timer <= 0.0:
		state = State.PATROL

func _do_chase(delta: float) -> void:
	_move_towards(player.global_position, chase_speed)
	if not _can_see_player():
		_state_timer -= delta
		if _state_timer <= 0.0:
			_enter_investigate(player.global_position)
	else:
		_state_timer = 2.0

func _move_towards(target: Vector3, speed: float) -> void:
	var to_target: Vector3 = target - global_position
	to_target.y = 0
	if to_target.length() > 0.05:
		var dir := to_target.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		look_at(global_position + dir, Vector3.UP)
	else:
		velocity.x = 0
		velocity.z = 0

func _can_see_player() -> bool:
	if player == null:
		return false
	var to_player: Vector3 = player.global_position - global_position
	var dist := to_player.length()
	if dist > vision_range:
		return false
	var forward: Vector3 = -global_transform.basis.z
	var angle := rad_to_deg(forward.angle_to(to_player.normalized()))
	if angle > vision_angle_deg:
		return false
	vision_ray.target_position = vision_ray.to_local(player.global_position + Vector3(0, 1.0, 0))
	vision_ray.force_raycast_update()
	if vision_ray.is_colliding():
		var collider = vision_ray.get_collider()
		if collider != player:
			return false
	return true

func _can_hear_player() -> bool:
	if player == null:
		return false
	var dist := global_position.distance_to(player.global_position)
	return dist <= hear_range

func _enter_chase() -> void:
	state = State.CHASE
	_state_timer = 2.0

func _enter_investigate(target: Vector3) -> void:
	state = State.INVESTIGATE
	_investigate_target = target
	_state_timer = 4.0

func _check_catch() -> void:
	if player == null:
		return
	if state == State.CHASE and global_position.distance_to(player.global_position) <= catch_distance:
		GameManager.lose_game("Враг тебя поймал.")
