class_name HealthComponent
extends Node2D

signal health_depleted
signal damage_taken

var current_health : float
@export var max_health : float
var current_health_regeneration : float
@export var health_regeneration : float
var invulnerability_timer : float

@onready var user : Node2D = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	current_health = max_health
	current_health_regeneration = health_regeneration

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	regen_health(delta)
	if invulnerability_timer > 0:
		invulnerability_timer -= delta
		user.anim_sprite.self_modulate = Color(1, 0.3, 0.3, 0.75)
	elif invulnerability_timer > -0.2:
		invulnerability_timer -= delta
		user.anim_sprite.self_modulate = Color(1, 1, 1, 1)
	

func regen_health(delta):
	current_health += current_health_regeneration * delta
	if current_health >= max_health:
		current_health = max_health
	

func take_damage(amount):
	if invulnerability_timer <= 0:
		invulnerability_timer = 0.25
		current_health -= amount
		damage_taken.emit()
		if current_health <= 0:
			emit_signal("health_depleted")

func heal(amount):
	current_health += amount
	if current_health >= max_health:
		current_health = max_health

func update_health():
	# for UI purposes
	pass
