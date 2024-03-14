extends CharacterBody2D

var current_movement_speed : float = 50
@export_multiline var interacted_dialogue : Array[String]
var interacted_dialogue_idx : int = 0
@export_multiline var repeated_dialogue : Array[String]
var repeated_dialogue_idx : int = 0
@export_multiline var aberrola_dialogue_response : String = "MONSTER!!!"

enum STATE{
	PATROL,
	AFRAID,
	DEAD
}
var state : STATE = STATE.PATROL

@onready var health_component : HealthComponent = get_node("HealthComponent")
@onready var dialogue_component : DialogueComponent = get_node("DialogueComponent")
@onready var patrol_component : PatrolComponent = get_node("PatrolComponent")
@onready var anim_sprite : AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var anim : AnimationPlayer = get_node("AnimationPlayer")
@onready var aberrola_detector : ShapeCast2D = get_node("AberrolaDetector")

var current_detected_aberrola

var aberrola_response_timer : float

func _ready():
	health_component.connect("health_depleted", _handle_death)
	health_component.connect("damage_taken", _handle_hurt)

func _process(delta):

	if not aberrola_detector.collision_result.is_empty():
		state = STATE.AFRAID
		current_detected_aberrola = aberrola_detector.collision_result[0].collider
	else:
		state = STATE.PATROL
		current_detected_aberrola = null


	match state:
		STATE.PATROL:
			patrol_component.process_patrol_data(delta)
		STATE.AFRAID:
			if aberrola_response_timer < 0:
				dialogue_component.start_dialogue(aberrola_dialogue_response)
				aberrola_response_timer = 4
			else:
				aberrola_response_timer -= delta
	if velocity.x > 0:
		anim_sprite.flip_h = false
	elif velocity.x < 0:
		anim_sprite.flip_h = true

func _physics_process(delta):
	match state:
		STATE.PATROL:
			patrol_component.move_to_patrol_point()
		STATE.AFRAID:
			velocity = current_detected_aberrola.global_position.direction_to(global_position) * current_movement_speed * 1.25
		STATE.DEAD:
			velocity = Vector2.ZERO
	move_and_slide()

func handle_interactable():
	dialogue_component.start_dialogue(interacted_dialogue[interacted_dialogue_idx])

func _handle_hurt():
	dialogue_component.start_dialogue("Aw")

func _handle_death():
	health_component.process_mode = Node.PROCESS_MODE_DISABLED
	dialogue_component.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	anim.play("Death")

func separate_sprite_and_free():
	var new_position = global_position
	remove_child(anim_sprite)
	anim_sprite.position = new_position
	anim_sprite.self_modulate = Color(1, 1, 1, 0.8)
	get_tree().current_scene.add_child(anim_sprite)
	queue_free()

func _on_interaction_zone_area_entered(area:Area2D):
	if (area.get_parent().is_in_group("Player")):
		dialogue_component.on_interaction = true

func _on_interaction_zone_area_exited(area:Area2D):
	if (area.get_parent().is_in_group("Player")):
		dialogue_component.on_interaction = false
