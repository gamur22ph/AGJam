extends Control

@onready var paper : Panel = get_node("Paper")
@onready var note_text : Label = get_node("Paper/NoteText")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	paper.hide()
