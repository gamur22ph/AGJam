extends CharacterBody2D

@export var laser_damage = 20
var damage_activated : bool = false

@onready var anim : AnimationPlayer = get_node("AnimationPlayer")
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var laser_area : Area2D = get_node("Area2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	scale.y = 0

func activate():
	anim.play("Laser")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if damage_activated:
		for entity in laser_area.get_overlapping_bodies():
			if entity.has_node("HealthComponent"):
				entity.health_component.take_damage(laser_damage)

func _physics_process(delta):
	var angle_to_player = global_position.angle_to_point(player.position)
	rotation = rotate_toward(rotation, angle_to_player, 0.6 * delta)
	move_and_slide()


func activate_damage():
	damage_activated = true

func deactivate_damage():
	damage_activated = false
