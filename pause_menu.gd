extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide() # Replace with function body.

func _input(event):
	if event.is_action_pressed("ui_cancel"): # "ui_cancel" es la tecla Esc por defecto
		toggle_pause()

func toggle_pause():
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_continuar_pressed() -> void:
	toggle_pause() # Replace with function body.

func _on_salir_pressed() -> void:
	get_tree().quit() # Replace with function body.
