extends Node2D

signal on_first_read

@export_multiline var note_content : String
var marked_as_read

func handle_interactable():
	if not marked_as_read:
		on_first_read.emit()
		marked_as_read = true
	get_tree().get_first_node_in_group("NoteManager").paper.show()
	get_tree().get_first_node_in_group("NoteManager").note_text.text = note_content
