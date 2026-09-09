extends Node

signal game_won
signal game_lost(reason: String)

const ROUND_SECONDS: float = 300.0

var time_left: float = ROUND_SECONDS
var is_running: bool = false

func _ready() -> void:
	call_deferred("start_round")

func start_round() -> void:
	time_left = ROUND_SECONDS
	is_running = true
	TouchInput.hide_message()
	TouchInput.show_controls()
	TouchInput.set_timer_text(_format_time(time_left))

func _process(delta: float) -> void:
	if not is_running:
		return
	time_left -= delta
	TouchInput.set_timer_text(_format_time(max(time_left, 0.0)))
	if time_left <= 0.0:
		win_game()

func _format_time(t: float) -> String:
	var total := int(ceil(t))
	var m := int(total / 60)
	var s := total % 60
	return "%02d:%02d" % [m, s]

func win_game() -> void:
	if not is_running:
		return
	is_running = false
	TouchInput.hide_controls()
	TouchInput.show_message("ТЫ ПОБЕДИЛ", Color(0.2, 1.0, 0.3))
	game_won.emit()

func lose_game(reason: String) -> void:
	if not is_running:
		return
	is_running = false
	TouchInput.hide_controls()
	TouchInput.show_message("ТЫ ПРОИГРАЛ\n" + reason, Color(1.0, 0.15, 0.15))
	game_lost.emit(reason)
