extends Area2D

var damage : float = 60
var charge_speed : float = 300
var direction : Vector2
var active : bool
@export var speed : float
@onready var user : Node2D = get_parent()

func _process(delta):
	pass

func set_direction(new_direction):
	direction = new_direction

func activate():
	user.anim.play("Charging")
	
func charge():
	active = true
	monitoring = true

func stop():
	monitoring = false
	active = false
	user.state = Enemy.STATE.AGGRO

func is_active():
	return active

func _on_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		body.health_component.take_damage(damage)

