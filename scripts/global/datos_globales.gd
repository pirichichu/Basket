extends Node

var pelo_actual: int = 0
var playera_actual: int = 0


func establecer_personalizacion(categoria: String, indice: int) -> void:
	match categoria:
		"pelo":
			pelo_actual = indice
		"playera":
			playera_actual = indice
