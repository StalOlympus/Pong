extends SpecialPower

@export var paddle: CharacterBody2D

func _apply_effect() -> void:
    var collision_shape = paddle.get_node("CollisionShape2D")
    collision_shape.shape.size.y *= 1.5 # Increase paddle size by 50%

func _remove_effect() -> void:
    var collision_shape = paddle.get_node("CollisionShape2D")
    collision_shape.shape.size.y /= 1.5 # Revert paddle size