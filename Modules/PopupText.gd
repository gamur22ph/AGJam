class_name PopupText
extends Node2D

var content : String
@onready var label : Label = get_node("Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = content


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y -= delta * 5
	modulate.a -= delta * 0.2
	if modulate.a <= 0:
		queue_free()
