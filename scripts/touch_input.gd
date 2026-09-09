extends Node

var move_vector: Vector2 = Vector2.ZERO
var look_delta: Vector2 = Vector2.ZERO
var jump_just_pressed: bool = false
var controls_enabled: bool = true

var _joystick_touch_index: int = -1
var _joystick_base_pos: Vector2 = Vector2.ZERO
var _look_touch_index: int = -1

const JOYSTICK_RADIUS := 100.0
const JOYSTICK_MARGIN := 140.0
const JUMP_BUTTON_RADIUS := 60.0
const JUMP_BUTTON_MARGIN := 120.0

var _canvas: CanvasLayer
var _joystick_base_draw: Control
var _joystick_knob_draw: Control
var _jump_button_draw: Control
var _timer_label: Label
var _message_label: Label

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	_canvas = CanvasLayer.new()
	add_child(_canvas)

	_joystick_base_draw = _make_circle(JOYSTICK_RADIUS, Color(1, 1, 1, 0.25))
	_joystick_knob_draw = _make_circle(JOYSTICK_RADIUS * 0.5, Color(1, 1, 1, 0.55))
	_jump_button_draw = _make_circle(JUMP_BUTTON_RADIUS, Color(1, 1, 1, 0.35))
	_canvas.add_child(_joystick_base_draw)
	_canvas.add_child(_joystick_knob_draw)
	_canvas.add_child(_jump_button_draw)

	_timer_label = Label.new()
	_timer_label.add_theme_font_size_override("font_size", 42)
	_timer_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_timer_label.position = Vector2(0, 40)
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_canvas.add_child(_timer_label)

	_message_label = Label.new()
	_message_label.add_theme_font_size_override("font_size", 64)
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_message_label.add_theme_color_override("font_color", Color(1, 0.15, 0.15))
	_message_label.visible = false
	_canvas.add_child(_message_label)

	call_deferred("_reposition_ui")
	get_viewport().size_changed.connect(_reposition_ui)

func _reposition_ui() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	_joystick_base_pos = Vector2(JOYSTICK_MARGIN, vp_size.y - JOYSTICK_MARGIN)
	_joystick_base_draw.position = _joystick_base_pos - Vector2(JOYSTICK_RADIUS, JOYSTICK_RADIUS)
	_joystick_knob_draw.position = _joystick_base_pos - Vector2(JOYSTICK_RADIUS * 0.5, JOYSTICK_RADIUS * 0.5)
	_jump_button_draw.position = Vector2(vp_size.x - JUMP_BUTTON_MARGIN, vp_size.y - JUMP_BUTTON_MARGIN) - Vector2(JUMP_BUTTON_RADIUS, JUMP_BUTTON_RADIUS)

func _make_circle(radius: float, color: Color) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(radius * 2, radius * 2)
	c.size = c.custom_minimum_size
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := ColorRect.new()
	panel.color = color
	panel.size = c.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(panel)
	return c

func _input(event: InputEvent) -> void:
	if not controls_enabled:
		return
	var vp_size := get_viewport().get_visible_rect().size
	var jump_pos := Vector2(vp_size.x - JUMP_BUTTON_MARGIN, vp_size.y - JUMP_BUTTON_MARGIN)

	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.distance_to(_joystick_base_pos) <= JOYSTICK_RADIUS * 1.6 and _joystick_touch_index == -1:
				_joystick_touch_index = event.index
				_update_joystick(event.position)
			elif event.position.distance_to(jump_pos) <= JUMP_BUTTON_RADIUS * 1.6:
				jump_just_pressed = true
			elif _look_touch_index == -1:
				_look_touch_index = event.index
		else:
			if event.index == _joystick_touch_index:
				_joystick_touch_index = -1
				move_vector = Vector2.ZERO
				_joystick_knob_draw.position = _joystick_base_pos - Vector2(JOYSTICK_RADIUS * 0.5, JOYSTICK_RADIUS * 0.5)
			elif event.index == _look_touch_index:
				_look_touch_index = -1
	elif event is InputEventScreenDrag:
		if event.index == _joystick_touch_index:
			_update_joystick(event.position)
		elif event.index == _look_touch_index:
			look_delta += event.relative

func _update_joystick(pos: Vector2) -> void:
	var offset: Vector2 = pos - _joystick_base_pos
	if offset.length() > JOYSTICK_RADIUS:
		offset = offset.normalized() * JOYSTICK_RADIUS
	_joystick_knob_draw.position = (_joystick_base_pos + offset) - Vector2(JOYSTICK_RADIUS * 0.5, JOYSTICK_RADIUS * 0.5)
	move_vector = offset / JOYSTICK_RADIUS

func consume_look_delta() -> Vector2:
	var d := look_delta
	look_delta = Vector2.ZERO
	return d

func consume_jump() -> bool:
	var j := jump_just_pressed
	jump_just_pressed = false
	return j

func set_timer_text(text: String) -> void:
	if _timer_label:
		_timer_label.text = text

func show_message(text: String, color: Color = Color(1, 0.15, 0.15)) -> void:
	_message_label.text = text
	_message_label.add_theme_color_override("font_color", color)
	_message_label.visible = true

func hide_message() -> void:
	_message_label.visible = false

func hide_controls() -> void:
	controls_enabled = false
	move_vector = Vector2.ZERO
	_joystick_base_draw.visible = false
	_joystick_knob_draw.visible = false
	_jump_button_draw.visible = false

func show_controls() -> void:
	controls_enabled = true
	_joystick_base_draw.visible = true
	_joystick_knob_draw.visible = true
	_jump_button_draw.visible = true
