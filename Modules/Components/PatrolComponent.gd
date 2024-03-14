class_name PatrolComponent
extends Node2D

enum PATROLTYPE{
	SEQUENTIAL,
	RANDOM,
	REAL_RANDOM_RELATIVE
}

@export var patrol_type : PATROLTYPE = PATROLTYPE.SEQUENTIAL
## when set to true, the designated patrol points coordinates will be relative from the nodes base position, false if absolute
@export var relative_to_base_position : bool
@export var patrol_points : Array[Vector2]
var current_patrol_point : Vector2
@export var min_patrol_time : float = 0
@export var max_patrol_time : float
var patrol_timer : float
var current_patrol_point_idx : int
var going_next : bool = true # if false then it is going to previous indices

var base_position : Vector2
@onready var user : Node2D = get_parent()
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var done_taken_position : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	base_position = user.global_position
	if patrol_type == PATROLTYPE.REAL_RANDOM_RELATIVE:
		patrol_points.append(Vector2(0, 0))
		patrol_points.append(Vector2(0, 0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	# Sample Use
	# if user.state == STATE.PATROL:
	# 	if on_patrol_point():
	# 		go_to_next_patrol_point()

func _physics_process(delta):
	pass
	# Sample Use
	# move_to_patrol_point()

func process_patrol_data(delta):
	if on_patrol_point() and patrol_timer < 0:
		go_to_next_patrol_point()
		patrol_timer = rng.randf_range(min_patrol_time, max_patrol_time)
	else:
		patrol_timer -= delta


func on_patrol_point():
	var patrol_position = patrol_points[current_patrol_point_idx] if not relative_to_base_position else base_position + patrol_points[current_patrol_point_idx]
	return user.position.distance_to(patrol_position) <= 5

func go_to_next_patrol_point():
	match patrol_type:
		PATROLTYPE.SEQUENTIAL:
			if going_next:
				current_patrol_point_idx += 1
			else:
				current_patrol_point_idx -= 1

			if current_patrol_point_idx == patrol_points.size() - 1:
				going_next = false
			elif current_patrol_point_idx == 0:
				going_next = true
		PATROLTYPE.RANDOM:
			current_patrol_point_idx = randi_range(0, patrol_points.size() - 1)
		PATROLTYPE.REAL_RANDOM_RELATIVE:
			if not done_taken_position:
				base_position = user.global_position
				done_taken_position = true
			current_patrol_point_idx = abs(current_patrol_point_idx) - 1
			patrol_points[current_patrol_point_idx].x = rng.randf_range(-50, 50)
			patrol_points[current_patrol_point_idx].y = rng.randf_range(-50, 50)


func move_to_patrol_point():
	if not on_patrol_point():
		var patrol_position = patrol_points[current_patrol_point_idx] if not relative_to_base_position else base_position + patrol_points[current_patrol_point_idx]
		user.velocity = user.position.direction_to(patrol_position) * user.current_movement_speed
	else:
		user.velocity = Vector2.ZERO

