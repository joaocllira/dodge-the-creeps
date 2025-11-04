extends Area2D
signal hit


@export var speed: float = 400.0 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var mouse_move_direction: String = "none";

var mouse_motion_dir: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		# Raw motion delta (pixels moved since last frame)
		var motion: Vector2 = event.relative
		
		# Normalize to unit direction (-1 to 1)
		if motion.length() > 0:
			mouse_motion_dir = motion.normalized()
			
			# Separate into cardinal directions
			mouse_move_direction = determine_cardinal_direction(mouse_motion_dir)

func determine_cardinal_direction(dir: Vector2) -> String:
	# Threshold to avoid jitter (optional, tweak 0.3-0.5)
	var threshold: float = 0.4
	
	if abs(dir.x) > threshold:
		if dir.x > 0:
			return "right"
		else:
			return "left"
	elif abs(dir.y) > threshold:
		if dir.y < 0:  # Y-up in Go
			return "up"
		else:
			return "down"
	else:
		return "none"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	# if Input.is_action_pressed("move_right"):
	#	velocity.x += 1
	# if Input.is_action_pressed("move_left"):
	#	velocity.x -= 1
	# if Input.is_action_pressed("move_down"):
	#	velocity.y += 1
	# if Input.is_action_pressed("move_up"):
	#	velocity.y -= 1
		
	if mouse_move_direction != "none":
		if mouse_move_direction == "right":
			velocity.x += 1
		if mouse_move_direction == "left":
			velocity.x -= 1
		if mouse_move_direction == "down":
			velocity.y += 1
		if mouse_move_direction == "up":
			velocity.y -= 1

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
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0
		
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
