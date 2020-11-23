extends Area2D
class_name HexTile

var deactivated = false #Defines whether or not tile is in greyscale (black) mode.
var moused_over = false
var base_color = Color(0,0,0,1)
var visited_by = []

onready var shape = get_node("CollisionShape2D/Polygon2D")

func mouse_entered():
	moused_over = true
	
func mouse_exited():
	moused_over = false
	
func generate_new_color():
	randomize()
	$NewColorTimer.start(rand_range(3,20))
	if not moused_over:
		var color_rb = rand_range(120, 200) / 255
		var color_g = rand_range(20, 90) / 255
		base_color = Color(color_rb, color_g, color_rb, 1)
		
func darken():
	$CollisionShape2D/Polygon2D.color = Color(0,0,0,1)

func recursive_darken(recursion_id: int):
	if recursion_id in visited_by: return
	visited_by.append(recursion_id)
	darken()
	yield(get_tree().create_timer(0.05), "timeout")
	var tiles = get_overlapping_areas()
	for tile in tiles:
		if not tile.is_in_group("Tile"):
			tiles.erase(tile)
	if len(tiles) == 6:
		for tile in tiles:
			if not recursion_id in tile.visited_by and tile.is_in_group("Tile"):
				tile.recursive_darken(recursion_id)
	else:
		for tile in tiles:
			if not recursion_id in tile.visited_by and tile.is_in_group("Tile"):
				tile.darken()
	
func _ready():
	
	if len(TileManager.points) == 0:
		print("No points available. Cannot instance.")
		# This should never happen (?)
		return
	
	# Connect mouse input signals
	connect("mouse_entered",self,"mouse_entered")
	connect("mouse_exited",self,"mouse_exited")
	
	# Connect timer signals
	$NewColorTimer.connect("timeout",self,"generate_new_color")
	$RecurseTimer.connect("timeout",self,"recursive_darken_others")
	
	# Random pinkish colour:
	# Set R and B to the same value, high.
	# Set G to a low value.
	generate_new_color()
	
	# Get points from the tile manager
	$CollisionShape2D/Polygon2D.polygon = TileManager.points
	$CollisionShape2D.shape.points = TileManager.points_collision

func _process(delta):
	if deactivated:
		shape.color = lerp(shape.color, base_color - Color(0.66,0.66,0.66,0), 0.1)
	elif moused_over:
		shape.color = lerp(shape.color, base_color - Color(0.3,0.3,0.3,0), 0.1)
	else:
		shape.color = lerp(shape.color, base_color, 0.05)

func _draw():
	if TileManager.outline:
		var poly = shape.get_polygon()
		for i in range(0, poly.size()):
			draw_line(poly[i] , poly[i + 1 if i < 5 else 0], TileManager.outline_color, TileManager.outline_width)