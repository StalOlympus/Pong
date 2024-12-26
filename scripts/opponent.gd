extends CharacterBody2D
class_name Opponent

@export var speed: float = 300.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0
@export var prediction_time: float = 0.5 # How far ahead to predict ball position
@export var difficulty: float = 0.85 # AI accuracy (0.0 to 1.0)
@export var max_prediction_distance: float = 400.0 # Maximum distance to predict ahead

var ball: Ball
var direction: Vector2 = Vector2.ZERO
var target_velocity: Vector2 = Vector2.ZERO
var disable: bool = false
var last_ball_position: Vector2
var prediction_point: Vector2
var random_offset: float = 0.0
var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	await get_tree().create_timer(0.1).timeout
	ball = get_tree().get_first_node_in_group("Ball")


func _physics_process(delta: float) -> void:
	if disable:
		return
	if not ball:
		ball = get_tree().get_first_node_in_group("Ball")
	

	_update_ai_movement(delta)
	
	# Apply movement with smooth acceleration and deceleration
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Ensure paddle stays within screen bounds
	var half_height = $CollisionShape2D.shape.size.y / 2
	global_position.y = clamp(global_position.y, half_height, screen_size.y - half_height)
	
	move_and_collide(velocity * delta)

func _update_ai_movement(delta: float) -> void:
	var ball_velocity = ball.velocity
	var ball_pos = ball.global_position
	
	if (global_position.x > screen_size.x / 2 and ball_velocity.x > 0) or \
	   (global_position.x < screen_size.x / 2 and ball_velocity.x < 0):
		
		# Predict ball position
		prediction_point = _predict_ball_position(ball_pos, ball_velocity)
		
		# Check if the ball is guaranteed to hit the paddle
		var paddle_height = $CollisionShape2D.shape.size.y
		var paddle_top = global_position.y - paddle_height / 4
		var paddle_bottom = global_position.y + paddle_height / 4

		# Allow some margin for the AI to adjust its position
		if prediction_point.y >= paddle_top and prediction_point.y <= paddle_bottom:
			# Ball is likely to hit the paddle, but allow for minor adjustments
			# Calculate the distance to the predicted position
			var distance_to_prediction = prediction_point.y - global_position.y

			# If the distance is small, allow the AI to stay still
			if abs(distance_to_prediction) < 2: # Adjust this threshold as needed
				direction = Vector2.ZERO
				target_velocity = Vector2.ZERO
				return
		# If the ball is not guaranteed to hit, continue with movement logic
		
		# Apply difficulty factor and random offset
		var target_y = prediction_point.y
		target_y = lerp(global_position.y, target_y, difficulty)
		target_y += random_offset
		
		# Calculate direction and target velocity
		var distance_to_target = target_y - global_position.y
		direction = Vector2(0, sign(distance_to_target))
		target_velocity = direction * speed
		
	else:
		# Check if the ball is moving away and adjust paddle position accordingly
		var distance_to_center = screen_size.y / 2 - global_position.y
		var ball_direction = 1 if ball.velocity.y > 0 else -1
		
		# If the ball is moving away from the paddle, move towards the center with a gradual speed
		if (ball_direction == sign(distance_to_center)):
			target_velocity = Vector2(0, sign(distance_to_center) * speed)
		else:
			# If the ball is moving towards the paddle, maintain current position
			target_velocity = Vector2.ZERO

func _predict_ball_position(ball_pos: Vector2, ball_vel: Vector2) -> Vector2:
	var predicted_pos = ball_pos
	var time_to_reach = 0.0
	
	# Calculate the time required for the ball to reach the paddle's x position
	if ball_vel.x != 0:
		time_to_reach = abs((global_position.x - ball_pos.x) / ball_vel.x)
	
	# Cap the prediction time to avoid excessive calculations
	time_to_reach = min(time_to_reach, prediction_time)
	
	# Compute the predicted position based on the ball's velocity and time to reach
	predicted_pos += ball_vel * time_to_reach
	
	# Adjust for potential bounces off the top and bottom walls
	var paddle_height = $CollisionShape2D.shape.size.y
	if predicted_pos.y < 0 or predicted_pos.y > screen_size.y:
		predicted_pos.y = clamp(predicted_pos.y, paddle_height / 2, screen_size.y - paddle_height / 2)
	
	# Smoothly adjust the paddle's position towards the predicted position
	var current_y = global_position.y
	var target_y = predicted_pos.y
	var smooth_factor = 0.1 # Adjust this value for smoother or snappier movement
	var new_y = lerp(current_y, target_y, smooth_factor)
	
	# Return the refined predicted position
	return Vector2(predicted_pos.x, new_y)