extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered",self,"area_entered")
	connect("area_exited",self,"area_exited")
	
func area_entered(object):
	if object.is_in_group("Tile"):
		object.deactivated = true
	
func area_exited(object):
	if object.is_in_group("Tile"):
		object.deactivated = false
