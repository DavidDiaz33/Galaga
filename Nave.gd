extends Area2D

@export var velocidad: float = 380.0
@export var escena_bala: PackedScene = preload("res://Bala.tscn")
@export var cadencia_disparo: float = 0.22
@export var tiempo_reinicio: float = 1.0

var esta_muerto: bool = false
var tiempo_ultimo_disparo: float = 0.0

func _ready() -> void:
	add_to_group("jugador")
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if esta_muerto:
		return

	# Movimiento horizontal con teclas de flechas o A/D
	var direccion: float = 0.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direccion -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direccion += 1.0

	position.x += direccion * velocidad * delta
	position.x = clamp(position.x, 30.0, 610.0)

	# Disparo con barra espaciadora, Enter o clic izquierdo
	tiempo_ultimo_disparo += delta
	var quiere_disparar: bool = Input.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if quiere_disparar and tiempo_ultimo_disparo >= cadencia_disparo:
		tiempo_ultimo_disparo = 0.0
		disparar()

func disparar() -> void:
	if not escena_bala or not is_inside_tree():
		return
	var bala = escena_bala.instantiate()
	bala.global_position = global_position + Vector2(0, -25)
	get_tree().current_scene.add_child(bala)

func morir() -> void:
	if esta_muerto:
		return
	esta_muerto = true

	# Efecto visual: cambiar color y desvanecer
	var sprite: Sprite2D = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color(1.0, 0.2, 0.2)
		var tween = create_tween()
		if tween:
			tween.tween_property(sprite, "modulate:a", 0.0, 0.5)

	# Desactivar colisión
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# Reiniciar juego automáticamente sin mensajes
	await get_tree().create_timer(tiempo_reinicio).timeout
	if is_inside_tree():
		get_tree().reload_current_scene()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemigos") or area.is_in_group("balas_enemigas"):
		morir()
