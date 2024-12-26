extends CharacterBody2D
class_name Player

@export var speed: float = 300.0
@export var acceleration: float = 1000.0 # Added acceleration
@export var friction: float = 1000.0 # Added friction for smooth deceleration

var direction: Vector2 = Vector2.ZERO
var target_velocity: Vector2 = Vector2.ZERO
var disable: bool

func _process(_delta: float) -> void:
	if disable:
		return
	get_direction()

func _physics_process(delta: float) -> void:
	# Calculate target velocity based on input direction
	target_velocity = direction * speed
	
	# Smoothly interpolate current velocity towards target velocity
	if direction != Vector2.ZERO:
		# Accelerate when there's input
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Decelerate when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	move_and_collide(velocity * delta)

func get_direction() -> void:
	# Get raw input values
	var input_y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# Update direction vector
	direction = Vector2(0, input_y).normalized()