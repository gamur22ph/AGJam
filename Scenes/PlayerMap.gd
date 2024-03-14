extends TextureRect

@onready var updated_map : CompressedTexture2D = preload("res://assets/Player/UpdatedPlayerMap.png")
@onready var pop_up : PackedScene = preload("res://Modules/PopupText.tscn")
@export var map_note : Node2D

func _ready():
	map_note.connect("on_first_read", _update_map)

func _update_map():
	texture = updated_map
	var new_pop_up = pop_up.instantiate()
	new_pop_up.content = "Map Updated"
	new_pop_up.position = get_tree().get_first_node_in_group("Player").position + (Vector2.UP * 25)
	get_tree().current_scene.add_child(new_pop_up)
