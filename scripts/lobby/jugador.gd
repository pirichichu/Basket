extends CharacterBody2D

var cambiando_pantalla := false

@onready var fade: ColorRect = $Fade


func _ready() -> void:
	$TextureButton.pressed.connect(func() -> void: iniciar_viaje("res://scenes/match/match.tscn"))
	$BotonLocker.pressed.connect(func() -> void: iniciar_viaje("res://scenes/locker/locker.tscn"))
	fade.modulate.a = 1.0
	create_tween().tween_property(fade, "modulate:a", 0.0, 0.25)


func iniciar_viaje(escena: String) -> void:
	if cambiando_pantalla:
		return

	cambiando_pantalla = true
	var transicion := create_tween()
	transicion.tween_property(fade, "modulate:a", 1.0, 0.2)
	await transicion.finished
	get_tree().change_scene_to_file(escena)
