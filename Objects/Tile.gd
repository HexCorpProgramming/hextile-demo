extends Area2D

var moused_over = false
var base_color = Color(0,0,0,1)
var visited = false

onready var TileManager = get_tree().get_root().get_node("Test")
onready var shape = get_node("CollisionShape2D/Polygon2D")

func mouse_entered():
	moused_over = true
	
func mouse_exited():
	moused_over = false
	
func generate_new_color():
	randomize()
	$Timer.start(rand_range(3,20))
	if not moused_over:
		var color_rb = rand_range(120, 200) / 255
		var color_g = rand_range(20, 90) / 255
		base_color = Color(color_rb, color_g, color_rb, 1)

func button_pressed():
	print("Beep! Here is my ID: ", get_instance_id())
	print("I'm overlapping ", len(get_overlapping_areas()), " tiles!")
	TileManager.track_recurse()
	for tile in get_overlapping_areas():
		tile.recursive_darken()
		
func darken():
	$CollisionShape2D/Polygon2D.color = Color(0,0,0,1)

func recursive_darken():
	if visited: return
	visited = true
	darken()
	yield(get_tree().create_timer(0.05), "timeout")
	var tiles = get_overlapping_areas()
	if len(tiles) == 6:
		for tile in tiles:
			if not tile.visited:
				tile.recursive_darken()
	else:
		for tile in tiles:
			if not tile.visited:
				tile.darken()
	
func _ready():
	
	# Connect mouse input signals
	connect("mouse_entered",self,"mouse_entered")
	connect("mouse_exited",self,"mouse_exited")
	
	# Connect timer signals
	$Timer.connect("timeout",self,"generate_new_color")
	$RecurseTimer.connect("timeout",self,"recursive_darken_others")
	
	# Connect button signals
	$Button.connect("pressed",self,"button_pressed")
	
	# Random pinkish colour:
	# Set R and B to the same value, high.
	# Set G to a low value.
	generate_new_color()
	
	# Get points from the tile manager
	$CollisionShape2D/Polygon2D.polygon = TileManager.points
	$CollisionShape2D.shape.points = TileManager.points

func _process(delta):
	if moused_over:
		shape.color = lerp(shape.color, base_color - Color(0.3,0.3,0.3,0), 0.1)
	else:
		shape.color = lerp(shape.color, base_color, 0.05)

func _draw():
	if TileManager.outline:
		var poly = shape.get_polygon()
		for i in range(0, poly.size()):
			draw_line(poly[i] , poly[i + 1 if i < 5 else 0], TileManager.outline_color, TileManager.outline_width)