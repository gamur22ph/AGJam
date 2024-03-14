extends Sprite2D

@onready var user = get_parent()
@onready var light_buffer = get_tree().get_first_node_in_group("Lightbuffer")
@export var dynamic_light : bool = false
@export var light_change_min : float = 0.1
@export var light_change_max : float = 0.15
@export var light_timer : float
@export var light_radius_offset_min : float = -0.1
@export var light_radius_offset_max : float = 0.1

var base_scale : Vector2
var done_scaling : bool = false
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	light_buffer.add_child(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dynamic_light and light_timer <= 0:
		light_timer = rng.randf_range(light_change_min, light_change_max)
		var radius_offset = rng.randf_range(light_radius_offset_min, light_radius_offset_max)
		if not done_scaling:
			base_scale = scale
			done_scaling = true
		scale = Vector2(base_scale.x + radius_offset, base_scale.y + radius_offset)
	else:
		light_timer -= delta


func _physics_process(delta):
	global_position = user.global_position
	
