extends Node
class_name SpecialPower

@export var duration: float = 5.0 # Duration of the power effect
@export var cooldown: float = 10.0 # Cooldown time before the power can be used again

var is_active: bool = false
var cooldown_timer: Timer
var effect_timer: Timer

func _ready() -> void:
    cooldown_timer = Timer.new()
    cooldown_timer.wait_time = cooldown
    cooldown_timer.one_shot = true
    add_child(cooldown_timer)

    effect_timer = Timer.new()
    effect_timer.wait_time = duration
    effect_timer.one_shot = true
    add_child(effect_timer)

func activate() -> void:
    if not is_active and not cooldown_timer.is_stopped():
        is_active = true
        effect_timer.start()
        _apply_effect()
        effect_timer.timeout.connect(_deactivate)

func _apply_effect() -> void:
    # Override this method in subclasses to apply the specific effect
    pass

func _deactivate() -> void:
    is_active = false
    _remove_effect()
    cooldown_timer.start()

func _remove_effect() -> void:
    # Override this method in subclasses to remove the specific effect
    pass