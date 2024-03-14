class_name Pickable
extends Node2D

@export var item_name : String
@onready var area2d : Area2D = get_node("Area2D")

func _process(delta):
	for pickable in area2d.get_overlapping_areas():
		if item_name == "Cherry" and pickable.get_parent().has_method("get_item_name"):
			if pickable.get_parent().get_item_name() == "Blueberry":
				var new_sunberry = load("res://Modules/Sunberry.tscn").instantiate()
				new_sunberry.position = (position + pickable.get_parent().position) / 2
				get_tree().current_scene.add_child(new_sunberry)
				pickable.get_parent().free()
				free()
				break

func handle_interactable():
	if get_tree().get_first_node_in_group("Player").pick_item(item_name):
		queue_free()

func get_item_name():
	return item_name

func _on_area_2d_area_entered(area:Area2D):
	pass
	# if item_name == "Cherry" and area.get_parent().has_method("get_item_name"):
	# 	if area.get_parent().get_item_name() == "Blueberry":
	# 		var new_sunberry = load("res://Modules/Sunberry.tscn").instantiate()
	# 		new_sunberry.position = (position + area.get_parent().position) / 2
	# 		get_tree().current_scene.add_child(new_sunberry)
	# 		area.get_parent().queue_free()
	# 		queue_free()
