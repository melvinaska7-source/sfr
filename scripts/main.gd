extends Node3D

const PlayerScript = preload("res://scripts/player.gd")
const EnemyScript = preload("res://scripts/enemy.gd")

func _ready() -> void:
	_build_level()
	_spawn_light()
	var player := _spawn_player(Vector3(0, 1, 0))
	_spawn_enemy(player, [Vector3(0, 0, -10), Vector3(6, 0, -10), Vector3(6, 0, -18), Vector3(0, 0, -18)])

func _build_level() -> void:
	# ВРЕМЕННЫЙ тестовый коридор. На этапе 2 заменим на реальную школу по плану эвакуации.
	_add_box(Vector3(20, 0.2, 40), Vector3(0, -0.1, -15), Color(0.75, 0.75, 0.78))
	_add_box(Vector3(0.3, 4, 40), Vector3(-10, 2, -15), Color(0.9, 0.9, 0.85))
	_add_box(Vector3(0.3, 4, 40), Vector3(10, 2, -15), Color(0.9, 0.9, 0.85))
	_add_box(Vector3(20, 4, 0.3), Vector3(0, 2, 5), Color(0.9, 0.9, 0.85))
	_add_box(Vector3(20, 4, 0.3), Vector3(0, 2, -35), Color(0.9, 0.9, 0.85))
	_add_box(Vector3(8, 4, 0.3), Vector3(-6, 2, -10), Color(0.85, 0.85, 0.8))
	_add_box(Vector3(0.3, 4, 12), Vector3(3, 2, -16), Color(0.85, 0.85, 0.8))

func _add_box(size: Vector3, pos: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.position = pos

	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh_instance.material_override = mat
	body.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)

	add_child(body)

func _spawn_light() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -30, 0)
	light.light_energy = 1.1
	add_child(light)

	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.05, 0.05, 0.06)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.5, 0.5, 0.55)
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)

func _spawn_player(spawn_pos: Vector3) -> CharacterBody3D:
	var player := CharacterBody3D.new()
	player.name = "Player"
	player.set_script(PlayerScript)
	player.position = spawn_pos

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.35
	shape.height = 1.7
	collision.shape = shape
	collision.position = Vector3(0, 0.85, 0)
	player.add_child(collision)

	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.position = Vector3(0, 1.6, 0)
	camera.fov = 80
	player.add_child(camera)

	add_child(player)
	return player

func _spawn_enemy(player: CharacterBody3D, patrol_points: Array) -> void:
	var enemy := CharacterBody3D.new()
	enemy.name = "Enemy"
	enemy.set_script(EnemyScript)
	enemy.position = patrol_points[0]
	enemy.player = player
	enemy.patrol_points = patrol_points

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	collision.shape = shape
	collision.position = Vector3(0, 0.9, 0)
	enemy.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.8, 1.8, 0.5)
	mesh_instance.mesh = box
	mesh_instance.position = Vector3(0, 0.9, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.1, 0.1)
	mesh_instance.material_override = mat
	enemy.add_child(mesh_instance)

	var ray := RayCast3D.new()
	ray.name = "VisionRay"
	ray.position = Vector3(0, 1.5, 0)
	ray.target_position = Vector3(0, 0, -1)
	ray.enabled = true
	enemy.add_child(ray)

	add_child(enemy)
