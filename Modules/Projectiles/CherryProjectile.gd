extends CharacterBody2D

var source_position : Vector2
var target_position : Vector2
# var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var life_timer : float = 20
var dps : float = 10
var damage_timer : float

@onready var sprite : Sprite2D = get_node("Sprite2D")
@onready var fire_anim : AnimatedSprite2D = get_node("Fire")
@onready var fire_area : Area2D = get_node("Area2D")

"""
func calculate_arc_velocity(sp, tp, arc_height):
	var arc_velocity = Vector2()
	var displacement = tp - sp

	if displacement.y > arc_height:
		var time_up = sqrt(-2 * arc_height / gravity)
		var time_down = sqrt(2 * (displacement.y - arc_height) / gravity)

		arc_velocity.y = -sqrt(-2 * gravity * arc_height)
		arc_velocity.x = displacement.x / float(time_up + time_down)

	return arc_velocity


func launch():
	var arc_height = target_position.y - global_position.y - 32
	velocity = calculate_arc_velocity(source_position + (Vector2.UP * 10), target_position, arc_height)
"""

func _process(delta):
	life_timer -= delta
	if life_timer <= 0:
		queue_free()
	if damage_timer <= 0:
		damage_timer = 0.5
		for entity in fire_area.get_overlapping_bodies():
			if (entity.is_in_group("Enemy") or entity.is_in_group("NPC")) and entity.has_node("HealthComponent"):
				entity.health_component.take_damage(dps)
				if entity.has_node("MercilessTimer"):
					entity.merciless_timer.start()
	else:
		damage_timer -= delta
		

func _physics_process(delta):
	if global_position.distance_to(target_position) <= 5:
		velocity = Vector2.ZERO
		fire_anim.rotation = 0
	else:
		sprite.rotate(2 * delta)
		fire_anim.rotation = source_position.angle_to_point(target_position) - deg_to_rad(90)
	"""
	else:
		velocity.y += gravity * delta
	"""
	move_and_slide()