class_name PlayerController
extends Node

var virtual_direction := Vector2.ZERO


func movement_direction() -> Vector2:
	var keyboard := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return (virtual_direction if virtual_direction.length() > keyboard.length() else keyboard).limit_length()

