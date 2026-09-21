class_name MatchCourt
extends Node2D

## Gameplay coordinates are deliberately independent from the court artwork.
## When final art arrives, adjust these values after mapping it to the image.
const PLAYABLE_RECT := Rect2(170, 170, 940, 450)
const HOOP := Vector2(640, 138)

@export var court_background: Texture2D


func _draw() -> void:
	# `court_background` can be assigned later without changing gameplay zones.
	draw_rect(Rect2(0, 0, 1280, 720), Color("102033"))
	if court_background != null:
		draw_texture_rect(court_background, Rect2(0, 0, 1280, 720), false)
		return
	# Placeholder visual: a trapezoid creates a 3/4 view toward the hoop.
	var court_shape: PackedVector2Array = PackedVector2Array([
		Vector2(380, 125), Vector2(900, 125), Vector2(1175, 665), Vector2(105, 665),
	])
	draw_colored_polygon(court_shape, Color("d88b4a"))
	draw_polyline(court_shape + PackedVector2Array([court_shape[0]]), Color("fff1cf"), 5.0)
	# Perspective-friendly placeholder markings. They are visual only.
	draw_colored_polygon(PackedVector2Array([Vector2(510, 140), Vector2(770, 140), Vector2(875, 335), Vector2(405, 335)]), Color("bf6e39"))
	draw_polyline(PackedVector2Array([Vector2(510, 140), Vector2(770, 140), Vector2(875, 335), Vector2(405, 335), Vector2(510, 140)]), Color("fff1cf"), 3.0)
	draw_arc(HOOP, 260.0, 0.30, PI - 0.30, 36, Color("fff1cf"), 4.0)
	# Backboard and rim live at the far end of the visual court.
	draw_line(Vector2(570, 102), Vector2(710, 102), Color.WHITE, 8.0)
	draw_line(Vector2(640, 102), Vector2(640, 125), Color.WHITE, 5.0)
	draw_arc(HOOP, 16.0, 0.0, TAU, 20, Color("ef4a33"), 6.0)
