extends Area2D
signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
@export var projectile_scene : PackedScene
@onready var punto_disparo = $PuntoDisparo
@export var dash_speed = 1200
var can_dash = false        # ¿Tiene el power-up?
var is_dashing = false      # ¿Está ejecutando el dash ahora?
var is_invincible = false   # Cooldown de invencibilidad
@export var salud_max = 3
var salud_actual

func start(pos):
	salud_actual = salud_max
	position = pos
	show()
	$CollisionShape2D.disabled = false
	get_parent().get_node("HUD").actualizar_vidas(salud_actual)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_just_pressed("shoot"):
		disparar()
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		ejecutar_embestida()

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
		if velocity.x < 0:
			punto_disparo.position.x = -20
			punto_disparo.rotation = PI
		else:
			punto_disparo.position.x = 20
			punto_disparo.rotation = 0

	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0
		if velocity.y < 0:
			punto_disparo.rotation = -PI/2 # -90 grados
		else:
			punto_disparo.rotation = PI/2  # 90 grados

func disparar():
	var bala = projectile_scene.instantiate() # Añadimos la bala a la raíz de la escena para que no se mueva con el jugador
	get_tree().root.add_child(bala) # Posicionamos la bala donde está el cañón
	bala.global_transform = punto_disparo.global_transform
	bala.rotation = punto_disparo.rotation
	
func activar_power_up():
	can_dash = true
	$AnimatedSprite2D.modulate = Color(1.0, 0.855, 0.681, 1.0) # Amarillo
	
func ejecutar_embestida():
	var velocity = Vector2.ZERO # The player's movement vector.
	is_dashing = true
	is_invincible = true
	
	# Guardamos la velocidad actual para saber hacia dónde embestir
	var dash_velocity = velocity.normalized() * dash_speed
	if dash_velocity == Vector2.ZERO: # Si está quieto, embiste hacia donde mira
		dash_velocity = Vector2.RIGHT.rotated(punto_disparo.rotation) * dash_speed
		
	# Usamos un Timer por código para la duración del dash (0.2 segundos)
	var timer = get_tree().create_timer(0.2)
	
	# Mientras dure el dash, movemos al personaje ignorando colisiones de daño
	while timer.time_left > 0:
		position += dash_velocity * get_process_delta_time()
		position = position.clamp(Vector2.ZERO, screen_size)
		await get_tree().process_frame
	is_dashing = false
	# Cooldown de invencibilidad (1 segundo)
	await get_tree().create_timer(1.0).timeout
	is_invincible = false
	$AnimatedSprite2D.modulate = Color(1, 1, 1) # Color normal
	can_dash = false


func _on_body_entered(body: Node2D) -> void:
	if is_invincible or is_dashing:
		if body.is_in_group("enemigos"):
			body.die() # Mata al enemigo si lo toca durante el dash
		return # No recibe daño
		
	salud_actual -= 1
	get_parent().get_node("HUD").actualizar_vidas(salud_actual)
	
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "modulate", Color.RED, 0.1)
	tween.tween_property($AnimatedSprite2D, "modulate", Color.WHITE, 0.1)
	
	if salud_actual <= 0:
		hide() # Player disappears after being hit.
		hit.emit()
		# Must be deferred as we can't change physics properties on a physics callback.
		$CollisionShape2D.set_deferred("disabled", true)
	else:
		# Volverse invencible un momento tras el golpe
		is_invincible = true
		await get_tree().create_timer(1.0).timeout
		is_invincible = false
