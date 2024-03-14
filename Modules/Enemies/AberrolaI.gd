extends Enemy

@export var spin_damage : float = 30
@onready var spin_cooldown_timer : Timer = get_node("SpinCooldownTimer")
var spin_attack_timer : float

@onready var spike_object : PackedScene = preload("res://Modules/Enemies/Spike.tscn")
@onready var spike_cooldown_timer : Timer = get_node("SpikePillarCooldownTimer")
var spike_interval_timer : float
var spike_attack_timer : float

@onready var laser = get_node("Laser")
@onready var laser_cooldown_timer : Timer = get_node("LaserCooldownTimer")
var laser_attack_timer: float
var laser_interval_timer : float

@onready var spin_area : ShapeCast2D = get_node("SpinArea")
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

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
			if spike_cooldown_timer.time_left == 0 and health_component.current_health < health_component.max_health * 0.75:
				state = STATE.ON_ACTION
				spike_attack_timer = 5
				spike_cooldown_timer.start()
				anim.play("Spike")
			elif laser_cooldown_timer.time_left == 0:
				state = STATE.ON_ACTION
				laser_attack_timer = 3.5
				laser.activate()
				laser_cooldown_timer.start()
				anim.play("Laser")
				laser.show()
			elif spin_cooldown_timer.time_left == 0 and position.distance_to(player.position) < aggro_range - 50:
				state = STATE.ON_ACTION
				spin_attack_timer = 3
				spin_cooldown_timer.start()
			if position.distance_to(player.position) > max_aggro_range and merciless_timer.time_left == 0:
				state = STATE.AGGRO_LOST
				player_last_seen_position = Vector2(player.position.x, player.position.y)
				aggro_lost_timer.start()
		STATE.AGGRO_LOST:
			handle_aggro()
			if aggro_lost_timer.time_left == 0:
				state = STATE.PATROL
		STATE.ON_ACTION:
			if spin_attack_timer > 0:
				spin_attack()
				spin_attack_timer -= delta
			elif spike_attack_timer > 0:
				if spike_interval_timer < 0 and spike_attack_timer < 4:
					spike_attack()
					spike_interval_timer = 0.05
				else:
					spike_interval_timer -= delta
				spike_attack_timer -= delta
			elif laser_attack_timer > 0:
				laser_attack_timer -= delta
			else:	
				state = STATE.AGGRO
				laser.hide()
				anim.play("Idle")

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
			if spin_attack_timer > 0:
				velocity = position.direction_to(player.position) * current_movement_speed * 1.3
				rotate(-2)
			if spike_attack_timer > 0 or laser_attack_timer > 0:
				velocity = Vector2.ZERO
				rotation = 0

			
		STATE.DEAD:
			velocity = Vector2.ZERO
	

	move_and_slide()

func spin_attack():
	for result in spin_area.collision_result:
		if result.collider.has_node("HealthComponent"):
			result.collider.health_component.take_damage(spin_damage)

func spike_attack():
	for i in range(5):
		var new_spike = spike_object.instantiate()
		new_spike.position = global_position + Vector2(rng.randf_range(-250, 250), rng.randf_range(-250, 250))
		get_tree().current_scene.add_child(new_spike)

