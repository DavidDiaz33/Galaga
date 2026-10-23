extends Node2D

@export var escena_enemigo: PackedScene = preload("res://Enemigo.tscn")
@export var escena_enemigo2: PackedScene = preload("res://Enemigo2.tscn")

@onready var nave: Node2D = $Nave
@onready var formacion: Node2D = $FormacionEnemigos

var velocidad_formacion: float = 60.0
var direccion_formacion: float = 1.0
var limite_izq: float = 20.0
var limite_der: float = 140.0
var tiempo_ataque: float = 0.0

func _ready() -> void:
	crear_oleada()

func _process(delta: float) -> void:
	# Mover formación de enemigos
	if formacion:
		formacion.position.x += velocidad_formacion * direccion_formacion * delta
		if formacion.position.x > limite_der:
			direccion_formacion = -1.0
		elif formacion.position.x < limite_izq:
			direccion_formacion = 1.0

	# Ataques en picada periódicos
	tiempo_ataque += delta
	if tiempo_ataque >= 2.0:
		tiempo_ataque = 0.0
		lanzar_enemigo_en_picada()

	# Oleada completada -> siguiente oleada
	if get_tree().get_nodes_in_group("enemigos").size() == 0:
		crear_oleada()

func crear_oleada() -> void:
	if not formacion:
		return

	formacion.position = Vector2(80, 70)
	direccion_formacion = 1.0

	var filas: int = 3
	var columnas: int = 7
	var espaciado_x: float = 65.0
	var espaciado_y: float = 50.0

	for fila in range(filas):
		for col in range(columnas):
			var enemigo: Node2D
			if fila == 0:
				enemigo = escena_enemigo2.instantiate()
			else:
				enemigo = escena_enemigo.instantiate()

			enemigo.position = Vector2(col * espaciado_x, fila * espaciado_y)
			formacion.add_child(enemigo)

func lanzar_enemigo_en_picada() -> void:
	var enemigos = get_tree().get_nodes_in_group("enemigos")
	var candidatos: Array[Node] = []
	for e in enemigos:
		if e is Area2D and not e.en_vuelo:
			candidatos.append(e)

	if candidatos.size() > 0 and is_instance_valid(nave):
		var elegido = candidatos.pick_random()
		var pos_global = elegido.global_position
		elegido.get_parent().remove_child(elegido)
		add_child(elegido)
		elegido.global_position = pos_global
		elegido.iniciar_ataque_vuelo(nave.global_position)
