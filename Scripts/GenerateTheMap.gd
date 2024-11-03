extends Node2D

@export_category("World Properties")
@export var world_size : int = 200

@export_category("Map Properties")
@export_range(33,99) var linarity : int
@export var map_size : int = 200
@export var works_with_seed : bool = true
@export var dice_seed : int = 1000
@export_range(0,100) var non_linarity : int = 30
@export var path_count : int = 9

var world_map : Array[Array] = []
var world_sub_map : Array[Array] = []

var _last_pos_spawned_x : int = 0
var _last_pos_spawned_y : int = 0

var non_main_max_size : int = 0

var _current_index : int = 0

var _last_rand_used;

enum _tile_types {right , up , down , left}
var _last_tile_type = _tile_types.right

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not works_with_seed:
		dice_seed = randi()

	setup_map()
	create_world()
	set_non_main_path()
	print_map()
	
func print_map():
	var _s = ""
	for y in range(world_size):
		for x in range(world_size):
			if world_map[y][x] == -1:
				_s += " "
			else:
				#_s += str(world_sub_map[y][x])
				_s += str(world_map[y][x])
		_s += "\n"
	print(_s)
		
func setup_map() -> void:
	non_main_max_size = path_count

	if map_size > world_size:
		map_size = world_size
	
	for i in range(world_size):
		world_map.append([])
		world_sub_map.append([])
		for j in range(world_size):
			world_map[i].append(-1)
			world_sub_map[i].append(-1)
			
func create_world():
	# to ensure that we are running into errors
	if world_size <= 0 or map_size <= 0:
		get_tree().quit()

	# set the first tile position
	_last_pos_spawned_y = rand_from_seed(dice_seed)[0] % world_size
	_last_rand_used = _last_pos_spawned_y
	world_map[_last_pos_spawned_y][_last_pos_spawned_x] = 0
	world_sub_map[_last_pos_spawned_y][_last_pos_spawned_x] = 0
	_current_index += 1

	# setup the whole map
	for c in range(map_size):
		if _last_tile_type == _tile_types.right:
			set_next_tile_for_right_tile()
		elif _last_tile_type == _tile_types.up:
			set_next_tile_for_up_tile()
		else :
			set_next_tile_for_down_tile()

		world_map[_last_pos_spawned_y][_last_pos_spawned_x] = 0
		world_sub_map[_last_pos_spawned_y][_last_pos_spawned_x] = _current_index
		_current_index += 1

func set_next_tile_for_down_tile():
	var _dice : int = rand_from_seed(_last_rand_used)[0] % 100
	_last_rand_used = rand_from_seed(_last_rand_used + _dice)[0]

	# spawn a right tile
	if _dice < linarity:
		_last_pos_spawned_x += 1
		_last_tile_type = _tile_types.right
	# spawn a down tile
	else :
		if _last_pos_spawned_y < world_size - 1:
			_last_pos_spawned_y +=1
			_last_tile_type = _tile_types.down
		else :
			_last_pos_spawned_x += 1
			_last_tile_type = _tile_types.right

func set_next_tile_for_up_tile():
	var _dice : int = rand_from_seed(_last_rand_used)[0] % 100
	_last_rand_used = rand_from_seed(_last_rand_used + _dice)[0]

	# spawn a right tile
	if _dice < linarity:
		_last_pos_spawned_x += 1
		_last_tile_type = _tile_types.right
	# spawn an up tile
	else :
		if _last_pos_spawned_y > 0:
			_last_pos_spawned_y -=1
			_last_tile_type = _tile_types.up
		else :
			_last_pos_spawned_x += 1
			_last_tile_type = _tile_types.right

func set_next_tile_for_right_tile():
	var _dice : int = rand_from_seed(_last_rand_used)[0] % 100
	_last_rand_used = rand_from_seed(_last_rand_used + _dice)[0]

	# spawn a right tile
	if _dice < linarity:
		_last_pos_spawned_x += 1
		_last_tile_type = _tile_types.right
		print("r")
	# spawn an up tile
	elif _dice < ((100 - linarity)/2) + linarity:
		if _last_pos_spawned_y > 0:
			_last_pos_spawned_y -=1
			_last_tile_type = _tile_types.up
			print("u")
		else :
			_last_pos_spawned_x += 1
			_last_tile_type = _tile_types.right
			print("r")
	# spawn a down tile
	else :
		if _last_pos_spawned_y < world_size - 1:
			_last_pos_spawned_y +=1
			_last_tile_type = _tile_types.down
			print("d")
		else :
			_last_pos_spawned_x += 1
			_last_tile_type = _tile_types.right
			print("r")

func set_non_main_path():
	for y in range(world_size):
		for x in range(world_size):
			# if here is empty
			if world_map[y][x] != 0:
				continue
			else :
				var _dice : int = roll_a_dice()
				if _dice < non_linarity:
					set_next_non_main_tile(x,y,path_count , world_sub_map[y][x])

func set_next_non_main_tile(_x : int,_y : int,_counter : int , _sub : int):
	if _counter == 0:
		return

	if world_map[_y][_x] == -1:
		world_map[_y][_x] = non_main_max_size - _counter
		world_sub_map[_y][_x] = _sub
	
	var _dice = roll_a_dice()
	# spawn right
	if _dice < 40 :
		if _x < world_size :
			set_next_non_main_tile(_x+1 , _y , _counter-1 , _sub)
		else : return
	elif _dice < 60:
		if _y > 0:
			set_next_non_main_tile(_x , _y-1 , _counter-1 , _sub)
		else : return
	elif _dice < 80:
		if _x > 0:
			set_next_non_main_tile(_x-1 , _y , _counter-1 ,_sub)
		else : return
	else :
		if _y< world_size:
			set_next_non_main_tile(_x , _y+1 , _counter-1 , _sub)
		else : return

func roll_a_dice()->int:
	var _dice : int = rand_from_seed(_last_rand_used)[0] % 100
	_last_rand_used = rand_from_seed(_last_rand_used + _dice)[0]
	
	return _dice
