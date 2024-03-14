extends StaticBody2D

enum FRUIT{
	CHERRY,
	BLUEBERRY
}

@export var fruit : FRUIT

var grow_timer : float = 0
var current_grow_time : float = 0
@export var grow_time : float = 5

@export var can_be_fertilized : bool
var fertilizer_timer : float = 0
var max_fruits : int = 6
var current_fruits : int = 0

var fruit_sprite : PackedScene
var hanging_fruits : Array[Sprite2D]
@onready var tree_details : Label = get_node("Details/TreeDetails")
@onready var take_button : Button = get_node("Details/VBoxContainer/TakeButton")
@onready var fertilize_button : Button = get_node("Details/VBoxContainer/FertilizeButton")
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	current_grow_time = grow_time
	if fruit == FRUIT.CHERRY:
		fertilize_button.show()
		fruit_sprite = preload("res://Modules/CherrySprite.tscn")
	elif fruit == FRUIT.BLUEBERRY:
		fertilize_button.hide()
		fruit_sprite = preload("res://Modules/BlueberrySprite.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_fruits < max_fruits:
		grow_fruit(delta)   
	if is_fertilized():
		current_grow_time = grow_time / 2
		fertilizer_timer -= delta
	else:
		current_grow_time = grow_time
		

func grow_fruit(delta):
	grow_timer -= delta
	if grow_timer <= 0:
		grow_timer = current_grow_time
		current_fruits += 1
		var new_fruit = fruit_sprite.instantiate()
		new_fruit.position = Vector2(rng.randf_range(-8, 8), rng.randf_range(-16, -24))
		hanging_fruits.append(new_fruit)
		add_child(new_fruit)

func show_details():
	tree_details.get_parent().show()
	var fruit_name
	if fruit == FRUIT.CHERRY:
		fruit_name = "Acerola"
	elif fruit == FRUIT.BLUEBERRY:
		fruit_name = "Aberrola"
	tree_details.text = str(current_fruits) + "/" + str(max_fruits) + " " + fruit_name
	if current_fruits == max_fruits:
		tree_details.text += "\nMAX"
	else:
		tree_details.text += "\n" + str(roundf(grow_timer)) + "s"

	# Buttons
	if current_fruits == 0:
		take_button.disabled = true
	else:
		take_button.disabled = false

	if get_tree().get_first_node_in_group("Player").blueberry_count == 0 or is_fertilized():
		fertilize_button.disabled = true
	else:
		fertilize_button.disabled = false

	if is_fertilized():
		fertilize_button.text = "Fertilized " + str(roundf(fertilizer_timer)) 
	else:
		fertilize_button.text = "Fertilize"

func hide_details():
	tree_details.get_parent().hide()

func _on_take_button_pressed():
	get_fruit()

func handle_interactable():
	if current_fruits > 0:
		get_fruit()

func get_fruit():
	if fruit == FRUIT.CHERRY and not get_tree().get_first_node_in_group("Player").is_cherry_full():
		get_tree().get_first_node_in_group("Player").add_cherry()
		var removed_fruit = hanging_fruits.pop_back()
		removed_fruit.free()
		current_fruits -= 1
	elif fruit == FRUIT.BLUEBERRY and not get_tree().get_first_node_in_group("Player").is_blueberry_full():
		get_tree().get_first_node_in_group("Player").add_blueberry()
		var removed_fruit = hanging_fruits.pop_back()
		removed_fruit.free()
		current_fruits -= 1

func _on_fertilize_button_pressed():
	if fruit == FRUIT.CHERRY:
		get_tree().get_first_node_in_group("Player").blueberry_count -= 1
		fertilizer_timer = 10
		if grow_timer > grow_time / 2: ## Immediate change to the grow timer if fertilizer is used
			grow_timer = grow_time / 2

func is_fertilized():
	return fertilizer_timer > 0

