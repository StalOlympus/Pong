extends SpecialPower

@export var paddle: CharacterBody2D

func _apply_effect() -> void:
    paddle.speed *= 1.5 # Increase paddle speed by 50%

func _remove_effect() -> void:
    paddle.speed /= 1.5 # Revert paddle speed
