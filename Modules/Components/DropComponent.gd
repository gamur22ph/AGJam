class_name DropComponent
extends Node2D

@export var drops : Array[Drop]

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
@onready var user = get_parent()

func drop_random():
	var dropped_object_data = drops[rng.randi_range(0, drops.size() - 1)]
	var new_object = dropped_object_data.drop_object.instantiate()
	new_object.position = user.position + Vector2(rng.randf(), rng.randf()).normalized() * randf_range(-50, 50)
	get_tree().current_scene.add_child(new_object)

func drop_all():
	for drop_data in drops:
		for i in range(drop_data.quantity):
			var new_object = drop_data.drop_object.instantiate()
			new_object.position = user.position + Vector2(rng.randf(), rng.randf()).normalized() * randf_range(-50, 50)
			get_tree().current_scene.add_child(new_object)