extends Node2D


func _ready() -> void:
	$CanvasLayer/BotonVolver.pressed.connect(_volver_al_lobby)


func _volver_al_lobby() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby/jugador.tscn")
