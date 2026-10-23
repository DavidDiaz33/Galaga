extends Area2D

@export var velocidad: float = 650.0

func _ready() -> void:
	add_to_group("balas_jugador")
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position.y -= velocidad * delta
	if position.y < -30:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemigos"):
		if area.has_method("recibir_dano"):
			area.recibir_dano()
		queue_free()
