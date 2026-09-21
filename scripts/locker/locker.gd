extends Control

const CANTIDAD_DE_OPCIONES := 3
const RUTA_SPRITES := "res://assets/legacy/sprites/"

var categoria_actual := "pelo"

@onready var pelo_sprite: Sprite2D = $CanvasLayer/Previsualizacion/PeloSprite
@onready var playera_sprite: Sprite2D = $CanvasLayer/Previsualizacion/PlayeraSprite
@onready var botones_opcion: Array[Button] = [
	$CanvasLayer/ColumnaDerecha/BtnOpcion0,
	$CanvasLayer/ColumnaDerecha/BtnOpcion1,
	$CanvasLayer/ColumnaDerecha/BtnOpcion2,
]


func _ready() -> void:
	$CanvasLayer/BotonVolver.pressed.connect(_volver_al_lobby)
	$CanvasLayer/ColumnaIzquierda/BtnCategoriaPelo.pressed.connect(func() -> void: cambiar_categoria("pelo"))
	$CanvasLayer/ColumnaIzquierda/BtnCategoriaPlayera.pressed.connect(func() -> void: cambiar_categoria("playera"))

	for indice in botones_opcion.size():
		botones_opcion[indice].pressed.connect(elegir.bind(indice))

	cambiar_categoria(categoria_actual)
	actualizar_previsualizacion()


func _volver_al_lobby() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby/jugador.tscn")


func cambiar_categoria(nueva_categoria: String) -> void:
	categoria_actual = nueva_categoria
	for indice in botones_opcion.size():
		botones_opcion[indice].text = "%s %d" % [categoria_actual.capitalize(), indice + 1]


func elegir(indice: int) -> void:
	DatosGlobales.establecer_personalizacion(categoria_actual, indice)
	actualizar_previsualizacion()


func actualizar_previsualizacion() -> void:
	pelo_sprite.texture = cargar_sprite("pelos", "pelo", DatosGlobales.pelo_actual)
	playera_sprite.texture = cargar_sprite("playeras", "playera", DatosGlobales.playera_actual)


func cargar_sprite(carpeta: String, prefijo: String, indice: int) -> Texture2D:
	var ruta := "%s%s/%s_%d.png" % [RUTA_SPRITES, carpeta, prefijo, clampi(indice, 0, CANTIDAD_DE_OPCIONES - 1)]
	return load(ruta) as Texture2D
