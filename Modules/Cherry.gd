extends CharacterBody2D

func handle_interactable():
	get_tree().get_first_node_in_group("Player").add_cherry()
	queue_free()
