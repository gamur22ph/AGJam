extends CanvasLayer

@onready var health_ui : TextureProgressBar = get_node("HealthUI")
@onready var active_ui : TextureRect = get_node("ActiveImage")
@onready var sunberry_ui : Control = get_node("HBoxContainer/SunberryUI")
@onready var cherry_img : CompressedTexture2D = preload("res://assets/UI/CherryV2.png")
@onready var blueberry_img : CompressedTexture2D = preload("res://assets/UI/BlueberryV2.png")
@onready var sunberry_img : CompressedTexture2D = preload("res://assets/Sunberry.png")
@onready var updated_player_img : CompressedTexture2D = preload("res://assets/Player/UpdatedPlayerMap.png")
@onready var map_ui : TextureRect = get_node("PlayerMap")
@onready var player : Node2D = get_tree().get_first_node_in_group("Player")
@onready var note_manager = get_node("NoteManager")

@onready var game_menu : Control = get_node("GameMenu")
var main_menu_scene : PackedScene = preload("res://Scenes/MainMenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("berry_switched", _change_active_ui_texture)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	health_ui.value = player.health_component.current_health
	if Input.is_action_just_pressed("menu"):
		if not map_ui.visible and not note_manager.paper.visible:
			game_menu.show()
		elif game_menu.visible:
			game_menu.hide()
		map_ui.hide()
		note_manager.paper.hide()
	if Input.is_action_just_pressed("map"):
		map_ui.show()

func _change_active_ui_texture(idx):
	match idx:
		0: 
			active_ui.texture = cherry_img
		1:
			active_ui.texture = blueberry_img
		2:
			active_ui.texture = sunberry_img
	if player.sunberry_count > 0:
		sunberry_ui.show()

func update_player_map():
	map_ui.texture = updated_player_img
	
func _on_player_map_exit_button_pressed():
	map_ui.hide()

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_return_button_pressed():
	game_menu.hide()
