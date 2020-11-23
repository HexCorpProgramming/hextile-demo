extends HexTile

# The HexButton is like the HexTile but with clickable functionality

#enum actions {change,buy,sell}
#enum target_buildings {conversion,pr,science}
#enum target_menus {recruitment,idk}

func button_pressed():
	var recursion_id = TileManager.track_recursion()
	for tile in get_overlapping_areas():
		tile.recursive_darken(recursion_id)
		
func assimilate():
	_ready()
	var target = get_overlapping_areas()
	print(get_overlapping_areas())
	if len(target) > 0:
		for entity in get_overlapping_areas():
			if entity.is_in_group("Tile"):
				position = entity.position
				entity.queue_free()
				break
	else:
		print("Godot fucked up the instancing order. Sowwy. UWU")

func _ready():
	# Connect additional button signals
	$Button.connect("pressed",self,"button_pressed")