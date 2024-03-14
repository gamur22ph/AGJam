extends CharacterBody2D

signal berry_switched

@export var base_movement_speed = 150
var current_movement_speed : float
var current_interacted_object

var cherry_count : int = 0
var max_cherry : int = 50
@export var cherry_text : Label
var throw_cooldown : float
@export var throw_range : float = 175

var blueberry_count : int = 0
var max_blueberry : int = 25
@export var blueberry_text : Label

var sunberry_count : int = 0
var max_sunberry : int = 50
@export var sunberry_text : Label
var sunberry_unlocked : bool = false
var consume_spam_protection_timer : float
var action_spam_protection_timer : float


var aim_range : float = 200
var active_berry : int = 0

@onready var camera : Camera2D = get_node("Camera2D")
@onready var sprite : Sprite2D = get_node("Sprite2D")
@onready var interaction_zone : ShapeCast2D = get_node("InteractionZone")
@onready var cherry_sprint_timer : Timer = get_node("CherrySprintTimer")
@onready var crosshair : Sprite2D = get_node("Crosshair")
@onready var health_component : HealthComponent = get_node("HealthComponent")
@export var cherry_projectile : PackedScene
@onready var cherry : PackedScene = preload("res://Modules/Cherry.tscn")
@onready var blueberry : PackedScene = preload("res://Modules/Blueberry.tscn")
@onready var sunberry : PackedScene = preload("res://Modules/Sunberry.tscn")
@onready var self_light : Sprite2D = get_node("Light")
@onready var interaction_display : TextureRect = get_node("InteractionDisplay")
@onready var anim_sprite : AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var anim : AnimationPlayer = get_node("AnimationPlayer")
var current_self_light_increase : float
@export var self_light_increase : float = 3

enum STATE{
	IDLE,
	MOVING,
}

enum ACTION{
	NONE,
	AIMING,
}

var active_action : ACTION = ACTION.NONE

func _ready():
	current_movement_speed = base_movement_speed
	##health_component.connect("health_depleted", )

func _process(delta):
	handle_flip()
	handle_interaction_zone()
	handle_cherry_mode()
	update_ui()

	if sunberry_unlocked == false and sunberry_count > 0:
		sunberry_unlocked = true
		berry_switched.emit(active_berry)

	#Controls
	if Input.is_action_just_pressed("berry1"):
		active_berry = 0
		berry_switched.emit(0)
	elif Input.is_action_just_pressed("berry2"):
		active_berry = 1
		berry_switched.emit(1)
	elif Input.is_action_just_pressed("berry3") and sunberry_unlocked:
		active_berry = 2
		berry_switched.emit(2)
	if Input.is_action_just_pressed("switch"):
		if active_berry == 2:
			active_berry = 0
		else:
			active_berry += 1
		berry_switched.emit(active_berry)
	if Input.is_action_pressed("drop") and action_spam_protection_timer <= 0:
		if active_berry == 0 and cherry_count > 0:
			var dropped_cherry = cherry.instantiate()
			dropped_cherry.position = position
			get_tree().current_scene.add_child(dropped_cherry)
			cherry_count -= 1
		elif active_berry == 1 and blueberry_count > 0:
			var dropped_blueberry = blueberry.instantiate()
			dropped_blueberry.position = position
			get_tree().current_scene.add_child(dropped_blueberry)
			blueberry_count -= 1
		elif active_berry == 2 and sunberry_count > 0:
			var dropped_sunberry = sunberry.instantiate()
			dropped_sunberry.position = position
			get_tree().current_scene.add_child(dropped_sunberry)
			sunberry_count -= 1
		action_spam_protection_timer = 0.25
	if Input.is_action_just_released("drop"):
		action_spam_protection_timer = 0
	
	if action_spam_protection_timer > 0:
		action_spam_protection_timer -= delta

	if (Input.is_action_pressed("interact")) and current_interacted_object != null and action_spam_protection_timer <= 0:
		interact()
		action_spam_protection_timer = 0.25
	if Input.is_action_just_released("interact"):
		action_spam_protection_timer = 0
	consume_spam_protection_timer -= delta
	if Input.is_action_just_pressed("consume1") and consume_spam_protection_timer <= 0:
		consume_cherry()
	if Input.is_action_just_pressed("consume2") and consume_spam_protection_timer <= 0:
		consume_blueberry()
	if Input.is_action_just_pressed("aim"):
		handle_aim()

	match active_action:
		ACTION.AIMING:
			if Input.is_action_just_released("aim"):
				active_action = ACTION.NONE
			elif Input.is_action_just_pressed("throw") and cherry_count > 0 and throw_cooldown <= 0:
				throw_cherry()
				throw_cooldown = 0.3
	throw_cooldown -= delta

func throw_cherry():
	var new_projectile = cherry_projectile.instantiate()
	new_projectile.global_position = position + (Vector2.UP * 10)
	new_projectile.source_position = new_projectile.global_position
	if new_projectile.source_position.distance_to(crosshair.global_position) < throw_range: ## Throw anywhere below the max range
		new_projectile.target_position = crosshair.global_position
	else:
		new_projectile.target_position = position + new_projectile.source_position.direction_to(crosshair.global_position) * throw_range ## Throw Max Range
	new_projectile.velocity = new_projectile.global_position.direction_to(new_projectile.target_position) * 250
	get_tree().current_scene.add_child(new_projectile)
	cherry_count -= 1

func update_ui():
	update_cherry_text()
	update_blueberry_text()
	update_sunberry_text()

func _physics_process(delta):
	match active_action:
		ACTION.NONE:
			crosshair.hide()
		ACTION.AIMING:
			crosshair.show()
			crosshair.global_position = get_global_mouse_position()
	handle_movement()

func handle_flip():
	if velocity.x > 0:
		anim_sprite.flip_h = false
	elif velocity.x < 0:
		anim_sprite.flip_h = true

func handle_movement():
	if cherry_sprint_timer.time_left > 0:
		cherry_sprint()
	else:
		current_movement_speed = base_movement_speed

	var v_direction = Input.get_axis("up", "down")
	var h_direction = Input.get_axis("left", "right")
	if v_direction and h_direction:
		velocity = Vector2(h_direction, v_direction).normalized() * current_movement_speed 
		if throw_cooldown > 0:
			anim.play("Throwing")
		else:
			anim.play("Walking")
	elif v_direction or h_direction:
		velocity = Vector2(h_direction, v_direction) * current_movement_speed
		if throw_cooldown > 0:
			anim.play("Throwing")
		else:
			anim.play("Walking")
	else:
		velocity = Vector2.ZERO
		if throw_cooldown > 0:
			anim.play("Throwing")
		else:
			anim.play("Idle")

	move_and_slide()

func handle_interaction_zone():
	if not interaction_zone.collision_result.is_empty():
		interaction_display.show()
		if current_interacted_object != null:
			if current_interacted_object != interaction_zone.collision_result[0].collider.get_parent():
				if current_interacted_object.has_method("hide_details"):
					current_interacted_object.call("hide_details")
		if interaction_zone.collision_result[0].collider != null:
			current_interacted_object = interaction_zone.collision_result[0].collider.get_parent()
		if current_interacted_object != null:
			if current_interacted_object.has_method("show_details"):
				current_interacted_object.call("show_details")
	else:	
		interaction_display.hide()
		if current_interacted_object != null:
			if current_interacted_object.has_method("hide_details"):
				current_interacted_object.call("hide_details")
		current_interacted_object = null

func handle_cherry_mode():
	var color_reduction = 0.75 * (cherry_sprint_timer.time_left / cherry_sprint_timer.wait_time)
	anim_sprite.self_modulate = Color(1, 1 - color_reduction, 1 - color_reduction, 1)
	var bonus_scale = self_light_increase * (cherry_sprint_timer.time_left / cherry_sprint_timer.wait_time)
	self_light.scale = Vector2(1 + bonus_scale, 1 + bonus_scale)
	var offset_change = 12 * (cherry_sprint_timer.time_left / cherry_sprint_timer.wait_time)
	self_light.offset.y = -16 + offset_change

func handle_aim():
	active_action = ACTION.AIMING

func consume_cherry():
	if cherry_count > 0:
		cherry_count -= 1
		cherry_sprint_timer.start()
		consume_spam_protection_timer = 0.5

func consume_blueberry():
	if blueberry_count > 0 and health_component.current_health < health_component.max_health:
		health_component.heal(20)
		blueberry_count -= 1
		consume_spam_protection_timer = 0.15

func cherry_sprint():
	current_movement_speed = base_movement_speed + (base_movement_speed * (cherry_sprint_timer.time_left / cherry_sprint_timer.wait_time))

func interact():
	print("interacted with " + str(current_interacted_object.name))
	if current_interacted_object.has_method("handle_interactable"):
		current_interacted_object.call("handle_interactable")

func pick_item(item_name : String) -> bool:
	match item_name:
		"Cherry":
			if cherry_count != max_cherry:
				add_cherry()
				return true
		"Blueberry":
			if blueberry_count != max_blueberry:
				add_blueberry()
				return true
		"Sunberry":
			if sunberry_count != max_sunberry:
				add_sunberry()
				return true
	return false

func add_cherry():
	cherry_count += 1

func add_blueberry():
	blueberry_count += 1

func add_sunberry():
	sunberry_count += 1

func update_blueberry_text():
	blueberry_text.text = str(blueberry_count) + "/" + str(max_blueberry)

func update_cherry_text():
	cherry_text.text = str(cherry_count) + "/" + str(max_cherry)

func update_sunberry_text():
	sunberry_text.text = str(sunberry_count) + "/" + str(max_sunberry)

func is_cherry_full():
	return cherry_count == max_cherry

func is_blueberry_full():
	return blueberry_count == max_blueberry

func is_sunberry_full():
	return sunberry_count == max_sunberry