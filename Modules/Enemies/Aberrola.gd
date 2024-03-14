extends Enemy

@onready var bite_zone : ShapeCast2D = get_node("BiteZone")
@onready var bite_cooldown_timer : Timer = get_node("BiteCooldownTimer")

# Called when the node enters the scene tree for the first time.
func _ready():
	current_movement_speed = base_movement_speed
	health_component.connect("health_depleted", _handle_death)
	anim.play("Idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		STATE.PATROL:
			handle_aggro()
			patrol_component.process_patrol_data(delta)
		STATE.AGGRO:
			bite_zone.position = global_position.direction_to(player.position) * attack_range/2
			if bite_cooldown_timer.time_left == 0 and position.distance_to(player.position) <= attack_range:
				state = STATE.ON_ACTION
				anim.play("Bite")
				bite_cooldown_timer.start()
			if position.distance_to(player.position) > max_aggro_range and merciless_timer.time_left == 0:
				state = STATE.AGGRO_LOST
				player_last_seen_position = Vector2(player.position.x, player.position.y)
				aggro_lost_timer.start()
		STATE.AGGRO_LOST:
			handle_aggro()
			if aggro_lost_timer.time_left == 0:
				state = STATE.PATROL
		STATE.ON_ACTION:
			pass

	if state != STATE.ON_ACTION and state != STATE.DEAD:
		if velocity == Vector2.ZERO:
			anim.play("Idle")
		else:
			anim.play("Moving")


func _physics_process(delta):
	match state:
		STATE.PATROL:
			patrol_component.move_to_patrol_point()
		STATE.AGGRO:
			if position.distance_to(player.position) > 30:
				velocity = position.direction_to(player.position) * current_movement_speed
			else:
				velocity = Vector2.ZERO
			rotation = 0
		STATE.AGGRO_LOST:
			if position.distance_to(player_last_seen_position) < 5:
				velocity = Vector2.ZERO
			else:
				velocity = position.direction_to(player_last_seen_position) * current_movement_speed
			rotation = 0
		STATE.ON_ACTION:
			velocity = Vector2.ZERO
		STATE.DEAD:
			velocity = Vector2.ZERO
	

	move_and_slide()
	

func activate_bite_attack():
	for result in bite_zone.collision_result:
		if result.collider.has_node("HealthComponent"):
			result.collider.health_component.take_damage(damage)
