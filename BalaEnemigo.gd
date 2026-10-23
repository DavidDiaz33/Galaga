extends Area2D

@export var velocidad: float = 320.0

func _ready() -> void:
	add_to_group("balas_enemigas")
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position.y += velocidad * delta
	if position.y > 750:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("jugador"):
		if area.has_method("morir"):
			area.morir()
		queue_free()
