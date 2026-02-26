extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	print("He tocado a: ", area.name) # Esto aparecerá en la consola de Godot
	if area.is_in_group("jugador") or area.name == "Player":
		print("Es el jugador! Activando dash...")
		area.activar_power_up() # Llamamos a una función que crearemos en el jugador
		queue_free()
