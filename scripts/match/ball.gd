class_name MatchBall
extends Node2D

signal arrived(receiver: MatchPlayer)
signal scored(team_id: int)
signal intercepted(defender: MatchPlayer)

enum State { HELD, PASSING, SHOOTING, LOOSE }

var state := State.LOOSE
var holder: MatchPlayer
var receiver: MatchPlayer
var velocity := Vector2.ZERO
var flight_time := 0.0
var flight_duration := 0.0
var start_position := Vector2.ZERO
var target_position := Vector2.ZERO
var shooting_team := 0
var pass_defenders: Array[MatchPlayer] = []
var checked_interceptors: Dictionary = {}
@export var interception_radius := 44.0


func hold_by(player: MatchPlayer) -> void:
	state = State.HELD
	holder = player
	receiver = null


func pass_to(from: MatchPlayer, to: MatchPlayer, defenders: Array[MatchPlayer]) -> void:
	state = State.PASSING
	holder = null
	receiver = to
	start_position = from.global_position
	target_position = to.global_position + to.velocity * 0.22
	flight_time = 0.0
	flight_duration = clampf(start_position.distance_to(target_position) / 740.0, 0.26, 0.7)
	global_position = start_position
	pass_defenders = defenders
	checked_interceptors.clear()


func shoot_from(from: MatchPlayer, power: float, accuracy: float) -> void:
	state = State.SHOOTING
	holder = null
	receiver = null
	shooting_team = from.team_id
	start_position = from.global_position
	var miss := (1.0 - accuracy) * 115.0
	target_position = MatchCourt.HOOP + Vector2(randf_range(-miss, miss), randf_range(-miss * 0.45, miss * 0.45))
	flight_time = 0.0
	flight_duration = lerpf(0.38, 0.9, power)
	global_position = start_position


func _process(delta: float) -> void:
	match state:
		State.HELD:
			if holder != null:
				var bounce := absf(sin(Time.get_ticks_msec() * 0.012)) * 22.0
				global_position = holder.global_position + Vector2(20, 20 + bounce)
		State.PASSING, State.SHOOTING:
			flight_time += delta
			var t := minf(flight_time / flight_duration, 1.0)
			global_position = start_position.lerp(target_position, t) + Vector2(0, -sin(t * PI) * 75.0)
			if state == State.PASSING and _try_interception(t):
				queue_redraw()
				return
			if t >= 1.0:
				if state == State.PASSING and receiver != null:
					arrived.emit(receiver)
				elif state == State.SHOOTING:
					if global_position.distance_to(MatchCourt.HOOP) < 28.0:
						scored.emit(shooting_team)
					else:
						state = State.LOOSE
						velocity = (global_position - MatchCourt.HOOP).normalized() * 170.0
		State.LOOSE:
			global_position += velocity * delta
			velocity = velocity.move_toward(Vector2.ZERO, delta * 260.0)
	queue_redraw()


func _try_interception(progress: float) -> bool:
	var ground_ball_position := start_position.lerp(target_position, progress)
	var pass_speed := start_position.distance_to(target_position) / maxf(flight_duration, 0.01)
	var timing_factor := clampf(1.12 - pass_speed / 1800.0, 0.58, 1.0)
	for defender in pass_defenders:
		var defender_id := defender.get_instance_id()
		if checked_interceptors.has(defender_id):
			continue
		var distance := defender.global_position.distance_to(ground_ball_position)
		if distance > interception_radius:
			continue
		checked_interceptors[defender_id] = true
		var line_quality := 1.0 - distance / interception_radius
		if randf() <= line_quality * timing_factor:
			state = State.HELD
			holder = defender
			receiver = null
			intercepted.emit(defender)
			return true
	return false


func _draw() -> void:
	draw_circle(Vector2.ZERO, 11.0, Color("f28c28"))
	draw_arc(Vector2.ZERO, 11.0, -1.1, 1.1, 10, Color("4d2418"), 1.5)
	draw_arc(Vector2.ZERO, 11.0, 2.0, 4.2, 10, Color("4d2418"), 1.5)
	draw_line(Vector2(-11, 0), Vector2(11, 0), Color("4d2418"), 1.5)
