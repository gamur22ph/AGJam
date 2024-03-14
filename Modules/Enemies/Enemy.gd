class_name Enemy
extends CharacterBody2D


@export var base_movement_speed : float = 225
@export var aggro_range : float = 100
@export var max_aggro_range : float = 175
@export var attack_range : float = 25
@export var damage : float = 30
var current_movement_speed : float
var player_last_seen_position : Vector2

var current_target

enum STATE{
	PATROL,
	AGGRO,
	AGGRO_LOST,
	ON_ACTION,
	DEAD
}

@onready var aggro_lost_timer : Timer = get_node("AggroLostTimer")
var state : STATE = STATE.PATROL

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var health_component : HealthComponent = get_node("HealthComponent")
@onready var drop_component : DropComponent = get_node("DropComponent")

@onready var merciless_timer : Timer = get_node("MercilessTimer")
@onready var anim : AnimationPlayer = get_node("AnimationPlayer")
@onready var anim_sprite : AnimatedSprite2D = get_node("AnimatedSprite2D")

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var patrol_component = get_node("PatrolComponent")

func handle_aggro():
	if position.distance_to(player.position) < aggro_range or merciless_timer.time_left != 0:
		state = STATE.AGGRO

func set_to_aggro_state():
	state = STATE.AGGRO

func _handle_death():
	health_component.process_mode = Node.PROCESS_MODE_DISABLED
	state = STATE.DEAD
	drop_component.drop_all()
	anim.play("Death")

func separate_sprite_and_free():
	var new_position = global_position
	remove_child(anim_sprite)
	anim_sprite.position = new_position
	anim_sprite.self_modulate = Color(1, 1, 1, 0.8)
	get_tree().current_scene.add_child(anim_sprite)
	queue_free()
