extends Node
class_name Main

@export var ball_scene: PackedScene
@export var power_scene: PackedScene
var active_powers: Array = []

@export var score_sound: AudioStreamPlayer

@export var left_paddle: CharacterBody2D
@export var right_paddle: CharacterBody2D

@export var left_score_label: Label
@export var right_score_label: Label

@export var left_goal: Area2D
@export var right_goal: Area2D

@export var delay_to_spawn: float = 1
@export var delay_to_start: float = 2

var left_score: int = 0
var right_score: int = 0
var screen_middle: Vector2 = Vector2.ZERO

func _ready() -> void:
	var x: float = get_viewport().size.x / 2
	var y: float = get_viewport().size.y / 2
	screen_middle = Vector2(x, y)
	
	left_goal.connect("body_entered", _on_left_goal_body_entered)
	right_goal.connect("body_entered", _on_right_goal_body_entered)

	change_score(0)
	change_score(1)

	spawn_ball()

func spawn_ball() -> void:
	var ball_instance: Ball = ball_scene.instantiate() as Ball
	call_deferred("add_child", ball_instance)
	ball_instance.global_position = screen_middle
	left_paddle.global_position.y = screen_middle.y
	right_paddle.global_position.y = screen_middle.y
	await get_tree().create_timer(delay_to_start).timeout
	ball_instance.initial_velocity()

func change_score(side: int, score: int = 0) -> void:
	if side == 0:
		left_score += score
		left_score_label.text = str(left_score)
	else:
		right_score += score
		right_score_label.text = str(right_score)

func create_score_flash(label: Label) -> void:
	score_sound.play()

	var initial_color: Color = Color.from_string("393f7f64", Color.WHITE)
	var flash_color: Color = Color.from_string("616abc", Color.WHITE)
	var label_settings: LabelSettings = label.label_settings
	
	var tween = create_tween()
	tween.tween_property(label_settings, "font_color", flash_color, 0.2)
	tween.tween_property(label_settings, "font_color", initial_color, 0.2)

func _on_left_goal_body_entered(body: Node2D) -> void:
	change_score(1, 1)
	create_score_flash(right_score_label)
	body.queue_free()
	spawn_ball()
	
func _on_right_goal_body_entered(body: Node2D) -> void:
	change_score(0, 1)
	create_score_flash(left_score_label)
	body.queue_free()
	spawn_ball()

func activate_power(index: int) -> void:
	if index < active_powers.size():
		active_powers[index].activate()
