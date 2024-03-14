class_name DialogueComponent
extends Node2D

@onready var current_dialogue : Label = get_node("Label")


var next_character_timer : float
var on_interaction : bool

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var repeated_dialogue_timer : float

var dialogue_remove_timer : float
@onready var user = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_dialogue.visible_characters < current_dialogue.text.length() and next_character_timer <= 0:
		current_dialogue.visible_characters += 1;
		next_character_timer = 0.03
	else:
		next_character_timer -= delta

	if not on_interaction:
		## Hide the dialogue after some time
		if current_dialogue.visible_characters == current_dialogue.text.length():
			dialogue_remove_timer -= delta
			if dialogue_remove_timer <= 0:
				current_dialogue.hide()
		else:
			dialogue_remove_timer = 7

		## Repeat the dialogue after some time
		if repeated_dialogue_timer <= 0:
			start_dialogue(user.repeated_dialogue[user.repeated_dialogue_idx])
			repeated_dialogue_timer = rng.randf_range(30, 40)
		else:
			repeated_dialogue_timer -= delta

func start_dialogue(dialogue):
	current_dialogue.text = dialogue
	current_dialogue.visible_characters = 0
	current_dialogue.show()
