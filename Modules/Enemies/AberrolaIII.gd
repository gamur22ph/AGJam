extends Enemy

@onready var melee_attack : ShapeCast2D = get_node("MeleeAttack")
@onready var melee_attack_timer : Timer = get_node("MeleeAttackTimer")
@onready var charge_attack : Area2D = get_node("ChargeAttack")
@onready var charge_attack_timer : Timer = get_node("ChargeAttackTimer")

# Called when the node enters the scene tree for the first time.
func _ready():
	current_movement_speed = base_movement_speed
	health_component.connect("health_depleted", _handle_death)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		STATE.PATROL:
			handle_aggro()
			patrol_component.process_patrol_data(delta)
		STATE.AGGRO:
			melee_attack.position = global_position.direction_to(player.position) * attack_range
			if charge_attack_timer.time_left == 0 and position.distance_to(player.position) < 75:
				state = STATE.ON_ACTION
				charge_attack.set_direction(position.direction_to(player.position))
				charge_attack.activate()
				charge_attack_timer.start()
			elif melee_attack_timer.time_left == 0 and position.distance_to(player.position) < attack_range + 10:
				state = STATE.ON_ACTION
				anim.play("Melee")
				melee_attack_timer.start()
			if position.distance_to(player.position) > max_aggro_range and merciless_timer.time_left == 0:
				state = STATE.AGGRO_LOST
				player_last_seen_position = Vector2(player.position.x, player.position.y)
				aggro_lost_timer.start()
		STATE.AGGRO_LOST:
			handle_aggro()
			if aggro_lost_timer.time_left == 0:
				state = STATE.PATROL
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
		STATE.AGGRO_LOST:
			if position.distance_to(player_last_seen_position) < 5:
				velocity = Vector2.ZERO
			else:
				velocity = position.direction_to(player_last_seen_position) * current_movement_speed
		STATE.ON_ACTION:
			if charge_attack.is_active():
				velocity = charge_attack.direction * current_movement_speed * 3
			else:
				velocity = Vector2.ZERO
		STATE.DEAD:
			velocity = Vector2.ZERO
	

	move_and_slide()

func activate_melee_attack():
	for result in melee_attack.collision_result:
		if result.collider.has_node("HealthComponent"):
			result.collider.health_component.take_damage(damage)
