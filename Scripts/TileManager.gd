extends Node

signal recursion_complete

# https://stackoverflow.com/questions/3436453/calculate-coordinates-of-a-regular-polygons-vertices

export(float) var length_of_side = 50
export(float) var gap_size_percent = 0.3
export(bool) var outline = true
export(Color) var outline_color = Color(1,1,1,1)
export(float) var outline_width = 2

const number_of_sides = 6 # This will always be 6, for obvious reasons.
const interior_angle = ((number_of_sides - 2) * 180) / number_of_sides
const exterior_angle = PI * 2 / number_of_sides
var slant_height = length_of_side * sin(deg2rad(interior_angle - 90))
var slant_length = length_of_side * cos(deg2rad(interior_angle - 90))

var points = PoolVector2Array()

onready var hex_tile_src = load("res://Objects/Tile.tscn")

func track_recurse():
	if $Timer.is_stopped():
		print("Tracking recurse")
		$Timer.start(1.7)

func reset_recurse_tracking():
	print("Resetting recurse tracking.")
	for tile in get_tree().get_nodes_in_group("Tile"):
		tile.visited = false

func _ready():
	
	# Connect timer signals
	$Timer.connect("timeout",self,"reset_recurse_tracking")
	
	#Generate the polygon for the hexagon.
	for point in range(0, number_of_sides):
		var x_pos = length_of_side * sin(point * exterior_angle)
		var y_pos = length_of_side * cos(point * exterior_angle)
		points.append(Vector2(x_pos, y_pos))
	print("Hexagon vector array generated.")
	
	#TODO: Calculate ranges based on screen resolution.
	#Something like max range = screen res divided by length of side.
	
	for y in range(0,10):
		for x in range(0,15):
			if y % 2 == 0:
				var hex_tile_inst = hex_tile_src.instance()
				var x_pos = x * slant_length * 2
				var y_pos = (y * slant_height) + (y * length_of_side)
				hex_tile_inst.position = Vector2(x_pos,y_pos)
				get_tree().get_root().get_child(0).add_child(hex_tile_inst)
			else: #Alternate lines have the hexagons bumped slightly to the left so they tile.
				var hex_tile_inst = hex_tile_src.instance()
				var x_pos = (x * slant_length * 2) + slant_length
				var y_pos = (y * slant_height) + (y * length_of_side)
				hex_tile_inst.position = Vector2(x_pos,y_pos)
				get_tree().get_root().get_child(0).add_child(hex_tile_inst)
	
#	hex_tile_inst = hex_tile_src.instance()
#	var y_diff = (length_of_side) + (slant_height)
#	var x_diff = (slant_length)
#	x_diff = x_diff + (x_diff * gap_size_percent)
#	y_diff = y_diff + (y_diff * gap_size_percent)
#	hex_tile_inst.position = Vector2(300 + x_diff, 300 - y_diff)
#	get_tree().get_root().get_child(0).add_child(hex_tile_inst)
#
#	hex_tile_inst = hex_tile_src.instance()
#	x_diff = (slant_length * 2)
#	x_diff = x_diff + (x_diff * gap_size_percent)
#	hex_tile_inst.position = Vector2(300 + x_diff, 300)
#	get_tree().get_root().get_child(0).add_child(hex_tile_inst)