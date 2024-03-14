extends Node2D

var current_sunberries : int
@export var max_sunberries : int = 100

@onready var pop_up : PackedScene = preload("res://Modules/PopupText.tscn")
@onready var label : Label = get_node("Label")
@onready var machineSprite : TextureProgressBar = get_node("MachineSprite")
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var light_buffer = get_tree().get_first_node_in_group("Lightbuffer")
@onready var anim : AnimationPlayer = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = str(current_sunberries) + "/" + str(max_sunberries)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_sunberries == max_sunberries:
		anim.play("Activate")
		current_sunberries = 0

func handle_interactable():
	if player.sunberry_count > 0 and current_sunberries != max_sunberries:
		current_sunberries += 1
		player.sunberry_count -= 1
		machineSprite.value = (float(current_sunberries) / max_sunberries) * 100
		label.text = str(current_sunberries) + "/" + str(max_sunberries)

func show_details():
	label.show()

func hide_details():
	label.hide()

func create_light():
	light_buffer.hide()
	get_tree().current_scene.world_lit_up = true
	for npc in get_tree().get_nodes_in_group("NPC"):
		npc.interacted_dialogue_idx = 1
		npc.repeated_dialogue_idx = 1
		npc.dialogue_component.start_dialogue("THE SUN!!!")
	for entity in get_tree().get_nodes_in_group("Enemy"):
		entity._handle_death()
	var new_pop_up = pop_up.instantiate()
	new_pop_up.content = "The sun is finally up, thanks for playing."
	new_pop_up.position = get_tree().get_first_node_in_group("Player").position + (Vector2.UP * 25)
	get_tree().current_scene.add_child(new_pop_up)
