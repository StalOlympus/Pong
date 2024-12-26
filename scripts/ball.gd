extends CharacterBody2D
class_name Ball

@export var hit_sound: AudioStreamPlayer
@export var speed: float = 300.0
@export var max_speed: float = 600
@export var min_speed: float = 200
@export var speed_increase: float = 50
@export var max_bounce_angle: float = 75

var hit_edge: bool = false
var paddles: Array = []
var timer: Timer

signal paddle_hit(paddle: CharacterBody2D, hit_position: Vector2)

func _ready() -> void:
	# Get all paddles in the "Paddle" group
	paddles = get_tree().get_nodes_in_group("Paddle")
	
	# Reset hit edge flag
	hit_edge = false
	
	# Enable all paddles initially
	for paddle in paddles:
		paddle.disable = false
		
	# Create timer for resetting paddle hit state
	timer = Timer.new()
	timer.wait_time = 0.1 # 0.1 second timeout
	timer.one_shot = true # Timer runs only once
	add_child(timer)
	
	# Connect timer timeout to reset function
	timer.timeout.connect(func() -> void:
		# Reset hit edge flag
		hit_edge = false
		# Re-enable all paddles
		for paddle in paddles:
			paddle.disable = false
	)

func _physics_process(delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)

	if collision:
		handle_collision(collision)
	
func handle_collision(collision: KinematicCollision2D) -> void:
	var collider = collision.get_collider()
	var normal = collision.get_normal()

	if collider.is_in_group("Paddle") and not hit_edge:
		hit_sound.pitch_scale = randf_range(0.9, 1.1)
		hit_sound.play()
		if abs(normal.x) > abs(normal.y):
			handle_paddle_collision(collision, collider)
		else:
			print("Hit paddle's " + ("top" if normal.y < 0 else "bottom") + " edge!")
			velocity.y = -velocity.y * 0.8 # Reduce vertical component
			var new_x = (1.5 * speed) if velocity.x > 0 else (-1.5 * speed)
			velocity.x = new_x
			collider.velocity.y = -collider.velocity.y * 3
			collider.disable = true
			hit_edge = true
			timer.start()
	else:
		hit_sound.play()
		# Wall collision
		velocity = velocity.bounce(normal)
		
		# Ensure minimum speed after wall bounces
		if velocity.length() < min_speed:
			velocity = velocity.normalized() * min_speed

func handle_paddle_collision(collision: KinematicCollision2D, paddle: CharacterBody2D) -> void:
	paddle_hit.emit(paddle, collision.get_position())
	var hit_pos = collision.get_position()
	var paddle_pos = paddle.global_position
	var paddle_height = paddle.get_node("CollisionShape2D").shape.size.y
	
	# Calculate relative hit position (-1 to 1)
	var relative_y = (hit_pos.y - paddle_pos.y) / (paddle_height / 2)
	
	# Calculate new angle based on hit position
	var bounce_angle = relative_y * deg_to_rad(max_bounce_angle)
	
	# Determine new direction
	var direction = Vector2.ZERO
	direction.x = 1 if velocity.x < 0 else -1 # Reverse x direction
	direction.y = sin(bounce_angle)
	
	# Calculate new speed
	var new_speed = min(velocity.length() + speed_increase, max_speed)
	
	# Set new velocity
	velocity = direction * new_speed

func initial_velocity() -> void:
	# Random initial direction
	var x: float = 1 if randf() < 0.5 else -1
	var y: float = randf_range(0.5, 1) if randf() < 0.5 else randf_range(-1, -0.5)
	var direction: Vector2 = Vector2(x, y).normalized()
	
	# Start at base speed
	velocity = direction * speed

func get_current_speed() -> float:
	return velocity.length()