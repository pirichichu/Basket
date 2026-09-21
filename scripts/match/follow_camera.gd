class_name MatchFollowCamera
extends Camera2D

@export var target: Node2D


func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0
	position = Vector2(640, 360)


func _process(_delta: float) -> void:
	if target != null:
		# Favor the hoop and half court; player following remains deliberately subtle.
		global_position = Vector2(640, 360).lerp(target.global_position, 0.045)
