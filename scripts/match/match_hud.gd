class_name MatchHud
extends Control

signal joystick_changed(direction: Vector2)
signal pass_pressed
signal shoot_started
signal shoot_released(power: float)
signal exit_pressed

var joystick_center := Vector2(145, 575)
var joystick_radius := 74.0
var joystick_value := Vector2.ZERO
var joystick_touch := -1
var shoot_held := false
var shot_power := 0.0
var score_text := "AZUL 0  -  0 ROJO"
var message := "Primer saque: controla al jugador con el aro amarillo"
var message_time := 4.0


func _ready() -> void:
	set_process(true)
	queue_redraw()


func set_score(blue: int, red: int) -> void:
	score_text = "AZUL %d  -  %d ROJO" % [blue, red]
	queue_redraw()


func show_message(text: String, duration := 1.5) -> void:
	message = text
	message_time = duration


func _process(delta: float) -> void:
	if shoot_held:
		shot_power = minf(1.0, shot_power + delta * 0.75)
	if message_time > 0.0:
		message_time -= delta
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var pointer := Vector2.ZERO
	var pressed := false
	var released := false
	var touch_id := -1
	if event is InputEventScreenTouch:
		pointer = event.position
		pressed = event.pressed
		released = not event.pressed
		touch_id = event.index
	elif event is InputEventScreenDrag:
		pointer = event.position
		touch_id = event.index
		if touch_id == joystick_touch:
			_update_joystick(pointer)
			accept_event()
			return
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pointer = event.position
		pressed = event.pressed
		released = not event.pressed
		touch_id = 999
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if joystick_touch == 999:
			_update_joystick(event.position)
			accept_event()
			return
	if pressed:
		if pointer.distance_to(joystick_center) < joystick_radius * 1.45:
			joystick_touch = touch_id
			_update_joystick(pointer)
		elif Rect2(955, 555, 130, 100).has_point(pointer):
			pass_pressed.emit()
		elif Rect2(1100, 520, 150, 135).has_point(pointer):
			shoot_held = true
			shot_power = 0.0
			shoot_started.emit()
		elif Rect2(22, 18, 100, 42).has_point(pointer):
			exit_pressed.emit()
	if released:
		if touch_id == joystick_touch:
			joystick_touch = -1
			joystick_value = Vector2.ZERO
			joystick_changed.emit(joystick_value)
		if shoot_held:
			shoot_held = false
			shoot_released.emit(maxf(0.18, shot_power))
	accept_event()


func _update_joystick(pointer: Vector2) -> void:
	joystick_value = (pointer - joystick_center).limit_length(joystick_radius) / joystick_radius
	joystick_changed.emit(joystick_value)


func _draw() -> void:
	draw_rect(Rect2(420, 17, 440, 52), Color(0.03, 0.08, 0.14, 0.82), true)
	draw_string(ThemeDB.fallback_font, Vector2(505, 53), score_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.WHITE)
	draw_rect(Rect2(22, 18, 100, 42), Color(0.05, 0.1, 0.17, 0.85), true)
	draw_string(ThemeDB.fallback_font, Vector2(39, 46), "SALIR", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
	if message_time > 0.0:
		draw_string(ThemeDB.fallback_font, Vector2(360, 98), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("fff1cf"))
	# Virtual stick.
	draw_circle(joystick_center, joystick_radius, Color(0.04, 0.09, 0.16, 0.45))
	draw_arc(joystick_center, joystick_radius, 0.0, TAU, 28, Color("b8d7eb"), 2.0)
	draw_circle(joystick_center + joystick_value * joystick_radius, 29, Color(0.35, 0.72, 0.93, 0.8))
	# Mobile buttons.
	draw_rect(Rect2(955, 555, 130, 100), Color("287ba5"), true)
	draw_rect(Rect2(1100, 520, 150, 135), Color("e87532"), true)
	draw_string(ThemeDB.fallback_font, Vector2(982, 614), "PASS", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(1132, 593), "SHOOT", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color.WHITE)
