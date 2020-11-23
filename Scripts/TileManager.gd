extends Node

# https://stackoverflow.com/questions/3436453/calculate-coordinates-of-a-regular-polygons-vertices

export(float) var length_of_side = 60
export(float) var gap_size_percent = 0.3
export(bool) var outline = true
export(Color) var outline_color = Color(1,1,1,1)
export(float) var outline_width = 2

const number_of_sides = 6 # This will always be 6, for obvious reasons.
const interior_angle = ((number_of_sides - 2) * 180) / number_of_sides
const exterior_angle = PI * 2 / number_of_sides
var slant_height = length_of_side * sin(deg2rad(interior_angle - 90))
var slant_length = length_of_side * cos(deg2rad(interior_angle - 90))

var current_recursion_id = 0
const max_recursion_count = 100
const recursion_timeout = 2

var points = PoolVector2Array()
var points_collision = PoolVector2Array()

onready var hex_tile_src = load("res://Objects/HexTile.tscn")
onready var hex_button_src = load("res://Objects/HexButton.tscn")
onready var recursion_timer_src = load("res://Objects/RecursionTimer.tscn")

func track_recursion():
	current_recursion_id += 1
	if current_recursion_id > max_recursion_count:
		current_recursion_id = 0
	var recursion_timer_inst = recursion_timer_src.instance()
	recursion_timer_inst.wait_time = recursion_timeout
	recursion_timer_inst.recursion_id = current_recursion_id
	add_child(recursion_timer_inst)
	return current_recursion_id
	
func forget_recursion(recursion_id):
	for tile in get_tree().get_nodes_in_group("Node/Tile"):
		tile.visited_by.erase(recursion_id)

func _ready():
	#Generate the polygon for the hexagon.
	for point in range(0, number_of_sides):
		var x_pos = length_of_side * sin(point * exterior_angle)
		var y_pos = length_of_side * cos(point * exterior_angle)
		points.append(Vector2(x_pos, y_pos))
	print("Hexagon vector array generated.")
	
	#Generate collision hexagon (slightly bigger than base hexagon)
	for point in points:
		var point_collision = Vector2(point.x * 1.1, point.y * 1.1)
		points_collision.append(point_collision)
	
	#TODO: Calculate ranges based on screen resolution.
	#Something like max range = screen res divided by length of side.
	
	for y in range(0,10):
		for x in range(0,15):
			if y % 2 == 0:
				var hex_tile_inst = hex_tile_src.instance()
				var x_pos = x * slant_length * 2
				var y_pos = (y * slant_height) + (y * length_of_side)
				hex_tile_inst.position = Vector2(x_pos,y_pos)
				get_tree().get_root().get_node("Node/Test").add_child(hex_tile_inst)
			else: #Alternate lines have the hexagons bumped slightly to the left so they tile.
				var hex_tile_inst = hex_tile_src.instance()
				var x_pos = (x * slant_length * 2) + slant_length
				var y_pos = (y * slant_height) + (y * length_of_side)
				hex_tile_inst.position = Vector2(x_pos,y_pos)
				get_tree().get_root().get_node("Node/Test").add_child(hex_tile_inst)
				
	yield(get_tree().create_timer(0.05), "timeout")
				
	for assimilateable_tile in get_tree().get_nodes_in_group("Assimilate"):
		print("Assimilating tile from node manager.")
		assimilateable_tile.assimilate()