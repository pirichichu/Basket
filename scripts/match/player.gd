class_name MatchPlayer
extends Node2D

@export var player_name := "Player"
@export var team_id := 0
@export var is_human := false
@export var move_speed := 260.0
@export_range(0.0, 1.0) var shooting_rating := 0.65

var velocity := Vector2.ZERO
var has_ball := false
var target_position := Vector2.ZERO
var tint := Color("55c7ff")
var number := 1


func _ready() -> void:
	target_position = global_position
	queue_redraw()


func _process(_delta: float) -> void:
	# Near players are larger, reinforcing the 3/4 presentation without affecting logic.
	var depth := inverse_lerp(MatchCourt.PLAYABLE_RECT.position.y, MatchCourt.PLAYABLE_RECT.end.y, global_position.y)
	scale = Vector2.ONE * lerpf(0.72, 1.10, depth)


func move_towards(direction: Vector2, delta: float, speed_scale := 1.0) -> void:
	velocity = direction.limit_length() * move_speed * speed_scale
	global_position += velocity * delta
	global_position.x = clampf(global_position.x, MatchCourt.PLAYABLE_RECT.position.x, MatchCourt.PLAYABLE_RECT.end.x)
	global_position.y = clampf(global_position.y, MatchCourt.PLAYABLE_RECT.position.y, MatchCourt.PLAYABLE_RECT.end.y)


func _draw() -> void:
	if is_human:
		draw_arc(Vector2.ZERO, 31.0, 0.0, TAU, 24, Color("ffe55c"), 4.0)
		draw_colored_polygon(PackedVector2Array([Vector2(0, -42), Vector2(-9, -29), Vector2(9, -29)]), Color("ffe55c"))
	draw_circle(Vector2.ZERO, 22.0, tint)
	# Facing marker: all players orient toward the basket at the top of the screen.
	draw_colored_polygon(PackedVector2Array([Vector2(0, -20), Vector2(-7, -7), Vector2(7, -7)]), Color.WHITE)
	draw_circle(Vector2(0, -4), 15.0, tint.lightened(0.18))
	draw_circle(Vector2.ZERO, 22.0, Color("152033"), false, 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(-5, 7), str(number), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
	if has_ball:
		draw_circle(Vector2(18, 26), 5.0, Color("ffe55c"))
