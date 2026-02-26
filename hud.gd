extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game
@export var corazon_tex : Texture2D
@onready var contenedor = $ContenedorVidas

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ContenedorVidas.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "¡Esquiva los monos!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()


func _on_message_timer_timeout() -> void:
	$Message.hide()


func actualizar_vidas(vidas_actuales: int):
	$ContenedorVidas.show()
	# Primero borramos los corazones viejos
	for n in contenedor.get_children():
		n.queue_free()
		
	# Creamos tantos TextureRect como vidas queden
	for i in range(vidas_actuales):
		var rect = TextureRect.new()
		rect.texture = corazon_tex
		rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL # Para que no se deforme
		rect.custom_minimum_size = Vector2(50, 50) # Ajusta el tamaño aquí
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		contenedor.add_child(rect)
