extends Node2D

var spike_damage : float = 30
var signal_timer : float = 1

@onready var anim : AnimationPlayer = get_node("AnimationPlayer")
@onready var attack_area : Area2D = get_node("Area2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if signal_timer < 0:
		signal_timer = 99
		anim.play("Spike")
		for entity in attack_area.get_overlapping_bodies():
			if entity.has_node("HealthComponent"):
				entity.health_component.take_damage(spike_damage)
	else:
		signal_timer -= delta
