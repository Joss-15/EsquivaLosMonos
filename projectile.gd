extends Area2D

@export var velocidad = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direccion = Vector2.RIGHT.rotated(rotation)
	position += direccion * velocidad * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos"):
		body.die() # Llamamos a una función en el enemigo
		queue_free() # Eliminamos la bala # Replace with function body.
