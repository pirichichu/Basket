class_name ShotTiming
extends Node2D

@export var meter_duration := 1.15
@export var green_center := 0.58
@export var green_window_half_width := 0.10

var shooter: MatchPlayer
var active := false
var progress := 0.0
var active_green_window := 0.10
var last_release_was_green := false


func begin(player: MatchPlayer) -> void:
	shooter = player
	progress = 0.0
	last_release_was_green = false
	active_green_window = clampf(green_window_half_width + (player.shooting_rating - 0.5) * 0.10, 0.06, 0.16)
	active = true
	visible = true
	queue_redraw()


func release() -> float:
	if not active:
		return 0.0
	var timing_distance := absf(progress - green_center)
	last_release_was_green = timing_distance <= active_green_window
	var quality := 1.0 if last_release_was_green else clampf(1.0 - (timing_distance - active_green_window) / maxf(active_green_window * 2.2, 0.01), 0.0, 0.84)
	active = false
	visible = false
	return quality


func cancel() -> void:
	active = false
	visible = false


func _process(delta: float) -> void:
	if not active or shooter == null:
		return
	global_position = shooter.global_position + Vector2(-46, -75)
	progress = fmod(progress + delta / meter_duration, 1.0)
	queue_redraw()


func _draw() -> void:
	var bar_rect := Rect2(0, 0, 92, 12)
	var green_start := (green_center - active_green_window) * bar_rect.size.x
	var green_width := active_green_window * 2.0 * bar_rect.size.x
	draw_rect(bar_rect, Color("172030"), true)
	draw_rect(Rect2(green_start, 1, green_width, 10), Color("42d978"), true)
	draw_rect(bar_rect, Color.WHITE, false, 1.5)
	draw_line(Vector2(progress * bar_rect.size.x, -4), Vector2(progress * bar_rect.size.x, 16), Color("ffe55c"), 3.0)
