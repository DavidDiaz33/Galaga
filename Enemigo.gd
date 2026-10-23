extends Area2D

@export var escena_bala_enemigo: PackedScene = preload("res://BalaEnemigo.tscn")
@export var velocidad_vuelo: float = 220.0

var en_vuelo: bool = false
var direccion_vuelo: Vector2 = Vector2.DOWN
var tiempo_disparo: float = 0.0
var proximo_disparo: float = 3.0

func _ready() -> void:
	add_to_group("enemigos")
	area_entered.connect(_on_area_entered)
	proximo_disparo = randf_range(2.0, 6.0)

func _process(delta: float) -> void:
	tiempo_disparo += delta
	if tiempo_disparo >= proximo_disparo:
		tiempo_disparo = 0.0
		proximo_disparo = randf_range(3.0, 7.0)
		disparar()

	if en_vuelo:
		position += direccion_vuelo * velocidad_vuelo * delta
		if position.y > 750:
			position.y = -30
			position.x = randf_range(60.0, 580.0)
			en_vuelo = false

func iniciar_ataque_vuelo(pos_jugador: Vector2) -> void:
	if en_vuelo:
		return
	en_vuelo = true
	direccion_vuelo = (pos_jugador - global_position).normalized()
	if direccion_vuelo.y < 0.4:
		direccion_vuelo.y = 0.7
		direccion_vuelo = direccion_vuelo.normalized()

func disparar() -> void:
	if escena_bala_enemigo and is_inside_tree():
		var bala = escena_bala_enemigo.instantiate()
		bala.global_position = global_position + Vector2(0, 20)
		get_tree().current_scene.add_child(bala)

func recibir_dano() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("balas_jugador"):
		recibir_dano()
		area.queue_free()
	elif area.is_in_group("jugador"):
		if area.has_method("morir"):
			area.morir()
		queue_free()
